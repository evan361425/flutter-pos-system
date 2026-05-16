import 'package:flutter/material.dart';
import 'package:possystem/components/imageable_container.dart';
import 'package:possystem/components/models/order_attribute_value_widget.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/receipt_component.dart';
import 'package:possystem/models/repository/receipt_templates.dart';
import 'package:possystem/models/xfile.dart';
import 'package:possystem/translator.dart';

const _defaultTextColor = Color(0xFF424242);

class PrinterReceiptView extends StatelessWidget {
  final OrderObject order;
  final ImageableController controller;
  final List<ReceiptComponent>? customComponents;

  const PrinterReceiptView({super.key, required this.order, required this.controller, this.customComponents});

  @override
  Widget build(BuildContext context) {
    // Use custom components if provided, otherwise use default from repository
    final components = customComponents ?? ReceiptTemplates.instance.selected.components;

    final children = components
        .map((component) => Padding(padding: component.padding, child: _buildComponent(component, context)))
        .whereType<Widget>()
        .toList();

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: .noScaling),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 400),
        // wider width can result low density of receipt, since the paper
        // is fixed width (58mm or 80mm).
        width: 320, // fixed width can provide same density of receipt
        child: DefaultTextStyle(
          style: Theme.of(
            context,
          ).textTheme.bodyMedium!.copyWith(height: 1.8, overflow: .clip, color: _defaultTextColor),
          child: ImageableContainer(controller: controller, children: children),
        ),
      ),
    );
  }

  Widget? _buildComponent(ReceiptComponent component, BuildContext context) {
    final theme = Theme.of(context);
    final discounted = order.products.where((e) => e.isDiscount).toList();
    final attributes = order.attributes
        .where((e) => e.modeValue != null)
        .map((e) => [e.name, e.optionName, OrderAttributeValueWidget.string(e.mode, e.modeValue!)])
        .toList();

    switch (component.type) {
      case .textField:
        final c = component as TextFieldComponent;
        return RichText(
          text: TextSpan(children: c.texts.map((e) => e.buildSpan(order: order)).toList()),
          textAlign: c.textAlign,
        );
      case .divider:
        final c = component as DividerComponent;
        return Divider(height: c.height);
      case .image:
        final c = component as ImageComponent;
        return AspectRatio(
          aspectRatio: c.widthRatio,
          child: Image(
            fit: .cover,
            errorBuilder: (context, error, stackTrace) {
              Log.out('reading image failed', 'image_error', error: error, stackTrace: stackTrace);
              return Container(
                color: Colors.grey[200],
                alignment: Alignment.center,
                child: Icon(Icons.broken_image_outlined, color: Colors.grey[500], size: 40),
              );
            },
            image: FileImage(XFile(c.imagePath).file),
          ),
        );
      case .orderTable:
        final c = component as OrderTableComponent;
        return _buildOrderTable(c, theme.colorScheme);
      case .discountTable:
        if (discounted.isNotEmpty) {
          final c = component as DiscountTableComponent;
          return _buildDiscountTable(c, discounted);
        }
        return null;
      case .attributeTable:
        if (attributes.isNotEmpty) {
          final c = component as AttributeTableComponent;
          return _buildAttributesTable(c, attributes);
        }
        return null;
      case .priceTable:
        final c = component as PriceTableComponent;
        return _buildPriceTable(c);
    }
  }

  String _getProductName(OrderProductObject product, {bool showProductName = false, bool showCatalogName = false}) {
    if (!showProductName) {
      return product.catalogName;
    }

    if (!showCatalogName) {
      return product.productName;
    }

    return '${product.productName}(${product.catalogName})';
  }

  Widget _buildOrderTable(OrderTableComponent config, ColorScheme color) {
    final columns = <int, TableColumnWidth>{};
    final headers = <Widget>[];
    int colIndex = 0;

    if (config.showProductName || config.showCatalogName) {
      columns[colIndex++] = const FlexColumnWidth();
      headers.add(TableCell(child: Text(S.printerReceiptProductTableName)));
    }
    if (config.showQuantity) {
      columns[colIndex++] = const MaxColumnWidth(FractionColumnWidth(0.1), IntrinsicColumnWidth());
      headers.add(TableCell(child: Text(S.printerReceiptProductTableCount, textAlign: .end)));
    }
    if (config.showSinglePrice) {
      columns[colIndex++] = const MaxColumnWidth(FractionColumnWidth(0.1), IntrinsicColumnWidth());
      headers.add(TableCell(child: Text(S.printerReceiptProductTablePrice, textAlign: .end)));
    }
    if (config.showTotalPrice) {
      columns[colIndex++] = const MaxColumnWidth(FractionColumnWidth(0.2), IntrinsicColumnWidth());
      headers.add(TableCell(child: Text(S.printerReceiptProductTableTotal, textAlign: .end)));
    }

    return Table(
      defaultVerticalAlignment: .middle,
      columnWidths: columns,
      border: TableBorder(
        horizontalInside: BorderSide(color: color.outlineVariant),
        top: BorderSide(color: color.outline),
        bottom: BorderSide(color: color.outline),
      ),
      children: [
        TableRow(children: headers),
        for (final product in order.products)
          TableRow(
            children: [
              if (config.showProductName || config.showCatalogName)
                TableCell(
                  child: Text(
                    _getProductName(
                      product,
                      showProductName: config.showProductName,
                      showCatalogName: config.showCatalogName,
                    ),
                  ),
                ),
              if (config.showQuantity) TableCell(child: Text(product.count.toString(), textAlign: .end)),
              if (config.showSinglePrice)
                TableCell(child: Text('\$${product.singlePrice.toCurrency()}', textAlign: .end)),
              if (config.showTotalPrice)
                TableCell(child: Text('\$${product.totalPrice.toCurrency()}', textAlign: .end)),
            ],
          ),
      ],
    );
  }

  Widget _buildDiscountTable(DiscountTableComponent config, List<OrderProductObject> discounted) {
    final columns = <int, TableColumnWidth>{0: const FlexColumnWidth()};
    final headers = <Widget>[TableCell(child: Text(S.printerReceiptDiscountTableTitle))];
    int colIndex = 1;
    const numberStyle = TextStyle(fontSize: 12);

    if (config.showQuantity) {
      columns[colIndex++] = const MaxColumnWidth(FractionColumnWidth(0.1), IntrinsicColumnWidth());
      headers.add(TableCell(child: Text(S.printerReceiptDiscountTableCount)));
    }
    if (config.showTotalPrice) {
      columns[colIndex++] = const MaxColumnWidth(FractionColumnWidth(0.2), IntrinsicColumnWidth());
      headers.add(TableCell(child: Text(S.printerReceiptDiscountTableTotal)));
    }
    if (config.showSinglePrice) {
      columns[colIndex++] = const MaxColumnWidth(FractionColumnWidth(0.1), IntrinsicColumnWidth());
      headers.add(TableCell(child: Text(S.printerReceiptDiscountTablePrice)));
    }
    if (config.showOriginPrice) {
      columns[colIndex++] = const MaxColumnWidth(FractionColumnWidth(0.2), IntrinsicColumnWidth());
      headers.add(TableCell(child: Text(S.printerReceiptDiscountTablePrice)));
    }

    return Table(
      defaultVerticalAlignment: .middle,
      columnWidths: columns,
      border: TableBorder.all(width: 0, color: Colors.transparent),
      children: [
        TableRow(children: headers),
        for (final product in discounted)
          TableRow(
            children: [
              if (config.showProductName || config.showCatalogName)
                TableCell(
                  child: Padding(
                    padding: const .only(left: 8),
                    child: Text(
                      _getProductName(
                        product,
                        showProductName: config.showProductName,
                        showCatalogName: config.showCatalogName,
                      ),
                    ),
                  ),
                ),
              if (config.showQuantity)
                TableCell(
                  child: Text(product.count.toString(), style: numberStyle, textAlign: .end),
                ),
              if (config.showTotalPrice)
                TableCell(
                  child: Text('\$${product.totalPrice.toCurrency()}', style: numberStyle, textAlign: .end),
                ),
              if (config.showSinglePrice)
                TableCell(
                  child: Text('\$${product.singlePrice.toCurrency()}', style: numberStyle, textAlign: .end),
                ),
              if (config.showOriginPrice)
                TableCell(
                  child: Text('\$${product.originalPrice.toCurrency()}', style: numberStyle, textAlign: .end),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildAttributesTable(AttributeTableComponent config, List<List<String>> attributes) {
    final columns = <int, TableColumnWidth>{0: const FlexColumnWidth()};
    final headers = <Widget>[TableCell(child: Text(S.printerReceiptAttributeTableTitle))];
    int colIndex = 1;
    const numberStyle = TextStyle(fontSize: 12);

    if (config.showAdjustment) {
      columns[colIndex++] = const MaxColumnWidth(FractionColumnWidth(0.2), IntrinsicColumnWidth());
      headers.add(TableCell(child: Text(S.printerReceiptAttributeTableAdjustment)));
    }

    return Table(
      defaultVerticalAlignment: .middle,
      columnWidths: columns,
      border: TableBorder.all(width: 0, color: Colors.transparent),
      children: [
        TableRow(children: headers),
        for (final attribute in attributes)
          TableRow(
            children: [
              TableCell(
                child: Padding(
                  padding: const .only(left: 8),
                  child: Text(
                    [config.showName ? attribute[0] : '', config.showOptionName ? attribute[1] : ''].join(' '),
                  ),
                ),
              ),
              if (config.showAdjustment)
                TableCell(
                  child: Text(attribute[2], style: numberStyle, textAlign: .end),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildPriceTable(PriceTableComponent config) {
    const subtitle = TextStyle(fontSize: 12);
    final subtitles = <List<String>>[
      if (config.showPrice) [S.printerReceiptPriceTablePrice, '\$${order.price.toCurrency()}'],
      if (config.showChange) [S.printerReceiptPriceTableChange, '\$${order.change.toCurrency()}'],
      if (config.showProductsPrice) [S.printerReceiptPriceTableProductsPrice, '\$${order.productsPrice.toCurrency()}'],
      if (config.showProductsQuantity) [S.printerReceiptPriceTableProductsQuantity, order.productsCount.toString()],
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            Text(S.printerReceiptPriceTableTotal),
            Text('\$${order.price.toCurrency()}', style: const TextStyle(fontSize: 22)),
          ],
        ),
        if (subtitles.isNotEmpty || config.showPaid) ...[
          const Divider(height: 4),
          if (config.showPaid)
            Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Text(S.printerReceiptPriceTablePaid, style: subtitle),
                Text('\$${order.paid.toCurrency()}', style: subtitle),
              ],
            ),
          if (subtitles.isNotEmpty)
            Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Padding(
                  padding: const .only(left: 8),
                  child: Column(
                    mainAxisSize: .min,
                    crossAxisAlignment: .start,
                    children: subtitles.map((e) => Text(e[0], style: subtitle)).toList(),
                  ),
                ),
                Column(
                  mainAxisSize: .min,
                  crossAxisAlignment: .end,
                  children: subtitles.map((e) => Text(e[1], style: subtitle)).toList(),
                ),
              ],
            ),
        ],
      ],
    );
  }
}

// Keep the old hardcoded version for backwards compatibility
// class _OldPrinterReceiptView extends StatelessWidget {
//   final OrderObject order;
//   final ImageableController controller;

//   const _OldPrinterReceiptView({
//     required this.order,
//     required this.controller,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context).textTheme;
//     final color = Theme.of(context).colorScheme;
//     final discounted = order.products.where((e) => e.isDiscount);
//     final attributes = order.attributes
//         .where((e) => e.modeValue != null)
//         .map((e) => [e.optionName, OrderAttributeValueWidget.string(e.mode, e.modeValue!)])
//         .toList();
//     const text = Color(0xFF424242);

//     final children = [
//       Text(
//         S.printerReceiptTitle,
//         style: theme.headlineMedium?.copyWith(height: 1, color: text), // 28
//         textAlign: .center,
//       ),
//       const SizedBox(height: 4),
//       Text(DateFormat.yMMMd().addPattern(' ').add_Hms().format(order.createdAt), textAlign: .center),
//       const SizedBox(height: 4),
//       DefaultTextStyle(
//         style: theme.bodyMedium!.copyWith(height: 1.8, overflow: .clip, color: text),
//         child: Table(
//           defaultVerticalAlignment: .middle,
//           columnWidths: const {
//             0: FlexColumnWidth(),
//             1: MaxColumnWidth(FractionColumnWidth(0.1), IntrinsicColumnWidth()),
//             2: MaxColumnWidth(FractionColumnWidth(0.1), IntrinsicColumnWidth()),
//             3: MaxColumnWidth(FractionColumnWidth(0.2), IntrinsicColumnWidth()),
//           },
//           border: TableBorder(
//             horizontalInside: BorderSide(color: color.outlineVariant),
//             top: BorderSide(color: color.outline),
//             bottom: BorderSide(color: color.outline),
//           ),
//           children: [
//             TableRow(
//               children: [
//                 TableCell(child: Text(S.printerReceiptColumnName)),
//                 TableCell(child: Text(S.printerReceiptColumnCount, textAlign: .end)),
//                 TableCell(child: Text(S.printerReceiptColumnPrice, textAlign: .end)),
//                 TableCell(child: Text(S.printerReceiptColumnTotal, textAlign: .end)),
//               ],
//             ),
//             for (final product in order.products)
//               TableRow(
//                 children: [
//                   TableCell(child: Text(product.productName)),
//                   TableCell(child: Text(product.count.toString(), textAlign: .end)),
//                   TableCell(child: Text('\$${product.singlePrice.toCurrency()}', textAlign: .end)),
//                   TableCell(child: Text('\$${product.totalPrice.toCurrency()}', textAlign: .end)),
//                 ],
//               ),
//           ],
//         ),
//       ),
//       const SizedBox(height: 4),
//       Table(
//         defaultVerticalAlignment: .middle,
//         columnWidths: const {0: FlexColumnWidth(), 1: MaxColumnWidth(FractionColumnWidth(0.2), IntrinsicColumnWidth())},
//         border: TableBorder.all(width: 0, color: Colors.transparent),
//         children: [
//           if (discounted.isNotEmpty) ...[
//             TableRow(
//               children: [
//                 TableCell(child: Text(S.printerReceiptDiscountLabel)),
//                 TableCell(child: Text(S.printerReceiptDiscountOrigin)),
//               ],
//             ),
//             for (final product in discounted)
//               TableRow(
//                 children: [
//                   TableCell(
//                     child: Padding(padding: const .only(left: 8), child: Text(product.productName)),
//                   ),
//                 ),
//                 TableCell(
//                   child: Text(
//                     '\$${product.originalPrice.toCurrency()}',
//                     style: theme.labelMedium?.copyWith(color: text), // 12
//                     textAlign: .end,
//                   ),
//                 ],
//               ),
//             // add some padding
//             if (attributes.isNotEmpty)
//               const TableRow(
//                 children: [
//                   TableCell(child: SizedBox(height: 4.0)),
//                   TableCell(child: SizedBox(height: 4.0)),
//                 ],
//               ),
//           ],
//           if (attributes.isNotEmpty) ...[
//             TableRow(children: [
//               TableCell(child: Text(S.printerReceiptAddOnsLabel)),
//               TableCell(child: Text(S.printerReceiptAddOnsAdjustment)),
//             ]),
//             for (final attr in attributes)
//               TableRow(children: [
//                 TableCell(
//                   child: Padding(
//                     padding: const EdgeInsets.only(left: 8),
//                     child: Text(attr[0]),
//                   ),
//                 ),
//                 TableCell(
//                   child: Text(
//                     attr[1],
//                     style: theme.labelMedium?.copyWith(color: text), // 12
//                     textAlign: TextAlign.end,
//                   ),
//                 ),
//               ]),
//           ],
//           TableRow(children: [
//             TableCell(child: Text(S.printerReceiptTotal)),
//             TableCell(
//               child: Text(
//                 '\$${order.price.toCurrency()}',
//                 style: theme.titleLarge?.copyWith(color: text), // 22
//               ),
//             ),
//             for (final attr in attributes)
//               TableRow(
//                 children: [
//                   TableCell(
//                     child: Padding(padding: const .only(left: 8), child: Text(attr[0])),
//                   ),
//                   TableCell(
//                     child: Text(
//                       attr[1],
//                       style: theme.labelMedium?.copyWith(color: text),
//                       textAlign: .end,
//                     ),
//                   ),
//                 ],
//               ),
//           ],
//           TableRow(
//             children: [
//               TableCell(child: Text(S.printerReceiptTotal)),
//               TableCell(
//                 child: Text('\$${order.price.toCurrency()}', style: theme.titleLarge?.copyWith(color: text)),
//               ),
//             ],
//           ),
//         ],
//       ),
//       const Divider(height: 4),
//       Row(
//         mainAxisAlignment: .spaceBetween,
//         children: [
//           DefaultTextStyle(
//             style: theme.bodyMedium!.copyWith(fontSize: theme.labelMedium!.fontSize, color: text), // 14
//             child: Column(
//               mainAxisSize: .min,
//               crossAxisAlignment: .start,
//               children: [
//                 Text(S.printerReceiptPaid),
//                 Padding(
//                   padding: const .only(left: 8),
//                   child: Column(
//                     crossAxisAlignment: .start,
//                     children: [Text(S.printerReceiptPrice), Text(S.printerReceiptChange)],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           DefaultTextStyle(
//             style: theme.labelMedium!.copyWith(color: text), // 12
//             child: Column(
//               mainAxisSize: .min,
//               crossAxisAlignment: .end,
//               children: [
//                 Text('\$${order.paid.toCurrency()}'),
//                 Text('\$${order.price.toCurrency()}'),
//                 Text('\$${order.change.toCurrency()}'),
//               ],
//             ),
//           ),
//         ],
//       ),
//     ];

//     return MediaQuery(
//       data: MediaQuery.of(context).copyWith(textScaler: .noScaling),
//       child: Container(
//         constraints: const BoxConstraints(maxHeight: 400),
//         // wider width can result low density of receipt, since the paper
//         // is fixed width (58mm or 80mm).
//         width: 320, // fixed width can provide same density of receipt
//         child: ImageableContainer(controller: controller, children: children),
//       ),
//     );
//   }
// }
