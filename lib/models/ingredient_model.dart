import 'package:flutter/material.dart';

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

  Future<void> addSet(IngredientSet newSet) async {
    additionalSets[newSet.name] = newSet;
  }

  Future<void> replaceSet(IngredientSet oldSet, IngredientSet newSet) async {
    additionalSets.remove(oldSet.name);
    additionalSets[newSet.name] = newSet;
  }
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
}
