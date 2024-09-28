import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  List<BluetoothDevice>? paired;
  List<BluetoothDevice> searched = [];

  // field variable
  bool autoConnect = false;
  // PrinterProvider? provider;
  final nameController = TextEditingController(text: '');
  final nameFocusNode = FocusNode();

  @override
  String get title => widget.isNew ? '新增出單機' : '編輯出單機';

  @override
  List<Widget> buildFormFields() {
    if (printer == null) {
      if (paired == null) {
        return [
          FutureBuilder(
            future: scan(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return p(const Column(children: [
                  Text('搜尋藍牙設備中...'),
                  SizedBox(height: kInternalSpacing),
                  LinearProgressIndicator(),
                ]));
              }

              final errMsg = snapshot.data;
              if (errMsg != null) {
                return Center(child: Text(errMsg));
              }

              return const SizedBox.shrink();
            },
          )
        ];
      }

      final targets = searched.isEmpty ? paired! : searched;
      return [
        Center(child: HintText('搜尋到 ${targets.length} 個裝置')),
        for (final device in targets) _buildDeviceTile(device),
        const SizedBox(height: kInternalSpacing),
        // TODO: add button for "not found"
        scanStream != null
            ? const CircularProgressIndicator()
            : TextButton(onPressed: scanBroadcast, child: const Text('搜尋更多')),
      ];
    }

    return [
      if (widget.isNew)
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Builder(builder: (context) {
            return TextButton(
              key: const Key('printer.scan'),
              onPressed: () => reScan(context),
              child: const Text('重新搜尋'),
            );
          }),
        ]),
      PrinterView(printer: printer!),
      p(TextFormField(
        key: const Key('printer.name'),
        controller: nameController,
        focusNode: nameFocusNode,
        textInputAction: TextInputAction.next,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          labelText: '出單機名稱',
          hintText: widget.printer?.name ?? '例如：黑色出單機',
          filled: false,
        ),
        maxLength: 30,
        validator: Validator.textLimit('出單機名稱', 30, focusNode: nameFocusNode),
      )),
      CheckboxListTile(
        key: const Key('printer.autoConnect'),
        controlAffinity: ListTileControlAffinity.leading,
        value: autoConnect,
        selected: autoConnect,
        onChanged: toggleAutoConnect,
        title: const Text('自動連線'),
        subtitle: const Text('當進入訂單頁時自動連線'),
      ),
    ];
  }

  Widget _buildDeviceTile(BluetoothDevice device) {
    final exist = Printers.instance.hasAddress(device.address);
    return ListTile(
      title: Text(device.name),
      subtitle: MetaBlock.withString(context, [
        if (device.connected) '已連線',
        if (exist) '已建立，無法新增',
      ]),
      textColor: exist ? Colors.grey : null,
      trailing: exist ? null : const Icon(Icons.add),
      onTap: exist ? null : () => selectDevice(device),
    );
  }

  @override
  void initState() {
    super.initState();

    printer = widget.printer;
    nameController.text = widget.printer?.name ?? '';
    autoConnect = widget.printer?.autoConnect ?? false;
  }

  @override
  void dispose() {
    scanStream?.cancel();
    Bluetooth.instance.stopScan();
    super.dispose();
  }

  Future<void> reScan(BuildContext context) async {
    setState(() {
      printer = null;
      paired = null;
    });

    await scan();
  }

  Future<String?> scan() async {
    // avoid scan twice since it is called by FutureBuilder which
    // will rebuild from any state/tree change
    if (paired == null) {
      paired = [];

      try {
        final devices = await Bluetooth.instance.pairedDevices();
        setState(() {
          paired = devices;
        });

        // if no paired devices, directly scan broadcast without UI
        if (devices.isEmpty) {
          scanBroadcast();
        }
      } catch (e) {
        Log.err(e, 'printer_modal_scan', e is Error ? e.stackTrace : null);
        paired = null;
        return e.toString();
      }
    }

    return null;
  }

  void scanBroadcast() {
    scanStream = Bluetooth.instance.startScan().listen((devices) {
      setState(() {
        searched = devices;
      });
    }, onError: (Object error, StackTrace trace) {
      if (mounted) {
        showSnackBar(context, '${S.actError}：$error');
      }
      Log.err(error, 'bt_scan', trace);
    }, onDone: () {
      scanStream = null;
    }, cancelOnError: true);
  }

  Future<void> selectDevice(BluetoothDevice device) async {
    final provider = PrinterProvider.tryGuess(device.name);
    if (provider == null) {
      if (mounted) {
        showSnackBar(context, '不支援此裝置（${device.name}）');
      }
      Log.ger('non recognition ${device.name}', 'bt_select');
      return;
    }

    nameController.text = device.name;
    await scanStream?.cancel();

    setState(() {
      scanStream = null;
      printer = Printer(
        name: device.name,
        address: device.address,
        provider: provider,
      );
    });

    await Bluetooth.instance.stopScan();
  }

  void toggleAutoConnect(value) {
    setState(() {
      autoConnect = value!;
    });
  }

  @override
  Future<void> updateItem() async {
    if (printer == null) {
      return;
    }

    final object = parseObject();

    if (widget.isNew) {
      final item = Printer(
        name: object.name!,
        address: object.address!,
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
      address: printer!.address,
    );
  }
}
