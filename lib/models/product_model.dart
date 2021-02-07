import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:possystem/components/text_snack_bar.dart';
import 'package:possystem/models/catalog_model.dart';
import 'package:possystem/services/database.dart';
import 'package:provider/provider.dart';

class ProductModel extends ChangeNotifier {
  String _name;
  int _index;
  num _price;
  bool enable;
  final String catalogName;
  final Timestamp _createdAt;

  ProductModel(
    this._name, {
    @required int index,
    @required this.catalogName,
    num price = 0,
    Timestamp createdAt,
    this.enable = true,
  })  : _index = index,
        _price = price,
        _createdAt = createdAt ?? Timestamp.now();

  // I/O

  factory ProductModel.fromMap(String name, Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }

    return ProductModel(
      name,
      index: data['index'],
      price: data['price'],
      catalogName: data['catalogName'],
      createdAt: data['createdAt'],
      enable: data['enable'],
    );
  }

  factory ProductModel.empty(String catalogName) {
    return ProductModel(null, index: 0, catalogName: catalogName);
  }

  Map<String, dynamic> toMap() {
    return {
      'index': _index,
      'catalogName': catalogName,
      'price': _price,
      'createdAt': _createdAt,
      'enable': enable,
    };
  }

  // STATE CHANGE

  Future<void> setName(String name, BuildContext context) async {
    final db = context.read<Database>();

    return db.update(Collections.menu, {
      '$catalogName.$_name': FieldValue.delete(),
      '$catalogName.$name': toMap(),
    }).then((_) {
      TextSnackBar.success(context);

      final catalog = context.read<CatalogModel>();
      catalog.changeProduct(oldName: _name, newName: name);

      _name = name;
    }).catchError((_) {
      TextSnackBar.failed(context);
    });
  }

  Future<void> setIndex(int index, BuildContext context) async {
    final db = context.read<Database>();

    return db.update(Collections.menu, {
      '$catalogName.$_name.index': index,
    }).then((_) => _index = index);
  }

  Future<void> setPrice(double price, BuildContext context) async {
    final db = context.read<Database>();

    return db.update(Collections.menu, {
      '$catalogName.$_name.price': price,
    }).then((_) {
      TextSnackBar.success(context);

      final catalog = context.read<CatalogModel>();
      catalog.changeProduct();
      _price = price;
    }).catchError((_) {
      TextSnackBar.failed(context);
    });
  }

  void initial(String name, int index) {
    if (_name != null) throw UnsupportedError('Product has initialized');
    _name = name;
    _index = index;
    notifyListeners();
  }

  // HELPER

  bool get isReady => _name != null;

  // GETTER

  String get name => _name ?? '';

  int get index => _index;

  num get price => _price;
}
