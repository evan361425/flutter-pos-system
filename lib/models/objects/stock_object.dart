import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/model_object.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/models/stock/replenishment.dart';

class IngredientObject extends ModelObject<Ingredient> {
  IngredientObject({
    this.id,
    this.name,
    this.currentAmount,
    this.warningAmount,
    this.alertAmount,
    this.lastAmount,
    this.lastAddAmount,
    this.updatedAt,
  });

  String? id;
  String? name;
  num? currentAmount;
  num? warningAmount;
  num? alertAmount;
  num? lastAmount;
  num? lastAddAmount;
  DateTime? updatedAt;

  @override
  Map<String, Object?> toMap() {
    return {
      'name': name,
      'currentAmount': currentAmount,
      'warningAmount': warningAmount,
      'alertAmount': alertAmount,
      'lastAmount': lastAmount,
      'lastAddAmount': lastAddAmount,
      'updatedAt': updatedAt == null ? null : Util.toUTC(now: updatedAt),
    };
  }

  @override
  Map<String, Object> diff(Ingredient model) {
    final result = <String, Object>{};
    final prefix = model.prefix;

    if (name != null && name != model.name) {
      model.name = name!;
      result['$prefix.name'] = name!;
    }
    if (currentAmount != null && currentAmount != model.currentAmount) {
      model.currentAmount = currentAmount!;
      result['$prefix.currentAmount'] = currentAmount!;
    }
    if (lastAmount != null && lastAmount != model.lastAmount) {
      model.lastAmount = lastAmount;
      result['$prefix.lastAmount'] = lastAmount!;
    }
    if (lastAddAmount != null && lastAddAmount != model.lastAddAmount) {
      model.lastAddAmount = lastAddAmount;
      result['$prefix.lastAddAmount'] = lastAddAmount!;
    }

    if (result.isNotEmpty) {
      model.updatedAt = DateTime.now();
      result['$prefix.updatedAt'] = model.updatedAt.toString();
    }

    return result;
  }

  factory IngredientObject.build(Map<String, Object?> data) {
    return IngredientObject(
      id: data['id'] as String,
      name: data['name'] as String,
      currentAmount: data['currentAmount'] as num?,
      warningAmount: data['warningAmount'] as num?,
      alertAmount: data['alertAmount'] as num?,
      lastAmount: data['lastAmount'] as num?,
      lastAddAmount: data['lastAddAmount'] as num?,
      updatedAt: data['updatedAt'] == null
          ? null
          : DateTime.parse(data['updatedAt'] as String),
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
    if (defaultProportion != null &&
        defaultProportion != model.defaultProportion) {
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
