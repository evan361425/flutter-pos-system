import 'package:flutter/material.dart';
import 'package:possystem/components/loading_wrapper.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/helpers/exporter/data_exporter.dart';
import 'package:possystem/helpers/exporter/google_sheet_exporter.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/translator.dart';

import 'google_sheet/views.dart' as gs;
import 'plain_text/views.dart' as pt;

enum TransitCatalog {
  order,
  model,
}

enum TransitMethod {
  googleSheet,
  plainText,
}

class TransitStation extends StatefulWidget {
  final TransitMethod method;

  final TransitCatalog catalog;

  final DateTimeRange? range;

  @visibleForTesting
  final ValueNotifier<String>? notifier;

  @visibleForTesting
  final DataExporter? exporter;

  const TransitStation({
    super.key,
    required this.catalog,
    required this.method,
    this.exporter,
    this.notifier,
    this.range,
  });

  @override
  State<TransitStation> createState() => _TransitStationState();
}

class _TransitStationState extends State<TransitStation> with TickerProviderStateMixin {
  final loading = GlobalKey<LoadingWrapperState>();

  /// This is used to display the "in progress" information to avoid interruption during export.
  late final ValueNotifier<String> stateNotifier;

  late final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return LoadingWrapper(
      key: loading,
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.transitMethodName(widget.method.name)),
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
    switch (widget.catalog) {
      case TransitCatalog.model:
        return TabBar(
          controller: tabController,
          tabs: [
            Tab(text: S.transitExportBtn),
            Tab(text: S.transitImportBtn),
          ],
        );
      default:
        return null;
    }
  }

  Widget _buildBody() {
    switch (widget.catalog) {
      case TransitCatalog.model:
        return TabBarView(
          key: const Key('transit.basic_tab'),
          controller: tabController,
          children: [
            _buildScreen(_Combination.exportBasic),
            _buildScreen(_Combination.importBasic),
          ],
        );
      case TransitCatalog.order:
        return _buildScreen(_Combination.exportOrder);
    }
  }

  Widget _buildScreen(_Combination combination) {
    switch (widget.method) {
      case TransitMethod.googleSheet:
        final exporter = (widget.exporter ?? GoogleSheetExporter()) as GoogleSheetExporter;
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
