import 'package:flutter/material.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/exporter/csv_exporter.dart';
import 'package:possystem/ui/transit/formatter/formatter.dart';
import 'package:possystem/ui/transit/widgets.dart';

class ExportBasicView extends StatefulWidget {
  final CSVExporter exporter;

  const ExportBasicView({
    super.key,
    this.exporter = const CSVExporter(),
  });

  @override
  State<ExportBasicView> createState() => _ExportBasicViewState();
}

class _ExportBasicViewState extends State<ExportBasicView> {
  final ValueNotifier<Formattable> model = ValueNotifier(Formattable.menu);
  final ValueNotifier<bool> isProcessing = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ModelPicker(
        selected: model,
        isProcessing: isProcessing,
        onTap: _export,
        icon: Icon(Icons.share_sharp, semanticLabel: S.transitCSVShareBtn),
      ),
      const SizedBox(height: 16.0),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ValueListenableBuilder(valueListenable: model, builder: _buildView),
        ),
      ),
    ]);
  }

  Widget _buildView(BuildContext context, Formattable able, Widget? child) {
    final headers = widget.exporter.formatter.getHeader(able);
    return ModelDataTable(
      headers: headers.map((e) => e.toString()).toList(),
      notes: headers.map((e) => e.note).toList(),
      source: ModelDataTableSource(widget.exporter.formatter.getRows(able)),
    );
  }

  void _export(Formattable able) async {
    final result = await showSnackbarWhenFutureError(
      widget.exporter.export(able),
      'csv_export_failed',
      context: context,
    );

    if (mounted && result == true) {
      showSnackBar(S.transitCSVShareSuccess, context: context);
    }
  }
}
