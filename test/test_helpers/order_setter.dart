import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/objects/order_attribute_object.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/services/database.dart';

import '../mocks/mock_database.dart';
import '../mocks/mock_database.mocks.dart';

class OrderSetter {
  static OrderObject sample({
    int id = 1,
    num price = 40,
  }) {
    return OrderObject(
      id: id,
      price: price,
      cost: 30,
      productsPrice: 20,
      productsCount: 10,
      createdAt: DateTime(2023, 3, 4, 5, 6, 7, 0, 0),
      products: [
        const OrderProductObject(
          id: 1,
          productName: 'p-1',
          catalogName: 'c-1',
          count: 5,
          singleCost: 6,
          singlePrice: 7,
          originalPrice: 8,
          isDiscount: true,
          ingredients: [
            OrderIngredientObject(
              id: 1,
              ingredientName: 'i-1',
              quantityName: 'q-1',
              additionalPrice: 1,
              additionalCost: 2,
              amount: 3,
            ),
            OrderIngredientObject(id: 2, ingredientName: 'i-2', amount: 0),
            OrderIngredientObject(id: 3, ingredientName: 'i-3', amount: -5),
          ],
        ),
        const OrderProductObject(
          id: 2,
          productName: 'p-2',
          catalogName: 'c-2',
          count: 15,
          singleCost: 10,
          singlePrice: 20,
          originalPrice: 30,
          isDiscount: false,
          ingredients: [],
        ),
      ],
      attributes: const [
        OrderSelectedAttributeObject(
          id: 1,
          name: 'oa-1',
          optionName: 'oao-1',
        ),
        OrderSelectedAttributeObject(
          id: 2,
          name: 'oa-2',
          optionName: 'oao-2',
          mode: OrderAttributeMode.changeDiscount,
          modeValue: 10,
        ),
      ],
    );
  }

  static void setOrder(OrderObject order) {
    final om = [order].map((e) {
      final m = e.toMap();
      m['id'] = e.id;
      return m;
    }).toList();
    when(database.query(
      Seller.orderTable,
      where: argThat(equals('id = ${order.id}'), named: 'where'),
    )).thenAnswer((_) => Future.value(om));

    final op = order.products.map((e) {
      final m = e.toMap();
      m['id'] = e.id;
      m['orderId'] = order.id;
      return m;
    }).toList();

    final oi = order.products
        .expand((e) => e.ingredients.map((i) {
              final m = i.toMap();
              m['id'] = i.id;
              m['orderId'] = order.id;
              m['orderProductId'] = e.id;
              return m;
            }))
        .toList();

    final oa = order.attributes.map((e) {
      final m = e.toMap();
      m['id'] = e.id;
      m['orderId'] = order.id;
      return m;
    }).toList();

    final txn = MockDatabaseExecutor();
    final batch = MockBatch();

    when(database.transaction(any)).thenAnswer((inv) => inv.positionalArguments[0](txn));
    when(txn.batch()).thenReturn(batch);
    when(batch.commit()).thenAnswer((_) => Future.value([op, oi, oa]));
  }

  static void setOrders(List<OrderObject> orders) {
    when(database.query(
      Seller.orderTable,
      columns: anyNamed('columns'),
      where: argThat(
        equals('${Seller.orderTable}.createdAt BETWEEN ? AND ?'),
        named: 'where',
      ),
      whereArgs: anyNamed('whereArgs'),
      orderBy: anyNamed('orderBy'),
      limit: argThat(equals(10), named: 'limit'),
      offset: anyNamed('offset'),
      join: anyNamed('join'),
      groupBy: anyNamed('groupBy'),
    )).thenAnswer((_) => Future.value(orders.map((e) {
          final m = e.toMap();
          m['id'] = e.id;
          m['pn'] = e.products.map((e) => e.productName).join(Database.delimiter);
          m['pc'] = e.products.map((e) => e.count).join(Database.delimiter);
          return m;
        }).toList()));
  }

  static void setMetrics(
    List<OrderObject> orders, {
    bool countingAll = false,
  }) {
    when(database.query(
      Seller.orderTable,
      columns: argThat(contains('COUNT(*) count'), named: 'columns'),
      where: anyNamed('where'),
      whereArgs: anyNamed('whereArgs'),
    )).thenAnswer((_) => Future.value([
          {
            "count": orders.length,
            "revenue": orders.fold<num>(0, (pre, e) => pre + e.price),
            "cost": orders.fold<num>(0, (pre, e) => pre + e.cost),
            "profit": orders.fold<num>(0, (pre, e) => pre + e.profit),
          }
        ]));

    if (!countingAll) return;

    when(database.query(
      Seller.productTable,
      columns: argThat(contains('COUNT(*) count'), named: 'columns'),
      where: anyNamed('where'),
      whereArgs: anyNamed('whereArgs'),
    )).thenAnswer((_) => Future.value([
          {"count": orders.fold<num>(0, (pre, e) => pre + e.products.length)}
        ]));
    when(database.query(
      Seller.ingredientTable,
      columns: argThat(contains('COUNT(*) count'), named: 'columns'),
      where: anyNamed('where'),
      whereArgs: anyNamed('whereArgs'),
    )).thenAnswer((_) => Future.value([
          {
            "count": orders.fold<num>(0, (pre, e) {
              return pre +
                  e.products.fold(0, (pre2, e2) {
                    return pre2 + e2.ingredients.length;
                  });
            })
          }
        ]));
    when(database.query(
      Seller.attributeTable,
      columns: argThat(contains('COUNT(*) count'), named: 'columns'),
      where: anyNamed('where'),
      whereArgs: anyNamed('whereArgs'),
    )).thenAnswer((_) => Future.value([
          {"count": orders.fold<num>(0, (pre, e) => pre + e.attributes.length)}
        ]));
  }

  static void setDetailedOrders(List<OrderObject> orders) {
    final om = orders.map((e) {
      final m = e.toMap();
      m['id'] = e.id;
      return m;
    }).toList();

    final op = orders
        .expand((order) => order.products.map((e) {
              final m = e.toMap();
              m['id'] = e.id;
              m['orderId'] = order.id;
              return m;
            }).toList())
        .toList();

    final oi = orders
        .expand((order) => order.products
            .expand((e) => e.ingredients.map((i) {
                  final m = i.toMap();
                  m['id'] = i.id;
                  m['orderId'] = order.id;
                  m['orderProductId'] = e.id;
                  return m;
                }))
            .toList())
        .toList();

    final oa = orders
        .expand((order) => order.attributes.map((e) {
              final m = e.toMap();
              m['id'] = e.id;
              m['orderId'] = order.id;
              return m;
            }).toList())
        .toList();

    final txn = MockDatabaseExecutor();
    final batch = MockBatch();

    when(database.transaction(any)).thenAnswer((inv) => inv.positionalArguments[0](txn));
    when(txn.batch()).thenReturn(batch);
    when(batch.commit()).thenAnswer((_) => Future.value([om, op, oi, oa]));
  }

  static void Function() setPushed(OrderObject order) {
    final txn = MockDatabaseExecutor();
    final checkers = <void Function()>[];
    final batches = <MockBatch>[];

    when(database.transaction(any)).thenAnswer((inv) => inv.positionalArguments[0](txn));

    final om = order.toMap();
    when(txn.insert(Seller.orderTable, om)).thenAnswer((_) => Future.value(1));

    for (var i = 0; i < order.products.length; i++) {
      final p = order.products[i];
      final m = p.toMap();
      m['orderId'] = order.id;
      m['createdAt'] = om['createdAt'];
      when(txn.insert(Seller.productTable, m)).thenAnswer((_) => Future.value(i + 1));

      final batch = MockBatch();
      batches.add(batch);
      for (final ing in p.ingredients) {
        final m = ing.toMap();
        m['orderId'] = order.id;
        m['orderProductId'] = i + 1;
        m['createdAt'] = om['createdAt'];
        checkers.add(() => verify(batch.insert(Seller.ingredientTable, m)));
      }
    }

    final batch = MockBatch();
    batches.add(batch);
    for (final attr in order.attributes) {
      final m = attr.toMap();
      m['orderId'] = order.id;
      m['createdAt'] = om['createdAt'];
      checkers.add(() => verify(batch.insert(Seller.attributeTable, m)));
    }

    when(txn.batch()).thenReturnInOrder(batches);
    for (final b in batches) {
      when(b.commit(noResult: argThat(isTrue, named: 'noResult'))).thenAnswer((_) => Future.value([]));
    }

    return () {
      for (final checker in checkers) {
        checker();
      }
    };
  }
}
