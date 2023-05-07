import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/helpers/formatter/formatter.dart';
import 'package:possystem/helpers/exporter/plain_text_exporter.dart';
import 'package:possystem/translator.dart';

class ExporterScreen extends StatelessWidget {
  final PlainTextExporter exporter;

  const ExporterScreen({Key? key, required this.exporter}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      for (final able in Formattable.values)
        ExpansionTile(
          key: Key('expansion_tile.${able.name}'),
          title: Text(S.exporterPTRepoName(able.name)),
          subtitle: MetaBlock.withString(
            context,
            exporter.formatter.getHeader(able),
          ),
          expandedCrossAxisAlignment: CrossAxisAlignment.end,
          children: createRowsByAble(context, able),
        ),
    ]);
  }

  List<Widget> createRowsByAble(BuildContext context, Formattable able) {
    final rows = exporter.formatter.getRows(able);
    return [
      for (final row in rows)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final col in row)
                  SizedBox(
                    width: double.infinity,
                    child: Text(col),
                  ),
              ],
            ),
          ),
        ),
      if (rows.length > 1)
        FilledButton.icon(
          key: Key('export_btn.${able.name}'),
          onPressed: () {
            showSnackbarWhenFailed(
              exporter.export(able),
              context,
              'pt_export_failed',
            ).then((value) => showSnackBar(context, '複製成功'));
          },
          icon: const Icon(Icons.copy_outlined),
          label: const Text('複製文字'),
        )
    ];
  }
}
