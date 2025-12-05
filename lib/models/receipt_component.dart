import 'package:flutter/material.dart';

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
      case ReceiptComponentType.textField:
        return TextFieldComponent.fromJson(json);
      case ReceiptComponentType.divider:
        return DividerComponent.fromJson(json);
      case ReceiptComponentType.orderTimestamp:
        return OrderTimestampComponent.fromJson(json);
      case ReceiptComponentType.orderId:
        return OrderIdComponent.fromJson(json);
      case ReceiptComponentType.totalSection:
        return TotalSectionComponent.fromJson(json);
      case ReceiptComponentType.paymentSection:
        return PaymentSectionComponent.fromJson(json);
    }
  }

  /// Create a copy with updated properties
  ReceiptComponent copyWith();
}

enum ReceiptComponentType {
  orderTable,
  textField,
  divider,
  orderTimestamp,
  orderId,
  totalSection,
  paymentSection,
}

/// Order table component with customizable columns
class OrderTableComponent extends ReceiptComponent {
  final bool showProductName;
  final bool showCatalogName;
  final bool showCount;
  final bool showPrice;
  final bool showTotal;

  OrderTableComponent({
    this.showProductName = true,
    this.showCatalogName = false,
    this.showCount = true,
    this.showPrice = true,
    this.showTotal = true,
  }) : super(type: ReceiptComponentType.orderTable);

  factory OrderTableComponent.fromJson(Map<String, Object?> json) {
    return OrderTableComponent(
      showProductName: json['showProductName'] as bool? ?? true,
      showCatalogName: json['showCatalogName'] as bool? ?? false,
      showCount: json['showCount'] as bool? ?? true,
      showPrice: json['showPrice'] as bool? ?? true,
      showTotal: json['showTotal'] as bool? ?? true,
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

  @override
  OrderTableComponent copyWith({
    bool? showProductName,
    bool? showCatalogName,
    bool? showCount,
    bool? showPrice,
    bool? showTotal,
  }) {
    return OrderTableComponent(
      showProductName: showProductName ?? this.showProductName,
      showCatalogName: showCatalogName ?? this.showCatalogName,
      showCount: showCount ?? this.showCount,
      showPrice: showPrice ?? this.showPrice,
      showTotal: showTotal ?? this.showTotal,
    );
  }
}

/// Custom text field component
class TextFieldComponent extends ReceiptComponent {
  final String text;
  final double fontSize;
  final double height;
  final Color color;
  final TextAlign textAlign;

  TextFieldComponent({
    required this.text,
    this.fontSize = 14.0,
    this.height = 1.0,
    this.color = Colors.black,
    this.textAlign = TextAlign.left,
  }) : super(type: ReceiptComponentType.textField);

  factory TextFieldComponent.fromJson(Map<String, Object?> json) {
    return TextFieldComponent(
      text: json['text'] as String? ?? '',
      fontSize: json['fontSize'] as double? ?? 14.0,
      height: json['height'] as double? ?? 1.0,
      color: Color(json['color'] as int? ?? Colors.black.toARGB32()),
      textAlign: TextAlign.values.elementAtOrNull(json['textAlign'] as int? ?? 0) ?? TextAlign.left,
    );
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
    };
  }

  @override
  TextFieldComponent copyWith({
    String? text,
    double? fontSize,
    double? height,
    Color? color,
    TextAlign? textAlign,
  }) {
    return TextFieldComponent(
      text: text ?? this.text,
      fontSize: fontSize ?? this.fontSize,
      height: height ?? this.height,
      color: color ?? this.color,
      textAlign: textAlign ?? this.textAlign,
    );
  }
}

/// Divider component
class DividerComponent extends ReceiptComponent {
  final double height;

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

  @override
  DividerComponent copyWith({
    double? height,
  }) {
    return DividerComponent(
      height: height ?? this.height,
    );
  }
}

/// Order timestamp component with customizable format
class OrderTimestampComponent extends ReceiptComponent {
  final String dateFormat;

  OrderTimestampComponent({
    this.dateFormat = 'yMMMd Hms',
  }) : super(type: ReceiptComponentType.orderTimestamp);

  factory OrderTimestampComponent.fromJson(Map<String, Object?> json) {
    return OrderTimestampComponent(
      dateFormat: json['dateFormat'] as String? ?? 'yMMMd Hms',
    );
  }

  @override
  Map<String, Object?> toJson() {
    return {
      'type': type.index,
      'dateFormat': dateFormat,
    };
  }

  @override
  OrderTimestampComponent copyWith({
    String? dateFormat,
  }) {
    return OrderTimestampComponent(
      dateFormat: dateFormat ?? this.dateFormat,
    );
  }
}

/// Order ID component
class OrderIdComponent extends ReceiptComponent {
  final double fontSize;

  OrderIdComponent({
    this.fontSize = 14.0,
  }) : super(type: ReceiptComponentType.orderId);

  factory OrderIdComponent.fromJson(Map<String, Object?> json) {
    return OrderIdComponent(
      fontSize: json['fontSize'] as double? ?? 14.0,
    );
  }

  @override
  Map<String, Object?> toJson() {
    return {
      'type': type.index,
      'fontSize': fontSize,
    };
  }

  @override
  OrderIdComponent copyWith({
    double? fontSize,
  }) {
    return OrderIdComponent(
      fontSize: fontSize ?? this.fontSize,
    );
  }
}

/// Total section showing discounts and add-ons
class TotalSectionComponent extends ReceiptComponent {
  final bool showDiscounts;
  final bool showAddOns;

  TotalSectionComponent({
    this.showDiscounts = true,
    this.showAddOns = true,
  }) : super(type: ReceiptComponentType.totalSection);

  factory TotalSectionComponent.fromJson(Map<String, Object?> json) {
    return TotalSectionComponent(
      showDiscounts: json['showDiscounts'] as bool? ?? true,
      showAddOns: json['showAddOns'] as bool? ?? true,
    );
  }

  @override
  Map<String, Object?> toJson() {
    return {
      'type': type.index,
      'showDiscounts': showDiscounts,
      'showAddOns': showAddOns,
    };
  }

  @override
  TotalSectionComponent copyWith({
    bool? showDiscounts,
    bool? showAddOns,
  }) {
    return TotalSectionComponent(
      showDiscounts: showDiscounts ?? this.showDiscounts,
      showAddOns: showAddOns ?? this.showAddOns,
    );
  }
}

/// Payment section showing paid, price, and change
class PaymentSectionComponent extends ReceiptComponent {
  PaymentSectionComponent() : super(type: ReceiptComponentType.paymentSection);

  factory PaymentSectionComponent.fromJson(Map<String, Object?> json) {
    return PaymentSectionComponent();
  }

  @override
  Map<String, Object?> toJson() {
    return {
      'type': type.index,
    };
  }

  @override
  PaymentSectionComponent copyWith() {
    return PaymentSectionComponent();
  }
}
