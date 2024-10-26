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
  bool showNotFound = false;

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
      if (searched.isEmpty) {
        return [
          p(const Column(children: [
            Text('搜尋藍牙設備中...'),
            SizedBox(height: kInternalSpacing),
            LinearProgressIndicator(),
          ])),
        ];
      }

      return [
        Center(child: HintText('搜尋到 ${searched.length} 個裝置')),
        for (final device in searched) _buildDeviceTile(device),
        const SizedBox(height: kInternalSpacing),
        scanStream != null
            ? const CircularProgressIndicator()
            : TextButton(
                onPressed: scan,
                child: const Text('重新搜尋'),
              ),
      ];
    }

    return [
      if (widget.isNew)
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          TextButton(onPressed: scan, child: const Text('重新搜尋')),
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
          helperText: '位置：${printer!.address}',
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
        onChanged: (value) => setState(() => autoConnect = value!),
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
  Widget? buildFloatingActionButton() {
    if (!showNotFound) {
      return null;
    }

    return FloatingActionButton.extended(
      onPressed: () => showMoreInfoDialog(
        context,
        '找不到裝置？',
        const Text('可以嘗試以下操作：\n• 確認裝置是否開啟\n• 確認裝置是否在範圍內\n• 重新開啟藍牙'),
      ),
      label: const Text('找不到裝置？'),
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
    scanStream = Bluetooth.instance.startScan().listen((devices) {
      if (mounted) {
        setState(() {
          searched = devices;
        });
      }
    }, onError: (Object error, StackTrace trace) {
      showSnackbarWhenFutureError(
        Future.error(error),
        'printer_modal_scan',
        key: scaffoldMessengerKey,
      );
    }, onDone: scanDone, cancelOnError: true);

    notFoundFuture = Future.delayed(const Duration(seconds: 3), () {
      Log.out('not found delayed hit', 'printer_modal_scan');
      if (scanStream != null && mounted) {
        setState(() {
          showNotFound = true;
          notFoundFuture = null;
        });
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
      Log.ger('non recognition ${device.name}', 'printer_modal_select');
      showMoreInfoSnackBar(
        '不支援裝置 ${device.name}',
        const Text('目前尚未支援此裝置，你可以[聯絡我們](mailto:evanlu361425@gmail.com)以取得支援。'),
        key: scaffoldMessengerKey,
      );
      return;
    }

    nameController.text = device.name;
    printer = Printer(
      name: device.name,
      address: device.address,
      provider: provider,
    );

    scanDone();
    await Bluetooth.instance.stopScan();
  }

  @override
  Future<void> updateItem() async {
    if (printer == null) {
      showSnackBar('尚未選擇裝置', key: scaffoldMessengerKey);
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
