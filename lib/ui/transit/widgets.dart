import 'package:flutter/material.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/info_popup.dart';
import 'package:possystem/components/style/text_divider.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/formatter/formatter.dart';
import 'package:possystem/ui/transit/formatter/order_formatter.dart';

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

class ModelPicker extends StatefulWidget {
  /// Null means select all
  final ValueNotifier<FormattableModel> selected;
  final void Function(FormattableModel) onTap;
  final Icon icon;

  const ModelPicker({
    super.key,
    required this.selected,
    required this.onTap,
    required this.icon,
  });

  @override
  State<ModelPicker> createState() => _ModelPickerState();
}

class _ModelPickerState extends State<ModelPicker> {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: DropdownButtonFormField<FormattableModel>(
          key: const Key('transit.model_picker'),
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

class OrderTable extends StatefulWidget {
  final OrderObject order;

  const OrderTable({
    super.key,
    required this.order,
  });

  @override
  State<OrderTable> createState() => _OrderTableState();
}

class _OrderTableState extends State<OrderTable> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SimpleTable(
          headers: OrderFormatter.basicHeaders,
          data: OrderFormatter.formatBasic(widget.order),
          expandableIndexes: const [
            OrderFormatter.attrPosition,
            OrderFormatter.productPosition,
          ],
        ),
        TextDivider(label: S.transitGSOrderAttributeTitle),
        SimpleTable(
          headers: OrderFormatter.attrHeaders,
          data: OrderFormatter.formatAttr(widget.order),
        ),
        TextDivider(label: S.transitGSOrderProductTitle),
        SimpleTable(
          headers: OrderFormatter.productHeaders,
          data: OrderFormatter.formatProduct(widget.order),
          expandableIndexes: const [OrderFormatter.ingredientPosition],
        ),
        TextDivider(label: S.transitGSOrderIngredientTitle),
        SimpleTable(
          headers: OrderFormatter.ingredientHeaders,
          data: OrderFormatter.formatIngredient(widget.order),
        ),
      ]),
    );
  }
}

class SimpleTable extends StatelessWidget {
  final Iterable<String> headers;

  final Iterable<Iterable<Object>> data;

  final List<int> expandableIndexes;

  const SimpleTable({
    super.key,
    required this.headers,
    required this.data,
    this.expandableIndexes = const [],
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultColumnWidth: const IntrinsicColumnWidth(),
        border: TableBorder.all(borderRadius: BorderRadius.circular(4.0)),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(children: [
            for (final header in headers)
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  header.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
          ]),
          for (final row in data)
            TableRow(
              children: _rowWidgets(row).toList(),
            ),
        ],
      ),
    );
  }

  Iterable<Widget> _rowWidgets(Iterable<Object> row) sync* {
    int index = 0;
    for (final cell in row) {
      final idxOf = expandableIndexes.indexOf(index++);
      yield Padding(
        padding: const EdgeInsets.all(4.0),
        child: idxOf != -1
            ? HintText(S.transitGSOrderExpandableHint)
            : Text(
                cell.toString(),
                textAlign: cell is String ? TextAlign.end : TextAlign.start,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
      );
    }
  }
}
