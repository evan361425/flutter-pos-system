import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/scaffold/item_modal.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/printer.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/services/bluetooth.dart';
import 'package:possystem/translator.dart';

class PrinterModal extends StatefulWidget {
  final Printer? printer;

  final bool isNew;

  const PrinterModal({super.key, this.printer}) : isNew = printer == null;
  @override
  State<PrinterModal> createState() => _PrinterModalState();
}

class _PrinterModalState extends State<PrinterModal> with ItemModal<PrinterModal> {
  // scan variable
  BluetoothDevice? selected;
  StreamSubscription<BluetoothDevice>? scanStream;
  final List<BluetoothDevice> searched = [];

  // field variable
  bool defaultReceiptPrinter = false;
  final nameController = TextEditingController(text: '');
  final nameFocusNode = FocusNode();

  @override
  String get title => widget.isNew ? '新增出單機' : '編輯出單機';

  @override
  List<Widget> buildFormFields() {
    if (widget.isNew && selected == null) {
      if (searched.isEmpty) {
        return const [
          Text('搜尋藍牙設備中'),
          LinearProgressIndicator(),
        ];
      }

      return [
        Center(child: HintText('搜尋出 ${searched.length} 個裝置')),
        for (final device in searched)
          ListTile(
            title: Text(device.name ?? '未命名裝置'),
            // TODO: should give us some useful info
            onTap: () => selectDevice(device),
          ),
        // still searching
        if (scanStream != null) const CircularProgressIndicator(),
      ];
    }

    return [
      Material(
        elevation: 1.0,
        borderRadius: const BorderRadius.all(Radius.circular(6.0)),
        child: Row(children: [
          IconButton(
            key: const Key('printer.test'),
            onPressed: () => context.pushNamed(Routes.printerTest, pathParameters: {'address': selected!.address}),
            icon: const Column(children: [
              Icon(Icons.print_outlined),
              SizedBox(height: 4),
              Text('測試列印'),
            ]),
          ),
          const SizedBox(height: 28, child: VerticalDivider()),
          IconButton(
            key: const Key('printer.scan'),
            onPressed: reScan,
            icon: const Column(children: [
              Icon(Icons.bluetooth_searching_outlined),
              SizedBox(height: 4),
              Text('重新搜尋'),
            ]),
          ),
        ]),
      ),
      const SizedBox(height: kInternalSpacing),
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
        value: defaultReceiptPrinter,
        onChanged: (value) {
          setState(() {
            defaultReceiptPrinter = value!;
          });
        },
        title: const Text('是否為預設出單機'),
      ),
    ];
  }

  @override
  void initState() {
    super.initState();

    if (widget.isNew) {
      scan();
    }

    nameController.text = widget.printer?.name ?? '';
  }

  void scan() {
    scanStream = Bluetooth.instance.scan().listen((device) {
      setState(() {
        searched.add(device);
      });
    }, onError: (Object error, StackTrace trace) {
      Log.err(error, 'bluetooth_scan', trace);
      if (mounted) {
        showSnackBar(context, '${S.actError}：$error');
      }
    }, onDone: () {
      scanStream = null;
    }, cancelOnError: true);
  }

  void reScan() {
    setState(() {
      searched.clear();
      selected = null;
    });
    scan();
  }

  Future<void> selectDevice(BluetoothDevice device) async {
    nameController.text = device.name ?? '出單機${Printers.instance.length + 1}';
    setState(() {
      selected = device;
    });

    await scanStream?.cancel();
    scanStream = null;
  }

  @override
  Future<void> updateItem() async {
    final object = parseObject();

    if (widget.isNew) {
      await Printers.instance.addItem(Printer(
        name: object.name!,
        defaultReceiptPrinter: object.defaultReceiptPrinter!,
      ));
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
      defaultReceiptPrinter: defaultReceiptPrinter,
    );
  }
}
