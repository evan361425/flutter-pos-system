import 'package:flutter/material.dart';
import 'package:possystem/components/loading_wrapper.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/helpers/exporter/data_exporter.dart';
import 'package:possystem/helpers/exporter/google_sheet_exporter.dart';
import 'package:possystem/ui/exporter/google_sheet_widgets/screens.dart' as gs;
import 'package:possystem/ui/exporter/plain_text_widgets/screens.dart' as pt;
import 'package:possystem/translator.dart';

enum ExporterInfoType {
  basic,
  order,
}

enum ExportMethod { googleSheet, plainText }

class ExporterRoutes {
  static final routes = <ExportMethod, WidgetBuilder>{
    ExportMethod.googleSheet: (context) => ExporterStation(
          title: S.exporterGSTitle,
          info: ModalRoute.of(context)!.settings.arguments as ExporterInfo,
          method: ExportMethod.googleSheet,
        ),
    ExportMethod.plainText: (context) => ExporterStation(
          title: '純文字',
          info: ModalRoute.of(context)!.settings.arguments as ExporterInfo,
          method: ExportMethod.plainText,
        ),
  };
}

class ExporterStation extends StatefulWidget {
  final String title;

  final ExportMethod method;

  final ExporterInfo info;

  @visibleForTesting
  final ValueNotifier<String>? notifier;

  @visibleForTesting
  final DataExporter? exporter;

  const ExporterStation({
    Key? key,
    required this.title,
    required this.info,
    required this.method,
    this.exporter,
    this.notifier,
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
          bottom: _buildAppBarBottom(),
        ),
        body: _buildBody(),
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

  PreferredSizeWidget? _buildAppBarBottom() {
    switch (widget.info.type) {
      case ExporterInfoType.basic:
        return TabBar(
          controller: tabController,
          tabs: [
            Tab(text: S.btnExport),
            Tab(text: S.btnImport),
          ],
        );
      default:
        return null;
    }
  }

  Widget _buildBody() {
    switch (widget.info.type) {
      case ExporterInfoType.basic:
        return TabBarView(
          controller: tabController,
          children: [
            _buildScreen(_Combination.exportBasic),
            _buildScreen(_Combination.importBasic),
          ],
        );
      case ExporterInfoType.order:
        return _buildScreen(_Combination.exportOrder);
    }
  }

  Widget _buildScreen(_Combination combination) {
    switch (widget.method) {
      case ExportMethod.googleSheet:
        final exporter =
            (widget.exporter ?? GoogleSheetExporter()) as GoogleSheetExporter;
        switch (combination) {
          case _Combination.exportBasic:
            return gs.ExportBasicScreen(
              exporter: exporter,
              notifier: stateNotifier,
            );
          case _Combination.exportOrder:
            return gs.ExportOrderScreen(
              exporter: exporter,
              notifier: stateNotifier,
              range: widget.info.range!,
            );
          case _Combination.importBasic:
            return gs.ImportBasicScreen(
              exporter: exporter,
              notifier: stateNotifier,
            );
        }
      case ExportMethod.plainText:
        switch (combination) {
          case _Combination.exportBasic:
            return const pt.ExportBasicScreen();
          case _Combination.exportOrder:
            return pt.ExporterOrderScreen(range: widget.info.range!);
          case _Combination.importBasic:
            return const pt.ImportBasicScreen();
        }
    }
  }
}

class ExporterInfo {
  final ExporterInfoType type;

  final DateTimeRange? range;

  const ExporterInfo({
    required this.type,
    this.range,
  });
}

enum _Combination { exportBasic, importBasic, exportOrder }
