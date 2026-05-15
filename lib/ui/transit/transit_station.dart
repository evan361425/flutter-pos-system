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

  ValueNotifier<FormattableModel?>? _model;
  ValueNotifier<PreviewFormatter?>? _formatter;
  ValueNotifier<DateTimeRange>? _ranger;

  /// This is used to display the "in progress" information to avoid interruption during export.
  late final TransitStateNotifier stateNotifier;

  @override
  Widget build(BuildContext context) {
    return LoadingWrapper(
      key: loading,
      child: Scaffold(
        body: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverOverlapAbsorber(
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  sliver: SliverAppBar(
                    title: Text(widget.method.l10nName),
                    leading: const PopButton(),
                    automaticallyImplyLeading: false,
                    floating: true,
                    snap: true,
                    forceElevated: innerBoxIsScrolled,
                    bottom: PreferredSize(preferredSize: const .fromHeight(56.0), child: _buildHeader()),
                  ),
                ),
              ];
            },
            body: _buildBody(),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    stateNotifier = widget.notifier ?? TransitStateNotifier();
    stateNotifier.addListener(() {
      return switch (stateNotifier.value) {
        '_start' => loading.currentState?.startLoading(),
        '_finish' => loading.currentState?.finishLoading(),
        _ => loading.currentState?.setStatus(stateNotifier.value),
      };
    });

    super.initState();
  }

  @override
  void dispose() {
    loading.currentState?.dispose();
    stateNotifier.dispose();
    super.dispose();
  }

  ValueNotifier<TransitOrderSettings> get _settings {
    return ValueNotifier<TransitOrderSettings>(TransitOrderSettings.fromCache());
  }

  ValueNotifier<DateTimeRange> get ranger {
    return _ranger ??= ValueNotifier(widget.range ?? Util.getDateRange());
  }

  ValueNotifier<FormattableModel?> get model {
    return _model ??= ValueNotifier(null);
  }

  ValueNotifier<PreviewFormatter?> get formatter {
    return _formatter ??= ValueNotifier<PreviewFormatter?>(null);
  }

  GoogleSheetExporter get _googleSheetExporter {
    return (widget.exporter ?? GoogleSheetExporter()) as GoogleSheetExporter;
  }

  Widget _buildHeader() {
    if (widget.catalog == .importModel) {
      return switch (widget.method) {
        .googleSheet => gs.ImportBasicHeader(
          selected: model,
          stateNotifier: stateNotifier,
          formatter: formatter,
          exporter: _googleSheetExporter,
        ),
        .excel => excel.ImportBasicHeader(selected: model, stateNotifier: stateNotifier, formatter: formatter),
        .csv => csv.ImportBasicHeader(selected: model, stateNotifier: stateNotifier, formatter: formatter),
        .plainText => pt.ImportBasicHeader(selected: model, formatter: formatter),
      };
    }

    if (widget.catalog == .exportModel) {
      return switch (widget.method) {
        .googleSheet => gs.ExportBasicHeader(
          selected: model,
          stateNotifier: stateNotifier,
          exporter: _googleSheetExporter,
        ),
        .excel => excel.ExportBasicHeader(selected: model, stateNotifier: stateNotifier),
        .csv => csv.ExportBasicHeader(selected: model, stateNotifier: stateNotifier),
        .plainText => pt.ExportBasicHeader(selected: model, stateNotifier: stateNotifier),
      };
    }

    return switch (widget.method) {
      .googleSheet => gs.ExportOrderHeader(
        stateNotifier: stateNotifier,
        exporter: _googleSheetExporter,
        ranger: ranger,
        settings: _settings,
      ),
      .excel => excel.ExportOrderHeader(stateNotifier: stateNotifier, ranger: ranger, settings: _settings),
      .csv => csv.ExportOrderHeader(stateNotifier: stateNotifier, ranger: ranger),
      .plainText => pt.ExportOrderHeader(stateNotifier: stateNotifier, ranger: ranger),
    };
  }

  Widget _buildBody() {
    if (widget.catalog == .importModel) {
      return ImportView(
        stateNotifier: stateNotifier,
        selected: model,
        formatter: formatter,
        hint: widget.method == .plainText
            ? S.transitImportModelSelectionPlainTextHint
            : S.transitImportModelSelectionHint,
      );
    }

    if (widget.catalog == .exportModel) {
      return switch (widget.method) {
        .googleSheet => gs.ExportBasicView(selected: model, stateNotifier: stateNotifier),
        .excel => excel.ExportBasicView(selected: model, stateNotifier: stateNotifier),
        .csv => csv.ExportBasicView(selected: model, stateNotifier: stateNotifier),
        .plainText => pt.ExportBasicView(selected: model, stateNotifier: stateNotifier),
      };
    }

    return switch (widget.method) {
      .googleSheet => gs.ExportOrderView(ranger: ranger),
      .excel => excel.ExportOrderView(ranger: ranger),
      .csv => csv.ExportOrderView(ranger: ranger),
      .plainText => pt.ExportOrderView(ranger: ranger),
    };
  }
}
