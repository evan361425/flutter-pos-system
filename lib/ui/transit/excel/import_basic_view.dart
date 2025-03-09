import 'package:flutter/material.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/models/xfile.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/exporter/excel_exporter.dart';
import 'package:possystem/ui/transit/formatter/field_formatter.dart';
import 'package:possystem/ui/transit/formatter/formatter.dart';
import 'package:possystem/ui/transit/previews/preview_page.dart';
import 'package:possystem/ui/transit/widgets.dart';

class ImportBasicView extends StatelessWidget {
  final ExcelExporter exporter;
  final TransitStateNotifier stateNotifier;

  const ImportBasicView({
    super.key,
    this.exporter = const ExcelExporter(),
    required this.stateNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return ImportView(
      icon: const Icon(Icons.file_present_sharp),
      label: S.transitImportBtnExcel,
      stateNotifier: stateNotifier,
      onLoad: _load,
      allowAll: true,
    );
  }

  Future<PreviewFormatter?> _load(BuildContext context, ValueNotifier<FormattableModel?> _) async {
    final input = await XFile.pick(extensions: const ['xlsx', 'xls']);
    if (input == null) {
      // ignore: use_build_context_synchronously
      showSnackBar(S.transitImportErrorExcelPickFile, context: context);
      return null;
    }

    final excel = exporter.decode(input);
    return (FormattableModel able) {
      final data = exporter.import(excel, able.l10nName);

      if (data == null) {
        return null;
      }

      return findFieldFormatter(able).format(data);
    };
  }
}
