import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart' as esc;
import 'package:intl/intl.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/printer_config.dart';
import 'package:possystem/models/shift/shift.dart';
import 'package:possystem/models/shift/shift_report.dart';

typedef Order = OrderObject;
typedef OrderItem = OrderProductObject;
typedef PaperConfig = PrinterConfig;

class TicketLayoutGenerator {
  const TicketLayoutGenerator();

  Future<List<int>> generateCustomerReceipt(
    Order order,
    PaperConfig config,
  ) async {
    final profile = await esc.CapabilityProfile.load();
    final generator = esc.Generator(_paperSize(config.paperSize), profile);
    final bytes = <int>[];

    bytes.addAll(generator.reset());
    bytes.addAll(
      generator.text(
        'POS SYSTEM',
        styles: const esc.PosStyles(
          align: esc.PosAlign.center,
          bold: true,
          height: esc.PosTextSize.size2,
          width: esc.PosTextSize.size2,
        ),
      ),
    );
    bytes.addAll(
      generator.text(
        'Customer Receipt',
        styles: const esc.PosStyles(align: esc.PosAlign.center),
      ),
    );
    bytes.addAll(
      generator.text(
        order.createDateTimeString,
        styles: const esc.PosStyles(align: esc.PosAlign.center),
      ),
    );
    if (order.periodSeq != null) {
      bytes.addAll(
        generator.text(
          'Order #${order.periodSeq}',
          styles: const esc.PosStyles(align: esc.PosAlign.center),
        ),
      );
    }
    bytes.addAll(generator.hr(len: config.paperSize.charsPerLine));

    bytes.addAll(
      generator.row([
        esc.PosColumn(text: 'Item', width: 6),
        esc.PosColumn(
          text: 'Qty',
          width: 2,
          styles: const esc.PosStyles(align: esc.PosAlign.center),
        ),
        esc.PosColumn(
          text: 'Price',
          width: 4,
          styles: const esc.PosStyles(align: esc.PosAlign.right),
        ),
      ]),
    );
    bytes.addAll(generator.hr(len: config.paperSize.charsPerLine));

    for (final item in order.products) {
      bytes.addAll(
        generator.row([
          esc.PosColumn(text: item.productName, width: 6),
          esc.PosColumn(
            text: 'x${item.count}',
            width: 2,
            styles: const esc.PosStyles(align: esc.PosAlign.center),
          ),
          esc.PosColumn(
            text: item.totalPrice.toCurrency(),
            width: 4,
            styles: const esc.PosStyles(align: esc.PosAlign.right),
          ),
        ]),
      );

      for (final modifier in _modifierLines(item)) {
        bytes.addAll(
          generator.text(
            '  $modifier',
            styles: const esc.PosStyles(fontType: esc.PosFontType.fontB),
            maxCharsPerLine: config.paperSize.charsPerLine,
          ),
        );
      }
    }

    bytes.addAll(generator.hr(len: config.paperSize.charsPerLine));
    bytes.addAll(_amountRow(generator, 'Subtotal', order.productsPrice));
    if (order.attributesPrice != 0) {
      bytes.addAll(_amountRow(generator, 'Adjustments', order.attributesPrice));
    }
    bytes.addAll(
      generator.row([
        esc.PosColumn(
          text: 'TOTAL',
          width: 7,
          styles: const esc.PosStyles(bold: true),
        ),
        esc.PosColumn(
          text: order.price.toCurrency(),
          width: 5,
          styles: const esc.PosStyles(align: esc.PosAlign.right, bold: true),
        ),
      ]),
    );
    bytes.addAll(_amountRow(generator, 'Paid', order.paid));
    bytes.addAll(_amountRow(generator, 'Change', order.change));

    if (order.note.trim().isNotEmpty) {
      bytes.addAll(generator.hr(len: config.paperSize.charsPerLine));
      bytes.addAll(generator.text('Note: ${order.note}'));
    }

    bytes.addAll(generator.feed(1));
    bytes.addAll(
      generator.text(
        'Thank you!',
        styles: const esc.PosStyles(align: esc.PosAlign.center),
      ),
    );
    bytes.addAll(generator.cut(mode: esc.PosCutMode.partial));
    return bytes;
  }

  Future<List<int>> generatePreparationTicket(
    List<OrderItem> items,
    String stationName,
    PaperConfig config,
  ) async {
    final profile = await esc.CapabilityProfile.load();
    final generator = esc.Generator(_paperSize(config.paperSize), profile);
    final bytes = <int>[];

    bytes.addAll(generator.reset());
    bytes.addAll(
      generator.text(
        stationName.toUpperCase(),
        styles: const esc.PosStyles(
          align: esc.PosAlign.center,
          bold: true,
          reverse: true,
          height: esc.PosTextSize.size2,
          width: esc.PosTextSize.size2,
        ),
      ),
    );
    bytes.addAll(
      generator.text(
        'PREPARATION TICKET',
        styles: const esc.PosStyles(align: esc.PosAlign.center, bold: true),
      ),
    );
    bytes.addAll(generator.hr(ch: '=', len: config.paperSize.charsPerLine));

    for (final item in items) {
      bytes.addAll(
        generator.text(
          '${item.count} x ${item.productName}',
          styles: const esc.PosStyles(
            bold: true,
            height: esc.PosTextSize.size2,
            width: esc.PosTextSize.size2,
          ),
          maxCharsPerLine: (config.paperSize.charsPerLine / 2).floor(),
        ),
      );

      final modifiers = _modifierLines(item);
      if (modifiers.isNotEmpty) {
        for (final modifier in modifiers) {
          bytes.addAll(
            generator.text(
              '>> $modifier',
              styles: const esc.PosStyles(bold: true, underline: true),
              maxCharsPerLine: config.paperSize.charsPerLine,
            ),
          );
        }
      }
      bytes.addAll(generator.hr(len: config.paperSize.charsPerLine));
    }

    bytes.addAll(generator.feed(1));
    bytes.addAll(generator.cut(mode: esc.PosCutMode.partial));
    return bytes;
  }

  /// ESC/POS Z-report (end-of-shift till reconciliation).
  Future<List<int>> generateZReport(
    Shift shift,
    ShiftReport metrics,
    PaperSize size, {
    String employeeName = '',
  }) async {
    final profile = await esc.CapabilityProfile.load();
    final generator = esc.Generator(_paperSize(size), profile);
    final bytes = <int>[];
    final fmt = DateFormat.yMd().add_Hm();
    final chars = size.charsPerLine;
    final variance = metrics.variance ?? 0;
    final varianceLabel = variance >= 0 ? 'Overage' : 'Shortage';

    bytes.addAll(generator.reset());
    bytes.addAll(
      generator.text(
        'Z-REPORT',
        styles: const esc.PosStyles(
          align: esc.PosAlign.center,
          bold: true,
          height: esc.PosTextSize.size2,
          width: esc.PosTextSize.size2,
        ),
      ),
    );
    bytes.addAll(
      generator.text(
        'Rapport de caisse',
        styles: const esc.PosStyles(align: esc.PosAlign.center),
      ),
    );
    bytes.addAll(generator.hr(ch: '=', len: chars));

    bytes.addAll(generator.text('Opened:  ${fmt.format(shift.startTime)}'));
    bytes.addAll(
      generator.text(
        'Closed:  ${shift.endTime == null ? '-' : fmt.format(shift.endTime!)}',
      ),
    );
    if (employeeName.isNotEmpty) {
      bytes.addAll(generator.text('Employee: $employeeName'));
    }
    bytes.addAll(generator.text('Orders:   ${metrics.orderCount}'));
    bytes.addAll(generator.hr(len: chars));

    bytes.addAll(_amountRow(generator, 'Starting Cash', metrics.startingCash));
    bytes.addAll(_amountRow(generator, 'Cash Sales', metrics.cashSales));
    bytes.addAll(_amountRow(generator, 'Card Sales', metrics.cardSales));
    if (metrics.voucherSales != 0) {
      bytes.addAll(
        _amountRow(generator, 'Voucher Sales', metrics.voucherSales),
      );
    }
    bytes.addAll(
      generator.row([
        esc.PosColumn(
          text: 'TOTAL SALES',
          width: 7,
          styles: const esc.PosStyles(bold: true),
        ),
        esc.PosColumn(
          text: metrics.totalSales.toCurrency(),
          width: 5,
          styles: const esc.PosStyles(align: esc.PosAlign.right, bold: true),
        ),
      ]),
    );
    bytes.addAll(generator.hr(len: chars));

    bytes.addAll(_amountRow(generator, 'Expected Cash', metrics.expectedCash));
    bytes.addAll(
      _amountRow(generator, 'Actual Cash', metrics.actualEndingCash ?? 0),
    );
    bytes.addAll(
      generator.row([
        esc.PosColumn(
          text: 'Ecart ($varianceLabel)',
          width: 7,
          styles: const esc.PosStyles(bold: true),
        ),
        esc.PosColumn(
          text: variance.toCurrency(),
          width: 5,
          styles: const esc.PosStyles(align: esc.PosAlign.right, bold: true),
        ),
      ]),
    );

    bytes.addAll(generator.feed(1));
    bytes.addAll(
      generator.text(
        '*** END OF SHIFT ***',
        styles: const esc.PosStyles(align: esc.PosAlign.center, bold: true),
      ),
    );
    bytes.addAll(generator.cut(mode: esc.PosCutMode.partial));
    return bytes;
  }

  List<int> _amountRow(esc.Generator generator, String label, num amount) {
    return generator.row([
      esc.PosColumn(text: label, width: 7),
      esc.PosColumn(
        text: amount.toCurrency(),
        width: 5,
        styles: const esc.PosStyles(align: esc.PosAlign.right),
      ),
    ]);
  }

  List<String> _modifierLines(OrderItem item) {
    final lines = item.ingredients
        .where((ingredient) => ingredient.quantityName != null)
        .map(
          (ingredient) =>
              '${ingredient.ingredientName}: '
              '${ingredient.quantityName}',
        )
        .toList(growable: true);
    final note = item.note.trim();
    if (note.isNotEmpty) {
      lines.add('NOTE: $note');
    }
    return lines;
  }

  esc.PaperSize _paperSize(PaperSize size) {
    return switch (size) {
      PaperSize.mm58 => esc.PaperSize.mm58,
      PaperSize.mm80 => esc.PaperSize.mm80,
    };
  }
}
