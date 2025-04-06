import 'package:flutter/material.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/snackbar.dart';
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
  String text = '';

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListTile(
        title: Text('點選以貼上文字'),
        onTap: _showTextField,
        trailing: const Icon(Icons.copy_rounded),
      ),
    );
  }

  void _showTextField() async {
    final controller = TextEditingController(text: text);
    final ok = await showAdaptiveDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.multiline,
            minLines: 3,
            maxLines: 5,
            decoration: InputDecoration(
              border: const OutlineInputBorder(
                borderSide: BorderSide(width: 5.0),
              ),
              hintText: S.transitImportBtnPlainTextHint,
              helperMaxLines: 2,
            ),
          ),
          actions: [
            PopButton(title: MaterialLocalizations.of(context).cancelButtonLabel),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
            ),
          ],
        );
      },
    );

    if (ok == true && mounted) {
      text = controller.text;
      _onLoad();
    }
  }

  void _onLoad() async {
    final lines = text.trim().split('\n');
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
