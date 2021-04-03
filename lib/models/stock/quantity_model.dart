import 'package:flutter/material.dart';
import 'package:possystem/helper/util.dart';
import 'package:possystem/services/database.dart';

class QuantityModel extends ChangeNotifier {
  QuantityModel({
    @required this.name,
    this.defaultProportion = 0,
    String id,
  }) : id = id ?? Util.uuidV4();

  final String id;
  String name;
  double defaultProportion;

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

  void update({
    String name,
    double proportion,
  }) {
    final updateData = <String, dynamic>{};
    if (name != null && name != this.name) {
      this.name = name;
      updateData['$id.name'] = name;
    }
    if (proportion != null && proportion != defaultProportion) {
      defaultProportion = proportion;
      updateData['$id.defaultProportion'] = proportion;
    }

    if (updateData.isNotEmpty) {
      Database.service.update(Collections.quantities, updateData);

      notifyListeners();
    }
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
