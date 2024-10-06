import 'package:flutter/material.dart';
import 'package:possystem/components/dialog/responsive_dialog.dart';
import 'package:possystem/components/imageable_container.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/printer.dart';
import 'package:possystem/services/bluetooth.dart';
import 'package:possystem/translator.dart';

class PrinterTestDialog extends StatefulWidget {
  final String? name;
  final String? address;
  final String? id;

  const PrinterTestDialog({
    super.key,
    this.id,
    this.name,
    this.address,
  }) : assert((address != null && name != null) || id != null);

  @override
  State<PrinterTestDialog> createState() => _PrinterTestDialogState();
}

class _PrinterTestDialogState extends State<PrinterTestDialog> {
  final controller = ImageableController(key: GlobalKey());
  late final BluetoothDevice device;
  bool isPrinting = false;
  final printStream = ValueNotifier<Stream<num>?>(null);
  int size = 0;

  @override
  Widget build(BuildContext context) {
    Widget content = ImageableContainer(controller: controller, children: const [
      Text('這是一張測試列印'),
    ]);

    if (isPrinting) {
      content = Stack(
        children: [
          content,
          ValueListenableBuilder(
            valueListenable: printStream,
            builder: (context, stream, _) {
              if (stream == null) {
                return const Center(child: Text('正在準備列印...'));
              }

              return StreamBuilder<num>(
                stream: stream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    handleError(snapshot.error!);
                    return const SizedBox.shrink();
                  }

                  final value = snapshot.data ?? 0;
                  if (value == size) {
                    handleDone('列印完成');
                  }

                  return Center(child: CircularProgressIndicator.adaptive(value: value / size));
                },
              );
            },
          ),
        ],
      );
    }

    return ResponsiveDialog(
      title: Text('測試列印'),
      action: TextButton(onPressed: isPrinting ? null : startPrint, child: const Text('列印')),
      content: content,
    );
  }

  @override
  void initState() {
    if (widget.id != null) {
      final printer = Printers.instance.getItem(widget.id!) ?? Printer();
      device = BluetoothDevice(address: printer.address, name: printer.name);
    } else {
      device = BluetoothDevice(address: widget.address!, name: widget.name!);
    }

    super.initState();
  }

  void startPrint() async {
    if (!isPrinting) {
      setState(() {
        isPrinting = true;
      });

      final data = await controller.toImage();
      if (data != null) {
        final image = data
            .toGrayScale()
            .toBitMap(
              width: controller.width,
              blackIsOne: true,
              invertBits: true,
            )
            .bytes;
        printStream.value = Bluetooth.instance.write(device, image);
      }
    }
  }

  void handleError(Object err) {
    Log.err(err, 'print_error');
    handleDone('${S.actError}: $err');
  }

  void handleDone(String msg) {
    if (mounted) {
      setState(() {
        isPrinting = false;
        printStream.value = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }
}
