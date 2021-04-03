import 'package:flutter/material.dart';
import 'package:possystem/helper/util.dart';
import 'package:possystem/services/database.dart';

class QuantityModel extends ChangeNotifier {
  QuantityModel({
    @required this.name,
    this.defaultProportion = 0,
    String id,
  }) : id = id ?? Util.uuidV4();

  String name;
  double defaultProportion;
  final String id;

  factory QuantityModel.fromMap({
    String id,
    Map<String, dynamic> data,
  }) {
    return QuantityModel(
      name: data['name'],
      defaultProportion: data['defaultProportion'],
      id: id,
    );
  }

  factory QuantityModel.empty() {
    return QuantityModel(name: null);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'defaultProportion': defaultProportion,
    };
  }

  // STATE CHANGE

  Future<void> update(QuantityModel quantity) async {
    final updateData = {};
    final originData = toMap();
    quantity.toMap().forEach((key, value) {
      if (originData[key] != value) {
        updateData['$id.$key'] = value;
      }
    });

    return Database.service
        .update(Collections.ingredient, updateData)
        .then((_) {
      name = quantity.name;
      defaultProportion = quantity.defaultProportion;
      notifyListeners();
    });
  }

  int _similarityRating;
  void setSimilarity(String searchText) {
    _similarityRating = Util.similarity(name, searchText);
    // print('$name Similarity to $searchText is $_similarityRating');
  }

  int get similarity => _similarityRating;

  // GETTER

  bool get isReady => name != null;
  bool get isNotReady => name == null;
}
