import 'package:flutter/material.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/text_divider.dart';
import 'package:possystem/models/objects/order_object.dart';

import 'order_formatter.dart';

class OrderTable extends StatefulWidget {
  final OrderObject order;

  const OrderTable({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  State<OrderTable> createState() => _OrderTableState();
}

class _OrderTableState extends State<OrderTable> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SimpleTable(
          headers: OrderFormatter.orderHeaders,
          data: OrderFormatter.formatOrder(widget.order),
          expandableIndexes: const [
            OrderFormatter.orderSetAttrIndex,
            OrderFormatter.orderProductIndex,
          ],
        ),
        const TextDivider(label: '訂單顧客設定'),
        SimpleTable(
          headers: OrderFormatter.orderSetAttrHeaders,
          data: OrderFormatter.formatOrderSetAttr(widget.order),
        ),
        const TextDivider(label: '訂單產品細項'),
        SimpleTable(
          headers: OrderFormatter.orderProductHeaders,
          data: OrderFormatter.formatOrderProduct(widget.order),
          expandableIndexes: const [OrderFormatter.orderIngredientIndex],
        ),
        const TextDivider(label: '訂單成份細項'),
        SimpleTable(
          headers: OrderFormatter.orderIngredientHeaders,
          data: OrderFormatter.formatOrderIngredient(widget.order),
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
    Key? key,
    required this.headers,
    required this.data,
    this.expandableIndexes = const [],
  }) : super(key: key);

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
            ? const HintText('詳見下欄')
            : Text(
                cell.toString(),
                textAlign: cell is String ? TextAlign.end : TextAlign.start,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
      );
    }
  }
}
