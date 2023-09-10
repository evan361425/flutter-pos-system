import 'package:flutter/material.dart';
import 'package:possystem/components/loading_wrapper.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/helpers/exporter/data_exporter.dart';
import 'package:possystem/helpers/exporter/google_sheet_exporter.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/translator.dart';

import 'google_sheet/views.dart' as gs;
import 'plain_text_widgets/views.dart' as pt;

enum TransitType {
  order,
  basic,
}

enum TransitMethod {
  googleSheet,
  plainText,
}

class TransitStation extends StatefulWidget {
  final TransitMethod method;

  final TransitType type;

  final DateTimeRange? range;

  @visibleForTesting
  final ValueNotifier<String>? notifier;

  @visibleForTesting
  final DataExporter? exporter;

  const TransitStation({
    Key? key,
    required this.type,
    required this.method,
    this.exporter,
    this.notifier,
    this.range,
  }) : super(key: key);

  @override
  State<TransitStation> createState() => _TransitStationState();
}

class _TransitStationState extends State<TransitStation>
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
          title: Text(S.transitMethod(widget.method.name)),
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
    switch (widget.type) {
      case TransitType.basic:
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
    switch (widget.type) {
      case TransitType.basic:
        return TabBarView(
          controller: tabController,
          children: [
            _buildScreen(_Combination.exportBasic),
            _buildScreen(_Combination.importBasic),
          ],
        );
      case TransitType.order:
        return _buildScreen(_Combination.exportOrder);
    }
  }

  Widget _buildScreen(_Combination combination) {
    switch (widget.method) {
      case TransitMethod.googleSheet:
        final exporter =
            (widget.exporter ?? GoogleSheetExporter()) as GoogleSheetExporter;
        switch (combination) {
          case _Combination.exportBasic:
            return gs.ExportBasicView(
              exporter: exporter,
              notifier: stateNotifier,
            );
          case _Combination.exportOrder:
            return gs.ExportOrderView(
              exporter: exporter,
              statusNotifier: stateNotifier,
              rangeNotifier: ValueNotifier(widget.range ?? Util.getDateRange()),
            );
          case _Combination.importBasic:
            return gs.ImportBasicView(
              exporter: exporter,
              notifier: stateNotifier,
            );
        }
      case TransitMethod.plainText:
        switch (combination) {
          case _Combination.exportBasic:
            return const pt.ExportBasicView();
          case _Combination.exportOrder:
            return pt.ExportOrderView(
              notifier: ValueNotifier(widget.range ?? Util.getDateRange()),
            );
          case _Combination.importBasic:
            return const pt.ImportBasicView();
        }
    }
  }
}

enum _Combination { exportBasic, importBasic, exportOrder }
