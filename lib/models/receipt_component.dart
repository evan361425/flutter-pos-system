import 'package:collection/collection.dart';
import 'package:editor_ant/editor_ant.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/translator.dart';

enum ReceiptComponentType { orderTable, discountTable, attributeTable, priceTable, textField, image, divider }

enum OrderTableColumn {
  productName(0),
  productNameWithCatalogName(0),
  quantity(60),
  singlePrice(60),
  totalPrice(80);

  static Iterable<OrderTableColumn> get isNotSelectable => [.productName, .productNameWithCatalogName];

  final double width;

  const OrderTableColumn(this.width);

  String get title => switch (this) {
    .quantity => S.printerReceiptTableOrderQuantity,
    .singlePrice => S.printerReceiptTableOrderSinglePrice,
    .totalPrice => S.printerReceiptTableOrderTotalPrice,
    _ => S.printerReceiptTableOrderName,
  };

  String valueFromOrder(OrderProductObject order) => switch (this) {
    .quantity => order.count.toString(),
    .singlePrice => '\$${order.singlePrice.toCurrency()}',
    .totalPrice => '\$${order.totalPrice.toCurrency()}',
    _ => _namer(order.productName, order.catalogName, name.contains('WithCatalogName')),
  };
}

enum DiscountTableColumn {
  productName(0),
  productNameWithCatalogName(0),
  quantity(60),
  originPrice(80),
  singlePrice(80),
  totalPrice(80);

  static Iterable<DiscountTableColumn> get isNotSelectable => [.productName, .productNameWithCatalogName];

  final double width;

  const DiscountTableColumn(this.width);

  String get title => switch (this) {
    .quantity => S.printerReceiptTableDiscountQuantity,
    .originPrice => S.printerReceiptTableDiscountOriginPrice,
    .singlePrice => S.printerReceiptTableDiscountSinglePrice,
    .totalPrice => S.printerReceiptTableDiscountTotalPrice,
    _ => S.printerReceiptTableDiscountTitle,
  };

  String valueFromOrder(OrderProductObject order) => switch (this) {
    .quantity => order.count.toString(),
    .originPrice => '\$${order.originalPrice.toCurrency()}',
    .singlePrice => '\$${order.singlePrice.toCurrency()}',
    .totalPrice => '\$${order.totalPrice.toCurrency()}',
    _ => _namer(order.productName, order.catalogName, name.contains('WithCatalogName')),
  };
}

enum AttributeTableColumn {
  optionName(0),
  attrName(0),
  optionNameWithAttrName(0),
  adjustment(80);

  static Iterable<AttributeTableColumn> get isNotSelectable => [.optionName, .attrName, .optionNameWithAttrName];

  final double width;

  const AttributeTableColumn(this.width);

  String get title => switch (this) {
    .adjustment => S.printerReceiptTableAttributeAdjustment,
    _ => S.printerReceiptTableAttributeTitle,
  };

  String valueFromOrder(OrderEffectiveAttribute attribute) => switch (this) {
    .adjustment => attribute.priceChanged,
    _ => _namer(
      attribute.optionName,
      attribute.name,
      name.contains('ttrName'), // to match with attrName and optionNameWithAttrName
      name.contains('optionName'),
    ),
  };
}

enum PriceTableColumn {
  total,
  paid,
  price,
  change,
  productsQuantity,
  productsPrice;

  String get title => switch (this) {
    .total => S.printerReceiptTablePriceTotal,
    .paid => S.printerReceiptTablePricePaid,
    .price => S.printerReceiptTablePricePrice,
    .change => S.printerReceiptTablePriceChange,
    .productsQuantity => S.printerReceiptTablePriceProductsQuantity,
    .productsPrice => S.printerReceiptTablePriceProductsPrice,
  };

  String valueFromOrder(OrderObject order) => switch (this) {
    .total => '\$${order.price.toCurrency()}',
    .paid => '\$${order.paid.toCurrency()}',
    .price => '\$${order.price.toCurrency()}',
    .change => '\$${order.change.toCurrency()}',
    .productsQuantity => order.productsCount.toString(),
    .productsPrice => '\$${order.productsPrice.toCurrency()}',
  };
}

/// Base class for all receipt components
abstract class ReceiptComponent {
  final ReceiptComponentType type;
  final Widget leading;
  EdgeInsets padding;

  ReceiptComponent({required this.type, required this.leading, this.padding = const EdgeInsets.all(0)});

  /// Convert to JSON for storage
  Map<String, Object?> toJson() {
    return {
      'type': type.index,
      if (padding != .zero)
        'padding': [padding.left, padding.top, padding.right, padding.bottom].map((e) => e.toInt()).join(','),
    };
  }

  /// Create from JSON
  factory ReceiptComponent.fromType(ReceiptComponentType type) {
    return switch (type) {
      .orderTable => OrderTableComponent(),
      .attributeTable => AttributeTableComponent(),
      .discountTable => DiscountTableComponent(),
      .priceTable => PriceTableComponent(),
      .textField => TextFieldComponent(),
      .image => ImageComponent(),
      .divider => DividerComponent(),
    };
  }

  factory ReceiptComponent.fromJson(Map<String, Object?> json) {
    final typeIdx = json['type'] as int? ?? 0;
    final type = ReceiptComponentType.values.elementAtOrNull(typeIdx) ?? .orderTable;
    final paddingValues =
        (json['padding'] as String?)?.split(',').map((e) => double.tryParse(e) ?? 0).toList().cast<double>() ??
        [0, 0, 0, 0];
    final EdgeInsets padding = .fromLTRB(
      paddingValues.elementAtOrNull(0) ?? 0,
      paddingValues.elementAtOrNull(1) ?? 0,
      paddingValues.elementAtOrNull(2) ?? 0,
      paddingValues.elementAtOrNull(3) ?? 0,
    );
    return switch (type) {
      .orderTable => OrderTableComponent.fromJson(json, padding: padding),
      .attributeTable => AttributeTableComponent.fromJson(json, padding: padding),
      .discountTable => DiscountTableComponent.fromJson(json, padding: padding),
      .priceTable => PriceTableComponent.fromJson(json, padding: padding),
      .textField => TextFieldComponent.fromJson(json, padding: padding),
      .image => ImageComponent.fromJson(json, padding: padding),
      .divider => DividerComponent.fromJson(json, padding: padding),
    };
  }
}

/// Order table component with customizable columns
class OrderTableComponent extends ReceiptComponent {
  List<TableColumnConfig<OrderTableColumn>> columns;

  OrderTableComponent({
    super.padding,
    this.columns = const [
      TableColumnConfig(OrderTableColumn.productName),
      TableColumnConfig(OrderTableColumn.quantity),
      TableColumnConfig(OrderTableColumn.singlePrice),
      TableColumnConfig(OrderTableColumn.totalPrice),
    ],
  }) : super(type: .orderTable, leading: const Icon(Icons.receipt_long_outlined));

  factory OrderTableComponent.fromJson(Map<String, Object?> json, {required EdgeInsets padding}) {
    final List<TableColumnConfig<OrderTableColumn>> columns = _columnsFromJson(
      json['columns'],
      OrderTableColumn.values,
    );
    return OrderTableComponent(padding: padding, columns: columns);
  }

  @override
  Map<String, Object?> toJson() {
    return {...super.toJson(), 'columns': columns.map((c) => c.toJson()).toList()};
  }
}

class DiscountTableComponent extends ReceiptComponent {
  List<TableColumnConfig<DiscountTableColumn>> columns;

  DiscountTableComponent({
    super.padding,
    this.columns = const [
      TableColumnConfig(DiscountTableColumn.productName),
      TableColumnConfig(DiscountTableColumn.originPrice),
    ],
  }) : super(type: .discountTable, leading: const Icon(Icons.discount_outlined));

  factory DiscountTableComponent.fromJson(Map<String, Object?> json, {required EdgeInsets padding}) {
    final List<TableColumnConfig<DiscountTableColumn>> columns = _columnsFromJson(
      json['columns'],
      DiscountTableColumn.values,
    );
    return DiscountTableComponent(padding: padding, columns: columns);
  }

  @override
  Map<String, Object?> toJson() {
    return {...super.toJson(), 'columns': columns.map((c) => c.toJson()).toList()};
  }
}

class AttributeTableComponent extends ReceiptComponent {
  List<TableColumnConfig<AttributeTableColumn>> columns;

  AttributeTableComponent({
    super.padding,
    this.columns = const [
      TableColumnConfig(AttributeTableColumn.optionName),
      TableColumnConfig(AttributeTableColumn.adjustment),
    ],
  }) : super(type: .attributeTable, leading: const Icon(Icons.attribution_outlined));

  factory AttributeTableComponent.fromJson(Map<String, Object?> json, {required EdgeInsets padding}) {
    final List<TableColumnConfig<AttributeTableColumn>> columns = _columnsFromJson(
      json['columns'],
      AttributeTableColumn.values,
    );
    return AttributeTableComponent(padding: padding, columns: columns);
  }

  @override
  Map<String, Object?> toJson() {
    return {...super.toJson(), 'columns': columns.map((c) => c.toJson()).toList()};
  }
}

class PriceTableComponent extends ReceiptComponent {
  List<TableColumnConfig<PriceTableColumn>> columns;

  PriceTableComponent({
    super.padding,
    this.columns = const [
      TableColumnConfig(PriceTableColumn.total),
      TableColumnConfig(PriceTableColumn.paid),
      TableColumnConfig(PriceTableColumn.price),
      TableColumnConfig(PriceTableColumn.change),
    ],
  }) : super(type: .priceTable, leading: const Icon(Icons.price_change_outlined));

  factory PriceTableComponent.fromJson(Map<String, Object?> json, {required EdgeInsets padding}) {
    final List<TableColumnConfig<PriceTableColumn>> columns = _columnsFromJson(
      json['columns'],
      PriceTableColumn.values,
    );
    return PriceTableComponent(padding: padding, columns: columns);
  }

  @override
  Map<String, Object?> toJson() {
    return {...super.toJson(), 'columns': columns.map((c) => c.toJson()).toList()};
  }
}

class TextFieldComponent extends ReceiptComponent {
  List<TextFieldObject> texts;
  TextAlign textAlign;

  TextFieldComponent({super.padding, this.texts = const [], this.textAlign = .start})
    : super(type: .textField, leading: const Icon(Icons.text_fields));

  factory TextFieldComponent.fromJson(Map<String, Object?> json, {required EdgeInsets padding}) {
    final texts = (json['texts'] as List<Object?>?)
        ?.whereType<Map<String, Object?>>()
        .map((e) {
          final part = partFromJson(e['_part'] as Map<String, Object?>? ?? {});
          return part is PlaceholderPart
              ? StyledPlaceholderObject.fromJson(part, e)
              : StyledTextObject.fromJson(part, e);
        })
        .cast<TextFieldObject>()
        .toList();
    final textAlign = json['textAlign'] as int? ?? 0;

    return TextFieldComponent(
      padding: padding,
      texts: texts ?? [],
      textAlign: TextAlign.values.elementAtOrNull(textAlign) ?? .start,
    );
  }

  @override
  Map<String, Object?> toJson() {
    return {...super.toJson(), 'texts': texts.map((e) => e.toJson()).toList(), 'textAlign': textAlign.index};
  }

  void updateFromParts(List<StyledPart> parts) {
    texts = parts
        .map((part) {
          return part is PlaceholderPart ? StyledPlaceholderObject(part: part) : StyledTextObject(part: part);
        })
        .cast<TextFieldObject>()
        .toList();
  }

  static DateFormat? _defaultDateTimeFormatter;

  /// Format text with placeholders for date
  static String _formatWithDateTime(String format, DateTime dt) {
    final formatter = format == '' || format == 'yMMMd Hms'
        ? (_defaultDateTimeFormatter ??= DateFormat.yMMMd().addPattern(' ').add_Hms())
        : DateFormat(format);
    return formatter.format(dt);
  }
}

class DividerComponent extends ReceiptComponent {
  double height;

  DividerComponent({super.padding, this.height = 4.0})
    : super(type: .divider, leading: const Icon(Icons.horizontal_rule));

  factory DividerComponent.fromJson(Map<String, Object?> json, {required EdgeInsets padding}) {
    return DividerComponent(padding: padding, height: json['height'] as double? ?? 4.0);
  }

  @override
  Map<String, Object?> toJson() {
    return {...super.toJson(), 'height': height};
  }
}

class ImageComponent extends ReceiptComponent {
  String imagePath;
  double widthRatio;

  ImageComponent({super.padding, this.imagePath = '', this.widthRatio = 1.0})
    : super(type: .image, leading: const Icon(Icons.image));

  factory ImageComponent.fromJson(Map<String, Object?> json, {required EdgeInsets padding}) {
    return ImageComponent(
      padding: padding,
      imagePath: json['imagePath'] as String? ?? '',
      widthRatio: json['widthRatio'] as double? ?? 1.0,
    );
  }

  @override
  Map<String, Object?> toJson() {
    return {...super.toJson(), 'imagePath': imagePath, 'widthRatio': widthRatio};
  }
}

class TableColumnConfig<T extends Enum> {
  final T type;

  final String? title;

  final double? width;

  const TableColumnConfig(this.type, {this.title, this.width});

  Map<String, Object?> toJson() {
    return {'type': type.index, if (title != null) 'title': title, if (width != null) 'width': width};
  }

  factory TableColumnConfig.fromJson(Map<String, Object?> json, List<T> allTypes) {
    return TableColumnConfig(
      allTypes.elementAtOrNull(json['type'] as int? ?? 0) ?? allTypes.first,
      title: json['title'] as String?,
      width: json['width'] as double?,
    );
  }
}

abstract class TextFieldObject<T extends StyledPart> {
  final T part;

  const TextFieldObject({required this.part});

  Map<String, Object?> toJson();

  InlineSpan buildSpan({OrderObject? order});
}

class StyledTextObject extends TextFieldObject<StyledPart> {
  const StyledTextObject({super.part = const StyledPart(text: '', style: null)});

  factory StyledTextObject.fromJson(StyledPart part, Map<String, Object?> json) {
    return StyledTextObject(part: part);
  }

  @override
  Map<String, Object?> toJson() {
    return {'_part': part.toJson()};
  }

  @override
  InlineSpan buildSpan({OrderObject? order}) {
    return TextSpan(text: part.text, style: part.style?.toTextStyle());
  }
}

class StyledPlaceholderObject extends TextFieldObject<PlaceholderPart> {
  final TextFieldPlaceholderType type;

  final String? meta;

  final double? height;
  final double? letterSpacing;

  StyledPlaceholderObject({super.part = const PlaceholderPart(text: '', style: null), this.height, this.letterSpacing})
    : meta = part is MenuPlaceholderPart ? part.meta : null,
      type = TextFieldPlaceholderType.values.firstWhereOrNull((e) => e.name == part.text) ?? .title;

  factory StyledPlaceholderObject.fromJson(PlaceholderPart part, Map<String, Object?> json) {
    return StyledPlaceholderObject(part: part);
  }

  factory StyledPlaceholderObject.fromType(
    TextFieldPlaceholderType type, {
    String? meta,
    double? height,
    double? letterSpacing,
    bool? isBold,
    bool? isItalic,
    bool? isStrikethrough,
    bool? isUnderline,
    int? fontSize,
    Color? color,
  }) {
    final style = StyledText.nullableFactory(
      isBold: isBold,
      isItalic: isItalic,
      isStrikethrough: isStrikethrough,
      isUnderline: isUnderline,
      fontSize: fontSize,
      color: color,
    );
    return StyledPlaceholderObject(
      part: meta == null
          ? PlaceholderPart(text: type.name, style: style)
          : MenuPlaceholderPart(text: type.name, meta: meta, style: style),
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  @override
  Map<String, Object?> toJson() {
    return {'_part': part.toJson()};
  }

  @override
  InlineSpan buildSpan({OrderObject? order}) {
    return TextSpan(
      text: order == null ? '' : formatText(order: order),
      style: part.style?.toTextStyle().copyWith(height: height, letterSpacing: letterSpacing),
    );
  }

  String formatText({required OrderObject order}) {
    return switch (type) {
      .title => S.printerReceiptTitle,
      .now => TextFieldComponent._formatWithDateTime(meta ?? '', .now()),
      .seq => order.periodSeq?.toString() ?? '',
      .productCount => order.productsCount.toString(),
      .paid => order.paid.toCurrency(),
      .change => order.change.toCurrency(),
      .price => order.price.toCurrency(),
      .cost => order.cost.toCurrency(),
      .revenue => order.profit.toCurrency(),
      .productPrice => order.productsPrice.toCurrency(),
      .attributePrice => order.attributesPrice.toCurrency(),
      .orderedAt => TextFieldComponent._formatWithDateTime(meta ?? '', order.createdAt),
    };
  }
}

enum TextFieldPlaceholderType {
  title(unSelectable: true),
  now(isDate: true),
  seq(),
  productCount(),
  paid(),
  change(),
  price(),
  cost(),
  revenue(),
  productPrice(),
  attributePrice(),
  orderedAt(isDate: true);

  final bool isDate;
  final bool unSelectable;

  const TextFieldPlaceholderType({this.isDate = false, this.unSelectable = false});

  TextPlaceholder buildPlaceholder({Future<String?> Function(MenuPlaceholder<String>)? onMenuSelected}) {
    if (!isDate) {
      return TextPlaceholder(id: name, text: S.printerReceiptComponentTextPlaceholders(name));
    }

    return MenuPlaceholder<String>(
      id: name,
      text: S.printerReceiptComponentTextPlaceholders(name),
      meta: 'yMMMd Hms',
      onMenuSelected: onMenuSelected,
    );
  }
}

List<TableColumnConfig<T>> _columnsFromJson<T extends Enum>(Object? json, List<T> allTypes) {
  return (json is List<Object?>)
      ? json.whereType<Map<String, Object?>>().map((e) => TableColumnConfig.fromJson(e, allTypes)).toList()
      : [];
}

String _namer(String base, String suffix, bool? withSuffix, [bool? withBase = true]) {
  if (withBase != true) {
    return suffix;
  }

  if (withSuffix == true) {
    return '$base($suffix)';
  }

  return base;
}
