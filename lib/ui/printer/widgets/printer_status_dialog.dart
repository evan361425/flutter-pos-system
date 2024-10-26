import 'package:flutter/material.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/models/printer.dart';

class PrinterStatusDialog extends StatelessWidget {
  final Printer printer;
  final BluetoothSignal? signal;
  final PrinterStatus? status;

  const PrinterStatusDialog({
    super.key,
    required this.printer,
    this.signal,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('出單機狀態'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('名稱'),
            leading: const Icon(Icons.text_fields),
            subtitle: Text(printer.name),
          ),
          ListTile(
            title: const Text('地址'),
            leading: const Icon(Icons.location_on),
            subtitle: Text(printer.address),
          ),
          if (signal != null)
            ListTile(
              title: const Text('訊號'),
              leading: signalIcons[signal],
              subtitle: Text(signal!.name),
            ),
          if (status != null)
            ListTile(
              title: const Text('狀態'),
              leading: statusIcons[status],
              subtitle: Text(status!.name),
            ),
        ],
      ),
      actions: [
        PopButton(title: MaterialLocalizations.of(context).cancelButtonLabel),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(printer.connected ? '中斷連線' : '建立連線'),
        ),
      ],
    );
  }
}

const signalIcons = {
  BluetoothSignal.weak: Icon(Icons.signal_cellular_alt_1_bar),
  BluetoothSignal.normal: Icon(Icons.signal_cellular_alt_2_bar),
  BluetoothSignal.good: Icon(Icons.signal_cellular_alt),
};

const statusIcons = {
  PrinterStatus.good: Icon(Icons.check_circle_outline, color: Colors.green),
  PrinterStatus.lowBattery: Icon(Icons.warning_amber_outlined, color: Colors.orange),
  PrinterStatus.paperNotFound: Icon(Icons.error_outline, color: Colors.red),
  PrinterStatus.printing: SizedBox.square(dimension: 16, child: CircularProgressIndicator.adaptive(strokeWidth: 2)),
  PrinterStatus.tooHot: Icon(Icons.warning_amber_outlined, color: Colors.orange),
  PrinterStatus.unknown: Icon(Icons.warning_amber_outlined, color: Colors.orange),
};
