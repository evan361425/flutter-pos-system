import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:possystem/models/models.dart';
import 'package:possystem/services/database.dart';
import 'package:provider/provider.dart';

class IngredientModel {
  IngredientModel(
    this.name,
    this.defaultAmount, {
    this.additionalSets = const {},
  });

  String name;
  num defaultAmount;
  Map<String, IngredientSet> additionalSets;

  factory IngredientModel.fromMap(String name, Map<String, dynamic> data) {
    final additionalSets = data['additionalSets'];
    final actualAdditionalSets = <String, IngredientSet>{};

    if (additionalSets is Map) {
      additionalSets.forEach((key, additionalSet) {
        if (additionalSet is Map) {
          actualAdditionalSets[key] = IngredientSet.fromMap(key, additionalSet);
        }
      });
    }

    return IngredientModel(
      name,
      data['defaultAmount'],
      additionalSets: actualAdditionalSets,
    );
  }

  static IngredientModel empty() {
    return IngredientModel(null, 0);
  }

  Map<String, dynamic> toMap() {
    final additionalSetsMap = <String, Map<String, num>>{};

    additionalSets.forEach((key, additionalSet) {
      additionalSetsMap[key] = additionalSet.toMap();
    });

    return {
      'defaultAmount': defaultAmount,
      'additionalSets': additionalSetsMap,
    };
  }

  Future<void> addSet(IngredientSet newSet) async {
    additionalSets[newSet.name] = newSet;
  }

  Future<void> replaceSet(IngredientSet oldSet, IngredientSet newSet) async {
    additionalSets.remove(oldSet.name);
    additionalSets[newSet.name] = newSet;
  }

  Future<void> update(
    BuildContext context,
    ProductModel product, {
    String name,
    num amount,
  }) async {
    final prefix = '${product.catalogName}.${product.name}.ingredients.';
    var updateData = <String, dynamic>{};
    if (defaultAmount != amount) {
      updateData['$prefix${this.name}.defaultAmount'] = amount;
    }
    if (name != this.name) {
      updateData = {
        '$prefix$name': toMap(),
        '$prefix${this.name}': FieldValue.delete(),
      };
    }

    final db = context.read<Database>();
    return db.update(Collections.menu, updateData).then((_) {
      defaultAmount = amount;

      if (name == this.name) {
        product.changeIngredient();
      } else {
        product.changeIngredient(old: this.name, last: name);
        this.name = name;
      }
    });
  }

  bool get isReady => name != null;
}

class IngredientSet {
  IngredientSet({
    @required this.name,
    this.ammount = 0,
    this.additionalCost = 0,
    this.additionalPrice = 0,
  });

  String name;
  num ammount;
  num additionalCost;
  num additionalPrice;

  factory IngredientSet.fromMap(
    String name,
    Map<String, dynamic> map,
  ) {
    return IngredientSet(
      name: name,
      ammount: map['ammount'],
      additionalCost: map['additionalCost'],
      additionalPrice: map['additionalPrice'],
    );
  }

  Map<String, num> toMap() {
    return {
      'ammount': ammount,
      'additionalCost': additionalCost,
      'additionalPrice': additionalPrice,
    };
  }

  Future<void> update(IngredientSet newSet) async {
    if (newSet.name != name) {
      throw ArgumentError(
        'you should not change name, try replaceSet in IngredientModel',
      );
    }

    ammount = newSet.ammount;
    additionalCost = newSet.additionalCost;
    additionalPrice = newSet.additionalPrice;
  }

  bool get isNotReady => name.isEmpty;
}
