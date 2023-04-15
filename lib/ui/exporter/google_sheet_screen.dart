import 'package:flutter/material.dart';
import 'package:possystem/components/loading_wrapper.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/helpers/exporter/google_sheet_exporter.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/exporter/google_sheet_widgets/exporter_screen.dart';
import 'package:possystem/ui/exporter/google_sheet_widgets/importer_screen.dart';

class GoogleSheetScreen extends StatefulWidget {
  final GoogleSheetExporter? exporter;

  const GoogleSheetScreen({Key? key, this.exporter}) : super(key: key);

  @override
  State<GoogleSheetScreen> createState() => GoogleSheetScreenState();
}

class GoogleSheetScreenState extends State<GoogleSheetScreen> {
  final loading = GlobalKey<LoadingWrapperState>();

  late final GoogleSheetExporter exporter;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: LoadingWrapper(
        key: loading,
        child: Scaffold(
          appBar: AppBar(
            title: Text(S.exporterGSTitle),
            leading: const PopButton(),
            bottom: TabBar(
              tabs: [
                Tab(text: S.btnExport),
                Tab(text: S.btnImport),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              ExporterScreen(
                exporter: exporter,
                startLoading: _startLoading,
                finishLoading: _finishLoading,
                setProgressStatus: _setProgressStatus,
              ),
              ImporterScreen(
                exporter: exporter,
                startLoading: _startLoading,
                finishLoading: _finishLoading,
                setProgressStatus: _setProgressStatus,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startLoading() {
    loading.currentState?.startLoading();
  }

  void _finishLoading() {
    loading.currentState?.finishLoading();
  }

  void _setProgressStatus(String status) {
    loading.currentState?.setStatus(status);
  }

  @override
  void initState() {
    exporter = widget.exporter ?? GoogleSheetExporter();
    super.initState();
  }

  @override
  void dispose() {
    loading.currentState?.dispose();
    super.dispose();
  }
}
