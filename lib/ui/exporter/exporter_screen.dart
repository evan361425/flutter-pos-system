import 'package:flutter/material.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/exporter/google_sheet_exporter.dart';

class ExporterScreen extends StatelessWidget {
  const ExporterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('匯出資料'),
        leading: const PopButton(),
      ),
      body: Center(
          child: ElevatedButton(
        onPressed: () async {
          final exporter = GoogleSheetExporter();
          await exporter.pickSheets();
        },
        child: const Text('hi'),
      )),
    );
  }
}
