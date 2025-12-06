import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/translator.dart';

/// Base class for all receipt components
abstract class ReceiptComponent {
  final ReceiptComponentType type;
  final Icon icon;

  ReceiptComponent({
    required this.type,
    required this.icon,
  });

  /// Convert to JSON for storage
  Map<String, Object?> toJson();

  Widget buildDescription(BuildContext context);

  /// Create from JSON
  factory ReceiptComponent.fromJson(Map<String, Object?> json) {
    final typeIdx = json['type'] as int? ?? 0;
    final type = ReceiptComponentType.values.elementAtOrNull(typeIdx) ?? ReceiptComponentType.orderTable;
    switch (type) {
      case ReceiptComponentType.orderTable:
        return OrderTableComponent.fromJson(json);
      case ReceiptComponentType.attributeTable:
        return AttributeTableComponent.fromJson(json);
      case ReceiptComponentType.discountTable:
        return DiscountTableComponent.fromJson(json);
      case ReceiptComponentType.priceTable:
        return PriceTableComponent.fromJson(json);
      case ReceiptComponentType.textField:
        return TextFieldComponent.fromJson(json);
      case ReceiptComponentType.image:
        return ImageComponent.fromJson(json);
      case ReceiptComponentType.divider:
        return DividerComponent.fromJson(json);
    }
  }
}

enum ReceiptComponentType {
  orderTable,
  discountTable,
  attributeTable,
  priceTable,
  textField,
  image,
  divider,
}

/// Order table component with customizable columns
class OrderTableComponent extends ReceiptComponent {
  bool showProductName;
  bool showCatalogName;
  bool showQuantity;
  bool showSinglePrice;
  bool showTotalPrice;

  OrderTableComponent({
    this.showProductName = true,
    this.showCatalogName = false,
    this.showQuantity = true,
    this.showSinglePrice = true,
    this.showTotalPrice = true,
  }) : super(type: ReceiptComponentType.orderTable, icon: const Icon(Icons.receipt_long_outlined));

  factory OrderTableComponent.fromJson(Map<String, Object?> json) {
    return OrderTableComponent(
      showProductName: json['showProductName'] as bool? ?? true,
      showCatalogName: json['showCatalogName'] as bool? ?? false,
      showQuantity: json['showQuantity'] as bool? ?? true,
      showSinglePrice: json['showSinglePrice'] as bool? ?? true,
      showTotalPrice: json['showTotalPrice'] as bool? ?? true,
    );
  }

  @override
  Widget buildDescription(BuildContext context) => MetaBlock.withString(
      context,
      [
        if (showProductName) S.printerReceiptComponentLabelProductName,
        if (showCatalogName) S.printerReceiptComponentLabelCatalogName,
        if (showQuantity) S.printerReceiptComponentLabelQuantity,
        if (showSinglePrice) S.printerReceiptComponentLabelSinglePrice,
        if (showTotalPrice) S.printerReceiptComponentLabelTotalPrice,
      ],
      maxLines: 1,
      emptyText: '')!;

  @override
  Map<String, Object?> toJson() {
    return {
      'type': type.index,
      'showProductName': showProductName,
      'showCatalogName': showCatalogName,
      'showQuantity': showQuantity,
      'showSinglePrice': showSinglePrice,
      'showTotalPrice': showTotalPrice,
    };
  }
}

class DiscountTableComponent extends ReceiptComponent {
  bool showProductName;
  bool showCatalogName;
  bool showQuantity;
  bool showTotalPrice;
  bool showSinglePrice;
  bool showOriginPrice;

  DiscountTableComponent({
    this.showProductName = true,
    this.showCatalogName = false,
    this.showQuantity = false,
    this.showTotalPrice = false,
    this.showSinglePrice = false,
    this.showOriginPrice = true,
  }) : super(type: ReceiptComponentType.discountTable, icon: const Icon(Icons.discount_outlined));

  factory DiscountTableComponent.fromJson(Map<String, Object?> json) {
    return DiscountTableComponent(
      showProductName: json['showProductName'] as bool? ?? true,
      showCatalogName: json['showCatalogName'] as bool? ?? false,
      showQuantity: json['showQuantity'] as bool? ?? false,
      showTotalPrice: json['showTotalPrice'] as bool? ?? false,
      showSinglePrice: json['showSinglePrice'] as bool? ?? false,
      showOriginPrice: json['showOriginPrice'] as bool? ?? true,
    );
  }

  @override
  Widget buildDescription(BuildContext context) => MetaBlock.withString(
      context,
      [
        if (showProductName) S.printerReceiptComponentLabelProductName,
        if (showCatalogName) S.printerReceiptComponentLabelCatalogName,
        if (showQuantity) S.printerReceiptComponentLabelQuantity,
        if (showSinglePrice) S.printerReceiptComponentLabelSinglePrice,
        if (showTotalPrice) S.printerReceiptComponentLabelTotalPrice,
        if (showOriginPrice) S.printerReceiptComponentLabelOriginPrice,
      ],
      maxLines: 1,
      emptyText: '')!;

  @override
  Map<String, Object?> toJson() {
    return {
      'type': type.index,
      'showProductName': showProductName,
      'showCatalogName': showCatalogName,
      'showQuantity': showQuantity,
      'showTotalPrice': showTotalPrice,
      'showSinglePrice': showSinglePrice,
      'showOriginPrice': showOriginPrice,
    };
  }
}

class AttributeTableComponent extends ReceiptComponent {
  bool showName;
  bool showOptionName;
  bool showAdjustment;

  AttributeTableComponent({
    this.showName = false,
    this.showOptionName = true,
    this.showAdjustment = true,
  }) : super(type: ReceiptComponentType.attributeTable, icon: const Icon(Icons.attribution_outlined));

  factory AttributeTableComponent.fromJson(Map<String, Object?> json) {
    return AttributeTableComponent(
      showName: json['showName'] as bool? ?? false,
      showOptionName: json['showOptionName'] as bool? ?? true,
      showAdjustment: json['showAdjustment'] as bool? ?? true,
    );
  }

  @override
  Widget buildDescription(BuildContext context) => MetaBlock.withString(
      context,
      [
        if (showName) S.printerReceiptComponentLabelAttributeName,
        if (showOptionName) S.printerReceiptComponentLabelAttributeOption,
        if (showAdjustment) S.printerReceiptComponentLabelAttributeAdjustment,
      ],
      maxLines: 1,
      emptyText: '')!;

  @override
  Map<String, Object?> toJson() {
    return {
      'type': type.index,
      'showName': showName,
      'showOptionName': showOptionName,
      'showAdjustment': showAdjustment,
    };
  }
}

class PriceTableComponent extends ReceiptComponent {
  bool showPaid;
  bool showPrice;
  bool showChange;
  bool showProductsQuantity;
  bool showProductsPrice;

  PriceTableComponent({
    this.showPaid = true,
    this.showPrice = true,
    this.showChange = true,
    this.showProductsQuantity = false,
    this.showProductsPrice = false,
  }) : super(type: ReceiptComponentType.priceTable, icon: const Icon(Icons.price_change_outlined));

  factory PriceTableComponent.fromJson(Map<String, Object?> json) {
    return PriceTableComponent(
      showPaid: json['showPaid'] as bool? ?? true,
      showPrice: json['showPrice'] as bool? ?? true,
      showChange: json['showChange'] as bool? ?? true,
      showProductsQuantity: json['showProductsQuantity'] as bool? ?? false,
      showProductsPrice: json['showProductsPrice'] as bool? ?? false,
    );
  }

  @override
  Widget buildDescription(BuildContext context) => MetaBlock.withString(
      context,
      [
        if (showPaid) S.printerReceiptComponentLabelPaid,
        if (showPrice) S.printerReceiptComponentLabelPrice,
        if (showChange) S.printerReceiptComponentLabelChange,
        if (showProductsQuantity) S.printerReceiptComponentLabelProductsQuantity,
        if (showProductsPrice) S.printerReceiptComponentLabelProductsPrice,
      ],
      maxLines: 1,
      emptyText: '')!;

  @override
  Map<String, Object?> toJson() {
    return {
      'type': type.index,
      'showPaid': showPaid,
      'showPrice': showPrice,
      'showChange': showChange,
      'showProductsQuantity': showProductsQuantity,
      'showProductsPrice': showProductsPrice,
    };
  }
}

class TextFieldComponent extends ReceiptComponent {
  String text;
  double fontSize;
  double height;
  Color color;
  TextAlign textAlign;
  EdgeInsets padding;

  static DateFormat? _defaultDateTimeFormatter;
  static String _formatWithDateTime(String text, String key, DateTime dt) {
    final regex = RegExp('\\{$text(:[^}]*)?\\}');
    final matches = regex.allMatches(text);
    final matchMap = {for (final match in matches) match.group(0)!: match.group(1)};

    for (final entry in matchMap.entries) {
      final formatter = entry.value == null
          ? (_defaultDateTimeFormatter ??= DateFormat.yMMMd().addPattern(' ').add_Hms())
          : DateFormat(entry.value!.substring(1));
      text = text.replaceAll(entry.key, formatter.format(dt));
    }

    return text;
  }

  TextFieldComponent({
    required this.text,
    this.fontSize = 14.0,
    this.height = 1.0,
    this.color = const Color(0xFF424242),
    this.textAlign = TextAlign.center,
    this.padding = const EdgeInsets.all(0),
  }) : super(type: ReceiptComponentType.textField, icon: const Icon(Icons.text_fields));

  factory TextFieldComponent.fromJson(Map<String, Object?> json) {
    return TextFieldComponent(
      text: json['text'] as String? ?? '',
      fontSize: json['fontSize'] as double? ?? 14.0,
      height: json['height'] as double? ?? 1.0,
      color: Color(json['color'] as int? ?? Colors.black.toARGB32()),
      textAlign: TextAlign.values.elementAtOrNull(json['textAlign'] as int? ?? 0) ?? TextAlign.center,
      padding: EdgeInsets.fromLTRB(
        (json['paddingLeft'] as double?) ?? 0,
        (json['paddingTop'] as double?) ?? 0,
        (json['paddingRight'] as double?) ?? 0,
        (json['paddingBottom'] as double?) ?? 0,
      ),
    );
  }

  @override
  Widget buildDescription(BuildContext context) => Text(text, overflow: TextOverflow.ellipsis, maxLines: 1);

  String formatText({
    String? title,
    DateTime? now,
    OrderObject? order,
  }) {
    String formatted = text;
    if (title != null) {
      formatted = formatted.replaceAll('{title}', title);
    }
    if (now != null) {
      formatted = _formatWithDateTime(formatted, 'now', now);
    }
    if (order != null) {
      formatted = formatted
          .replaceAll('{seq}', '${order.periodSeq}')
          .replaceAll('{productCount}', '${order.productsCount}')
          .replaceAll('{paid}', order.paid.toCurrency())
          .replaceAll('{price}', order.price.toCurrency())
          .replaceAll('{cost}', order.cost.toCurrency())
          .replaceAll('{revenue}', order.profit.toCurrency())
          .replaceAll('{productPrice}', order.productsPrice.toCurrency())
          .replaceAll('{attributePrice}', order.attributesPrice.toCurrency());
      formatted = _formatWithDateTime(formatted, 'createdAt', order.createdAt);
    }
    return formatted;
  }

  @override
  Map<String, Object?> toJson() {
    return {
      'type': type.index,
      'text': text,
      'fontSize': fontSize,
      'height': height,
      'color': color.toARGB32(),
      'textAlign': textAlign.index,
      'paddingLeft': padding.left,
      'paddingTop': padding.top,
      'paddingRight': padding.right,
      'paddingBottom': padding.bottom,
    };
  }
}

class DividerComponent extends ReceiptComponent {
  double height;

  DividerComponent({
    this.height = 4.0,
  }) : super(type: ReceiptComponentType.divider, icon: const Icon(Icons.horizontal_rule));

  factory DividerComponent.fromJson(Map<String, Object?> json) {
    return DividerComponent(
      height: json['height'] as double? ?? 4.0,
    );
  }

  @override
  Widget buildDescription(BuildContext context) => Text('Height: $height'); // TODO: i18n

  @override
  Map<String, Object?> toJson() {
    return {
      'type': type.index,
      'height': height,
    };
  }
}

class ImageComponent extends ReceiptComponent {
  String imagePath;
  double width;
  double height;

  ImageComponent({
    required this.imagePath,
    this.width = 100.0,
    this.height = 100.0,
  }) : super(type: ReceiptComponentType.image, icon: const Icon(Icons.image));

  factory ImageComponent.fromJson(Map<String, Object?> json) {
    return ImageComponent(
      imagePath: json['imagePath'] as String? ?? '',
      width: json['width'] as double? ?? 100.0,
      height: json['height'] as double? ?? 100.0,
    );
  }

  @override
  Widget buildDescription(BuildContext context) => Text(imagePath); // TODO: using image preview

  @override
  Map<String, Object?> toJson() {
    return {
      'type': type.index,
      'imagePath': imagePath,
      'width': width,
      'height': height,
    };
  }
}
