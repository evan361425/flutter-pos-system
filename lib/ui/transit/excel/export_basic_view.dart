import 'package:flutter/material.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/exporter/excel_exporter.dart';
import 'package:possystem/ui/transit/formatter/field_formatter.dart';
import 'package:possystem/ui/transit/formatter/formatter.dart';
import 'package:possystem/ui/transit/widgets.dart';

class ExportBasicView extends StatefulWidget {
  final ExcelExporter exporter;
  final ValueNotifier<String> stateNotifier;

  const ExportBasicView({
    super.key,
    this.exporter = const ExcelExporter(),
    required this.stateNotifier,
  });

  @override
  State<ExportBasicView> createState() => _ExportBasicViewState();
}

class _ExportBasicViewState extends State<ExportBasicView> {
  final ValueNotifier<FormattableModel> model = ValueNotifier(FormattableModel.menu);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ModelPicker(
          selected: model,
          onTap: _export,
          icon: Icon(Icons.share_outlined, semanticLabel: S.transitCSVShareBtn),
        ),
      ),
      const SizedBox(height: 16.0),
      Expanded(
        child: ValueListenableBuilder(valueListenable: model, builder: _buildView),
      ),
    ]);
  }

  Widget _buildView(BuildContext context, FormattableModel able, Widget? child) {
    final formatter = findFieldFormatter(able);
    final headers = formatter.getHeader();
    return ModelDataTable(
      headers: headers.map((e) => e.toString()).toList(),
      notes: headers.map((e) => e.note).toList(),
      source: ModelDataTableSource(formatter.getRows()),
    );
  }

  void _export(FormattableModel able) async {
    if (widget.stateNotifier.value != '_start') {
      try {
        widget.stateNotifier.value = '_start';

        final formatter = findFieldFormatter(able);
        final rows = formatter.getRows();
        final result = await showSnackbarWhenFutureError(
          widget.exporter.export([S.transitModelName(able.name)], [rows]),
          'excel_export_failed',
          context: context,
        );

        if (mounted && result == true) {
          showSnackBar(S.transitCSVShareSuccess, context: context);
        }
      } finally {
        widget.stateNotifier.value = '_finish';
      }
    }
  }
}
