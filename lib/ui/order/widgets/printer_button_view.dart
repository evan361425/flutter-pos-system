import 'dart:async';

import 'package:flutter/material.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/printer.dart';
import 'package:possystem/services/bluetooth.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/printer/widgets/printer_info_dialog.dart';

class PrinterButtonView extends StatefulWidget {
  const PrinterButtonView({super.key});

  @override
  State<PrinterButtonView> createState() => _PrinterButtonViewState();
}

class _PrinterButtonViewState extends State<PrinterButtonView> {
  late final Set<String> printers;
  final List<Printer> connected = [];
  final List<Printer> connecting = [];
  final Map<String, _Record<BluetoothSignal>> signalRecords = {};
  final Map<String, _Record<PrinterStatus>> statusRecords = {};

  @override
  Widget build(BuildContext context) {
    final unused = printers
        .difference(connected.map((e) => e.id).toSet())
        .difference(connecting.map((e) => e.id).toSet())
        .map((e) => Printers.instance.getItem(e))
        .where((e) => e != null)
        .toList();

    final menuChildren = <Widget>[
      if (printers.isEmpty) Center(child: Text(S.orderPrinterEmpty)),
      if (connected.isNotEmpty) Center(child: HintText(S.orderPrinterDividerConnected)),
      for (final printer in connected)
        MenuItemButton(
          leadingIcon: statusIcons[statusRecords[printer.id]!.value],
          trailingIcon: signalIcons[signalRecords[printer.id]!.value],
          onPressed: _showPrinterStatusDialog(printer),
          child: Text(printer.name),
        ),
      if (connecting.isNotEmpty) Center(child: HintText(S.orderPrinterDividerConnecting)),
      for (final printer in connecting)
        MenuItemButton(
          leadingIcon: const Icon(Icons.refresh),
          onPressed: null,
          child: Text(printer.name),
        ),
      if (unused.isNotEmpty) Center(child: HintText(S.orderPrinterDividerUnused)),
      for (final printer in unused)
        MenuItemButton(
          leadingIcon: const Icon(Icons.print_disabled_outlined),
          onPressed: _showPrinterStatusDialog(printer!),
          child: Text(printer.name),
        ),
    ];

    return MenuAnchor(
      menuChildren: menuChildren,
      builder: (context, controller, _) {
        late final Widget icon;
        if (connected.isNotEmpty) {
          final s = statusRecords.values.map((e) => e.value).reduce((prev, e) => e.priority > prev.priority ? e : prev);
          icon = s.priority < 1
              ? const Icon(Icons.print_outlined)
              : s == PrinterStatus.printing
                  ? statusIcons[s]!
                  : Tutorial(
                      id: 'order.printer_status',
                      title: S.orderTutorialPrinterBtnTitle,
                      message: S.orderTutorialPrinterBtnContent,
                      child: statusIcons[s]!,
                    );
        } else if (connecting.isEmpty) {
          icon = const Icon(Icons.print_disabled_outlined);
        } else {
          icon = const SizedBox.square(
            dimension: 16,
            child: CircularProgressIndicator.adaptive(strokeWidth: 2),
          );
        }

        return IconButton(
          icon: icon,
          onPressed: controller.toggle,
        );
      },
    );
  }

  @override
  void initState() {
    _addConnected(Printers.instance.items.where((e) => e.connected));
    connecting.addAll(Printers.instance.items.where((e) => e.autoConnect && !e.connected));
    printers = Printers.instance.items.map((e) => e.id).toSet();

    // after initialized, start watching printer status
    for (final printer in Printers.instance.items) {
      printer.addListener(_printerChanged);
    }

    _connectWantedPrinters();

    super.initState();
  }

  @override
  void dispose() {
    for (final printer in Printers.instance.items) {
      printer.removeListener(_printerChanged);
    }
    for (final e in signalRecords.values) {
      e.stream.cancel();
    }
    for (final e in statusRecords.values) {
      e.stream.cancel();
    }
    super.dispose();
  }

  void _connectWantedPrinters() async {
    if (connecting.isNotEmpty) {
      Log.ger('connect_order_printer', {'length': connecting.length});
      final names = connecting.map((e) => e.name).join(', ');
      await Future.wait([
        // [toList] create new list which avoid concurrent modification of the original list
        for (final printer in connecting.toList())
          showSnackbarWhenFutureError(
            printer.connect(),
            'order_printer_connect',
            context: context,
          ),
      ]);

      // if failed, remove all connecting printers
      if (connecting.where((e) => !e.connected).isNotEmpty) {
        if (mounted) {
          Log.ger('order_printer_failed', {'length': connecting.length});
          setState(connecting.clear);
        }
      } else {
        if (mounted) {
          showSnackBar(S.orderSnackbarPrinterConnected(names), context: context);
        }
      }
    }
  }

  void _printerChanged([void _]) {
    if (mounted) {
      setState(() {
        final wanted = <Printer>[];
        connecting.removeWhere((e) {
          if (e.connected) {
            wanted.add(e);
            return true;
          }

          return false;
        });
        connected.removeWhere((e) {
          if (!e.connected) {
            Log.out('printer ${e.name}(${e.address}) disconnected', 'connect_order_printer');
            showSnackBar(S.orderSnackbarPrinterDisconnected(e.name), context: context);
            signalRecords.remove(e.id)?.stream.cancel();
            statusRecords.remove(e.id)?.stream.cancel();
            return true;
          }

          return false;
        });
        _addConnected(wanted);
      });
    }
  }

  void _addConnected(Iterable<Printer> printers) {
    for (final printer in printers) {
      Log.out('connect_order_printer', 'printer ${printer.name}(${printer.address}) connected');
      connected.add(printer);

      signalRecords[printer.id] = _Record(BluetoothSignal.normal, _listenSignal(printer));
      statusRecords[printer.id] = _Record(PrinterStatus.unknown, _listenStatus(printer));
    }
  }

  StreamSubscription<BluetoothSignal> _listenSignal(Printer printer) {
    return showSnackbarWhenStreamError(
      printer.p.device!.createSignalStream(),
      'order_printer_signal',
      context: context,
    ).listen((value) {
      final record = signalRecords[printer.id];
      if (mounted && record != null && record.value != value) {
        setState(() {
          record.value = value;
        });
      }
    });
  }

  StreamSubscription<PrinterStatus> _listenStatus(Printer printer) {
    return showSnackbarWhenStreamError(
      printer.p.statusStream,
      'order_printer_status',
      context: context,
    ).listen((value) {
      final record = statusRecords[printer.id];
      if (mounted && record != null && record.value != value) {
        setState(() {
          record.value = value;
        });
      }
    });
  }

  VoidCallback _showPrinterStatusDialog(Printer printer) {
    return () async {
      final result = await showAdaptiveDialog(
        context: context,
        builder: (context) => PrinterInfoDialog(
          printer: printer,
          signal: signalRecords[printer.id]?.value,
          status: statusRecords[printer.id]?.value,
        ),
      );

      if (result == true && mounted) {
        if (printer.connected) {
          await printer.disconnect();
          return;
        }

        setState(() {
          connecting.add(printer);
        });
        _connectWantedPrinters();
      }
    };
  }
}

class _Record<T> {
  T value;
  final StreamSubscription<T> stream;

  _Record(this.value, this.stream);
}
