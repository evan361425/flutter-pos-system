import 'package:collection/collection.dart';
import 'package:editor_ant/editor_ant.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/xfile.dart';
import 'package:possystem/translator.dart';

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
      'padding': [padding.left, padding.top, padding.right, padding.bottom].map((e) => e.toInt()).join(','),
    };
  }

  Widget? buildLeading(BuildContext context) => leading;
  Widget? buildDescription(BuildContext context) => null;

  /// Create from JSON
  factory ReceiptComponent.fromType(ReceiptComponentType type) {
    return ReceiptComponent.fromJson({'type': type.index});
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
    switch (type) {
      case .orderTable:
        return OrderTableComponent.fromJson(json, padding: padding);
      case .attributeTable:
        return AttributeTableComponent.fromJson(json, padding: padding);
      case .discountTable:
        return DiscountTableComponent.fromJson(json, padding: padding);
      case .priceTable:
        return PriceTableComponent.fromJson(json, padding: padding);
      case .textField:
        return TextFieldComponent.fromJson(json, padding: padding);
      case .image:
        return ImageComponent.fromJson(json, padding: padding);
      case .divider:
        return DividerComponent.fromJson(json, padding: padding);
    }
  }
}

enum ReceiptComponentType { orderTable, discountTable, attributeTable, priceTable, textField, image, divider }

/// Order table component with customizable columns
class OrderTableComponent extends ReceiptComponent {
  bool showProductName;
  bool showCatalogName;
  bool showQuantity;
  bool showSinglePrice;
  bool showTotalPrice;

  OrderTableComponent({
    super.padding,
    this.showProductName = true,
    this.showCatalogName = false,
    this.showQuantity = true,
    this.showSinglePrice = true,
    this.showTotalPrice = true,
  }) : super(type: .orderTable, leading: const Icon(Icons.receipt_long_outlined));

  factory OrderTableComponent.fromJson(Map<String, Object?> json, {required EdgeInsets padding}) {
    return OrderTableComponent(
      padding: padding,
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
    emptyText: '',
  )!;

  @override
  Map<String, Object?> toJson() {
    return {
      ...super.toJson(),
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
    super.padding,
    this.showProductName = true,
    this.showCatalogName = false,
    this.showQuantity = false,
    this.showTotalPrice = false,
    this.showSinglePrice = false,
    this.showOriginPrice = true,
  }) : super(type: .discountTable, leading: const Icon(Icons.discount_outlined));

  factory DiscountTableComponent.fromJson(Map<String, Object?> json, {required EdgeInsets padding}) {
    return DiscountTableComponent(
      padding: padding,
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
    emptyText: '',
  )!;

  @override
  Map<String, Object?> toJson() {
    return {
      ...super.toJson(),
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
    super.padding,
    this.showName = false,
    this.showOptionName = true,
    this.showAdjustment = true,
  }) : super(type: .attributeTable, leading: const Icon(Icons.attribution_outlined));

  factory AttributeTableComponent.fromJson(Map<String, Object?> json, {required EdgeInsets padding}) {
    return AttributeTableComponent(
      padding: padding,
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
    emptyText: '',
  )!;

  @override
  Map<String, Object?> toJson() {
    return {
      ...super.toJson(),
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
    super.padding,
    this.showPaid = true,
    this.showPrice = true,
    this.showChange = true,
    this.showProductsQuantity = false,
    this.showProductsPrice = false,
  }) : super(type: .priceTable, leading: const Icon(Icons.price_change_outlined));

  factory PriceTableComponent.fromJson(Map<String, Object?> json, {required EdgeInsets padding}) {
    return PriceTableComponent(
      padding: padding,
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
    emptyText: '',
  )!;

  @override
  Map<String, Object?> toJson() {
    return {
      ...super.toJson(),
      'showPaid': showPaid,
      'showPrice': showPrice,
      'showChange': showChange,
      'showProductsQuantity': showProductsQuantity,
      'showProductsPrice': showProductsPrice,
    };
  }
}

class TextFieldComponent extends ReceiptComponent {
  List<TextFieldObject> texts;
  TextAlign textAlign;

  TextFieldComponent({super.padding, this.texts = const [], this.textAlign = TextAlign.center})
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
      textAlign: TextAlign.values.elementAtOrNull(textAlign) ?? .center,
    );
  }

  @override
  Map<String, Object?> toJson() {
    return {...super.toJson(), 'texts': texts.map((e) => e.toJson()).toList(), 'textAlign': textAlign.index};
  }

  @override
  Widget buildDescription(BuildContext context) => RichText(
    text: TextSpan(children: texts.map((e) => e.buildDescription()).toList()),
    overflow: .ellipsis,
    maxLines: 1,
  );

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
    final formatter = format == ''
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
  Widget buildDescription(BuildContext context) => Text(S.printerReceiptComponentLabelDividerMeta(height));

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
  Widget? buildLeading(BuildContext context) {
    return CircleAvatar(foregroundImage: FileImage(XFile(imagePath).file));
  }

  @override
  Map<String, Object?> toJson() {
    return {...super.toJson(), 'imagePath': imagePath, 'widthRatio': widthRatio};
  }
}

abstract class TextFieldObject<T extends StyledPart> {
  final T part;

  const TextFieldObject({required this.part});

  Map<String, Object?> toJson();

  InlineSpan buildDescription();

  InlineSpan buildSpan({OrderObject? order});
}

class StyledTextObject extends TextFieldObject<StyledPart> {
  const StyledTextObject({super.part = const StyledPart(text: '', style: null)});

  factory StyledTextObject.fromJson(StyledPart part, Map<String, Object?> json) {
    return StyledTextObject(part: part);
  }

  factory StyledTextObject.fromText(String text) {
    return StyledTextObject(part: StyledPart(text: text, style: null));
  }

  @override
  Map<String, Object?> toJson() {
    return {'_part': part.toJson()};
  }

  @override
  InlineSpan buildDescription() {
    return buildSpan();
  }

  @override
  InlineSpan buildSpan({OrderObject? order}) {
    return TextSpan(text: part.text, style: part.style?.toTextStyle());
  }
}

class StyledPlaceholderObject extends TextFieldObject<PlaceholderPart> {
  final TextFieldPlaceholderType type;

  final String? meta;

  StyledPlaceholderObject({super.part = const PlaceholderPart(text: '', style: null)})
    : meta = part is MenuPlaceholderPart ? part.meta : null,
      type = TextFieldPlaceholderType.values.firstWhereOrNull((e) => e.name == part.text) ?? .title;

  factory StyledPlaceholderObject.fromJson(PlaceholderPart part, Map<String, Object?> json) {
    return StyledPlaceholderObject(part: part);
  }

  factory StyledPlaceholderObject.fromType(
    TextFieldPlaceholderType type, {
    String? meta,
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
    );
  }

  @override
  Map<String, Object?> toJson() {
    return {'_part': part.toJson()};
  }

  @override
  InlineSpan buildDescription() {
    return TextPlaceholder(
      id: part.text,
      text: S.printerReceiptComponentLabelTextPlaceholders(part.text),
    ).buildSpan(part.style?.toTextStyle());
  }

  @override
  InlineSpan buildSpan({OrderObject? order}) {
    return TextSpan(
      text: order == null ? '' : formatText(order: order),
      style: part.style?.toTextStyle(),
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
  title(),
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

  const TextFieldPlaceholderType({this.isDate = false});

  TextPlaceholder buildPlaceholder({Future<String?> Function(MenuPlaceholder<String>)? onMenuSelected}) {
    if (!isDate) {
      return TextPlaceholder(id: name, text: S.printerReceiptComponentLabelTextPlaceholders(name));
    }

    return MenuPlaceholder<String>(
      id: name,
      text: S.printerReceiptComponentLabelTextPlaceholders(name),
      meta: '',
      onMenuSelected: onMenuSelected,
    );
  }
}
