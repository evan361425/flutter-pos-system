import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/exporter/plain_text_exporter.dart';
import 'package:possystem/ui/transit/formatter/formatter.dart';
import 'package:possystem/ui/transit/widgets.dart';

class ExportBasicView extends StatefulWidget {
  final PlainTextExporter exporter;

  const ExportBasicView({
    super.key,
    this.exporter = const PlainTextExporter(),
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
        onTap: _copy,
        icon: Icon(Icons.copy_outlined, semanticLabel: S.transitPTCopyBtn),
      ),
      const SizedBox(height: 16.0),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ValueListenableBuilder(valueListenable: model, builder: _buildView),
        ),
      ),
      const SizedBox(height: 16.0),
    ]);
  }

  Widget _buildView(BuildContext context, Formattable able, Widget? child) {
    final rows = widget.exporter.formatter.getRows(able);

    return Column(children: [
      MetaBlock.withString(
        context,
        widget.exporter.formatter.getHeader(able),
      )!,
      const SizedBox(height: 16.0),
      ListView.separated(
        separatorBuilder: (context, index) => const SizedBox(height: 8.0),
        itemCount: rows.length,
        itemBuilder: (context, index) {
          if (index == 0) {
            // Title
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final item in rows[0]) Center(child: Text(item)),
              ],
            );
          }

          return Card(
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Theme.of(context).colorScheme.outline),
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 100),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final item in rows[index]) Text(item),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ]);
  }

  void _copy(Formattable able) {
    showSnackbarWhenFutureError(
      widget.exporter.export(able),
      'pt_export_failed',
      context: context,
    ).then((value) {
      if (mounted) {
        showSnackBar(S.transitPTCopySuccess, context: context);
      }
    });
  }
}
