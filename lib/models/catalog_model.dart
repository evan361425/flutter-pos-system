import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:possystem/services/database.dart';
import 'package:sprintf/sprintf.dart';

import 'menu_model.dart';
import 'product_model.dart';

class CatalogModel extends ChangeNotifier {
  CatalogModel({
    @required this.name,
    this.index = 0,
    Map<String, ProductModel> products,
    Timestamp createdAt,
  })  : createdAt = createdAt ?? Timestamp.now(),
        products = products ?? {};

  // catalog's name
  String name;
  // index in menu
  int index;
  // when it has been added to menu
  final Timestamp createdAt;
  // product list
  final Map<String, ProductModel> products;

  // I/O

  factory CatalogModel.fromMap(String name, Map<String, dynamic> data) {
    final oriProducts = data['products'];
    final products = <String, ProductModel>{};

    final catalog = CatalogModel(
      name: name,
      index: data['index'],
      createdAt: data['createdAt'],
      products: products,
    );

    if (oriProducts is Map) {
      oriProducts.forEach((final key, final product) {
        if (key is String && product is Map) {
          products[key] = ProductModel.fromMap(
            catalog: catalog,
            name: key,
            data: product,
          );
        }
      });
    }

    return catalog;
  }

  factory CatalogModel.empty() {
    return CatalogModel(name: null);
  }

  Map<String, dynamic> toMap() {
    return {
      'index': index,
      'createdAt': createdAt,
      'products': {
        for (var entry in products.entries) entry.key: entry.value.toMap()
      },
    };
  }

  // STATE CHANGE

  Future<void> add(ProductModel product) async {
    await Database.service.update(Collections.menu, {
      '$name.products.${product.name}': product.toMap(),
    });

    products[product.name] = product;
    notifyListeners();
  }

  Future<void> update(
    MenuModel menu, {
    String name,
    int index,
  }) async {
    final updateData = getUpdateData(
      name: name,
      index: index,
    );

    if (updateData.isEmpty) return;

    return Database.service.update(Collections.menu, updateData).then((_) {
      if (name == this.name) {
        menu.changeCatalog();
      } else {
        menu.changeCatalog(oldName: this.name, newName: name);
        this.name = name;
      }
    });
  }

  void changeProduct({String oldName, String newName}) {
    if (oldName != newName) {
      products[newName] = products[oldName];
      products.remove(oldName);
    }

    notifyListeners();
  }

  // HELPER

  bool has(String key) => products.containsKey(key);

  Map<String, dynamic> getUpdateData({
    String name,
    int index,
  }) {
    final updateData = <String, dynamic>{};
    if (index != this.index) {
      this.index = index;
      updateData['${this.name}.index'] = index;
    }
    if (name != this.name) {
      updateData.clear();
      updateData[this.name] = FieldValue.delete();
      updateData[name] = toMap();
    }
    return updateData;
  }

  // GETTER

  ProductModel operator [](String name) {
    return products[name];
  }

  List<ProductModel> get productList {
    final productList = products.values.toList();
    productList.sort((a, b) => a.index.compareTo(b.index));
    return productList;
  }

  bool get isReady => name != null;

  int get length => products.length;

  String get createdDate {
    final date = createdAt.toDate();
    return sprintf('%04d-%02d-%02d', [date.year, date.month, date.day]);
  }
}
