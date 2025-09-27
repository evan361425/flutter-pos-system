import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/scaffold/item_modal.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/printer.dart';
import 'package:possystem/services/bluetooth.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/printer/widgets/printer_view.dart';

class PrinterModal extends StatefulWidget {
  final Printer? printer;

  final bool isNew;

  const PrinterModal({super.key, this.printer}) : isNew = printer == null;
  @override
  State<PrinterModal> createState() => _PrinterModalState();
}

class _PrinterModalState extends State<PrinterModal> with ItemModal<PrinterModal> {
  Printer? printer;

  // scan variable
  StreamSubscription<List<BluetoothDevice>>? scanStream;
  List<BluetoothDevice> searched = [];
  Future<void>? notFoundFuture;
  final notFoundFAB = ValueNotifier<bool>(false);

  // field variable
  bool autoConnect = false;
  final nameController = TextEditingController(text: '');
  final nameFocusNode = FocusNode();

  @override
  String get title => widget.isNew ? S.printerTitleCreate : S.printerTitleUpdate;

  @override
  List<Widget> buildFormFields() {
    // Scan result
    if (printer == null) {
      if (searched.isEmpty) {
        return [
          p(Column(children: [
            Text(S.printerScanIng),
            const SizedBox(height: kInternalSpacing),
            const LinearProgressIndicator(),
          ])),
        ];
      }

      return [
        Center(child: HintText(S.printerScanCount(searched.length))),
        for (final device in searched) _buildDeviceTile(device),
        const SizedBox(height: kInternalSpacing),
        scanStream != null
            ? const CircularProgressIndicator.adaptive()
            : TextButton(
                onPressed: scan,
                child: Text(S.printerScanRetry),
              ),
      ];
    }

    // Selected printer
    return [
      if (widget.isNew)
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          TextButton(onPressed: scan, child: Text(S.printerScanRetry)),
        ]),
      PrinterView(printer: printer!),
      // Add printer type change button
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: kHorizontalSpacing),
        child: Card(
          child: ListTile(
            leading: const Icon(Icons.print),
            title: Text(S.printerTypeSelectLabel),
            subtitle: Text(S.printerTypeSelectName(printer!.provider.name)),
            trailing: TextButton(
              onPressed: _changePrinterType,
              child: const Text('Change'),
            ),
          ),
        ),
      ),
      p(TextFormField(
        key: const Key('printer.name'),
        controller: nameController,
        focusNode: nameFocusNode,
        textInputAction: TextInputAction.next,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          labelText: S.printerNameLabel,
          hintText: widget.printer?.name ?? S.printerNameHint,
          helperText: S.printerNameHelper(printer!.address),
          filled: false,
        ),
        maxLength: 30,
        validator: Validator.textLimit(S.printerNameLabel, 30, focusNode: nameFocusNode),
      )),
      CheckboxListTile(
        controlAffinity: ListTileControlAffinity.leading,
        value: autoConnect,
        selected: autoConnect,
        onChanged: (value) => setState(() => autoConnect = value!),
        title: Text(S.printerAutoConnLabel),
        subtitle: Text(S.printerAutoConnHelper),
      ),
    ];
  }

  Widget _buildDeviceTile(BluetoothDevice device) {
    final exist = Printers.instance.hasAddress(device.address);
    return ListTile(
      title: Text(device.name == '' ? '<unknown>' : device.name),
      subtitle: MetaBlock.withString(context, [
        if (device.connected) S.printerMetaConnected,
        if (exist) S.printerMetaExist,
      ]),
      selected: !exist,
      enabled: !exist,
      onTap: () => selectDevice(device),
    );
  }

  @override
  Widget? buildFloatingActionButton() {
    return ListenableBuilder(
      listenable: notFoundFAB,
      builder: (context, child) {
        if (notFoundFAB.value) {
          return FloatingActionButton.extended(
            onPressed: () => showMoreInfoDialog(
              context,
              S.printerScanNotFound,
              Text(S.printerErrorTimeoutMore),
            ),
            label: Text(S.printerScanNotFound),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  @override
  void initState() {
    super.initState();

    printer = widget.printer;
    nameController.text = widget.printer?.name ?? '';
    autoConnect = widget.printer?.autoConnect ?? false;

    if (widget.isNew) {
      scan();
    }
  }

  @override
  void dispose() {
    scanStream?.cancel();
    notFoundFuture?.ignore();
    Bluetooth.instance.stopScan();
    super.dispose();
  }

  void scan() {
    scanStream = showSnackbarWhenStreamError(
      Bluetooth.instance.startScan(),
      'printer_modal_scan',
    ).listen((devices) {
      if (mounted) {
        // if there has any device scanned, demo device will be replaced.
        if (kDebugMode && devices.isEmpty) {
          devices.add(BluetoothDevice.demo());
        }

        setState(() {
          searched = devices;
        });
      }
    }, onDone: scanDone, cancelOnError: true);

    notFoundFuture = Future.delayed(btSearchWarningTime, () {
      Log.out('not found delayed hit', 'printer_modal_scan');
      if (scanStream != null && notFoundFuture != null && mounted) {
        notFoundFAB.value = true;
        notFoundFuture = null;
      }
    });

    setState(() {
      printer = null;
    });
  }

  void scanDone() {
    if (mounted) {
      Log.out('done', 'printer_modal_scan');
      scanStream?.cancel();
      notFoundFAB.value = false;
      setState(() {
        notFoundFuture?.ignore();
        notFoundFuture = null;
        scanStream = null;
      });
    }
  }

  Future<void> selectDevice(BluetoothDevice device) async {
    var provider = PrinterProvider.tryGuess(device.name);
    if (provider == null) {
      final selected = await _ManualTypeSelection.show(context, device);
      if (selected == null) {
        // user cancel
        return;
      }

      Log.out('manual select device: ${device.name} provider: ${selected.name}', 'printer_modal_select');
      provider = selected;
    } else {
      Log.out('auto select device: ${device.name} provider: ${provider.name}', 'printer_modal_select');
    }

    // advertise name is the default name
    nameController.text = device.name;
    printer = Printer(
      name: device.name,
      address: device.address,
      provider: provider,
    );

    scanDone();
    Bluetooth.instance.stopScan();
  }

  @override
  Future<void> updateItem() async {
    if (printer == null) {
      showSnackBar(S.printerErrorNotSelect, key: scaffoldMessengerKey);
      return;
    }

    final object = parseObject();

    if (widget.isNew) {
      final item = Printer(
        name: object.name!,
        address: printer!.address,
        autoConnect: object.autoConnect!,
        provider: printer!.provider,
        other: printer!.p,
      );

      await Printers.instance.addItem(item);
    } else {
      await widget.printer!.update(object);
    }

    if (mounted && context.canPop()) {
      context.pop();
    }
  }

  PrinterObject parseObject() {
    return PrinterObject(
      name: nameController.text,
      autoConnect: autoConnect,
    );
  }

  Future<void> _changePrinterType() async {
    if (printer == null) return;

    // Create a dummy device for the dialog (device parameter is not actually used in the widget)
    final dummyDevice = BluetoothDevice.demo();

    final selected = await _ManualTypeSelection.show(context, dummyDevice);
    if (selected == null) {
      // user cancelled
      return;
    }

    if (selected != printer!.provider) {
      // Update the printer with new provider
      Log.out('change printer type: ${printer!.name} from ${printer!.provider.name} to ${selected.name}', 'printer_modal_change_type');
      
      setState(() {
        printer = Printer(
          id: printer!.id,
          name: printer!.name,
          address: printer!.address,
          autoConnect: printer!.autoConnect,
          provider: selected,
          other: printer!.p,
        );
      });
    }
  }
}

class _ManualTypeSelection extends StatefulWidget {
  final BluetoothDevice device;

  const _ManualTypeSelection({super.key, required this.device});

  static Future<PrinterProvider?> show(BuildContext context, BluetoothDevice device) async {
    final key = GlobalKey<_ManualTypeSelectionState>();
    return showAdaptiveDialog<PrinterProvider>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(S.printerTypeSelectTitle),
        scrollable: true,
        content: Column(children: [
          HintText(S.printerTypeSelectHint),
          const SizedBox(height: kInternalSpacing),
          _ManualTypeSelection(key: key, device: device),
        ]),
        actions: [
          PopButton(title: MaterialLocalizations.of(context).cancelButtonLabel),
          TextButton(
            onPressed: () => Navigator.of(context).pop(key.currentState?.selected),
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
          ),
        ],
      ),
    );
  }

  @override
  State<_ManualTypeSelection> createState() => _ManualTypeSelectionState();
}

class _ManualTypeSelectionState extends State<_ManualTypeSelection> {
  PrinterProvider? selected;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      for (final provider in PrinterProvider.values)
        RadioListTile<PrinterProvider>(
          value: provider,
          groupValue: selected,
          onChanged: (PrinterProvider? value) {
            if (value != null) {
              setState(() {
                selected = value;
              });
            }
          },
          title: Text(S.printerTypeSelectName(provider.name)),
        ),
    ]);
  }
}
