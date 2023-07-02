import 'package:flutter/material.dart';
import 'package:possystem/components/loading_wrapper.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/helpers/exporter/data_exporter.dart';
import 'package:possystem/helpers/exporter/google_sheet_exporter.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/ui/exporter/google_sheet_widgets/screens.dart' as gs;
import 'package:possystem/ui/exporter/plain_text_widgets/screens.dart' as pt;
import 'package:possystem/translator.dart';

enum ExporterInfoType {
  order,
  basic,
}

enum ExportMethod { googleSheet, plainText }

class ExporterRoutes {
  static final routes = <ExportMethod, WidgetBuilder>{
    ExportMethod.googleSheet: (context) => ExporterStation(
          info: ModalRoute.of(context)!.settings.arguments as ExporterInfoType,
          method: ExportMethod.googleSheet,
        ),
    ExportMethod.plainText: (context) => ExporterStation(
          info: ModalRoute.of(context)!.settings.arguments as ExporterInfoType,
          method: ExportMethod.plainText,
        ),
  };
}

class ExporterStation extends StatefulWidget {
  final ExportMethod method;

  final ExporterInfoType info;

  final DateTimeRange? range;

  @visibleForTesting
  final ValueNotifier<String>? notifier;

  @visibleForTesting
  final DataExporter? exporter;

  const ExporterStation({
    Key? key,
    required this.info,
    required this.method,
    this.exporter,
    this.notifier,
    this.range,
  }) : super(key: key);

  @override
  State<ExporterStation> createState() => _ExporterStationState();
}

class _ExporterStationState extends State<ExporterStation>
    with TickerProviderStateMixin {
  final loading = GlobalKey<LoadingWrapperState>();

  /// 這個是用來顯示「正在執行中」的資訊，避免匯出時被中斷。
  late final ValueNotifier<String> stateNotifier;

  late final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return LoadingWrapper(
      key: loading,
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.exporterTypes(widget.method.name)),
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
    switch (widget.info) {
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
    switch (widget.info) {
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
              statusNotifier: stateNotifier,
              rangeNotifier: ValueNotifier(widget.range ?? Util.getDateRange()),
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
            return pt.ExporterOrderScreen(
              notifier: ValueNotifier(widget.range ?? Util.getDateRange()),
            );
          case _Combination.importBasic:
            return const pt.ImportBasicScreen();
        }
    }
  }
}

enum _Combination { exportBasic, importBasic, exportOrder }
