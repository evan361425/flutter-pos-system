import 'package:flutter/material.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/exporter/plain_text_exporter.dart';
import 'package:possystem/helpers/formatter/formatter.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/previews/preview_page.dart';

class ImportBasicView extends StatefulWidget {
  final PlainTextExporter exporter;

  const ImportBasicView({
    Key? key,
    this.exporter = const PlainTextExporter(),
  }) : super(key: key);

  @override
  State<ImportBasicView> createState() => _ImportBasicViewState();
}

class _ImportBasicViewState extends State<ImportBasicView>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        const SizedBox(height: 16.0),
        Card(
          key: const Key('import_btn'),
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListTile(
            title: const Text('預覽結果'),
            trailing: const Icon(KIcons.preview),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            onTap: importData,
          ),
        ),
        const SizedBox(height: 16.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
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
        ),
      ]),
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
    final allow = await PreviewPage.show(context, able, formatted);
    await Formatter.finishFormat(able, allow);

    if (mounted && allow == true) {
      showSnackBar(context, S.actSuccess);
    }
  }
}
