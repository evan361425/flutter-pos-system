import 'package:flutter/material.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/exporter/exporter_routes.dart';

class ExporterScreen extends StatelessWidget {
  const ExporterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.exporterTitle),
        leading: const PopButton(),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: HintText(S.exporterDescription),
          ),
          ListTile(
            key: const Key('exporter.google_sheet'),
            leading: CircleAvatar(
              backgroundImage: const AssetImage('assets/google_sheet_icon.png'),
              backgroundColor: Theme.of(context).focusColor,
              radius: 24,
            ),
            title: Text(S.exporterGSTitle),
            subtitle: Text(S.exporterGSDescription),
            onTap: () => _navTo(context, ExporterRoutes.googleSheet),
          ),
          ListTile(
            key: const Key('exporter.plain_text'),
            leading: const CircleAvatar(
              radius: 24,
              child: Text('Text'),
            ),
            title: const Text('純文字'),
            subtitle: const Text('有些人就愛這味。就像資料分析師說的那樣：請給我生魚片，不要煮過的。'),
            onTap: () => _navTo(context, ExporterRoutes.plainText),
          ),
        ]),
      ),
    );
  }

  void _navTo(BuildContext context, String name) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: ExporterRoutes.routes[name]!),
    );
  }
}
