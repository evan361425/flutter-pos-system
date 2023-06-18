import 'package:flutter/material.dart';
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
  bool showSetAttr = false;
  bool showProduct = false;
  bool showIngredient = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SimpleTable(
          headers: OrderFormatter.orderHeaders,
          data: [OrderFormatter.formatOrder(widget.order)],
          expandableCallbacks: {
            OrderFormatter.orderSetAttrIndex: showSetAttr
                ? null
                : () => setState(() {
                      showSetAttr = true;
                    }),
            OrderFormatter.orderProductIndex: showProduct
                ? null
                : () => setState(() {
                      showProduct = true;
                    }),
          },
        ),
        if (showSetAttr) const TextDivider(label: '訂單顧客設定'),
        if (showSetAttr)
          SimpleTable(
            headers: OrderFormatter.orderSetAttrHeaders,
            data: OrderFormatter.formatOrderSetAttr(widget.order),
          ),
        if (showProduct) const TextDivider(label: '訂單產品細項'),
        if (showProduct)
          SimpleTable(
            headers: OrderFormatter.orderProductHeaders,
            data: OrderFormatter.formatOrderProduct(widget.order),
            expandableCallbacks: {
              OrderFormatter.orderIngredientIndex: showIngredient
                  ? null
                  : () => setState(() {
                        showIngredient = true;
                      }),
            },
          ),
        if (showIngredient) const TextDivider(label: '訂單成份細項'),
        if (showIngredient)
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

  final Map<int, void Function()?> expandableCallbacks;

  const SimpleTable({
    Key? key,
    required this.headers,
    required this.data,
    this.expandableCallbacks = const {},
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
      final hasCallback = expandableCallbacks.containsKey(index++);
      yield Padding(
        padding: const EdgeInsets.all(4.0),
        child: hasCallback
            ? OutlinedButton(
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  padding: const MaterialStatePropertyAll(
                    EdgeInsets.all(2.0),
                  ),
                  shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  )),
                ),
                onPressed: expandableCallbacks[index - 1],
                child: const Text('展開'),
              )
            : Text(
                cell.toString(),
                textAlign: cell is String ? TextAlign.end : TextAlign.start,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
      );
    }
  }
}
