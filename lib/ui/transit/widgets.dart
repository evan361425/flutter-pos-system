import 'package:flutter/material.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/info_popup.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/constants/constant.dart';
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

/// It will use [AutomaticKeepAliveClientMixin] to avoid rebuild preview data.
class ImportView extends StatefulWidget {
  final Widget? header;
  final Icon icon;
  final TransitStateNotifier stateNotifier;
  final Future<PreviewFormatter?> Function(BuildContext context, ValueNotifier<FormattableModel?> able) onLoad;
  final PreviewOnDone onDone;

  /// Allow all data type to be imported.
  ///
  /// For example, in CSV import, it is not allowed to import all data type.
  final bool allowAll;

  const ImportView({
    super.key,
    this.header,
    required this.icon,
    required this.stateNotifier,
    required this.onLoad,
    required this.onDone,
    this.allowAll = false,
  });

  @override
  State<ImportView> createState() => _ImportViewState();
}

class _ImportViewState extends State<ImportView> with AutomaticKeepAliveClientMixin {
  final ValueNotifier<FormattableModel?> model = ValueNotifier(FormattableModel.menu);
  final ValueNotifier<PreviewFormatter?> formatter = ValueNotifier(null);

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    Widget header;
    if (widget.header != null) {
      header = Row(spacing: kInternalSpacing, children: [
        widget.header!,
        IconButton.filled(
          onPressed: () => _onLoad(null),
          icon: widget.icon,
        ),
      ]);
    } else {
      header = _ModelPicker(
        selected: model,
        onTap: _onLoad,
        allowAll: widget.allowAll,
        icon: widget.icon,
      );
    }

    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: kHorizontalSpacing),
        child: header,
      ),
      const Divider(),
      Expanded(
        child: ValueListenableBuilder(
          valueListenable: formatter,
          builder: (context, f, child) {
            if (f == null) {
              return const Center(child: HintText('請選擇資料類型來進行匯入'));
            }

            return PreviewPage.buildTabBarView(
              ables: model.value?.toList() ?? FormattableModel.values,
              formatter: f,
              onDone: widget.onDone,
            );
          },
        ),
      ),
    ]);
  }

  void _onLoad(FormattableModel? able) {
    widget.stateNotifier.exec(() => showSnackbarWhenFutureError(
          widget.onLoad(context, model).then((v) => formatter.value = v),
          'transit_load',
          context: context,
        ));
  }
}

class ExportView extends StatefulWidget {
  final Icon icon;
  final TransitStateNotifier stateNotifier;
  final Future<void> Function(BuildContext context, FormattableModel? able) onExport;
  final Widget Function(BuildContext context, FormattableModel? able) buildModel;

  /// Allow all data type to be imported.
  ///
  /// For example, in CSV import, it is not allowed to import all data type.
  final bool allowAll;

  const ExportView({
    super.key,
    required this.icon,
    required this.stateNotifier,
    required this.onExport,
    required this.buildModel,
    this.allowAll = false,
  });

  @override
  State<ExportView> createState() => _ExportViewState();
}

class _ExportViewState extends State<ExportView> {
  final ValueNotifier<FormattableModel?> model = ValueNotifier(FormattableModel.menu);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: kHorizontalSpacing),
        child: _ModelPicker(
          selected: model,
          onTap: _onExport,
          icon: widget.icon,
          allowAll: widget.allowAll,
        ),
      ),
      const Divider(),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: kHorizontalSpacing),
          child: ValueListenableBuilder(
            valueListenable: model,
            builder: (context, able, _) => widget.buildModel(context, able),
          ),
        ),
      ),
    ]);
  }

  void _onExport(FormattableModel? able) {
    widget.stateNotifier.exec(() => showSnackbarWhenFutureError(
          widget.onExport(context, able),
          'transit_export',
          context: context,
        ));
  }
}

class ModelDataTable extends StatelessWidget {
  final List<String> headers;
  final ModelDataTableSource source;
  final List<String?> notes;

  const ModelDataTable({
    super.key,
    required this.headers,
    required this.source,
    required this.notes,
  }) : assert(headers.length == notes.length);

  @override
  Widget build(BuildContext context) {
    return PaginatedDataTable(
      columns: [for (final (i, v) in headers.indexed) _buildColumn(i, v)],
      source: source,
      showCheckboxColumn: false,
    );
  }

  DataColumn _buildColumn(int i, String v) {
    final note = notes.elementAtOrNull(i);
    if (note == null) {
      return DataColumn(
        label: Text(v, style: const TextStyle(fontWeight: FontWeight.bold)),
      );
    }

    return DataColumn(
      label: Row(children: [
        Text(v, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 4),
        InfoPopup(note),
      ]),
    );
  }
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

class _ModelPicker extends StatefulWidget {
  /// Null means select all
  final ValueNotifier<FormattableModel?> selected;
  final void Function(FormattableModel?) onTap;
  final Icon icon;
  final bool allowAll;

  const _ModelPicker({
    required this.selected,
    required this.onTap,
    required this.icon,
    this.allowAll = true,
  });

  @override
  State<_ModelPicker> createState() => _ModelPickerState();
}

class _ModelPickerState extends State<_ModelPicker> {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: DropdownButtonFormField<FormattableModel?>(
          key: const Key('transit.model_picker'),
          value: widget.selected.value,
          decoration: const InputDecoration(
            label: Text('選擇資料類型'),
            floatingLabelBehavior: FloatingLabelBehavior.always,
          ),
          onChanged: (value) {
            if (mounted) {
              setState(() => widget.selected.value = value);
            }
          },
          items: [
            if (widget.allowAll)
              const DropdownMenuItem(
                key: Key('transit.model_picker._all'),
                value: null,
                child: Text('全部'),
              ),
            for (final able in FormattableModel.values)
              DropdownMenuItem(
                key: Key('transit.model_picker.${able.name}'),
                value: able,
                child: Text(S.transitModelName(able.name)),
              ),
          ],
        ),
      ),
      const SizedBox(width: 8),
      IconButton.filled(
        onPressed: () => widget.onTap(widget.selected.value),
        icon: widget.icon,
      ),
    ]);
  }
}
