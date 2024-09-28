import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:possystem/components/imageable_container.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/settings/currency_setting.dart';

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
    const text = Color(0xFF424242);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 400),
      child: ImageableContainer(controller: controller, children: [
        Text(
          '交易明細',
          style: theme.headlineMedium?.copyWith(height: 1, color: text),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          Text(DateFormat('yyyy MMM dd - HH:mm:ss').format(order.createdAt)),
        ]),
        const SizedBox(height: 4),
        DefaultTextStyle(
          style: theme.bodyMedium!.copyWith(height: 1.8, overflow: TextOverflow.ellipsis, color: text),
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
              const TableRow(children: [
                TableCell(child: Text('品項')),
                TableCell(child: Text('數量', textAlign: TextAlign.end)),
                TableCell(child: Text('單價', textAlign: TextAlign.end)),
                TableCell(child: Text('小計', textAlign: TextAlign.end)),
              ]),
              for (final product in order.products)
                TableRow(children: [
                  TableCell(child: Text(product.productName)),
                  TableCell(child: Text(product.count.toString(), textAlign: TextAlign.end)),
                  TableCell(child: Text(product.singlePrice.toCurrency(), textAlign: TextAlign.end)),
                  TableCell(child: Text('\$${product.totalPrice}', textAlign: TextAlign.end)),
                ]),
            ],
          ),
        ),
        const SizedBox(height: 4),
        if (discounted.isNotEmpty)
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('折扣'),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Column(children: [
                  for (final product in discounted) Text(product.productName),
                ]),
              ),
            ]),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('原單價'),
                for (final product in discounted)
                  Text('\$${product.originalPrice.toCurrency()}', style: theme.labelMedium?.copyWith(color: text)),
              ],
            ),
          ]),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          const Text('總價'),
          const SizedBox(width: 4),
          Text(
            '\$${order.price.toCurrency()}',
            style: theme.titleLarge?.copyWith(color: text),
          ),
        ]),
        const Divider(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          DefaultTextStyle(
            style: theme.bodyMedium!.copyWith(fontSize: theme.labelMedium!.fontSize, color: text),
            child: const Column(mainAxisSize: MainAxisSize.min, children: [
              Text('付額'),
              Padding(
                padding: EdgeInsets.only(left: 16),
                child: Column(children: [
                  Text('總價'),
                  Text('找錢'),
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
      ]),
    );
  }
}
