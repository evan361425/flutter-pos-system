import 'package:flutter/material.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/helpers/exporter/plain_text_exporter.dart';
import 'package:possystem/helpers/formatter/formatter.dart';
import 'package:possystem/ui/exporter/previews/previewer_screen.dart';

class ImportBasicScreen extends StatefulWidget {
  final PlainTextExporter exporter;

  const ImportBasicScreen({
    Key? key,
    this.exporter = const PlainTextExporter(),
  }) : super(key: key);

  @override
  State<ImportBasicScreen> createState() => _ImportBasicScreenState();
}

class _ImportBasicScreenState extends State<ImportBasicScreen>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          TextField(
            key: const Key('import_text'),
            controller: controller,
            keyboardType: TextInputType.multiline,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(width: 5.0),
              ),
              hintText: '請貼上複製而來的文字',
              helperText: '貼上文字後，會分析文字並決定匯入的是什麼種類的資訊。',
              helperMaxLines: 2,
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            key: const Key('import_btn'),
            onPressed: importData,
            label: const Text('預覽結果'),
            icon: const Icon(Icons.remove_red_eye_sharp),
          ),
        ]),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  void importData() async {
    final lines = controller.text.trim().split('\n');
    final first = lines.isEmpty ? '' : lines.removeAt(0);
    final able = widget.exporter.formatter.whichFormattable(first);

    if (able == null) {
      showSnackBar(context, '這段文字無法匹配相應的服務，請參考匯出時的文字內容');
      return;
    }

    final formatted = widget.exporter.formatter.format(able, [lines]);
    final allow = await PreviewerScreen.navByAble(context, able, formatted);
    await Formatter.finishFormat(able, allow);
  }
}
