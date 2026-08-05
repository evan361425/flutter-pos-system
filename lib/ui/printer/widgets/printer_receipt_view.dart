import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:possystem/components/imageable_container.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/receipt_component.dart';
import 'package:possystem/models/repository/receipt_templates.dart';
import 'package:possystem/models/xfile.dart';

class PrinterReceiptView extends StatelessWidget {
  static const defaultTextStyle = TextStyle(
    fontSize: 14,
    fontWeight: .w400,
    color: Color(0xFF424242),
    overflow: .clip,
    height: 16 / 14,
    textBaseline: .alphabetic,
    letterSpacing: 0.25,
  );
  static const smallTextStyle = TextStyle(fontSize: 14, height: 16 / 14);
  static const largeTextStyle = TextStyle(fontSize: 22, height: 28 / 22, letterSpacing: 0);

  final OrderObject order;
  final ImageableController controller;
  final List<ReceiptComponent>? customComponents;

  const PrinterReceiptView({super.key, required this.order, required this.controller, this.customComponents});

  @override
  Widget build(BuildContext context) {
    // Use custom components if provided, otherwise use default from repository
    final components = customComponents ?? ReceiptTemplates.instance.selected.components;

    final children = components
        .map(
          (component) =>
              Padding(padding: component.padding, child: PrinterReceiptView.buildComponent(context, component, order)),
        )
        .whereType<Widget>()
        .toList();

    return SingleChildScrollView(
      scrollDirection: .horizontal,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: .noScaling),
        child: SizedBox(
          // wider width can result low density of receipt, since the paper
          // is fixed width (58mm or 80mm).
          // fixed width can provide same density of receipt
          width: 348, // 320 + 28 (padding)
          child: ImageableContainer(controller: controller, style: defaultTextStyle, children: children),
        ),
      ),
    );
  }

  static Widget? buildComponent(BuildContext context, ReceiptComponent component, OrderObject order) {
    final attributes = order.effectiveAttributes.toList();

    switch (component.type) {
      case .textField:
        final c = component as TextFieldComponent;
        return Text.rich(
          TextSpan(children: c.texts.map((e) => e.buildSpan(order: order)).toList()),
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
        return PrinterReceiptView.buildOrderTable(c, order, context: context);
      case .discountTable:
        if (order.discounted.isNotEmpty) {
          final c = component as DiscountTableComponent;
          return PrinterReceiptView.buildDiscountTable(c, order.discounted.toList());
        }
        return null;
      case .attributeTable:
        if (attributes.isNotEmpty) {
          final c = component as AttributeTableComponent;
          return PrinterReceiptView.buildAttributesTable(c, attributes);
        }
        return null;
      case .priceTable:
        final c = component as PriceTableComponent;
        return PrinterReceiptView.buildPriceTable(c, order, context: context);
    }
  }

  static Widget buildOrderTable(
    OrderTableComponent config,
    OrderObject order, {
    required BuildContext context,
    List<Widget> Function(int index)? actions,
  }) {
    final columnWidths = Map.fromEntries(
      config.columns.mapIndexed((i, e) {
        return MapEntry(i, switch (e.type) {
          .quantity ||
          .singlePrice ||
          .totalPrice => MaxColumnWidth(FixedColumnWidth(e.width ?? e.type.width), const IntrinsicColumnWidth()),
          _ => const FlexColumnWidth(),
        });
      }),
    );
    final headers = config.columns.mapIndexed((i, e) {
      return _CellWithActions(actions: actions?.call(i), child: Text(e.title ?? e.type.title));
    });
    final cellBuilder = config.columns.map<Widget Function(OrderProductObject)>((e) {
      return switch (e.type) {
        .quantity ||
        .singlePrice ||
        .totalPrice => (product) => TableCell(child: Text(e.type.valueFromOrder(product), textAlign: .end)),
        _ => (product) => TableCell(child: Text(e.type.valueFromOrder(product))),
      };
    });

    final color = Theme.of(context).colorScheme;
    return DefaultTextStyle(
      style: defaultTextStyle.merge(const TextStyle(height: 1.8)),
      child: Table(
        defaultVerticalAlignment: .middle,
        columnWidths: columnWidths,
        border: TableBorder(
          horizontalInside: BorderSide(color: color.outlineVariant),
          top: BorderSide(color: color.outline),
          bottom: BorderSide(color: color.outline),
        ),
        children: [
          TableRow(children: headers.toList()),
          for (final product in order.products)
            TableRow(children: cellBuilder.map((generator) => generator(product)).toList()),
        ],
      ),
    );
  }

  static Widget buildDiscountTable(
    DiscountTableComponent config,
    List<OrderProductObject> discounted, {
    List<Widget> Function(int index)? actions,
  }) {
    final columnWidths = Map.fromEntries(
      config.columns.mapIndexed((i, e) {
        return MapEntry(i, switch (e.type) {
          .quantity ||
          .originPrice ||
          .singlePrice ||
          .totalPrice => MaxColumnWidth(FixedColumnWidth(e.width ?? e.type.width), const IntrinsicColumnWidth()),
          _ => const FlexColumnWidth(),
        });
      }),
    );
    final headers = config.columns.mapIndexed((i, e) {
      return _CellWithActions(actions: actions?.call(i), child: Text(e.title ?? e.type.title));
    });
    final cellBuilder = config.columns.map<Widget Function(OrderProductObject)>((e) {
      return switch (e.type) {
        .quantity || .originPrice || .singlePrice || .totalPrice => (product) => TableCell(
          child: Text(e.type.valueFromOrder(product), style: smallTextStyle, textAlign: .end),
        ),
        _ => (product) => TableCell(
          child: Padding(padding: const .only(left: 8), child: Text(e.type.valueFromOrder(product))),
        ),
      };
    });

    return Table(
      defaultVerticalAlignment: .middle,
      columnWidths: columnWidths,
      border: TableBorder.all(width: 0, color: Colors.transparent),
      children: [
        TableRow(children: headers.toList()),
        for (final product in discounted)
          TableRow(children: cellBuilder.map((generator) => generator(product)).toList()),
      ],
    );
  }

  static Widget buildAttributesTable(
    AttributeTableComponent config,
    List<OrderEffectiveAttribute> attributes, {
    List<Widget> Function(int index)? actions,
  }) {
    final columnWidths = Map.fromEntries(
      config.columns.mapIndexed((i, e) {
        return MapEntry(i, switch (e.type) {
          .adjustment => MaxColumnWidth(FixedColumnWidth(e.width ?? e.type.width), const IntrinsicColumnWidth()),
          _ => const FlexColumnWidth(),
        });
      }),
    );
    final headers = config.columns.mapIndexed((i, e) {
      return _CellWithActions(actions: actions?.call(i), child: Text(e.title ?? e.type.title));
    });
    final cellBuilder = config.columns.map<Widget Function(OrderEffectiveAttribute)>((e) {
      return switch (e.type) {
        .adjustment => (attribute) => TableCell(
          child: Text(e.type.valueFromOrder(attribute), style: smallTextStyle, textAlign: .end),
        ),
        _ => (attribute) => TableCell(
          child: Padding(padding: const .only(left: 8), child: Text(e.type.valueFromOrder(attribute))),
        ),
      };
    });

    return Table(
      defaultVerticalAlignment: .middle,
      columnWidths: columnWidths,
      border: TableBorder.all(width: 0, color: Colors.transparent),
      children: [
        TableRow(children: headers.toList()),
        for (final attribute in attributes)
          TableRow(children: cellBuilder.map((generator) => generator(attribute)).toList()),
      ],
    );
  }

  static Widget buildPriceTable(
    PriceTableComponent config,
    OrderObject order, {
    required BuildContext context,
    List<Widget> Function(int index)? actions,
  }) {
    final color = Theme.of(context).colorScheme;
    final titles = config.columns.map((e) => e.title ?? e.type.title).toList();
    final values = config.columns.map((e) => e.type.valueFromOrder(order)).toList();

    return Table(
      defaultVerticalAlignment: .middle,
      columnWidths: const {0: FlexColumnWidth(), 1: IntrinsicColumnWidth()},
      border: TableBorder.all(width: 0, color: Colors.transparent),
      children: [
        TableRow(
          children: [
            _CellWithActions(actions: actions?.call(0), child: Text(titles[0])),
            Text(values[0], style: largeTextStyle),
          ],
        ),
        for (int i = 1; i < titles.length; i++)
          TableRow(
            decoration: i == 1
                ? BoxDecoration(
                    border: Border(top: BorderSide(color: color.outlineVariant)),
                  )
                : null,
            children: [
              _CellWithActions(
                actions: actions?.call(i),
                child: Padding(
                  padding: i == 1 ? const .only(top: 4) : const .only(left: 8),
                  child: Text(titles[i], style: smallTextStyle),
                ),
              ),
              TableCell(
                child: Text(values[i], style: smallTextStyle, textAlign: .end),
              ),
            ],
          ),
      ],
    );
  }
}

class _CellWithActions extends StatelessWidget {
  final List<Widget>? actions;
  final Widget child;

  const _CellWithActions({required this.child, required this.actions});

  @override
  Widget build(BuildContext context) {
    if (actions == null) {
      return TableCell(child: child);
    }

    return TableCell(
      child: SizedBox(
        height: 28,
        child: MenuAnchor(
          builder: (BuildContext context, MenuController controller, Widget? child) {
            return InkWell(
              onTap: () {
                controller.isOpen ? controller.close() : controller.open();
              },
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  child!,
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: 2,
                    child: Icon(Icons.arrow_drop_down, color: Colors.grey[600], size: 16),
                  ),
                ],
              ),
            );
          },
          menuChildren: actions!,
          child: child,
        ),
      ),
    );
  }
}

class ReceiptSawtoothClipper extends CustomClipper<Path> {
  /// Each sawtooth's width
  final double triangleWidth;

  /// Every sawtooth's height
  final double triangleHeight;

  /// Offset below the sawtooth
  final double bottomOffset;

  ReceiptSawtoothClipper({this.triangleWidth = 10.0, this.triangleHeight = 10.0, this.bottomOffset = 0.0});

  @override
  Path getClip(Size size) {
    final path = Path();
    final height = size.height - bottomOffset;

    // 1. from left top corner to left bottom corner
    path.lineTo(0, height - triangleHeight);

    // 2. how many triangles can fit in the width of the container
    final count = (size.width / triangleWidth).floor();
    final actualWidth = size.width / count; // 動態平均分配寬度，確保左右對齊

    // 3. loop
    for (int i = 0; i < count; i++) {
      final startX = i * actualWidth;

      path.lineTo(startX + (actualWidth / 2), height);
      path.lineTo(startX + actualWidth, height - triangleHeight);
    }

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant ReceiptSawtoothClipper oldClipper) {
    return oldClipper.triangleWidth != triangleWidth || oldClipper.triangleHeight != triangleHeight;
  }
}
