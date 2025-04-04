import 'package:flutter/material.dart';
import 'package:possystem/components/loading_wrapper.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/exporter/data_exporter.dart';
import 'package:possystem/ui/transit/exporter/google_sheet_exporter.dart';
import 'package:possystem/ui/transit/formatter/formatter.dart';
import 'package:possystem/ui/transit/order_widgets.dart';
import 'package:possystem/ui/transit/previews/preview_page.dart';
import 'package:possystem/ui/transit/widgets.dart';

import 'csv/views.dart' as csv;
import 'excel/views.dart' as excel;
import 'google_sheet/views.dart' as gs;
import 'plain_text/views.dart' as pt;

enum TransitCatalog {
  exportOrder,
  exportModel,
  importModel;

  String get l10nName {
    return S.transitCatalogName(name);
  }

  String get l10nHelper {
    return S.transitCatalogHelper(name);
  }
}

enum TransitMethod {
  googleSheet,
  excel,
  csv,
  plainText;

  String get l10nName {
    return S.transitMethodName(name);
  }
}

class TransitStation extends StatefulWidget {
  final TransitMethod method;

  final TransitCatalog catalog;

  final DateTimeRange? range;

  @visibleForTesting
  final TransitStateNotifier? notifier;

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

class _TransitStationState extends State<TransitStation> {
  final loading = GlobalKey<LoadingWrapperState>();

  final scrollable = ValueNotifier(true);

  ValueNotifier<FormattableModel?>? _model;
  ValueNotifier<PreviewFormatter?>? _formatter;

  /// This is used to display the "in progress" information to avoid interruption during export.
  late final TransitStateNotifier stateNotifier;

  @override
  Widget build(BuildContext context) {
    return LoadingWrapper(
      key: loading,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            scrollable.value = innerBoxIsScrolled;
            return [
              SliverAppBar(
                automaticallyImplyLeading: false,
                floating: true,
                leading: const PopButton(),
                title: Text(widget.method.l10nName),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(48.0),
                  child: _buildHeader(),
                ),
              ),
            ];
          },
          body: _buildBody(),
        ),
      ),
    );
  }

  @override
  void initState() {
    stateNotifier = widget.notifier ?? TransitStateNotifier();
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
    scrollable.dispose();
    super.dispose();
  }

  ValueNotifier<TransitOrderSettings> get _settings {
    return ValueNotifier<TransitOrderSettings>(TransitOrderSettings.fromCache());
  }

  ValueNotifier<DateTimeRange> get _ranger {
    return ValueNotifier(widget.range ?? Util.getDateRange());
  }

  ValueNotifier<FormattableModel?> get model {
    return _model ??= ValueNotifier(FormattableModel.menu);
  }

  ValueNotifier<PreviewFormatter?> get formatter {
    return _formatter ??= ValueNotifier<PreviewFormatter?>(null);
  }

  GoogleSheetExporter get _googleSheetExporter {
    return (widget.exporter ?? GoogleSheetExporter()) as GoogleSheetExporter;
  }

  Widget _buildHeader() {
    if (widget.catalog == TransitCatalog.importModel) {
      switch (widget.method) {
        case TransitMethod.googleSheet:
          return gs.ImportBasicHeader(
            selected: model,
            stateNotifier: stateNotifier,
            formatter: formatter,
            exporter: _googleSheetExporter,
          );
        case TransitMethod.excel:
          return excel.ImportBasicHeader(selected: model, stateNotifier: stateNotifier, formatter: formatter);
        case TransitMethod.csv:
          return csv.ImportBasicHeader(selected: model, stateNotifier: stateNotifier, formatter: formatter);
        case TransitMethod.plainText:
          return pt.ImportBasicHeader(selected: model, formatter: formatter);
      }
    }

    if (widget.catalog == TransitCatalog.exportModel) {
      switch (widget.method) {
        case TransitMethod.googleSheet:
          return gs.ExportBasicHeader(selected: model, stateNotifier: stateNotifier, exporter: _googleSheetExporter);
        case TransitMethod.excel:
          return excel.ExportBasicHeader(selected: model, stateNotifier: stateNotifier);
        case TransitMethod.csv:
          return csv.ExportBasicHeader(selected: model, stateNotifier: stateNotifier);
        case TransitMethod.plainText:
          return pt.ExportBasicHeader(selected: model, stateNotifier: stateNotifier);
      }
    }

    switch (widget.method) {
      case TransitMethod.googleSheet:
        return gs.ExportOrderHeader(
          stateNotifier: stateNotifier,
          exporter: _googleSheetExporter,
          ranger: _ranger,
          settings: _settings,
        );
      case TransitMethod.excel:
        return excel.ExportOrderHeader(stateNotifier: stateNotifier, ranger: _ranger, settings: _settings);
      case TransitMethod.csv:
        return csv.ExportOrderHeader(stateNotifier: stateNotifier, ranger: _ranger);
      case TransitMethod.plainText:
        return pt.ExportOrderHeader(stateNotifier: stateNotifier, ranger: _ranger);
    }
  }

  Widget _buildBody() {
    if (widget.catalog == TransitCatalog.importModel) {
      return ImportView(
        stateNotifier: stateNotifier,
        selected: model,
        formatter: formatter,
        scrollable: scrollable,
      );
    }

    if (widget.catalog == TransitCatalog.exportModel) {
      switch (widget.method) {
        case TransitMethod.googleSheet:
          return gs.ExportBasicView(selected: model, stateNotifier: stateNotifier, scrollable: scrollable);
        case TransitMethod.excel:
          return excel.ExportBasicView(selected: model, stateNotifier: stateNotifier, scrollable: scrollable);
        case TransitMethod.csv:
          return csv.ExportBasicView(selected: model, stateNotifier: stateNotifier, scrollable: scrollable);
        case TransitMethod.plainText:
          return pt.ExportBasicView(selected: model, stateNotifier: stateNotifier, scrollable: scrollable);
      }
    }

    switch (widget.method) {
      case TransitMethod.googleSheet:
        return gs.ExportOrderView(ranger: _ranger);
      case TransitMethod.excel:
        return excel.ExportOrderView(ranger: _ranger);
      case TransitMethod.csv:
        return csv.ExportOrderView(ranger: _ranger);
      case TransitMethod.plainText:
        return pt.ExportOrderView(ranger: _ranger);
    }
  }
}
