import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/models/printer.dart';
import 'package:possystem/ui/printer/widgets/printer_receipt_view.dart';

void main() {
  group('Printer Model', () {
    test('Confirm all width is support to image container width scaling', () {
      for (final printer in PrinterProvider.values) {
        const source = PrinterReceiptView.viewWidth;
        final target = printer.manufactory.widthBits;
        final ratio = target / source;
        expect(
          (source * ratio).ceil(),
          equals(target),
          reason:
              'Float error: $source * $ratio = ${source * ratio}, '
              'ceil would give ${(source * ratio).ceil()} instead of $target.',
        );
      }
    });
  });
}
