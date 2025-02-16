import 'package:flutter/material.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/formatter/formatter.dart';
import 'package:possystem/ui/transit/formatter/plain_text_formatter.dart';
import 'package:possystem/ui/transit/previews/preview_page.dart';
import 'package:possystem/ui/transit/widgets.dart';

class ImportBasicView extends StatefulWidget {
  final TransitStateNotifier stateNotifier;

  const ImportBasicView({
    super.key,
    required this.stateNotifier,
  });

  @override
  State<ImportBasicView> createState() => _ImportBasicViewState();
}

class _ImportBasicViewState extends State<ImportBasicView> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ImportView(
      header: TextField(
        key: const Key('transit.pt_text'),
        controller: controller,
        keyboardType: TextInputType.multiline,
        minLines: 1,
        maxLines: 2,
        decoration: InputDecoration(
          border: const OutlineInputBorder(
            borderSide: BorderSide(width: 5.0),
          ),
          hintText: S.transitPTImportHint,
          helperText: S.transitPTImportHelper,
          helperMaxLines: 2,
        ),
      ),
      icon: const Icon(KIcons.preview, semanticLabel: '預覽資料'),
      stateNotifier: widget.stateNotifier,
      onLoad: _load,
      onDone: _done,
    );
  }

  Future<PreviewFormatter?> _load(BuildContext context, ValueNotifier<FormattableModel?> model) async {
    final lines = controller.text.trim().split('\n');
    final first = lines.isEmpty ? '' : lines.removeAt(0);
    final able = findPlainTextFormattable(first);

    if (able == null) {
      showSnackBar(S.transitPTImportErrorNotFound, context: context);
      return null;
    }

    model.value = able;
    return (FormattableModel _) => findPlainTextFormatter(able).format([lines]);
  }

  void _done(BuildContext context) {
    showSnackBar(S.transitPTCopySuccess, context: context);
  }
}
