import 'package:possystem/helper/util.dart';
import 'package:possystem/models/stock/ingredient_model.dart';
import 'package:possystem/models/stock/quantity_model.dart';
import 'package:possystem/models/stock/stock_batch_model.dart';

class IngredientObject {
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

  Map<String, Object?> toMap() {
    return {
      'name': name,
      'currentAmount': currentAmount,
      'warningAmount': warningAmount,
      'alertAmount': alertAmount,
      'lastAmount': lastAmount,
      'lastAddAmount': lastAddAmount,
      'updatedAt': updatedAt.toString(),
    };
  }

  Map<String, Object?> diff(IngredientModel ingredient) {
    final result = <String, Object?>{};
    final prefix = ingredient.prefix;

    if (name != null && name != ingredient.name) {
      ingredient.name = name!;
      result['$prefix.name'] = name;
    }
    if (currentAmount != null && currentAmount != ingredient.currentAmount) {
      ingredient.currentAmount = currentAmount!;
      result['$prefix.currentAmount'] = currentAmount;
    }
    if (warningAmount != null && warningAmount != ingredient.warningAmount) {
      ingredient.warningAmount = warningAmount;
      result['$prefix.warningAmount'] = warningAmount;
    }
    if (alertAmount != null && alertAmount != ingredient.alertAmount) {
      ingredient.alertAmount = alertAmount;
      result['$prefix.alertAmount'] = alertAmount;
    }
    if (lastAmount != null && lastAmount != ingredient.lastAmount) {
      ingredient.lastAmount = lastAmount;
      result['$prefix.lastAmount'] = lastAmount;
    }
    if (lastAddAmount != null && lastAddAmount != ingredient.lastAddAmount) {
      ingredient.lastAddAmount = lastAddAmount;
      result['$prefix.lastAddAmount'] = lastAddAmount;
    }

    if (result.isNotEmpty) {
      ingredient.updatedAt = DateTime.now();
      result['$prefix.updatedAt'] = ingredient.updatedAt.toString();
    }

    return result;
  }

  factory IngredientObject.build(Map<String, Object?> data) {
    return IngredientObject(
      id: data['id'] as String?,
      name: data['name'] as String?,
      currentAmount: data['currentAmount'] as num?,
      warningAmount: data['warningAmount'] as num?,
      alertAmount: data['alertAmount'] as num?,
      lastAmount: data['lastAmount'] as num?,
      lastAddAmount: data['lastAddAmount'] as num?,
      updatedAt: Util.parseDate(data['updatedTime'] as String?, true),
    );
  }
}

class QuantityObject {
  QuantityObject({
    this.id,
    this.name,
    this.defaultProportion,
  });

  final String? id;
  final String? name;
  final num? defaultProportion;

  Map<String, Object?> toMap() {
    return {
      'name': name,
      'defaultProportion': defaultProportion,
    };
  }

  Map<String, Object?> diff(QuantityModel quantity) {
    final result = <String, Object?>{};
    final prefix = quantity.prefix;

    if (name != null && name != quantity.name) {
      quantity.name = name!;
      result['$prefix.name'] = name;
    }
    if (defaultProportion != null &&
        defaultProportion != quantity.defaultProportion) {
      quantity.defaultProportion = defaultProportion!;
      result['$prefix.defaultProportion'] = defaultProportion;
    }

    return result;
  }

  factory QuantityObject.build(Map<String, Object?> data) {
    return QuantityObject(
      id: data['id'] as String?,
      name: data['name'] as String?,
      defaultProportion: data['defaultProportion'] as num?,
    );
  }
}

class StockBatchObject {
  StockBatchObject({
    this.id,
    this.name,
    this.data,
  });

  String? name;
  Map<String, num>? data;
  final String? id;

  Map<String, Object?> toMap() {
    return {
      'name': name,
      'data': data,
    };
  }

  Map<String, Object?> diff(StockBatchModel batch) {
    final result = <String, Object?>{};
    final prefix = batch.prefix;

    if (name != null && name != batch.name) {
      batch.name = name!;
      result['$prefix.name'] = name;
    }
    if (data != null) {
      data!.forEach((key, value) {
        if (batch.data[key] != value) {
          batch.data[key] = value;
          result['$prefix.data.$key'] = value;
        }
      });
    }

    return result;
  }

  factory StockBatchObject.build(Map<String, Object?> data) {
    final batchData = <String, num>{};
    final oriData = data['data'];

    if (oriData is Map) {
      oriData.forEach((key, value) {
        batchData[key] = value;
      });
    }

    return StockBatchObject(
      id: data['id'] as String,
      name: data['name'] as String,
      data: batchData,
    );
  }
}
