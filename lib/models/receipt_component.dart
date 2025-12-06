import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/objects/order_object.dart';

/// Base class for all receipt components
abstract class ReceiptComponent {
  final ReceiptComponentType type;

  ReceiptComponent({
    required this.type,
  });

  /// Convert to JSON for storage
  Map<String, Object?> toJson();

  /// Create from JSON
  factory ReceiptComponent.fromJson(Map<String, Object?> json) {
    final type =
        ReceiptComponentType.values.elementAtOrNull(json['type'] as int? ?? 0) ?? ReceiptComponentType.orderTable;
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
  bool showCount;
  bool showPrice;
  bool showTotal;

  OrderTableComponent({
    this.showProductName = false,
    this.showCatalogName = false,
    this.showCount = false,
    this.showPrice = false,
    this.showTotal = false,
  }) : super(type: ReceiptComponentType.orderTable);

  factory OrderTableComponent.fromJson(Map<String, Object?> json) {
    return OrderTableComponent(
      showProductName: json['showProductName'] as bool? ?? false,
      showCatalogName: json['showCatalogName'] as bool? ?? false,
      showCount: json['showCount'] as bool? ?? false,
      showPrice: json['showPrice'] as bool? ?? false,
      showTotal: json['showTotal'] as bool? ?? false,
    );
  }

  @override
  Map<String, Object?> toJson() {
    return {
      'type': type.index,
      'showProductName': showProductName,
      'showCatalogName': showCatalogName,
      'showCount': showCount,
      'showPrice': showPrice,
      'showTotal': showTotal,
    };
  }
}

class DiscountTableComponent extends ReceiptComponent {
  bool showProductName;
  bool showCatalogName;
  bool showCount;
  bool showTotalPrice;
  bool showSinglePrice;
  bool showOriginalPrice;

  DiscountTableComponent({
    this.showProductName = false,
    this.showCatalogName = false,
    this.showCount = false,
    this.showTotalPrice = false,
    this.showSinglePrice = false,
    this.showOriginalPrice = false,
  }) : super(type: ReceiptComponentType.discountTable);

  factory DiscountTableComponent.fromJson(Map<String, Object?> json) {
    return DiscountTableComponent(
      showProductName: json['showProductName'] as bool? ?? false,
      showCatalogName: json['showCatalogName'] as bool? ?? false,
      showCount: json['showCount'] as bool? ?? false,
      showTotalPrice: json['showTotalPrice'] as bool? ?? false,
      showSinglePrice: json['showSinglePrice'] as bool? ?? false,
      showOriginalPrice: json['showOriginalPrice'] as bool? ?? false,
    );
  }

  @override
  Map<String, Object?> toJson() {
    return {
      'type': type.index,
      'showProductName': showProductName,
      'showCatalogName': showCatalogName,
      'showCount': showCount,
      'showTotalPrice': showTotalPrice,
      'showSinglePrice': showSinglePrice,
      'showOriginalPrice': showOriginalPrice,
    };
  }
}

class AttributeTableComponent extends ReceiptComponent {
  bool showName;
  bool showOptionName;
  bool showAdjustment;

  AttributeTableComponent({
    this.showName = false,
    this.showOptionName = false,
    this.showAdjustment = false,
  }) : super(type: ReceiptComponentType.attributeTable);

  factory AttributeTableComponent.fromJson(Map<String, Object?> json) {
    return AttributeTableComponent(
      showName: json['showName'] as bool? ?? false,
      showOptionName: json['showOptionName'] as bool? ?? false,
      showAdjustment: json['showAdjustment'] as bool? ?? false,
    );
  }

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
  bool showProductCount;
  bool showProductPrice;

  PriceTableComponent({
    this.showPaid = false,
    this.showPrice = false,
    this.showChange = false,
    this.showProductCount = false,
    this.showProductPrice = false,
  }) : super(type: ReceiptComponentType.priceTable);

  factory PriceTableComponent.fromJson(Map<String, Object?> json) {
    return PriceTableComponent(
      showPaid: json['showPaid'] as bool? ?? false,
      showPrice: json['showPrice'] as bool? ?? false,
      showChange: json['showChange'] as bool? ?? false,
      showProductCount: json['showProductCount'] as bool? ?? false,
      showProductPrice: json['showProductPrice'] as bool? ?? false,
    );
  }

  @override
  Map<String, Object?> toJson() {
    return {
      'type': type.index,
      'showPaid': showPaid,
      'showPrice': showPrice,
      'showChange': showChange,
      'showProductCount': showProductCount,
      'showProductPrice': showProductPrice,
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
  }) : super(type: ReceiptComponentType.textField);

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
  }) : super(type: ReceiptComponentType.divider);

  factory DividerComponent.fromJson(Map<String, Object?> json) {
    return DividerComponent(
      height: json['height'] as double? ?? 4.0,
    );
  }

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
  }) : super(type: ReceiptComponentType.image);

  factory ImageComponent.fromJson(Map<String, Object?> json) {
    return ImageComponent(
      imagePath: json['imagePath'] as String? ?? '',
      width: json['width'] as double? ?? 100.0,
      height: json['height'] as double? ?? 100.0,
    );
  }

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
