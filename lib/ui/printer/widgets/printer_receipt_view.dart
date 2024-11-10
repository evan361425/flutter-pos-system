import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:possystem/components/imageable_container.dart';
import 'package:possystem/components/models/order_attribute_value_widget.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/translator.dart';

class PrinterReceiptView extends StatelessWidget {
  final OrderObject order;
  final ImageableController controller;

  const PrinterReceiptView({
    super.key,
    required this.order,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final color = Theme.of(context).colorScheme;
    final discounted = order.products.where((e) => e.isDiscount);
    final attributes = order.attributes
        .where((e) => e.modeValue != null)
        .map((e) => [
              e.optionName,
              OrderAttributeValueWidget.string(e.mode, e.modeValue!),
            ])
        .toList();
    const text = Color(0xFF424242);

    final children = [
      Text(
        S.printerReceiptTitle,
        style: theme.headlineMedium?.copyWith(height: 1, color: text),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 4),
      Text(DateFormat('yyyy MMM dd - HH:mm:ss').format(order.createdAt), textAlign: TextAlign.center),
      const SizedBox(height: 4),
      DefaultTextStyle(
        style: theme.bodyMedium!.copyWith(height: 1.8, overflow: TextOverflow.clip, color: text),
        child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: const {
            0: FlexColumnWidth(),
            1: MaxColumnWidth(FractionColumnWidth(0.1), IntrinsicColumnWidth()),
            2: MaxColumnWidth(FractionColumnWidth(0.1), IntrinsicColumnWidth()),
            3: MaxColumnWidth(FractionColumnWidth(0.2), IntrinsicColumnWidth()),
          },
          border: TableBorder(
            horizontalInside: BorderSide(color: color.outlineVariant),
            top: BorderSide(color: color.outline),
            bottom: BorderSide(color: color.outline),
          ),
          children: [
            TableRow(children: [
              TableCell(child: Text(S.printerReceiptColumnName)),
              TableCell(child: Text(S.printerReceiptColumnCount, textAlign: TextAlign.end)),
              TableCell(child: Text(S.printerReceiptColumnPrice, textAlign: TextAlign.end)),
              TableCell(child: Text(S.printerReceiptColumnTotal, textAlign: TextAlign.end)),
            ]),
            for (final product in order.products)
              TableRow(children: [
                TableCell(child: Text(product.productName)),
                TableCell(child: Text(product.count.toString(), textAlign: TextAlign.end)),
                TableCell(child: Text('\$${product.singlePrice.toCurrency()}', textAlign: TextAlign.end)),
                TableCell(child: Text('\$${product.totalPrice.toCurrency()}', textAlign: TextAlign.end)),
              ]),
          ],
        ),
      ),
      const SizedBox(height: 4),
      Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: const {
          0: FlexColumnWidth(),
          1: MaxColumnWidth(FractionColumnWidth(0.2), IntrinsicColumnWidth()),
        },
        border: TableBorder.all(width: 0, color: Colors.transparent),
        children: [
          if (discounted.isNotEmpty) ...[
            TableRow(children: [
              TableCell(child: Text(S.printerReceiptDiscountLabel)),
              TableCell(child: Text(S.printerReceiptDiscountOrigin)),
            ]),
            for (final product in discounted)
              TableRow(children: [
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(product.productName),
                  ),
                ),
                TableCell(
                  child: Text(
                    '\$${product.originalPrice.toCurrency()}',
                    style: theme.labelMedium?.copyWith(color: text),
                    textAlign: TextAlign.end,
                  ),
                ),
              ]),
            // add some padding
            if (attributes.isNotEmpty)
              const TableRow(children: [
                TableCell(child: SizedBox(height: 4.0)),
                TableCell(child: SizedBox(height: 4.0)),
              ]),
          ],
          if (attributes.isNotEmpty) ...[
            TableRow(children: [
              TableCell(child: Text(S.printerReceiptAddOnsLabel)),
              TableCell(child: Text(S.printerReceiptAddOnsAdjustment)),
            ]),
            for (final attr in attributes)
              TableRow(children: [
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(attr[0]),
                  ),
                ),
                TableCell(
                  child: Text(
                    attr[1],
                    style: theme.labelMedium?.copyWith(color: text),
                    textAlign: TextAlign.end,
                  ),
                ),
              ]),
          ],
          TableRow(children: [
            TableCell(child: Text(S.printerReceiptTotal)),
            TableCell(
              child: Text(
                '\$${order.price.toCurrency()}',
                style: theme.titleLarge?.copyWith(color: text),
              ),
            ),
          ]),
        ],
      ),
      const Divider(height: 4),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        DefaultTextStyle(
          style: theme.bodyMedium!.copyWith(fontSize: theme.labelMedium!.fontSize, color: text),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(S.printerReceiptPaid),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(S.printerReceiptPrice),
                Text(S.printerReceiptChange),
              ]),
            ),
          ]),
        ),
        DefaultTextStyle(
          style: theme.labelMedium!.copyWith(color: text),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('\$${order.paid.toCurrency()}'),
              Text('\$${order.price.toCurrency()}'),
              Text('\$${order.change.toCurrency()}'),
            ],
          ),
        ),
      ]),
    ];

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 400),
        // wider width can result low density of receipt, since the paper
        // is fixed width (58mm or 80mm).
        width: 320, // fixed width can provide same density of receipt
        child: ImageableContainer(controller: controller, children: children),
      ),
    );
  }
}
