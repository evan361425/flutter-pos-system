import 'package:possystem/helper/util.dart';
import 'package:possystem/models/stock/ingredient_model.dart';
import 'package:possystem/models/stock/quantity_model.dart';
import 'package:possystem/models/stock/stock_batch_model.dart';

class StockObject {
  StockObject({
    this.updatedTime,
    this.ingredients,
  });

  final DateTime updatedTime;
  final Iterable<IngredientObject> ingredients;

  factory StockObject.build(Map<String, dynamic> data) {
    Map<String, Map<String, dynamic>> ingredients = data['ingredients'];

    return StockObject(
      updatedTime: Util.parseDate(data['updatedTime'], true),
      ingredients: ingredients?.entries?.map<IngredientObject>(
        (e) => IngredientObject.build({'id': e.key, ...e.value}),
      ),
    );
  }
}

class IngredientObject {
  IngredientObject({
    this.id,
    this.name,
    this.currentAmount,
    this.warningAmount,
    this.alertAmount,
    this.lastAmount,
    this.lastAddAmount,
  });

  String id;
  String name;
  num currentAmount;
  num warningAmount;
  num alertAmount;
  num lastAmount;
  num lastAddAmount;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'currentAmount': currentAmount,
      'warningAmount': warningAmount,
      'alertAmount': alertAmount,
      'lastAmount': lastAmount,
      'lastAddAmount': lastAddAmount,
    };
  }

  Map<String, dynamic> diff(IngredientModel ingredient) {
    final result = <String, dynamic>{};
    final prefix = ingredient.prefix;

    if (name != null && name != ingredient.name) {
      ingredient.name = name;
      result['$prefix.name'] = name;
    }
    if (currentAmount != null && currentAmount != ingredient.currentAmount) {
      ingredient.currentAmount = currentAmount;
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

    return result;
  }

  factory IngredientObject.build(Map<String, dynamic> data) {
    return IngredientObject(
      id: data['id'],
      name: data['name'],
      currentAmount: data['currentAmount'],
      warningAmount: data['warningAmount'],
      alertAmount: data['alertAmount'],
      lastAmount: data['lastAmount'],
      lastAddAmount: data['lastAddAmount'],
    );
  }
}

class QuantityObject {
  QuantityObject({
    this.id,
    this.name,
    this.defaultProportion,
  });

  final String id;
  final String name;
  final num defaultProportion;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'defaultProportion': defaultProportion,
    };
  }

  Map<String, dynamic> diff(QuantityModel quantity) {
    final result = <String, dynamic>{};
    final prefix = quantity.prefix;

    if (name != null && name != quantity.name) {
      quantity.name = name;
      result['$prefix.name'] = name;
    }
    if (defaultProportion != null &&
        defaultProportion != quantity.defaultProportion) {
      quantity.defaultProportion = defaultProportion;
      result['$prefix.defaultProportion'] = defaultProportion;
    }

    return result;
  }

  factory QuantityObject.build(Map<String, dynamic> data) {
    return QuantityObject(
      id: data['id'],
      name: data['name'],
      defaultProportion: data['defaultProportion'],
    );
  }
}

class StockBatchObject {
  StockBatchObject({
    this.name,
    this.id,
    this.data,
  });

  String name;
  final Map<String, num> data;
  final String id;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'data': data,
    };
  }

  Map<String, dynamic> diff(StockBatchModel batch) {
    final result = <String, dynamic>{};
    final prefix = batch.prefix;

    if (name != null && name != batch.name) {
      batch.name = name;
      result['$prefix.name'] = name;
    }
    if (data != null) {
      data.forEach((key, value) {
        if (batch.data[key] != value) {
          batch.data[key] = value;
          result['$prefix.data.$key'] = value;
        }
      });
    }

    return result;
  }

  factory StockBatchObject.build(Map<String, dynamic> data) {
    final batchData = <String, num>{};
    final oriData = data['data'];

    if (oriData is Map) {
      oriData.forEach((key, value) {
        batchData[key] = num.tryParse(value);
      });
    }

    return StockBatchObject(
      id: data['id'],
      name: data['name'],
      data: batchData,
    );
  }
}
