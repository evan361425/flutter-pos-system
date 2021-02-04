import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:possystem/services/firestore_database.dart';

class CatalogModel {
  String _name;
  final int _index;
  final Timestamp createdAt;
  final bool enable;

  CatalogModel(this._name, this._index, {this.createdAt, this.enable = true});

  factory CatalogModel.fromMap(String name, Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }

    return CatalogModel(
      name,
      data['index'],
      createdAt: data['createdAt'],
      enable: data['enable'],
    );
  }

  factory CatalogModel.add(String name, int index) {
    var unix = (DateTime.now().millisecondsSinceEpoch / 1000).round();

    return CatalogModel(
      name,
      index,
      createdAt: Timestamp(unix, 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'index': _index,
      'createdAt': createdAt,
      'enable': enable,
    };
  }

  void setName(String name, FirestoreDatabase db) async {
    await db.update(Collections.menu, {
      _name: FieldValue.delete(),
      name: toMap(),
    });

    _name = name;
  }

  int get index => _index;

  String get name => _name;
}
