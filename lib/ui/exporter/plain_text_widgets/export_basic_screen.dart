import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
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
            Tab(text: S.exporterPTRepoName(able.name))
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
        key: Key('expansion_tile.${able.name}'),
        title: Text(S.exporterPTRepoName(able.name)),
        subtitle: MetaBlock.withString(
          context,
          widget.exporter.formatter.getHeader(able),
        ),
        trailing: ElevatedButton.icon(
          key: Key('export_btn.${able.name}'),
          onPressed: () {
            showSnackbarWhenFailed(
              widget.exporter.export(able),
              context,
              'pt_export_failed',
            ).then((value) => showSnackBar(context, '複製成功'));
          },
          icon: const Icon(Icons.copy_outlined),
          label: const Text('複製文字'),
        ),
      ),
      Expanded(child: _buildItemsView(widget.exporter.formatter.getRows(able))),
    ]);
  }

  ListView _buildItemsView(List<List<String>> items) {
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final item in items[index])
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(item),
              ),
          ],
        );
      },
    );
  }
}
