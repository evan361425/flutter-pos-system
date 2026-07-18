import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/objects/order_ingredient_object.dart';
import 'package:possystem/models/objects/order_product_object.dart';
import 'package:possystem/models/objects/order_selected_attribute_object.dart';
import 'package:possystem/models/objects/order_serializable.dart';
import 'package:possystem/models/order/cart_product.dart';
import 'package:possystem/models/order/payment_intent.dart';
import 'package:possystem/models/repository/menu.dart';

export 'order_ingredient_object.dart';
export 'order_product_object.dart';
export 'order_selected_attribute_object.dart';

/// Order in object mode, helps I/O in DB.
class OrderObject extends OrderSerializable {
  /// ID of database row
  final int? id;

  /// Periodic sequence, number of each order and may reset periodically.
  final int? periodSeq;

  /// Typed payment lines (cash / card / voucher).
  final List<PaymentIntent> payments;

  /// Aggregated tax amount for the order.
  final num totalTax;

  /// The cost of order.
  final num cost;

  /// The price of order, all products' price and order attribute's price.
  final num price;

  /// Note for the order.
  final String note;

  /// The count of products.
  final int productsCount;

  /// All products' price.
  final num productsPrice;

  /// Attributes details of the order.
  final List<OrderSelectedAttributeObject> attributes;

  /// All product details.
  final List<OrderProductObject> products;

  /// Order created time, important property to sort.
  final DateTime createdAt;

  /// Linked [DiningTable.id] for dine-in; null for takeaway / counter orders.
  final String? tableId;

  /// Guest count (couverts). Null means "no pax" (takeaway), distinct from 0.
  final int? pax;

  /// [Employee.id] of the staff member who created / checked out this order.
  final String? employeeId;

  /// [Shift.id] of the open cash-register shift when this order was checked out.
  final String? shiftId;

  /// [payments] takes precedence when non-null.
  /// Legacy [paid] hydrates a single cash [PaymentIntent] for API compatibility.
  OrderObject({
    this.id,
    this.periodSeq = 0,
    List<PaymentIntent>? payments,
    num paid = 0,
    this.totalTax = 0,
    this.cost = 0,
    this.price = 0,
    this.note = '',
    this.productsCount = 0,
    this.productsPrice = 0,
    this.attributes = const [],
    this.products = const [],
    required this.createdAt,
    this.tableId,
    this.pax,
    this.employeeId,
    this.shiftId,
  }) : payments = payments ?? _paymentsFromLegacyPaid(paid);

  /// Sum of all payment intents (legacy column / UI compatibility).
  num get paid => payments.fold<num>(0, (sum, p) => sum + p.amount);

  /// Price before tax (grand [price] minus [totalTax]).
  num get subtotal => price - totalTax;

  /// Profit on taxable base: [subtotal] minus [cost].
  num get profit => subtotal - cost;

  /// Order-attribute delta: [subtotal] minus [productsPrice].
  num get attributesPrice => subtotal - productsPrice;

  /// Given change, [paid] minus [price].
  num get change => paid - price;

  /// Get [products] as [CartProduct].
  ///
  /// Help to restore from stash.
  Iterable<CartProduct> get productModels sync* {
    for (final object in products) {
      final product = Menu.instance.getProduct(object.productId);

      if (product == null) continue;

      yield CartProduct(
        product,
        count: object.count,
        singlePrice: object.singlePrice,
        note: object.note,
        quantities: {
          for (final item in object.ingredients)
            if (item.productQuantityId != null)
              item.productIngredientId: item.productQuantityId!,
        },
      );
    }
  }

  /// Get [attributes] as map.
  ///
  /// Help to restore from stash.
  Map<String, String> get selectedAttributes => {
    for (final attr in attributes) attr.attributeId: attr.optionId,
  };

  String get createDateTimeString =>
      DateFormat.MMMd().addPattern(' ').add_Hms().format(createdAt);

  String get createTimeString => DateFormat.Hm().format(createdAt);

  /// Update the amounts of stock by the ordered ingredients.
  void applyToStock(Map<String, num> amounts, {required bool add}) {
    for (final product in products) {
      for (final ing in product.ingredients) {
        final val = add ? ing.amount : -ing.amount;
        amounts[ing.ingredientId] = (amounts[ing.ingredientId] ?? 0) + val;
      }
    }
  }

  @override
  Map<String, Object?> toMap() {
    return {
      'periodSeq': periodSeq,
      'paid': paid,
      'payments': jsonEncode(payments.map((e) => e.toMap()).toList()),
      'totalTax': totalTax,
      'price': price,
      'cost': cost,
      'revenue': profit,
      'note': note,
      'productsPrice': productsPrice,
      'productsCount': productsCount,
      'attributesPrice': attributesPrice,
      'createdAt': Util.toUTC(now: createdAt),
      'table_id': tableId,
      'pax': pax,
      'employee_id': employeeId,
      'shift_id': shiftId,
    };
  }

  @override
  Map<String, Object?> toStashMap() {
    return {
      'note': note,
      'encodedProducts': jsonEncode(
        products.map((e) => e.toStashMap()).toList(),
      ),
      'encodedAttributes': jsonEncode(
        attributes.map((e) => e.toStashMap()).toList(),
      ),
      'createdAt': Util.toUTC(now: createdAt),
      'table_id': tableId,
      'pax': pax,
      'employee_id': employeeId,
    };
  }

  /// Create object from DB format.
  factory OrderObject.fromMap(
    Map<String, Object?> order,
    Iterable<Map<String, Object?>> products, [
    List<Map<String, Object?>> ingredients = const [],
    List<Map<String, Object?>> attributes = const [],
  ]) {
    // null-safety to make test easy
    return OrderObject(
      id: order['id'] as int? ?? 0,
      periodSeq: order['periodSeq'] as int? ?? 0,
      payments: _parsePayments(order),
      totalTax: order['totalTax'] as num? ?? 0,
      cost: order['cost'] as num? ?? 0,
      price: order['price'] as num? ?? 0,
      note: order['note'] as String? ?? '',
      productsCount: order['productsCount'] as int? ?? 0,
      productsPrice: order['productsPrice'] as num? ?? 0,
      products: [
        for (Map<String, dynamic> product in products)
          OrderProductObject.fromMap(product, ingredients),
      ],
      attributes: [
        for (Map<String, dynamic> attr in attributes)
          OrderSelectedAttributeObject.fromMap(attr),
      ],
      createdAt: Util.fromUTC(order['createdAt'] as int? ?? 0),
      tableId: order['table_id'] as String?,
      pax: (order['pax'] as num?)?.toInt(),
      employeeId: order['employee_id'] as String?,
      shiftId: order['shift_id'] as String?,
    );
  }

  /// Create object from DB format.
  factory OrderObject.fromStashMap(Map<String, Object?> data) {
    final products = _safeParseList(data['encodedProducts'] as String?);
    final attributes = _safeParseList(data['encodedAttributes'] as String?);

    return OrderObject(
      id: data['id'] as int?,
      note: data['note'] as String? ?? '',
      attributes: attributes
          .map((e) => OrderSelectedAttributeObject.fromStashMap(e))
          .toList(),
      products: products
          .map((e) => OrderProductObject.fromStashMap(e))
          .toList(),
      createdAt: Util.fromUTC(data['createdAt'] as int? ?? 0),
      tableId: data['table_id'] as String?,
      pax: (data['pax'] as num?)?.toInt(),
      employeeId: data['employee_id'] as String?,
    );
  }
}

List<PaymentIntent> _paymentsFromLegacyPaid(num paid) {
  if (paid == 0) return const [];
  return [PaymentIntent(amount: paid, method: PaymentMethod.cash)];
}

List<PaymentIntent> _parsePayments(Map<String, Object?> order) {
  final raw = order['payments'];
  if (raw is String && raw.isNotEmpty) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return [
          for (final item in decoded)
            if (item is Map<String, dynamic>)
              PaymentIntent.fromMap(item)
            else if (item is Map)
              PaymentIntent.fromMap(Map<String, dynamic>.from(item)),
        ];
      }
    } catch (_) {
      // Fall through to legacy paid column.
    }
  }

  return _paymentsFromLegacyPaid(order['paid'] as num? ?? 0);
}

List<dynamic> _safeParseList(String? source) {
  try {
    return jsonDecode(source ?? '');
  } catch (e) {
    return const [];
  }
}
