import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/model_object.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/models/stock/replenishment.dart';

class IngredientObject extends ModelObject<Ingredient> {
  String? id;
  String? name;
  num? currentAmount;
  num? totalAmount;
  num? restockPrice;
  num? restockQuantity;
  num? restockLastPrice;
  num? lastAmount;
  DateTime? updatedAt;
  bool fromModal;

  IngredientObject({
    this.id,
    this.name,
    this.currentAmount,
    this.totalAmount,
    this.restockPrice,
    this.restockQuantity,
    this.restockLastPrice,
    this.lastAmount,
    this.updatedAt,
    this.fromModal = false,
  });

  @override
  Map<String, Object?> toMap() {
    return {
      'name': name,
      'currentAmount': currentAmount,
      'restockPrice': restockPrice,
      'restockQuantity': restockQuantity,
      'restockLastPrice': restockLastPrice,
      'lastAmount': lastAmount,
      'totalAmount': totalAmount,
      'updatedAt': updatedAt == null ? null : Util.toUTC(now: updatedAt),
    };
  }

  @override
  Map<String, Object?> diff(Ingredient model) {
    final result = <String, Object?>{};
    final prefix = model.prefix;

    if (name != null && name != model.name) {
      model.name = name!;
      result['$prefix.name'] = name!;
    }
    if (restockPrice != null && restockPrice != model.restockPrice) {
      model.restockPrice = restockPrice;
      result['$prefix.restockPrice'] = restockPrice!;
    }
    if (restockQuantity != null && restockQuantity != model.restockQuantity) {
      model.restockQuantity = restockQuantity!;
      result['$prefix.restockQuantity'] = restockQuantity!;
    }
    if (restockLastPrice != null && restockLastPrice != model.restockLastPrice) {
      model.restockLastPrice = restockLastPrice;
      result['$prefix.restockLastPrice'] = restockLastPrice!;
    }
    if (currentAmount != null && currentAmount != model.currentAmount) {
      model.currentAmount = currentAmount!;
      result['$prefix.currentAmount'] = currentAmount!;
    }
    if (lastAmount != null && lastAmount != model.lastAmount) {
      model.lastAmount = lastAmount;
      result['$prefix.lastAmount'] = lastAmount!;
    }
    if ((fromModal || totalAmount != null) && totalAmount != model.totalAmount) {
      model.totalAmount = totalAmount;
      result['$prefix.totalAmount'] = totalAmount;
    }

    if (result.isNotEmpty) {
      // should not only change currentAmount
      if (!(result.length == 1 && result.containsKey('$prefix.currentAmount'))) {
        model.updatedAt = DateTime.now();
        result['$prefix.updatedAt'] = model.updatedAt.toString();
      }
    }

    return result;
  }

  factory IngredientObject.build(Map<String, Object?> data) {
    return IngredientObject(
      id: data['id'] as String,
      name: data['name'] as String,
      currentAmount: data['currentAmount'] as num?,
      restockPrice: data['restockPrice'] as num?,
      restockQuantity: data['restockQuantity'] as num?,
      restockLastPrice: data['restockLastPrice'] as num?,
      lastAmount: data['lastAmount'] as num?,
      totalAmount: data['totalAmount'] as num?,
      updatedAt: data['updatedAt'] == null ? null : DateTime.parse(data['updatedAt'] as String),
    );
  }
}

class QuantityObject extends ModelObject<Quantity> {
  QuantityObject({
    this.id,
    this.name,
    this.defaultProportion,
  });

  final String? id;
  final String? name;
  final num? defaultProportion;

  @override
  Map<String, Object> toMap() {
    return {
      'name': name!,
      'defaultProportion': defaultProportion!,
    };
  }

  @override
  Map<String, Object> diff(Quantity model) {
    final result = <String, Object>{};
    final prefix = model.prefix;

    if (name != null && name != model.name) {
      model.name = name!;
      result['$prefix.name'] = name!;
    }
    if (defaultProportion != null && defaultProportion != model.defaultProportion) {
      model.defaultProportion = defaultProportion!;
      result['$prefix.defaultProportion'] = defaultProportion!;
    }

    return result;
  }

  factory QuantityObject.build(Map<String, Object?> data) {
    return QuantityObject(
      id: data['id'] as String,
      name: data['name'] as String,
      defaultProportion: data['defaultProportion'] as num,
    );
  }
}

class ReplenishmentObject extends ModelObject<Replenishment> {
  ReplenishmentObject({
    this.id,
    required this.name,
    required this.data,
  });

  String name;
  Map<String, num> data;
  final String? id;

  @override
  Map<String, Object> toMap() {
    return {
      'name': name,
      'data': data,
    };
  }

  @override
  Map<String, Object> diff(Replenishment model) {
    final result = <String, Object>{};
    final prefix = model.prefix;

    if (name != model.name) {
      model.name = name;
      result['$prefix.name'] = name;
    }
    data.forEach((key, value) {
      if (model.getNumOfId(key) != value) {
        model.data[key] = value;
        result['$prefix.data.$key'] = value;
      }
    });

    return result;
  }

  factory ReplenishmentObject.build(Map<String, Object?> data) {
    final replenishmentData = <String, num>{};
    final oriData = data['data'];

    if (oriData is Map) {
      oriData.forEach((key, value) {
        if (value != 0) {
          replenishmentData[key] = value;
        }
      });
    }

    return ReplenishmentObject(
      id: data['id'] as String,
      name: data['name'] as String,
      data: replenishmentData,
    );
  }
}
