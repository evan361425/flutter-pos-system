import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:possystem/services/firestore_database.dart';

class CatalogModel {
  String _name;
  final Timestamp createdAt;
  final bool enable;

  CatalogModel(this._name, {this.createdAt, this.enable: true});

  factory CatalogModel.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }

    return CatalogModel(
      data['name'],
      createdAt: data['createdAt'],
      enable: data['enable'],
    );
  }

  factory CatalogModel.add(String name) {
    var unix = (DateTime.now().millisecondsSinceEpoch / 1000).round();

    return CatalogModel(
      name,
      createdAt: Timestamp(unix, 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': _name,
      'createdAt': createdAt,
      'enable': enable,
    };
  }

  void setName(String name, FirestoreDatabase firestore) async {
    _name = name;

    await firestore.update(Collections.menu, {
      'catalogs': FieldValue.arrayUnion([
        {'name': _name}
      ])
    });
  }

  get name => _name;
}
