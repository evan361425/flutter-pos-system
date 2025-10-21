import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:possystem/components/imageable_container.dart';
import 'package:possystem/components/models/order_attribute_value_widget.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/receipt_component.dart';
import 'package:possystem/settings/receipt_setting.dart';
import 'package:possystem/translator.dart';

class PrinterReceiptView extends StatelessWidget {
  final OrderObject order;
  final ImageableController controller;
  final List<ReceiptComponent>? customComponents;

  const PrinterReceiptView({
    super.key,
    required this.order,
    required this.controller,
    this.customComponents,
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

    // Use custom components if provided, otherwise use default settings
    final components = customComponents ?? ReceiptSetting.instance.value;

    final children = components.map((component) {
      return _buildComponent(component, theme, color, text, discounted, attributes);
    }).toList();

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

  Widget _buildComponent(
    ReceiptComponent component,
    TextTheme theme,
    ColorScheme color,
    Color text,
    Iterable<dynamic> discounted,
    List<List<String>> attributes,
  ) {
    switch (component.type) {
      case ReceiptComponentType.textField:
        final c = component as TextFieldComponent;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            c.text,
            style: theme.bodyMedium?.copyWith(fontSize: c.fontSize, color: text),
            textAlign: c.textAlign,
          ),
        );
      case ReceiptComponentType.orderTimestamp:
        final c = component as OrderTimestampComponent;
        DateFormat format;
        try {
          // Parse custom format
          final parts = c.dateFormat.split(' ');
          format = DateFormat.yMMMd();
          for (final part in parts) {
            if (part == 'Hms') {
              format.addPattern(' ').add_Hms();
            }
          }
        } catch (e) {
          format = DateFormat.yMMMd().addPattern(' ').add_Hms();
        }
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            format.format(order.createdAt),
            textAlign: TextAlign.center,
            style: theme.bodyMedium?.copyWith(color: text),
          ),
        );
      case ReceiptComponentType.orderId:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            'Order ID: ${order.id}',
            style: theme.bodyMedium?.copyWith(color: text),
          ),
        );
      case ReceiptComponentType.divider:
        final c = component as DividerComponent;
        return SizedBox(height: c.height);
      case ReceiptComponentType.orderTable:
        final c = component as OrderTableComponent;
        return _buildOrderTable(c, theme, color, text);
      case ReceiptComponentType.totalSection:
        final c = component as TotalSectionComponent;
        return _buildTotalSection(c, theme, text, discounted, attributes);
      case ReceiptComponentType.paymentSection:
        return _buildPaymentSection(theme, text);
    }
  }

  Widget _buildOrderTable(OrderTableComponent config, TextTheme theme, ColorScheme color, Color text) {
    final columns = <int, TableColumnWidth>{};
    int colIndex = 0;

    if (config.showProductName || config.showCatalogName) {
      columns[colIndex++] = const FlexColumnWidth();
    }
    if (config.showCount) {
      columns[colIndex++] = const MaxColumnWidth(FractionColumnWidth(0.1), IntrinsicColumnWidth());
    }
    if (config.showPrice) {
      columns[colIndex++] = const MaxColumnWidth(FractionColumnWidth(0.1), IntrinsicColumnWidth());
    }
    if (config.showTotal) {
      columns[colIndex++] = const MaxColumnWidth(FractionColumnWidth(0.2), IntrinsicColumnWidth());
    }

    return DefaultTextStyle(
      style: theme.bodyMedium!.copyWith(height: 1.8, overflow: TextOverflow.clip, color: text),
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: columns,
        border: TableBorder(
          horizontalInside: BorderSide(color: color.outlineVariant),
          top: BorderSide(color: color.outline),
          bottom: BorderSide(color: color.outline),
        ),
        children: [
          TableRow(
            children: [
              if (config.showProductName || config.showCatalogName)
                TableCell(child: Text(S.printerReceiptColumnName)),
              if (config.showCount) TableCell(child: Text(S.printerReceiptColumnCount, textAlign: TextAlign.end)),
              if (config.showPrice) TableCell(child: Text(S.printerReceiptColumnPrice, textAlign: TextAlign.end)),
              if (config.showTotal) TableCell(child: Text(S.printerReceiptColumnTotal, textAlign: TextAlign.end)),
            ],
          ),
          for (final product in order.products)
            TableRow(
              children: [
                if (config.showProductName || config.showCatalogName)
                  TableCell(
                    child: Text(config.showCatalogName ? product.catalogName : product.productName),
                  ),
                if (config.showCount) TableCell(child: Text(product.count.toString(), textAlign: TextAlign.end)),
                if (config.showPrice)
                  TableCell(child: Text('\$${product.singlePrice.toCurrency()}', textAlign: TextAlign.end)),
                if (config.showTotal)
                  TableCell(child: Text('\$${product.totalPrice.toCurrency()}', textAlign: TextAlign.end)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTotalSection(
    TotalSectionComponent config,
    TextTheme theme,
    Color text,
    Iterable<dynamic> discounted,
    List<List<String>> attributes,
  ) {
    final children = <TableRow>[];

    if (config.showDiscounts && discounted.isNotEmpty) {
      children.add(
        TableRow(children: [
          TableCell(child: Text(S.printerReceiptDiscountLabel)),
          TableCell(child: Text(S.printerReceiptDiscountOrigin)),
        ]),
      );
      for (final product in discounted) {
        children.add(
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
        );
      }
      if (config.showAddOns && attributes.isNotEmpty) {
        children.add(
          const TableRow(children: [
            TableCell(child: SizedBox(height: 4.0)),
            TableCell(child: SizedBox(height: 4.0)),
          ]),
        );
      }
    }

    if (config.showAddOns && attributes.isNotEmpty) {
      children.add(
        TableRow(children: [
          TableCell(child: Text(S.printerReceiptAddOnsLabel)),
          TableCell(child: Text(S.printerReceiptAddOnsAdjustment)),
        ]),
      );
      for (final attr in attributes) {
        children.add(
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
        );
      }
    }

    children.add(
      TableRow(children: [
        TableCell(child: Text(S.printerReceiptTotal)),
        TableCell(
          child: Text(
            '\$${order.price.toCurrency()}',
            style: theme.titleLarge?.copyWith(color: text),
          ),
        ),
      ]),
    );

    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: const {
        0: FlexColumnWidth(),
        1: MaxColumnWidth(FractionColumnWidth(0.2), IntrinsicColumnWidth()),
      },
      border: TableBorder.all(width: 0, color: Colors.transparent),
      children: children,
    );
  }

  Widget _buildPaymentSection(TextTheme theme, Color text) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
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
    ]);
  }
}

// Keep the old hardcoded version for backwards compatibility
class _OldPrinterReceiptView extends StatelessWidget {
  final OrderObject order;
  final ImageableController controller;

  const _OldPrinterReceiptView({
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
      Text(DateFormat.yMMMd().addPattern(' ').add_Hms().format(order.createdAt), textAlign: TextAlign.center),
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
