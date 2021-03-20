import 'package:flutter/material.dart';
import 'package:possystem/helper/util.dart';
import 'package:possystem/services/database.dart';

class IngredientSetModel extends ChangeNotifier {
  IngredientSetModel({
    @required this.name,
    this.defaultProportion = 0,
    String id,
  }) : id = id ?? Util.uuidV4();

  String name;
  double defaultProportion;
  final String id;

  factory IngredientSetModel.fromMap({
    String id,
    Map<String, dynamic> data,
  }) {
    return IngredientSetModel(
      name: data['name'],
      defaultProportion: data['defaultProportion'],
      id: id,
    );
  }

  factory IngredientSetModel.empty() {
    return IngredientSetModel(name: null);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'defaultProportion': defaultProportion,
    };
  }

  // STATE CHANGE

  Future<void> update(IngredientSetModel newIngredientSet) async {
    final updateData = {};
    final originData = toMap();
    newIngredientSet.toMap().forEach((key, value) {
      if (originData[key] != value) {
        updateData['$id.$key'] = value;
      }
    });

    return Database.service
        .update(Collections.ingredient, updateData)
        .then((_) {
      name = newIngredientSet.name;
      defaultProportion = newIngredientSet.defaultProportion;
      notifyListeners();
    });
  }

  // GETTER

  bool get isReady => name != null;
  bool get isNotReady => name == null;
}
