import 'package:flutter/material.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/formatter/formatter.dart';
import 'package:possystem/ui/transit/formatter/plain_text_formatter.dart';
import 'package:possystem/ui/transit/previews/preview_page.dart';

class ImportBasicHeader extends StatefulWidget {
  final ValueNotifier<FormattableModel?> selected;
  final ValueNotifier<PreviewFormatter?> formatter;

  const ImportBasicHeader({
    super.key,
    required this.selected,
    required this.formatter,
  });

  @override
  State<ImportBasicHeader> createState() => _ImportBasicHeaderState();
}

class _ImportBasicHeaderState extends State<ImportBasicHeader> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final textField = TextField(
      key: const Key('transit.pt_text'),
      controller: controller,
      keyboardType: TextInputType.multiline,
      minLines: 1,
      maxLines: 1,
      readOnly: true,
      onTap: _showTextField,
      decoration: InputDecoration(
        border: const OutlineInputBorder(
          borderSide: BorderSide(width: 5.0),
        ),
        hintText: S.transitImportBtnPlainTextHint,
        helperText: S.transitImportBtnPlainTextHelper,
        helperMaxLines: 2,
      ),
    );

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: Padding(padding: const EdgeInsets.only(top: kInternalSpacing), child: textField)),
      IconButton.filled(
        onPressed: _onLoad,
        tooltip: S.transitImportBtnPlainTextAction,
        icon: const Icon(Icons.import_export_sharp),
      ),
    ]);
  }

  void _showTextField() async {
    final subController = TextEditingController(text: controller.text);
    final ok = await showAdaptiveDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: TextField(
            controller: subController,
            keyboardType: TextInputType.multiline,
            minLines: 3,
            decoration: InputDecoration(
              border: const OutlineInputBorder(
                borderSide: BorderSide(width: 5.0),
              ),
              hintText: S.transitImportBtnPlainTextHint,
              helperText: S.transitImportBtnPlainTextHelper,
              helperMaxLines: 2,
            ),
          ),
          actions: [
            const PopButton(),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
            ),
          ],
        );
      },
    );

    if (ok == true && mounted) {
      setState(() {
        controller.text = subController.text;
      });
    }
  }

  void _onLoad() async {
    final lines = controller.text.trim().split('\n');
    final first = lines.isEmpty ? '' : lines.removeAt(0);
    final able = findPlainTextFormattable(first);

    if (able == null) {
      showSnackBar(S.transitImportErrorPlainTextNotFound, context: context);
      widget.formatter.value = null;
      return;
    }

    widget.selected.value = able;
    widget.formatter.value = (FormattableModel _) => findPlainTextFormatter(able).format([lines]);
  }
}
