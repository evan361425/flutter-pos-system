import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/exporter/plain_text_exporter.dart';
import 'package:possystem/ui/transit/formatter/formatter.dart';
import 'package:possystem/ui/transit/formatter/plain_text_formatter.dart';
import 'package:possystem/ui/transit/widgets.dart';

class ExportBasicView extends StatelessWidget {
  final TransitStateNotifier stateNotifier;
  final PlainTextExporter exporter;

  const ExportBasicView({
    super.key,
    required this.stateNotifier,
    this.exporter = const PlainTextExporter(),
  });

  @override
  Widget build(BuildContext context) {
    return ExportView(
      icon: Icon(Icons.copy_outlined, semanticLabel: '複製'),
      stateNotifier: stateNotifier,
      allowAll: false,
      onExport: _export,
      buildModel: _buildModel,
    );
  }

  Widget _buildModel(BuildContext context, FormattableModel? able) {
    final formatter = findPlainTextFormatter(able!);
    final rows = formatter.getRows();

    return Column(children: [
      MetaBlock.withString(context, formatter.getHeader())!,
      const SizedBox(height: 16.0),
      Expanded(
        child: ListView.separated(
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
      ),
    ]);
  }

  Future<void> _export(BuildContext context, FormattableModel? able) async {
    await exporter.export(able!);

    if (context.mounted) {
      showSnackBar(S.transitPTCopySuccess, context: context);
    }
  }
}
