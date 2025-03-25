import 'package:flutter/material.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/models/xfile.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/exporter/csv_exporter.dart';
import 'package:possystem/ui/transit/formatter/field_formatter.dart';
import 'package:possystem/ui/transit/formatter/formatter.dart';
import 'package:possystem/ui/transit/previews/preview_page.dart';
import 'package:possystem/ui/transit/widgets.dart';

class ImportBasicHeader extends ImportBasicBaseHeader {
  final CSVExporter exporter;

  const ImportBasicHeader({
    super.key,
    required super.selected,
    required super.stateNotifier,
    required super.formatter,
    super.icon = const Icon(Icons.file_present_sharp),
    super.allowAll = false,
    this.exporter = const CSVExporter(),
  });

  @override
  String get label => S.transitImportBtnCsv;

  @override
  Future<PreviewFormatter?> onImport(BuildContext context) async {
    final input = await XFile.pick();
    if (input == null) {
      // ignore: use_build_context_synchronously
      showSnackBar(S.transitImportErrorCsvPickFile, context: context);
      return null;
    }

    final data = await exporter.import(input);
    return (FormattableModel able) => findFieldFormatter(able).format(data);
  }
}
