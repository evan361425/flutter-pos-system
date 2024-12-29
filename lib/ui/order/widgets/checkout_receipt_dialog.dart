import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:possystem/components/imageable_container.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/printer/widgets/printer_receipt_view.dart';

class CheckoutReceiptDialog extends StatefulWidget {
  final OrderObject order;

  final List<int> widths;

  const CheckoutReceiptDialog._({
    required this.order,
    required this.widths,
  });

  /// Show the dialog and return the image list.
  ///
  /// - [widths] is the width in pixels of the image.
  static Future<List<ConvertibleImage>?> show(BuildContext context, OrderObject order, List<int> widths) async {
    final data = await showAdaptiveDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (context) => CheckoutReceiptDialog._(order: order, widths: widths),
    );

    if (data is! List<ConvertibleImage>) {
      if (data != null) {
        // We need Log.err in this function, no matter context is mounted or not
        // ignore: use_build_context_synchronously
        await showSnackbarWhenFutureError(Future.error(data), 'order_print_receipt', context: context);
      }

      return null;
    }

    return data;
  }

  @override
  State<CheckoutReceiptDialog> createState() => _CheckoutReceiptDialogState();
}

class _CheckoutReceiptDialogState extends State<CheckoutReceiptDialog> {
  late final ImageableController controller;

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      contentPadding: const EdgeInsets.all(0),
      content: Stack(alignment: Alignment.center, children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 24.0,
            top: 16,
            right: 24.0,
            bottom: 24.0,
          ),
          child: PrinterReceiptView(
            controller: controller,
            order: widget.order,
          ),
        ),
        Positioned.fill(
          child: AbsorbPointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(89),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Center(child: CircularProgressIndicator.adaptive()),
            ),
          ),
        ),
      ]),
    );
  }

  @override
  void initState() {
    controller = ImageableManger.instance.create();

    SchedulerBinding.instance.addPostFrameCallback(_popWithImage);

    super.initState();
  }

  void _popWithImage([Duration? _]) async {
    try {
      final data = await controller.toImage(widths: widget.widths);
      if (mounted) {
        final result = data?.map((e) => e.toGrayScale().toBitMap()).toList();
        Navigator.of(context).pop(result ?? S.orderPrinterErrorCreateReceipt);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(e);
      }
    }
  }
}
