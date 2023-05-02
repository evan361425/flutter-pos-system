import 'package:flutter/material.dart';
import 'package:possystem/components/loading_wrapper.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/helpers/exporter/data_exporter.dart';
import 'package:possystem/helpers/exporter/google_sheet_exporter.dart';
import 'package:possystem/helpers/exporter/plain_text_exporter.dart';
import 'package:possystem/ui/exporter/google_sheet_widgets/screens.dart' as gs;
import 'package:possystem/ui/exporter/plain_text_widgets/screens.dart' as pt;
import 'package:possystem/translator.dart';

class ExporterRoutes {
  static const googleSheet = 'googleSheet';
  static const plainText = 'plainText';

  static Widget gsExportScreen(
    DataExporter exporter,
    ValueNotifier<String> notifier,
  ) {
    return gs.ExporterScreen(
      exporter: exporter as GoogleSheetExporter,
      notifier: notifier,
    );
  }

  static Widget gsImportScreen(
    DataExporter exporter,
    ValueNotifier<String> notifier,
  ) {
    return gs.ImporterScreen(
      exporter: exporter as GoogleSheetExporter,
      notifier: notifier,
    );
  }

  static Widget ptExportScreen(
    DataExporter exporter,
    ValueNotifier<String> notifier,
  ) {
    return pt.ExporterScreen(exporter: exporter as PlainTextExporter);
  }

  static Widget ptImportScreen(
    DataExporter exporter,
    ValueNotifier<String> notifier,
  ) {
    return pt.ImporterScreen(exporter: exporter as PlainTextExporter);
  }

  static final routes = <String, WidgetBuilder>{
    googleSheet: (_) => ExporterStation(
          title: S.exporterGSTitle,
          exporter: GoogleSheetExporter(),
          exportScreenBuilder: gsExportScreen,
          importScreenBuilder: gsImportScreen,
        ),
    plainText: (_) => const ExporterStation(
          title: '純文字',
          exporter: PlainTextExporter(),
          exportScreenBuilder: ptExportScreen,
          importScreenBuilder: ptImportScreen,
        ),
  };
}

class ExporterStation extends StatefulWidget {
  final String title;

  final DataExporter exporter;

  final ExporterBuilder exportScreenBuilder;

  final ExporterBuilder importScreenBuilder;

  final ValueNotifier<String>? notifier;

  const ExporterStation({
    Key? key,
    required this.title,
    required this.exporter,
    this.notifier,
    required this.exportScreenBuilder,
    required this.importScreenBuilder,
  }) : super(key: key);

  @override
  State<ExporterStation> createState() => _ExporterStationState();
}

class _ExporterStationState extends State<ExporterStation>
    with TickerProviderStateMixin {
  final loading = GlobalKey<LoadingWrapperState>();

  late final ValueNotifier<String> stateNotifier;

  late final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return LoadingWrapper(
      key: loading,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          leading: const PopButton(),
          bottom: TabBar(
            controller: tabController,
            tabs: [
              Tab(text: S.btnExport),
              Tab(text: S.btnImport),
            ],
          ),
        ),
        body: TabBarView(
          controller: tabController,
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: widget.exportScreenBuilder(
                widget.exporter,
                stateNotifier,
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: widget.importScreenBuilder(
                widget.exporter,
                stateNotifier,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        FocusManager.instance.primaryFocus?.unfocus();
      }
    });

    stateNotifier = widget.notifier ?? ValueNotifier('');
    stateNotifier.addListener(() {
      switch (stateNotifier.value) {
        case '_start':
          loading.currentState?.startLoading();
          break;
        case '_finish':
          loading.currentState?.finishLoading();
          break;
        default:
          loading.currentState?.setStatus(stateNotifier.value);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    loading.currentState?.dispose();
    stateNotifier.dispose();
    super.dispose();
  }
}

typedef ExporterBuilder = Widget Function(
  DataExporter exporter,
  ValueNotifier<String> notifier,
);
