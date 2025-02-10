import 'package:flutter/material.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/translator.dart';
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

class _ImportBasicViewState extends State<ImportBasicView> with AutomaticKeepAliveClientMixin {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        const SizedBox(height: 16.0),
        Card(
          key: const Key('transit.pt_preview'),
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListTile(
            title: Text(S.transitImportPreviewTitle),
            trailing: const Icon(KIcons.preview),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            onTap: _import,
          ),
        ),
        const SizedBox(height: 16.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            key: const Key('transit.pt_text'),
            controller: controller,
            keyboardType: TextInputType.multiline,
            minLines: 3,
            maxLines: 6,
            decoration: InputDecoration(
              border: const OutlineInputBorder(
                borderSide: BorderSide(width: 5.0),
              ),
              hintText: S.transitPTImportHint,
              helperText: S.transitPTImportHelper,
              helperMaxLines: 2,
            ),
          ),
        ),
      ]),
    );
  }

  @override
  bool get wantKeepAlive => true;

  void _import() {
    widget.stateNotifier.exec(() => showSnackbarWhenFutureError(
          _startImport(),
          'pt_import_failed',
          context: context,
        ));
  }

  Future<void> _startImport() async {
    final lines = controller.text.trim().split('\n');
    final first = lines.isEmpty ? '' : lines.removeAt(0);
    final able = findPlainTextFormattable(first);

    if (able == null) {
      showSnackBar(S.transitPTImportErrorNotFound, context: context);
      return;
    }

    await PreviewPage.show(
      context,
      able: able,
      items: findPlainTextFormatter(able).format([lines]),
      commitAfter: true,
    );

    // ignore: use_build_context_synchronously
    showSnackBar(S.transitPTCopySuccess, context: context);
  }
}
