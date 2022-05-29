import 'package:flutter/material.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/exporter/google_sheet_screen.dart';

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
            onTap: () => _navTo(context, _Pages.googleSheet),
          ),
        ]),
      ),
    );
  }

  void _navTo(BuildContext context, _Pages name) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          switch (name) {
            case _Pages.googleSheet:
              return const GoogleSheetScreen();
          }
        },
      ),
    );
  }
}

enum _Pages {
  googleSheet,
}
