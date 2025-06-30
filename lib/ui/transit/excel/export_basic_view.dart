import 'package:flutter/material.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/exporter/excel_exporter.dart';
import 'package:possystem/ui/transit/formatter/field_formatter.dart';
import 'package:possystem/ui/transit/formatter/formatter.dart';
import 'package:possystem/ui/transit/widgets.dart';

class ExportBasicHeader extends BasicModelPicker {
  final ExcelExporter exporter;

  const ExportBasicHeader({
    super.key,
    required super.selected,
    required super.stateNotifier,
    this.exporter = const ExcelExporter(),
    super.icon = const Icon(Icons.share_outlined),
    super.allowAll = true,
  });

  @override
  String get label => S.transitExportBasicBtnExcel;

  @override
  Future<void> onExport(BuildContext context, FormattableModel? able) async {
    final names = able?.toL10nNames() ?? FormattableModel.allL10nNames;
    final data = getAllFormattedFieldData(able);
    final headers = getAllFormattedFieldHeaders(able);

    final ok = await exporter.export(
      names: names,
      data: data,
      headers: headers,
      fileName: '${S.transitExportBasicFileName}.xlsx',
    );
    if (ok && context.mounted) {
      showSnackBar(S.transitExportOrderSuccessExcel, context: context);
    }
  }
}

class ExportBasicView extends ExportView {
  const ExportBasicView({
    super.key,
    required super.selected,
    required super.stateNotifier,
  });

  @override
  ModelData getSourceAndHeaders(FormattableModel able) {
    final formatter = findFieldFormatter(able);
    final headers = formatter.getHeader();
    return ModelData(headers, formatter.getRows());
  }
}
