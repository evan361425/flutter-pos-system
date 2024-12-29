import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/imageable_container.dart';
import 'package:possystem/components/linkify.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/objects/order_attribute_object.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/printer.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/printer/widgets/printer_receipt_view.dart';

class PrinterView extends StatefulWidget {
  final Printer printer;

  final Widget? trailing;

  final VoidCallback? onTap;
  final VoidCallback? onLogPress;

  const PrinterView({
    super.key,
    required this.printer,
    this.trailing,
    this.onTap,
    this.onLogPress,
  });

  @override
  State<PrinterView> createState() => _PrinterViewState();
}

class _PrinterViewState extends State<PrinterView> {
  ValueNotifier<bool> waiting = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      _buildCard(),
      ListenableBuilder(
        listenable: waiting,
        builder: (context, child) {
          if (waiting.value) {
            return const _Backdrop(child: CircularProgressIndicator());
          }

          return const SizedBox.shrink();
        },
      ),
    ]);
  }

  Widget _buildCard() {
    return ListenableBuilder(
      listenable: widget.printer,
      builder: (context, child) {
        return widget.printer.connected ? _buildConnected() : _buildDisconnected();
      },
    );
  }

  Widget _buildConnected() {
    return Card(
      shadowColor: Colors.green,
      elevation: 4,
      margin: const EdgeInsets.fromLTRB(kHorizontalSpacing, 0, kHorizontalSpacing, kInternalSpacing),
      child: _wrapWithInkWell(Column(
        children: [
          ListTile(
            title: Text(widget.printer.name),
            leading: const Icon(Icons.bluetooth_connected),
            subtitle: Text(S.printerStatusSuccess),
            trailing: widget.trailing,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            OutlinedButton.icon(
              onPressed: startPrint,
              label: Text(S.printerBtnTestPrint),
              icon: const Icon(Icons.print),
            ),
            const SizedBox(width: 8.0),
            MenuAnchor(
              menuChildren: [
                MenuItemButton(
                  onPressed: reconnect,
                  leadingIcon: const Icon(Icons.refresh),
                  child: Text(S.printerBtnRetry),
                ),
                MenuItemButton(
                  onPressed: disconnect,
                  leadingIcon: const Icon(Icons.bluetooth_disabled),
                  child: Text(S.printerBtnDisconnect),
                ),
              ],
              builder: (context, controller, _) {
                return FilledButton.icon(
                  onPressed: controller.toggle,
                  label: Text(S.printerStatusConnecting),
                  icon: const Icon(Icons.arrow_drop_down),
                  iconAlignment: IconAlignment.end,
                );
              },
            ),
            const SizedBox(width: 8.0),
          ]),
          const SizedBox(height: 4),
        ],
      )),
    );
  }

  Widget _buildDisconnected() {
    return Card(
      shadowColor: Colors.amber,
      elevation: 4,
      margin: const EdgeInsets.fromLTRB(kHorizontalSpacing, 0, kHorizontalSpacing, kInternalSpacing),
      child: _wrapWithInkWell(Column(
        children: [
          ListTile(
            title: Text(widget.printer.name),
            leading: const Icon(Icons.bluetooth_disabled),
            subtitle: HintText(S.printerStatusStandby),
            trailing: widget.trailing,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            FilledButton(
              onPressed: connect,
              child: Text(S.printerBtnConnect),
            ),
            const SizedBox(width: 8.0),
          ]),
          const SizedBox(height: 4.0),
        ],
      )),
    );
  }

  Widget _wrapWithInkWell(Widget child) {
    if (widget.onTap == null) {
      return child;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: widget.onTap,
      onLongPress: widget.onLogPress,
      child: child,
    );
  }

  void connect() async {
    if (!waiting.value) {
      waiting.value = true;

      final success = await showSnackbarWhenFutureError(
        widget.printer.connect(),
        'printer_view_connect',
        context: context,
      );
      onConnected(success);

      waiting.value = false;
    }
  }

  void disconnect() async {
    if (!waiting.value) {
      waiting.value = true;

      await showSnackbarWhenFutureError(
        widget.printer.disconnect(),
        'printer_view_disconnect',
        context: context,
      );

      waiting.value = false;
    }
  }

  void reconnect() async {
    if (!waiting.value) {
      waiting.value = true;

      await showSnackbarWhenFutureError(() async {
        await widget.printer.disconnect();
        final success = await widget.printer.connect();
        onConnected(success);
      }(), 'printer_view_reconnect', context: context);

      waiting.value = false;
    }
  }

  /// if success == null, it means the error has been thrown and caught
  void onConnected(bool? success) {
    if (success == false && mounted) {
      showMoreInfoSnackBar(
        S.printerErrorNotSupportTitle,
        Linkify.fromString(S.printerErrorNotSupportContent),
        context: context,
      );
    }
  }

  void startPrint() async {
    final progress = ValueNotifier<double?>(null);
    final controller = ImageableManger.instance.create();
    final done = await showAdaptiveDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(S.printerBtnTestPrint),
        contentPadding: const EdgeInsets.all(0),
        actions: [
          PopButton(title: MaterialLocalizations.of(context).cancelButtonLabel),
          _PrintButton(
            progress: progress,
            controller: controller,
            printer: widget.printer,
          ),
        ],
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
              order: OrderObject(
                createdAt: DateTime.now(),
                price: 300,
                paid: 500,
                attributes: [
                  OrderSelectedAttributeObject(
                    optionName: S.orderAttributeExamplePlaceDineIn,
                    mode: OrderAttributeMode.changeDiscount,
                    modeValue: 10,
                  ),
                ],
                products: [
                  OrderProductObject(
                    productName: S.menuExampleProductCheeseBurger,
                    count: 2,
                    singlePrice: 60,
                    originalPrice: 120,
                    isDiscount: true,
                  ),
                  OrderProductObject(
                    productName: S.menuExampleProductHamBurger,
                    count: 1,
                    singlePrice: 180,
                    originalPrice: 180,
                  ),
                ],
              ),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: progress,
            builder: (context, value, _) {
              return value == null
                  ? const SizedBox.shrink()
                  : _Backdrop(child: CircularProgressIndicator.adaptive(value: value));
            },
          ),
        ]),
      ),
    );

    if (done == true && mounted) {
      showSnackBar(S.printerStatusPrinted, context: context);
    }
  }
}

class _Backdrop extends StatelessWidget {
  final Widget child;

  const _Backdrop({required this.child});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AbsorbPointer(
        child: DecoratedBox(
          decoration: BoxDecoration(color: Colors.black.withAlpha(89)),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _PrintButton extends StatelessWidget {
  final ValueNotifier<double?> progress;
  final ImageableController controller;
  final Printer printer;

  const _PrintButton({
    required this.progress,
    required this.controller,
    required this.printer,
  });

  @override
  Widget build(BuildContext context) {
    void handleDone() {
      if (progress.value != null) {
        reset();
        if (context.mounted && context.canPop()) {
          context.pop(true);
        }
      }
    }

    void handlePress() async {
      // disable the button
      progress.value = 0;

      final future = controller.toImage(widths: [printer.provider.manufactory.widthBits]);
      final data = await future;
      if (data != null && context.mounted) {
        final image = data.first.toGrayScale().toBitMap().bytes;
        showSnackbarWhenStreamError(
          printer.draw(image),
          'printer_test',
          context: context,
          callback: reset,
        ).listen((value) => progress.value = value, onDone: handleDone);
      }
    }

    return ValueListenableBuilder(
      valueListenable: progress,
      builder: (context, value, _) {
        return TextButton(
          onPressed: value == null ? handlePress : null,
          child: Text(S.printerBtnPrint),
        );
      },
    );
  }

  void reset() {
    progress.value = null;
  }
}
