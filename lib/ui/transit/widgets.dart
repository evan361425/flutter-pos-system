import 'package:flutter/material.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/info_popup.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/formatter/formatter.dart';
import 'package:possystem/ui/transit/previews/preview_page.dart';

class TransitStateNotifier extends ValueNotifier<String> {
  TransitStateNotifier() : super('_finish');

  bool get isProgressing => value != '_finish';

  void startProgress() {
    value = '_start';
  }

  void finishProgress() {
    value = '_finish';
  }

  void exec(VoidCallback callback) {
    if (!isProgressing) {
      try {
        startProgress();
        callback();
      } finally {
        finishProgress();
      }
    }
  }
}

abstract class ImportBasicBaseHeader extends BasicModelPicker {
  final ValueNotifier<PreviewFormatter?> formatter;

  const ImportBasicBaseHeader({
    super.key,
    required super.selected,
    required super.stateNotifier,
    required super.icon,
    required super.allowAll,
    required this.formatter,
  });

  String? get errorMessage => null;

  String? get moreMessage => null;

  @override
  void onTap(BuildContext context) {
    stateNotifier.exec(() => showSnackbarWhenFutureError(
          onImport(context).then((v) => formatter.value = v),
          'transit_basic_import',
          context: context,
          message: errorMessage,
          more: moreMessage,
        ));
  }

  Future<PreviewFormatter?> onImport(BuildContext context);
}

/// It will use [AutomaticKeepAliveClientMixin] to avoid rebuild preview data.
class ImportView extends StatefulWidget {
  final TransitStateNotifier stateNotifier;
  final ValueNotifier<FormattableModel?> selected;
  final ValueNotifier<PreviewFormatter?> formatter;

  const ImportView({
    super.key,
    required this.stateNotifier,
    required this.selected,
    required this.formatter,
  });

  @override
  State<ImportView> createState() => _ImportViewState();
}

class _ImportViewState extends State<ImportView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ValueListenableBuilder(
      valueListenable: widget.formatter,
      builder: (context, f, child) {
        if (f == null) {
          return Center(child: HintText(S.transitImportModelSelectionHint));
        }

        return PreviewPage.buildTabBarView(
          ables: widget.selected.value?.toList() ?? FormattableModel.values,
          formatter: f,
        );
      },
    );
  }
}

abstract class ExportView extends StatefulWidget {
  final TransitStateNotifier stateNotifier;
  final ValueNotifier<FormattableModel?> selected;

  const ExportView({
    super.key,
    required this.stateNotifier,
    required this.selected,
  });

  @override
  State<ExportView> createState() => _ExportViewState();

  ModelData getSourceAndHeaders(FormattableModel able) {
    throw UnimplementedError();
  }

  /// Build the model data table.
  Widget buildModel(BuildContext context, FormattableModel able) {
    final data = getSourceAndHeaders(able);
    return PaginatedDataTable(
      columns: [
        for (final cell in data.headers) _buildColumn(cell),
      ],
      source: data.source,
      showCheckboxColumn: false,
    );
  }

  DataColumn _buildColumn(CellData cell) {
    if (cell.note == null) {
      return DataColumn(
        label: Text(
          cell.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    }

    return DataColumn(
      label: Row(children: [
        Text(
          cell.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 4),
        InfoPopup(cell.note!),
      ]),
    );
  }
}

class _ExportViewState extends State<ExportView> with SingleTickerProviderStateMixin {
  late final TabController controller;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverPersistentHeader(
          pinned: true,
          delegate: SliverTabBarDelegate(
            TabBar(controller: controller, tabs: [
              for (final able in FormattableModel.values) Tab(text: able.l10nName),
            ]),
          ),
        ),
        SliverFillRemaining(
          child: TabBarView(children: [
            for (final able in FormattableModel.values) widget.buildModel(context, able),
          ]),
        ),
      ],
    );
  }

  @override
  initState() {
    super.initState();
    controller = TabController(
      length: FormattableModel.values.length,
      vsync: this,
    );

    controller.addListener(() {
      final model = FormattableModel.values[controller.index];
      if (widget.selected.value != null && widget.selected.value != model) {
        widget.selected.value = model;
      }
    });
    widget.selected.addListener(_onModelChange);
  }

  @override
  void dispose() {
    controller.dispose();
    widget.selected.removeListener(_onModelChange);
    super.dispose();
  }

  void _onModelChange() {
    final model = widget.selected.value;

    if (model != null) {
      final index = FormattableModel.values.indexOf(model);
      if (index != controller.index) {
        controller.animateTo(index);
      }
    }
  }
}

abstract class BasicModelPicker extends StatefulWidget {
  /// Null means select all
  final ValueNotifier<FormattableModel?> selected;
  final TransitStateNotifier stateNotifier;
  final Icon icon;

  /// Allow all data type to be imported.
  ///
  /// For example, in CSV import, it is not allowed to import all data type.
  final bool allowAll;

  const BasicModelPicker({
    super.key,
    required this.selected,
    required this.stateNotifier,
    required this.icon,
    this.allowAll = true,
  });

  @override
  State<BasicModelPicker> createState() => _BasicModelPickerState();

  /// The label of the export button.
  String get label;

  void onTap(BuildContext context) {
    stateNotifier.exec(() => showSnackbarWhenFutureError(
          onExport(context, selected.value),
          'transit_basic_export',
          context: context,
        ));
  }

  /// Action to export the data.
  Future<void> onExport(BuildContext context, FormattableModel? able) async {}
}

class _BasicModelPickerState extends State<BasicModelPicker> {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: DropdownButtonFormField<FormattableModel?>(
          key: const Key('transit.model_picker'),
          value: widget.selected.value,
          decoration: InputDecoration(
            label: Text(S.transitImportModelSelectionLabel),
            floatingLabelBehavior: FloatingLabelBehavior.always,
          ),
          onChanged: (value) {
            if (mounted) {
              setState(() => widget.selected.value = value);
            }
          },
          items: [
            if (widget.allowAll)
              DropdownMenuItem(
                key: const Key('transit.model_picker._all'),
                value: null,
                child: Text(S.transitImportModelSelectionAll),
              ),
            for (final able in FormattableModel.values)
              DropdownMenuItem(
                key: Key('transit.model_picker.${able.name}'),
                value: able,
                child: Text(able.l10nName),
              ),
          ],
        ),
      ),
      const SizedBox(width: 8),
      IconButton.filled(
        onPressed: () => widget.onTap(context),
        tooltip: widget.label,
        icon: widget.icon,
      ),
    ]);
  }
}

class ModelData {
  final List<CellData> headers;
  final List<List<Object?>> data;

  ModelData(this.headers, this.data);

  ModelDataTableSource get source => ModelDataTableSource(data);
}

class ModelDataTableSource extends DataTableSource {
  final List<List<Object?>> data;

  ModelDataTableSource(this.data);

  @override
  DataRow? getRow(int index) {
    return DataRow(cells: [
      for (final item in data[index])
        DataCell(Tooltip(
          message: item.toString(),
          child: Text(item.toString()),
        )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}
