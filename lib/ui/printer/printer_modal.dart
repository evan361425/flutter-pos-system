import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/linkify.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/scaffold/item_modal.dart';
import 'package:possystem/components/style/hint_text.dart';
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
  PrinterProvider? selectedProvider;
  BluetoothDevice? devicePendingTypeSelection;
  final nameController = TextEditingController(text: '');
  final nameFocusNode = FocusNode();

  @override
  String get title => widget.isNew ? S.printerTitleCreate : S.printerTitleUpdate;

  @override
  List<Widget> buildFormFields() {
    // Show printer type selection if we have a device pending type selection
    if (devicePendingTypeSelection != null) {
      return _buildTypeSelectionFields();
    }

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

    return [
      if (widget.isNew)
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          TextButton(onPressed: scan, child: Text(S.printerScanRetry)),
        ]),
      PrinterView(printer: printer!),
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

  List<Widget> _buildTypeSelectionFields() {
    return [
      p(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.printerTypeSelectTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: kInternalSpacing),
          Text(
            S.printerTypeSelectHelper,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: kInternalLargeSpacing),
          Text(
            'Device: ${devicePendingTypeSelection!.name}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: kInternalLargeSpacing),
        ],
      )),
      for (final provider in PrinterProvider.values)
        RadioListTile<PrinterProvider>(
          title: Text(_getProviderDisplayName(provider)),
          value: provider,
          groupValue: selectedProvider,
          onChanged: (value) => setState(() => selectedProvider = value),
        ),
      const SizedBox(height: kInternalLargeSpacing),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _cancelTypeSelection,
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          const SizedBox(width: kInternalSpacing),
          ElevatedButton(
            onPressed: selectedProvider != null ? _confirmTypeSelection : null,
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
          ),
        ],
      ),
    ];
  }

  String _getProviderDisplayName(PrinterProvider provider) {
    switch (provider) {
      case PrinterProvider.cat1:
        return S.printerTypeCat1;
      case PrinterProvider.cat2:
        return S.printerTypeCat2;
      case PrinterProvider.epsonPrinter:
        return S.printerTypeEpson;
      case PrinterProvider.xPrinter:
        return S.printerTypeXPrinter;
    }
  }

  Widget _buildDeviceTile(BluetoothDevice device) {
    final exist = Printers.instance.hasAddress(device.address);
    return ListTile(
      title: Text(device.name),
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
    devicePendingTypeSelection = null;
    selectedProvider = null;

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
      devicePendingTypeSelection = null;
      selectedProvider = null;
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
    final provider = PrinterProvider.tryGuess(device.name);
    if (provider == null) {
      // Instead of showing error, trigger manual type selection
      Log.ger('unknown_printer_trigger_selection', {'device': device.name});
      setState(() {
        devicePendingTypeSelection = device;
        selectedProvider = null;
      });
      return;
    }

    // Auto-detected printer type, proceed as before
    _createPrinterWithProvider(device, provider);
  }

  void _createPrinterWithProvider(BluetoothDevice device, PrinterProvider provider) {
    // advertise name is the default name
    Log.ger('select_printer', {'device': device.name, 'provider': provider.name});
    nameController.text = device.name;
    printer = Printer(
      name: device.name,
      address: device.address,
      provider: provider,
    );

    scanDone();
    Bluetooth.instance.stopScan();
  }

  void _cancelTypeSelection() {
    setState(() {
      devicePendingTypeSelection = null;
      selectedProvider = null;
    });
  }

  void _confirmTypeSelection() {
    if (devicePendingTypeSelection != null && selectedProvider != null) {
      _createPrinterWithProvider(devicePendingTypeSelection!, selectedProvider!);
      setState(() {
        devicePendingTypeSelection = null;
        selectedProvider = null;
      });
    }
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
}
