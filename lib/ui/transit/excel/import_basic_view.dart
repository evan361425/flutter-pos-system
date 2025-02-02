import 'package:flutter/material.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/models/xfile.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/exporter/excel_exporter.dart';
import 'package:possystem/ui/transit/formatter/field_formatter.dart';
import 'package:possystem/ui/transit/formatter/formatter.dart';
import 'package:possystem/ui/transit/previews/preview_page.dart';
import 'package:possystem/ui/transit/widgets.dart';

class ImportBasicView extends StatefulWidget {
  final ExcelExporter exporter;
  final ValueNotifier<String> stateNotifier;

  const ImportBasicView({
    super.key,
    this.exporter = const ExcelExporter(),
    required this.stateNotifier,
  });

  @override
  State<ImportBasicView> createState() => _ImportBasicViewState();
}

class _ImportBasicViewState extends State<ImportBasicView> with AutomaticKeepAliveClientMixin {
  final ValueNotifier<FormattableModel> model = ValueNotifier(FormattableModel.menu);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(children: [
        ModelPicker(
          selected: model,
          onTap: _import,
          icon: const Icon(Icons.file_upload_sharp, semanticLabel: '選擇檔案'),
        ),
      ]),
    );
  }

  @override
  bool get wantKeepAlive => true;

  void _import(FormattableModel able) async {
    if (widget.stateNotifier.value != '_start') {
      try {
        widget.stateNotifier.value = '_start';
        final success = await showSnackbarWhenFutureError(
          _startImport(able),
          'excel_import_failed',
          context: context,
        );

        if (mounted && success == true) {
          showSnackBar(S.actSuccess, context: context);
        }
      } finally {
        widget.stateNotifier.value = '_finish';
      }
    }
  }

  Future<bool?> _startImport(FormattableModel able) async {
    final stream = await XFile.pick(extensions: const ['xlsx', 'xls']);
    if (stream == null) {
      if (mounted) {
        showSnackBar('檔案取得失敗', context: context);
      }

      return false;
    }

    final data = await widget.exporter.import(stream);
    bool? result;
    if (mounted) {
      result = await PreviewPage.show(
        context,
        able: able,
        items: findFieldFormatter(able).format(data),
        commitAfter: true,
      );
    }

    return result;
  }
}
