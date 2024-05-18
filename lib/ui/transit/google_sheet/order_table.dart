import 'package:flutter/material.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/text_divider.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/translator.dart';

import 'order_formatter.dart';

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
          headers: OrderFormatter.orderHeaders,
          data: OrderFormatter.formatOrder(widget.order),
          expandableIndexes: const [
            OrderFormatter.orderDetailsAttrIndex,
            OrderFormatter.orderDetailsProductIndex,
          ],
        ),
        TextDivider(label: S.transitGSOrderAttributeTitle),
        SimpleTable(
          headers: OrderFormatter.orderDetailsAttrHeaders,
          data: OrderFormatter.formatOrderDetailsAttr(widget.order),
        ),
        TextDivider(label: S.transitGSOrderProductTitle),
        SimpleTable(
          headers: OrderFormatter.orderDetailsProductHeaders,
          data: OrderFormatter.formatOrderDetailsProduct(widget.order),
          expandableIndexes: const [OrderFormatter.orderDetailsIngredientIndex],
        ),
        TextDivider(label: S.transitGSOrderIngredientTitle),
        SimpleTable(
          headers: OrderFormatter.orderDetailsIngredientHeaders,
          data: OrderFormatter.formatOrderDetailsIngredient(widget.order),
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
