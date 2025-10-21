import 'package:flutter/material.dart';

/// Base class for all receipt components
abstract class ReceiptComponent {
  final String id;
  final ReceiptComponentType type;

  ReceiptComponent({
    required this.id,
    required this.type,
  });

  /// Convert to JSON for storage
  Map<String, Object?> toJson();

  /// Create from JSON
  factory ReceiptComponent.fromJson(Map<String, Object?> json) {
    final type = ReceiptComponentType.values[json['type'] as int];
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
    required super.id,
    this.showProductName = true,
    this.showCatalogName = false,
    this.showCount = true,
    this.showPrice = true,
    this.showTotal = true,
  }) : super(type: ReceiptComponentType.orderTable);

  factory OrderTableComponent.fromJson(Map<String, Object?> json) {
    return OrderTableComponent(
      id: json['id'] as String,
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
      'id': id,
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
      id: id,
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
  final TextAlign textAlign;

  TextFieldComponent({
    required super.id,
    required this.text,
    this.fontSize = 14.0,
    this.textAlign = TextAlign.left,
  }) : super(type: ReceiptComponentType.textField);

  factory TextFieldComponent.fromJson(Map<String, Object?> json) {
    return TextFieldComponent(
      id: json['id'] as String,
      text: json['text'] as String? ?? '',
      fontSize: json['fontSize'] as double? ?? 14.0,
      textAlign: TextAlign.values[json['textAlign'] as int? ?? 0],
    );
  }

  @override
  Map<String, Object?> toJson() {
    return {
      'id': id,
      'type': type.index,
      'text': text,
      'fontSize': fontSize,
      'textAlign': textAlign.index,
    };
  }

  @override
  TextFieldComponent copyWith({
    String? text,
    double? fontSize,
    TextAlign? textAlign,
  }) {
    return TextFieldComponent(
      id: id,
      text: text ?? this.text,
      fontSize: fontSize ?? this.fontSize,
      textAlign: textAlign ?? this.textAlign,
    );
  }
}

/// Divider component
class DividerComponent extends ReceiptComponent {
  final double height;

  DividerComponent({
    required super.id,
    this.height = 4.0,
  }) : super(type: ReceiptComponentType.divider);

  factory DividerComponent.fromJson(Map<String, Object?> json) {
    return DividerComponent(
      id: json['id'] as String,
      height: json['height'] as double? ?? 4.0,
    );
  }

  @override
  Map<String, Object?> toJson() {
    return {
      'id': id,
      'type': type.index,
      'height': height,
    };
  }

  @override
  DividerComponent copyWith({
    double? height,
  }) {
    return DividerComponent(
      id: id,
      height: height ?? this.height,
    );
  }
}

/// Order timestamp component with customizable format
class OrderTimestampComponent extends ReceiptComponent {
  final String dateFormat;

  OrderTimestampComponent({
    required super.id,
    this.dateFormat = 'yMMMd Hms',
  }) : super(type: ReceiptComponentType.orderTimestamp);

  factory OrderTimestampComponent.fromJson(Map<String, Object?> json) {
    return OrderTimestampComponent(
      id: json['id'] as String,
      dateFormat: json['dateFormat'] as String? ?? 'yMMMd Hms',
    );
  }

  @override
  Map<String, Object?> toJson() {
    return {
      'id': id,
      'type': type.index,
      'dateFormat': dateFormat,
    };
  }

  @override
  OrderTimestampComponent copyWith({
    String? dateFormat,
  }) {
    return OrderTimestampComponent(
      id: id,
      dateFormat: dateFormat ?? this.dateFormat,
    );
  }
}

/// Order ID component
class OrderIdComponent extends ReceiptComponent {
  final double fontSize;

  OrderIdComponent({
    required super.id,
    this.fontSize = 14.0,
  }) : super(type: ReceiptComponentType.orderId);

  factory OrderIdComponent.fromJson(Map<String, Object?> json) {
    return OrderIdComponent(
      id: json['id'] as String,
      fontSize: json['fontSize'] as double? ?? 14.0,
    );
  }

  @override
  Map<String, Object?> toJson() {
    return {
      'id': id,
      'type': type.index,
      'fontSize': fontSize,
    };
  }

  @override
  OrderIdComponent copyWith({
    double? fontSize,
  }) {
    return OrderIdComponent(
      id: id,
      fontSize: fontSize ?? this.fontSize,
    );
  }
}

/// Total section showing discounts and add-ons
class TotalSectionComponent extends ReceiptComponent {
  final bool showDiscounts;
  final bool showAddOns;

  TotalSectionComponent({
    required super.id,
    this.showDiscounts = true,
    this.showAddOns = true,
  }) : super(type: ReceiptComponentType.totalSection);

  factory TotalSectionComponent.fromJson(Map<String, Object?> json) {
    return TotalSectionComponent(
      id: json['id'] as String,
      showDiscounts: json['showDiscounts'] as bool? ?? true,
      showAddOns: json['showAddOns'] as bool? ?? true,
    );
  }

  @override
  Map<String, Object?> toJson() {
    return {
      'id': id,
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
      id: id,
      showDiscounts: showDiscounts ?? this.showDiscounts,
      showAddOns: showAddOns ?? this.showAddOns,
    );
  }
}

/// Payment section showing paid, price, and change
class PaymentSectionComponent extends ReceiptComponent {
  PaymentSectionComponent({
    required super.id,
  }) : super(type: ReceiptComponentType.paymentSection);

  factory PaymentSectionComponent.fromJson(Map<String, Object?> json) {
    return PaymentSectionComponent(
      id: json['id'] as String,
    );
  }

  @override
  Map<String, Object?> toJson() {
    return {
      'id': id,
      'type': type.index,
    };
  }

  @override
  PaymentSectionComponent copyWith() {
    return PaymentSectionComponent(
      id: id,
    );
  }
}
