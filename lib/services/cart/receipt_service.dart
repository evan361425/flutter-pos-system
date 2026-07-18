import 'package:flutter/material.dart';
import 'package:possystem/components/imageable_container.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/printer.dart';
import 'package:possystem/models/printer_config.dart';
import 'package:possystem/models/shift/shift.dart';
import 'package:possystem/models/shift/shift_report.dart';
import 'package:possystem/services/printer/printer_config_store.dart';
import 'package:possystem/services/printer/printer_manager_service.dart';
import 'package:possystem/services/printer/ticket_layout_generator.dart';
import 'package:possystem/services/staff/employee_manager_service.dart';

/// Legacy Bluetooth receipt payload (pixel strips for thermal printers).
typedef ReceiptData = List<ConvertibleImage>;

/// Service responsible for generating and printing receipts.
class ReceiptService {
  static final ReceiptService instance = ReceiptService._();

  ReceiptService._();

  /// Generate receipts for the given order.
  Future<ReceiptData?> generateReceipts({
    required BuildContext context,
    required OrderObject order,
  }) async {
    return await Printers.instance.generateReceipts(
      context: context,
      order: order,
    );
  }

  /// Print the given receipts.
  void printReceipts(ReceiptData receipts) {
    Printers.instance.printReceipts(receipts);
  }

  /// Dispatch LAN/USB receipts and preparation tickets based on saved printer
  /// roles and product catalog names.
  ///
  /// When [kitchenOnly] is true, cashier receipts are skipped (fire-to-kitchen
  /// / stash path). Default remains full dispatch for checkout compatibility.
  ///
  /// This method is deliberately fail-safe: every printer job catches and logs
  /// its own failure, and the outer method never rethrows to checkout.
  Future<void> dispatchOrder(
    OrderObject order, {
    bool kitchenOnly = false,
  }) async {
    try {
      final store = PrinterConfigStore.instance;
      if (store.initialized) {
        await store.reload();
      } else {
        await store.initialize();
      }

      final configs = store.items;
      if (configs.isEmpty) return;

      final generator = const TicketLayoutGenerator();
      final manager = PrinterManagerService.instance;
      final jobs = <Future<void>>[];

      if (!kitchenOnly) {
        final cashierPrinters = configs.where(
          (config) => config.role == PrinterRole.cashier,
        );
        for (final printer in cashierPrinters) {
          jobs.add(
            _runPrintJob(printer, () async {
              final bytes = await generator.generateCustomerReceipt(
                order,
                printer,
              );
              await manager.sendBytes(printer, bytes);
            }),
          );
        }
      }

      final kitchenPrinters = configs.where(
        (config) => config.role == PrinterRole.kitchen,
      );
      for (final printer in kitchenPrinters) {
        final categories = printer.assignedCategories.toSet();
        if (categories.isEmpty) continue;

        final items = order.products
            .where((item) => categories.contains(item.catalogName))
            .toList(growable: false);
        if (items.isEmpty) continue;

        jobs.add(
          _runPrintJob(printer, () async {
            final bytes = await generator.generatePreparationTicket(
              items,
              printer.name,
              printer,
            );
            await manager.sendBytes(printer, bytes);
          }),
        );
      }

      await Future.wait(jobs);
    } catch (e, st) {
      Log.err(e, 'smart_dispatch_failed', st);
    }
  }

  /// Prints a Z-report to every configured cashier printer (fail-safe).
  Future<void> printZReport(Shift shift, ShiftReport metrics) async {
    try {
      final store = PrinterConfigStore.instance;
      if (store.initialized) {
        await store.reload();
      } else {
        await store.initialize();
      }

      final cashierPrinters = store.items.where(
        (config) => config.role == PrinterRole.cashier,
      );
      if (cashierPrinters.isEmpty) {
        Log.ger('z_report_no_cashier_printer', {'shiftId': shift.id});
        return;
      }

      final employeeName =
          (await EmployeeManagerService.instance.getEmployee(
            shift.employeeId,
          ))?.name ??
          '';
      final generator = const TicketLayoutGenerator();
      final manager = PrinterManagerService.instance;
      final jobs = <Future<void>>[];

      for (final printer in cashierPrinters) {
        jobs.add(
          _runPrintJob(printer, () async {
            final bytes = await generator.generateZReport(
              shift,
              metrics,
              printer.paperSize,
              employeeName: employeeName,
            );
            await manager.sendBytes(printer, bytes);
          }),
        );
      }

      await Future.wait(jobs);
    } catch (e, st) {
      Log.err(e, 'z_report_print_failed', st);
    }
  }

  Future<void> _runPrintJob(
    PrinterConfig printer,
    Future<void> Function() job,
  ) async {
    try {
      await job();
      Log.ger('smart_dispatch_printed', {
        'printer': printer.name,
        'role': printer.role.name,
        'type': printer.type.name,
      });
    } catch (e, st) {
      Log.err(
        'Printer ${printer.name} (${printer.address}) failed: $e',
        'smart_dispatch_printer_failed',
        st,
      );
    }
  }
}
