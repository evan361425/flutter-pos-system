import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/scaffold/item_modal.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/printer.dart';

class PrinterSettingsModal extends StatefulWidget {
  const PrinterSettingsModal({super.key});

  @override
  State<PrinterSettingsModal> createState() => _PrinterSettingsModalState();
}

class _PrinterSettingsModalState extends State<PrinterSettingsModal> with ItemModal<PrinterSettingsModal> {
  late PrinterDensity density;

  @override
  String get title => '設定出單機格式';

  @override
  List<Widget> buildFormFields() {
    return [
      SwitchListTile(
        title: const Text('窄間距'),
        subtitle: const Text('單子跟單子之間的空白會變少，較省紙張，但是撕紙時要小心'),
        value: density == PrinterDensity.tight,
        onChanged: (value) => setState(() => density = value ? PrinterDensity.tight : PrinterDensity.normal),
      ),
      const SizedBox(height: kInternalLargeSpacing),
      const Center(child: HintText('其他更多設定，敬請期待')),
    ];
  }

  @override
  initState() {
    density = Printers.instance.density;
    super.initState();
  }

  @override
  Future<void> updateItem() async {
    Printers.instance.density = density;
    await Printers.instance.saveProperties();

    if (mounted && context.canPop()) {
      context.pop();
    }
  }
}
