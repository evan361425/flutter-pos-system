import 'package:collection/collection.dart';
import 'package:possystem/models/model.dart';
import 'package:possystem/models/order/order_attribute_option.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/services/cache.dart';

/// Table names used by the [Seller] repository & analytics.
///
/// Extracted from the former God Object so both [SellerRepository] and
/// [SellerAnalyticsQueries] can reference them without a circular import
/// through the [Seller] facade.
class SellerTables {
  static const String order = 'order_records';
  static const String product = 'order_products';
  static const String ingredient = 'order_ingredients';
  static const String attribute = 'order_attributes';

  const SellerTables._();
}

/// Metrics from `Seller.getMetrics`.
class OrderMetrics {
  /// Total count of orders in specific day range.
  final int count;

  /// Total revenue of orders in specific day range.
  final num revenue;

  /// Total cost of orders in specific day range.
  final num cost;

  /// Total (net) profit of orders in specific day range.
  final num profit;

  /// How many rows in the table of products.
  final int? productCount;

  /// How many rows in the table of ingredients.
  final int? ingredientCount;

  /// How many rows in the table of order attributes.
  final int? attrCount;

  const OrderMetrics._({
    required this.cost,
    required this.revenue,
    required this.count,
    required this.profit,
    this.productCount,
    this.ingredientCount,
    this.attrCount,
  });

  /// Directly from DB data.
  factory OrderMetrics.fromMap(
    Map<String, Object?> map, {
    int? productCount,
    int? ingredientCount,
    int? attrCount,
  }) {
    return OrderMetrics._(
      count: map['count'] as int? ?? 0,
      revenue: map['revenue'] as num? ?? 0,
      cost: map['cost'] as num? ?? 0,
      profit: map['profit'] as num? ?? 0,
      productCount: productCount,
      ingredientCount: ingredientCount,
      attrCount: attrCount,
    );
  }
}

class OrderSummary {
  final DateTime at;

  final Map<String, num> values;

  const OrderSummary({required this.at, this.values = const {}});

  num value(String key) {
    return values[key] ?? 0;
  }

  int get count => value('count').toInt();

  num get revenue => value('revenue');

  num get cost => value('cost');

  num get profit => value('profit');
}

class OrderMetricPerItem {
  final String name;
  final num value;
  final double percent;

  OrderMetricPerItem(this.name, this.value, num total)
    : percent = total == 0 ? 0 : value / total;
}

/// Reset-ID period configuration persisted in [Cache].
///
/// Pure data + date arithmetic; no SQL and no I/O beyond the KV cache.
class Period {
  final List<int> values;
  final PeriodUnit unit;

  const Period({required this.values, required this.unit});

  factory Period.fromCache() {
    final idx = Cache.instance.get<int>('order.resetIdPeriod.unit');
    final values = Cache.instance
        .get<String>('order.resetIdPeriod.values')
        ?.split(',')
        .map(int.tryParse)
        .toList();
    if (values?.every((e) => e != null) == true && idx != null) {
      return Period(unit: PeriodUnit.values[idx], values: values!.cast<int>());
    }

    return const Period(unit: PeriodUnit.everyXDays, values: []);
  }

  static DateTime today() {
    final DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static Future<bool> cacheNext(DateTime next) {
    return Cache.instance.set<int>(
      'order.resetIdPeriod.next',
      next.millisecondsSinceEpoch,
    );
  }

  bool get isInvalid => values.isEmpty;

  Future<DateTime> saveToCache() async {
    final today = Period.today();
    final next = nextDate(today, today);

    await Cache.instance.set<int>('order.resetIdPeriod.unit', unit.index);
    await Cache.instance.set<String>(
      'order.resetIdPeriod.values',
      values.join(','),
    );
    await Cache.instance.set<int>(
      'order.resetIdPeriod.next',
      next.millisecondsSinceEpoch,
    );

    return next;
  }

  DateTime? nextDateFromCache() {
    final next = Cache.instance.get<int>('order.resetIdPeriod.next');
    if (next == null) {
      return null;
    }

    return DateTime.fromMillisecondsSinceEpoch(next);
  }

  DateTime nextDate(DateTime last, DateTime today) {
    assert(
      last.isBefore(today) || last == today,
      'Last date must be before today',
    );

    switch (unit) {
      case PeriodUnit.everyXDays:
        // (x / y).floor() * y + y == x - (x % y) + y
        final x = today.difference(last).inDays;
        final y = values.first;
        return last.add(Duration(days: x - (x % y) + y));
      case PeriodUnit.everyXWeeks:
        final x = today.difference(last).inDays;
        final y = values.first * 7;
        return last.add(Duration(days: x - (x % y) + y));
      case PeriodUnit.xDayOfEachWeek:
        final todayDay = today.weekday;
        final nextDay = values.firstWhereOrNull((day) => day > todayDay);

        if (nextDay == null) {
          // If no next day in this week, go to the first day of the next week
          return today.add(Duration(days: 7 - todayDay + values.first));
        }

        // If there is a next day in this week, return that day
        return today.add(Duration(days: nextDay - todayDay));
      case PeriodUnit.xDayOfEachMonth:
        final todayDay = today.day;
        final nextDay = values.firstWhereOrNull((day) => day > todayDay);

        if (nextDay != null) {
          return DateTime(today.year, today.month, nextDay);
        }

        // If no next day in this month, go to the first day of the next month
        return DateTime(today.year, today.month + 1, values.first);
    }
  }

  @override
  String toString() {
    return '${unit.name}: ${values.join(', ')}';
  }
}

enum OrderMetricUnit {
  money(r'${value}', r'$point.y'),
  count(r'{value}', r'point.y');

  final String labelFormat;
  final String tooltipFormat;

  const OrderMetricUnit(this.labelFormat, this.tooltipFormat);
}

enum OrderMetricType {
  revenue('SUM', 'price', 'singlePrice * count', OrderMetricUnit.money),
  cost('SUM', 'cost', 'singleCost * count', OrderMetricUnit.money),
  // profit = price - cost, we use `revenue` for historical reason.
  profit(
    'SUM',
    'revenue',
    '(singlePrice - singleCost) * count',
    OrderMetricUnit.money,
  ),
  count('COUNT', 'price', '*', OrderMetricUnit.count);

  /// The method to calculate the value in DB.
  final String method;

  /// The source column to execute [method].
  final String column;

  /// Target item column.
  final String targetColumn;

  /// The unit on chart.
  final OrderMetricUnit unit;

  const OrderMetricType(this.method, this.column, this.targetColumn, this.unit);
}

enum OrderMetricTarget {
  order(SellerTables.order, '', ''),
  catalog(SellerTables.product, 'catalogName', 'catalogName'),
  product(SellerTables.product, 'productName', 'productName'),
  ingredient(SellerTables.ingredient, 'ingredientName', 'ingredientName'),
  attribute(SellerTables.attribute, 'name', 'optionName');

  /// The table name in DB.
  final String table;

  /// The column use on `where` syntax in DB.
  final String filterColumn;

  /// The column use on `group` syntax in DB.
  final String groupColumn;

  const OrderMetricTarget(this.table, this.filterColumn, this.groupColumn);

  /// Whether the filter column is different from the group column.
  bool get hasDifferentColumn => filterColumn != groupColumn;

  /// Whether append parenthesis to the name when grouped.
  bool isGroupedName(List<String> selection) =>
      hasDifferentColumn && selection.length != 1;

  /// Get the items from the target.
  ///
  /// - [selection] null and empty means select all
  List<Model> getItems([List<String>? selection]) {
    if (this == OrderMetricTarget.attribute && selection != null) {
      if (selection.isEmpty) {
        return OrderAttributes.instance.itemList
            .expand((e) => e.itemList)
            .toList();
      }

      return selection
          .expand<OrderAttributeOption>(
            (id) =>
                OrderAttributes.instance.getItemByName(id)?.itemList ??
                const [],
          )
          .toList();
    }

    final result = switch (this) {
      OrderMetricTarget.product =>
        Menu.instance.products.toList() as List<Model>,
      OrderMetricTarget.catalog => Menu.instance.itemList,
      OrderMetricTarget.ingredient => Stock.instance.itemList,
      OrderMetricTarget.attribute => OrderAttributes.instance.itemList,
      _ => const <Model>[],
    };

    // null and empty means select all
    if (selection == null || selection.isEmpty) {
      return result;
    }

    return result.where((e) => selection.contains(e.name)).toList();
  }
}

enum MetricsIntervalType {
  hour(3600, 'HH:mm a'),
  day(86400, 'MMMEd'),
  month(2592000, 'MMMd');

  final int seconds;
  final String format;

  factory MetricsIntervalType.fromDays(int days) {
    if (days > 62) {
      return month;
    }

    if (days > 2) {
      return day;
    }

    return hour;
  }

  const MetricsIntervalType(this.seconds, this.format);
}

enum PeriodUnit {
  everyXDays(),
  everyXWeeks(),
  xDayOfEachWeek(onlyOneValue: false),
  xDayOfEachMonth(onlyOneValue: false);

  final bool onlyOneValue;

  const PeriodUnit({this.onlyOneValue = true});
}
