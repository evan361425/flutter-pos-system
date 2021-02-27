import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:possystem/components/text_snack_bar.dart';
import 'package:possystem/models/menu_model.dart';
import 'package:possystem/models/product_model.dart';
import 'package:possystem/services/database.dart';
import 'package:provider/provider.dart';
import 'package:sprintf/sprintf.dart';

class CatalogModel extends ChangeNotifier {
  // catalog's name
  String _name;
  // index in menu
  int _index;
  // is this orderable?
  bool enable;
  // when it has been added to menu
  final Timestamp _createdAt;
  // product list
  final Map<String, ProductModel> _products;

  CatalogModel(
    this._name, {
    @required int index,
    Map<String, ProductModel> products,
    Timestamp createdAt,
    this.enable = true,
  })  : _index = index,
        _createdAt = createdAt ?? Timestamp.now(),
        _products = products ?? {};

  // I/O

  factory CatalogModel.fromMap(String name, Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }

    var rawProducts = data['products'];
    var products;

    if (rawProducts is Map) {
      try {
        products = rawProducts.map((key, product) {
          if (key is String && product is Map) {
            product['catalogName'] = name;
            return MapEntry(key, ProductModel.fromMap(key, product));
          } else {
            throw TypeError();
          }
        });
      } catch (e) {
        Logger().e(e);
        products = null;
      }
    }

    return CatalogModel(
      name,
      index: data['index'],
      createdAt: data['createdAt'],
      products: products,
      enable: data['enable'],
    );
  }

  factory CatalogModel.empty() {
    return CatalogModel(null, index: 0);
  }

  Map<String, dynamic> toMap() {
    return {
      'index': _index,
      'createdAt': _createdAt,
      'products': _products.map(
        (name, product) => MapEntry(name, product.toMap()),
      ),
      'enable': enable,
    };
  }

  // STATE CHANGE

  Future<ProductModel> add(ProductModel product, BuildContext context) async {
    if (!product.isReady) throw UnsupportedError('Catalog is not ready');

    final db = context.read<Database>();
    await db.update(Collections.menu, {
      '$_name.products.${product.name}': product.toMap(),
    });

    _products[name] = product;
    notifyListeners();

    return product;
  }

  Future<void> setName(String name, BuildContext context) {
    final db = context.read<Database>();

    return db.update(Collections.menu, {
      _name: FieldValue.delete(),
      name: toMap(),
    }).then((_) {
      TextSnackBar.success(context);

      final menu = context.read<MenuModel>();
      menu.changeCatalog(oldName: _name, newName: name);

      _name = name;
    }).catchError((_) {
      TextSnackBar.failed(context);
    });
  }

  Future<void> setIndex(int index, BuildContext context) async {
    final db = context.read<Database>();

    return db.update(Collections.menu, {
      '$_name.index': index,
    }).then((_) => _index = index);
  }

  Future<void> setEnable(bool isEnable, BuildContext context) {
    final db = context.read<Database>();

    return db.update(
      Collections.menu,
      {'$_name.enable': isEnable},
    ).then((_) {
      TextSnackBar.success(context);

      enable = isEnable;
      final menu = context.read<MenuModel>();
      menu.changeCatalog();
    }).catchError((_) {
      TextSnackBar.failed(context);
    });
  }

  void changeProduct({String oldName, String newName}) {
    if (oldName != newName) {
      _products[newName] = _products[oldName];
      _products.remove(oldName);
    }

    notifyListeners();
  }

  void initial(String name, int index) {
    if (_name != null) throw UnsupportedError('Catalog has initialized');
    _name = name;
    _index = index;
    notifyListeners();
  }

  // HELPER

  bool has(String key) {
    return _products.containsKey(key);
  }

  bool get isReady => _name != null;

  // GETTER

  List<ProductModel> get products {
    final products = _products.values.toList();
    products.sort((a, b) => a.index.compareTo(b.index));
    return products;
  }

  int get index => _index;

  String get name => _name ?? '';

  int get length => _products.length;

  String get createdAt {
    final date = _createdAt.toDate();
    return sprintf('%04d-%02d-%02d', [date.year, date.month, date.day]);
  }
}
