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
  final TransitStateNotifier stateNotifier;

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
          allWarning: S.transitGSSpreadsheetImportAllHint,
        ),
      ]),
    );
  }

  @override
  bool get wantKeepAlive => true;

  void _import(FormattableModel? able) {
    widget.stateNotifier.exec(
      () => showSnackbarWhenFutureError(
        _startImport(able),
        'excel_import_failed',
        context: context,
      ).then((success) {
        if (success == true) {
          // ignore: use_build_context_synchronously
          showSnackBar(S.actSuccess, context: context);
        }
      }),
    );
  }

  Future<bool?> _startImport(FormattableModel? able) async {
    final input = await XFile.pick(extensions: const ['xlsx', 'xls']);
    if (input == null) {
      // ignore: use_build_context_synchronously
      showSnackBar('檔案取得失敗', context: context);
      return false;
    }

    final excel = widget.exporter.decode(input);

    // import specific sheet
    if (able != null) {
      final data = widget.exporter.import(excel, able.l10nName);
      if (data == null) {
        // ignore: use_build_context_synchronously
        showSnackBar('Excel 檔中找不到資料表：${able.l10nName}', context: context);
        return false;
      }

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

    // import all
    var missedSheets = <String>[];
    await Future.wait(FormattableModel.values.map((e) {
      final data = widget.exporter.import(excel, e.l10nName);
      if (data == null) {
        missedSheets.add(e.l10nName);
        return Future.value();
      }

      findFieldFormatter(e).format(data);
      return e.finishPreview(true);
    }));

    if (missedSheets.isNotEmpty) {
      // ignore: use_build_context_synchronously
      showSnackBar('Excel 檔中找不到資料表：${missedSheets.join(', ')}', context: context);
    }

    return missedSheets.isEmpty;
  }
}
