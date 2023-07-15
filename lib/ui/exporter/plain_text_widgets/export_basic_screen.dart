import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/card_info_text.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/helpers/formatter/formatter.dart';
import 'package:possystem/helpers/exporter/plain_text_exporter.dart';
import 'package:possystem/translator.dart';

class ExportBasicScreen extends StatefulWidget {
  final PlainTextExporter exporter;

  const ExportBasicScreen({
    Key? key,
    this.exporter = const PlainTextExporter(),
  }) : super(key: key);

  @override
  State<ExportBasicScreen> createState() => _ExportBasicScreenState();
}

class _ExportBasicScreenState extends State<ExportBasicScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      TabBar(
        controller: _tabController,
        isScrollable: true,
        tabs: [
          for (final able in Formattable.values)
            Tab(
              key: Key('tab.${able.name}'),
              text: S.exporterTypeName(able.name),
            )
        ],
      ),
      Expanded(
        child: TabBarView(
          controller: _tabController,
          children: <Widget>[
            for (final able in Formattable.values)
              _buildTabBarView(context, able),
          ],
        ),
      ),
    ]);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: Formattable.values.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildTabBarView(BuildContext context, Formattable able) {
    return Column(children: [
      ListTile(
        key: Key('export_btn.${able.name}'),
        title: const Text('複製文字'),
        subtitle: MetaBlock.withString(
          context,
          widget.exporter.formatter.getHeader(able),
        ),
        onTap: () => _copy(able),
        trailing: const Icon(
          Icons.copy_outlined,
          semanticLabel: '複製文字',
        ),
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildItemsView(
            able,
            widget.exporter.formatter.getRows(able),
          ),
        ),
      ),
    ]);
  }

  ListView _buildItemsView(Formattable able, List<List<String>> items) {
    return ListView.separated(
      separatorBuilder: (context, index) => const SizedBox(height: 8.0),
      itemCount: items.length,
      itemBuilder: (context, index) {
        if (index == 0) {
          // this should be the title
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final item in items[index]) Text(item),
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
                  for (final item in items[index]) Text(item),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _copy(Formattable able) {
    showSnackbarWhenFailed(
      widget.exporter.export(able),
      context,
      'pt_export_failed',
    ).then((value) => showSnackBar(context, '複製成功'));
  }
}
