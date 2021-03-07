import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:possystem/services/database.dart';

import 'product_model.dart';

class IngredientModel {
  IngredientModel({
    @required this.name,
    @required this.product,
    this.defaultAmount = 0,
    Map<String, IngredientSet> additionalSets,
  }) : additionalSets = additionalSets ?? {};

  String name;
  num defaultAmount;
  final ProductModel product;
  final Map<String, IngredientSet> additionalSets;

  factory IngredientModel.fromMap({
    ProductModel product,
    String name,
    Map<String, dynamic> data,
  }) {
    final oriAdditionalSets = data['additionalSets'];
    final additionalSets = <String, IngredientSet>{};

    if (oriAdditionalSets is Map) {
      oriAdditionalSets.forEach((key, additionalSet) {
        if (additionalSet is Map) {
          additionalSets[key] = IngredientSet.fromMap(key, additionalSet);
        }
      });
    }

    return IngredientModel(
      name: name,
      product: product,
      defaultAmount: data['defaultAmount'],
      additionalSets: additionalSets,
    );
  }

  factory IngredientModel.empty(ProductModel product) {
    return IngredientModel(name: null, product: product);
  }

  Map<String, dynamic> toMap() {
    return {
      'defaultAmount': defaultAmount,
      'additionalSets': {
        for (var entry in additionalSets.entries) entry.key: entry.value.toMap()
      },
    };
  }

  // STATE CHANGE

  Future<void> add(IngredientSet newSet) async {
    await Database.service.update(Collections.menu, {
      '$prefix.additionalSets.${newSet.name}': newSet.toMap(),
    });

    additionalSets[newSet.name] = newSet;
    product.changeIngredient();
  }

  Future<void> update({
    String name,
    num defaultAmount,
    bool updateDB = true,
  }) async {
    final updateData = getUpdateData(
      name: name,
      defaultAmount: defaultAmount,
    );
    if (updateData.isEmpty) return;

    if (!updateDB) {
      this.name = name;
      return;
    }

    return Database.service.update(Collections.menu, updateData).then((_) {
      if (name == this.name) {
        product.changeIngredient();
      } else {
        product.changeIngredient(oldName: this.name, newName: name);
        this.name = name;
      }
    });
  }

  void changeSet({String oldName, String newName}) {
    if (oldName != null && oldName != newName) {
      additionalSets[newName] = additionalSets[oldName];
      additionalSets.remove(oldName);
    }
  }

  // HELPER

  Map<String, dynamic> getUpdateData({
    String name,
    num defaultAmount,
  }) {
    final updateData = <String, dynamic>{};
    if (defaultAmount != null && defaultAmount != this.defaultAmount) {
      this.defaultAmount = defaultAmount;
      updateData['$prefix.defaultAmount'] = defaultAmount;
    }
    if (name != null && name != this.name) {
      updateData.clear();
      updateData[prefix] = FieldValue.delete();
      updateData['${product.prefix}.ingredients.$name'] = toMap();
    }
    return updateData;
  }

  // GETTER

  bool get isReady => name != null;
  bool get isNotReady => name == null;
  String get prefix => '${product.prefix}.ingredients.$name';
}

class IngredientSet {
  IngredientSet({
    @required this.name,
    this.amount = 0,
    this.additionalCost = 0,
    this.additionalPrice = 0,
  });

  String name;
  num amount;
  num additionalCost;
  num additionalPrice;

  factory IngredientSet.fromMap(
    String name,
    Map<String, dynamic> data,
  ) {
    return IngredientSet(
      name: name,
      amount: data['amount'],
      additionalCost: data['additionalCost'],
      additionalPrice: data['additionalPrice'],
    );
  }

  factory IngredientSet.empty() {
    return IngredientSet(name: null);
  }

  Map<String, num> toMap() {
    return {
      'amount': amount,
      'additionalCost': additionalCost,
      'additionalPrice': additionalPrice,
    };
  }

  // STATE CHANGE

  Future<void> update(
    IngredientModel ingredient,
    IngredientSet newSet,
  ) async {
    final updateData = getUpdateData(ingredient, newSet);

    if (updateData.isEmpty) return;

    return Database.service.update(Collections.menu, updateData).then((_) {
      if (name == newSet.name) {
        ingredient.changeSet();
      } else {
        ingredient.changeSet(oldName: name, newName: newSet.name);
        name = newSet.name;
      }
    });
  }

  // HELPER

  Map<String, dynamic> getUpdateData(
    IngredientModel ingredient,
    IngredientSet newSet,
  ) {
    final updateData = <String, dynamic>{};
    final prefix = '${ingredient.prefix}.additionalSets';
    if (amount != null && amount != newSet.amount) {
      amount = newSet.amount;
      updateData['$prefix.$name.amount'] = amount;
    }
    if (additionalCost != null && additionalCost != newSet.additionalCost) {
      additionalCost = newSet.additionalCost;
      updateData['$prefix.$name.additionalCost'] = additionalCost;
    }
    if (additionalPrice != null && additionalPrice != newSet.additionalPrice) {
      additionalPrice = newSet.additionalPrice;
      updateData['$prefix.$name.additionalPrice'] = additionalPrice;
    }
    if (name != null && name != newSet.name) {
      updateData.clear();
      updateData['$prefix.$name'] = FieldValue.delete();
      updateData['$prefix.${newSet.name}'] = toMap();
    }
    return updateData;
  }

  // GETTER

  bool get isNotReady => name == null;
}
