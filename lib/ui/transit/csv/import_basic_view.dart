import 'package:flutter/material.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/models/xfile.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/exporter/csv_exporter.dart';
import 'package:possystem/ui/transit/formatter/formatter.dart';
import 'package:possystem/ui/transit/previews/preview_page.dart';
import 'package:possystem/ui/transit/widgets.dart';

class ImportBasicView extends StatefulWidget {
  final CSVExporter exporter;

  const ImportBasicView({
    super.key,
    this.exporter = const CSVExporter(),
  });

  @override
  State<ImportBasicView> createState() => _ImportBasicViewState();
}

class _ImportBasicViewState extends State<ImportBasicView> with AutomaticKeepAliveClientMixin {
  final ValueNotifier<Formattable> model = ValueNotifier(Formattable.menu);
  final ValueNotifier<bool> isProcessing = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(children: [
      ModelPicker(
        selected: model,
        isProcessing: isProcessing,
        onTap: _import,
        icon: const Icon(Icons.file_upload, semanticLabel: '選擇檔案'),
      ),
    ]);
  }

  @override
  bool get wantKeepAlive => true;

  void _import(Formattable able) async {
    try {
      final success = await showSnackbarWhenFutureError(
        _startImport(able),
        'csv_import_failed',
        context: context,
      );

      if (mounted && success == true) {
        showSnackBar(S.actSuccess, context: context);
      }
    } finally {
      isProcessing.value = false;
    }
  }

  Future<bool?> _startImport(Formattable able) async {
    bool? result;

    final stream = await XFile.pick();
    if (stream != null) {
      final data = await CSVExporter.import(stream);
      final formatted = widget.exporter.formatter.format(able, data);

      if (mounted) {
        result = await PreviewPage.show(context, able, formatted);
        await Formatter.finishFormat(able, result);
      }
    }

    return result;
  }
}
