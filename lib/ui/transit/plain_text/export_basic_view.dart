import 'package:flutter/material.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/exporter/plain_text_exporter.dart';
import 'package:possystem/ui/transit/formatter/formatter.dart';
import 'package:possystem/ui/transit/formatter/plain_text_formatter.dart';
import 'package:possystem/ui/transit/widgets.dart';

class ExportBasicHeader extends BasicModelPicker {
  final PlainTextExporter exporter;

  const ExportBasicHeader({
    super.key,
    required super.selected,
    required super.stateNotifier,
    this.exporter = const PlainTextExporter(),
    super.icon = const Icon(Icons.copy_outlined),
    super.allowAll = false,
  });

  @override
  String get label => S.transitExportBasicBtnPlainText;

  @override
  Future<void> onExport(BuildContext context, FormattableModel? able) async {
    await exporter.export(able!);

    if (context.mounted) {
      showSnackBar(S.transitExportOrderSuccessPlainText, context: context);
    }
  }
}

class ExportBasicView extends ExportView {
  const ExportBasicView({
    super.key,
    required super.selected,
    required super.stateNotifier,
    required super.scrollable,
  });

  @override
  Widget buildModel(BuildContext context, FormattableModel able) {
    final formatter = findPlainTextFormatter(able);
    final rows = formatter.getRows();

    return ListView.separated(
      separatorBuilder: (context, index) => const SizedBox(height: 8.0),
      itemCount: rows.length,
      physics: NestedScrollPhysics(scrollable: scrollable),
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
    );
  }
}
