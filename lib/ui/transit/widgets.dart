import 'package:flutter/material.dart';
import 'package:possystem/components/style/circular_loading.dart';
import 'package:possystem/components/style/info_popup.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/formatter/formatter.dart';

class ModelDataTable extends StatelessWidget {
  final List<String> headers;
  final DataTableSource source;
  final List<String?> notes;

  const ModelDataTable({
    super.key,
    required this.headers,
    required this.source,
    required this.notes,
  });

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

class ModelPicker extends StatefulWidget {
  final ValueNotifier<Formattable> selected;
  final ValueNotifier<bool> isProcessing;
  final void Function(Formattable) onTap;
  final Icon icon;

  const ModelPicker({
    super.key,
    required this.selected,
    required this.isProcessing,
    required this.onTap,
    required this.icon,
  });

  @override
  State<ModelPicker> createState() => _ModelPickerState();
}

class _ModelPickerState extends State<ModelPicker> {
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Row(children: [
        DropdownButtonFormField<Formattable>(
          key: const Key('transit.model_picker'),
          isExpanded: true,
          value: widget.selected.value,
          decoration: const InputDecoration(
            label: Text('選擇資料類型'),
            floatingLabelBehavior: FloatingLabelBehavior.always,
          ),
          onChanged: (value) {
            if (value != null && mounted) {
              setState(() => widget.selected.value = value);
            }
          },
          items: [
            for (final able in Formattable.values)
              DropdownMenuItem(
                key: Key('transit.model_picker.${able.name}'),
                value: able,
                child: Text(S.transitModelName(able.name)),
              ),
          ],
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          onPressed: () => widget.onTap(widget.selected.value),
          icon: widget.icon,
        ),
      ]),
      Positioned.fill(
        child: ValueListenableBuilder(
          valueListenable: widget.isProcessing,
          builder: (context, bool value, child) {
            if (value) {
              return AbsorbPointer(
                child: ColoredBox(
                  color: Colors.black.withAlpha(0x80),
                  child: const CircularLoading(),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    ]);
  }
}
