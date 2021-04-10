import 'package:flutter/material.dart';
import 'package:possystem/helper/util.dart';
import 'package:possystem/services/database.dart';

class StockBatchModel {
  StockBatchModel({
    @required this.name,
    id,
    Map<String, num> data,
  })  : id = id ?? Util.uuidV4(),
        data = data ?? {};

  String name;
  final String id;
  final Map<String, num> data;

  // I/O

  factory StockBatchModel.fromMap({
    String id,
    Map<String, dynamic> data,
  }) {
    final batchData = <String, num>{};
    final oriData = data['data'];

    if (oriData is Map) {
      oriData.forEach((key, value) {
        batchData[key] = value;
      });
    }

    return StockBatchModel(
      id: id,
      name: data['name'],
      data: batchData,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'data': data,
    };
  }

  // STATE CHANGE

  void update({String name, Map<String, num> data}) {
    final updateData = <String, dynamic>{};
    if (name != null && name != this.name) {
      this.name = name;
      updateData['$id.name'] = name;
    }
    if (data != null) {
      data.forEach((key, value) {
        if (this.data[key] != value) {
          this.data[key] = value;
          updateData['$id.data.$key'] = value;
        }
      });
    }

    if (updateData.isNotEmpty) {
      Database.service.update(Collections.stock_batch, updateData);
    }
  }

  // HELPER

  bool has(String id) => data.containsKey(id);
  bool hasNot(String id) => !data.containsKey(id);
  num operator [](String id) => data[id];
}
