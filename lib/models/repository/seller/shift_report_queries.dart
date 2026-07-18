import 'dart:convert';

import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/repository/seller/metric_enums.dart';
import 'package:possystem/models/shift/shift_report.dart';
import 'package:possystem/services/database.dart';
import 'package:possystem/services/shift/shift_manager_service.dart';

/// Shift / Z-report analytics (extracted to keep [SellerAnalyticsQueries] < 400).
///
/// Prefers SQLite JSON1 (`json_each` / `json_extract`) so payment arrays in
/// `order_records.payments` are aggregated in SQL — never N+1. Falls back to
/// a single-row fetch + Dart fold if JSON1 is unavailable on the device.
class ShiftReportQueries {
  static final ShiftReportQueries instance = ShiftReportQueries._();

  ShiftReportQueries._();

  /// Builds a [ShiftReport] for [shiftId] with sales by payment method.
  Future<ShiftReport> getShiftReport(String shiftId) async {
    final shift = await ShiftManagerService.instance.getShift(shiftId);
    if (shift == null) {
      throw StateError('Shift not found: $shiftId');
    }

    try {
      return await _queryWithJson1(shiftId, shift.startingCash, shift.actualEndingCash);
    } catch (e, stack) {
      Log.err(e, 'shift_report_json1_fallback', stack);
      return _queryWithDartAggregate(
        shiftId,
        shift.startingCash,
        shift.actualEndingCash,
      );
    }
  }

  /// Two parameterized queries in one transaction:
  /// 1. Order totals — never joined to JSON rows (avoids multiplying revenue).
  /// 2. Payment breakdown via `json_each` + `GROUP BY method`.
  Future<ShiftReport> _queryWithJson1(
    String shiftId,
    num startingCash,
    num? actualEndingCash,
  ) async {
    final orderTable = SellerTables.order;

    return Database.instance.transaction((txn) async {
      final totals = await txn.rawQuery(
        'SELECT COUNT(*) AS order_count, '
        'COALESCE(SUM(price), 0) AS total_sales '
        'FROM `$orderTable` WHERE shift_id = ?',
        [shiftId],
      );

      final byMethod = await txn.rawQuery(
        '''
        SELECT
          json_extract(p.value, '\$.method') AS method,
          COALESCE(SUM(CAST(json_extract(p.value, '\$.amount') AS REAL)), 0)
            AS total
        FROM `$orderTable` AS o,
        json_each(
          CASE
            WHEN o.payments IS NOT NULL AND length(o.payments) > 2
              THEN o.payments
            ELSE json_array(json_object('amount', o.paid, 'method', 'cash'))
          END
        ) AS p
        WHERE o.shift_id = ?
        GROUP BY json_extract(p.value, '\$.method')
        ''',
        [shiftId],
      );

      final totalRow = totals.isEmpty ? const <String, Object?>{} : totals.first;
      final methods = _sumMethods(byMethod);

      return ShiftReport(
        shiftId: shiftId,
        startingCash: startingCash,
        actualEndingCash: actualEndingCash,
        orderCount: totalRow['order_count'] as int? ?? 0,
        totalSales: totalRow['total_sales'] as num? ?? 0,
        cashSales: methods.cash,
        cardSales: methods.card,
        voucherSales: methods.voucher,
      );
    });
  }

  /// Single SELECT of payment columns, fold in Dart (still one round-trip).
  Future<ShiftReport> _queryWithDartAggregate(
    String shiftId,
    num startingCash,
    num? actualEndingCash,
  ) async {
    final rows = await Database.instance.query(
      SellerTables.order,
      columns: ['price', 'paid', 'payments'],
      where: 'shift_id = ?',
      whereArgs: [shiftId],
    );

    num totalSales = 0;
    num cash = 0;
    num card = 0;
    num voucher = 0;

    for (final row in rows) {
      totalSales += row['price'] as num? ?? 0;
      final parsed = _parsePaymentAmounts(row);
      cash += parsed.cash;
      card += parsed.card;
      voucher += parsed.voucher;
    }

    return ShiftReport(
      shiftId: shiftId,
      startingCash: startingCash,
      actualEndingCash: actualEndingCash,
      orderCount: rows.length,
      totalSales: totalSales,
      cashSales: cash,
      cardSales: card,
      voucherSales: voucher,
    );
  }

  ({num cash, num card, num voucher}) _sumMethods(
    List<Map<String, Object?>> byMethod,
  ) {
    num cash = 0;
    num card = 0;
    num voucher = 0;
    for (final row in byMethod) {
      final method = row['method'] as String? ?? 'cash';
      final amount = row['total'] as num? ?? 0;
      switch (method) {
        case 'card':
          card += amount;
        case 'voucher':
          voucher += amount;
        default:
          cash += amount;
      }
    }
    return (cash: cash, card: card, voucher: voucher);
  }

  ({num cash, num card, num voucher}) _parsePaymentAmounts(
    Map<String, Object?> row,
  ) {
    final raw = row['payments'];
    if (raw is String && raw.length > 2) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          num cash = 0;
          num card = 0;
          num voucher = 0;
          for (final item in decoded) {
            if (item is! Map) continue;
            final map = Map<String, dynamic>.from(item);
            final amount = map['amount'] as num? ?? 0;
            switch (map['method'] as String? ?? 'cash') {
              case 'card':
                card += amount;
              case 'voucher':
                voucher += amount;
              default:
                cash += amount;
            }
          }
          return (cash: cash, card: card, voucher: voucher);
        }
      } catch (_) {
        // Fall through to legacy paid.
      }
    }
    return (cash: row['paid'] as num? ?? 0, card: 0, voucher: 0);
  }
}
