import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:possystem/components/text_snack_bar.dart';
import 'package:possystem/models/catalog_model.dart';
import 'package:possystem/models/ingredient_model.dart';
import 'package:possystem/services/database.dart';
import 'package:provider/provider.dart';

class ProductModel extends ChangeNotifier {
  String _name;
  int _index;
  num _price;
  num _cost;
  bool enable;
  final Map<String, IngredientModel> ingredients;
  final String catalogName;
  final Timestamp _createdAt;

  ProductModel(
    this._name, {
    @required int index,
    @required this.catalogName,
    num price = 0,
    num cost = 0,
    Timestamp createdAt,
    this.enable = true,
    this.ingredients = const {},
  })  : _index = index,
        _price = price,
        _cost = cost,
        _createdAt = createdAt ?? Timestamp.now();

  // I/O

  factory ProductModel.fromMap(String name, Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }

    final ingredients = data['ingredients'];
    final actualIngredients = <String, IngredientModel>{};

    if (ingredients is Map) {
      ingredients.forEach((key, ingredient) {
        if (ingredient is Map) {
          actualIngredients[key] = IngredientModel.fromMap(key, ingredient);
        }
      });
    }

    return ProductModel(
      name,
      index: data['index'],
      price: data['price'],
      catalogName: data['catalogName'],
      createdAt: data['createdAt'],
      enable: data['enable'],
      ingredients: actualIngredients,
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
    return setter<String>(
      updateData: {
        '$catalogName.$_name': FieldValue.delete(),
        '$catalogName.$name': toMap(),
      },
      context: context,
      cb: (value) => _name = value,
    );
  }

  Future<void> setPrice(num price, BuildContext context) async {
    return setter<num>(
      key: 'price',
      value: price,
      cb: (value) => _price = value,
      context: context,
    );
  }

  Future<void> setCost(num cost, BuildContext context) async {
    return setter<num>(
      key: 'price',
      value: cost,
      cb: (value) => _cost = value,
      context: context,
    );
  }

  void initial(String name, int index) {
    if (_name != null) throw UnsupportedError('Product has initialized');
    _name = name;
    _index = index;
    notifyListeners();
  }

  // HELPER

  Future<void> setter<T>({
    String key,
    T value,
    @required BuildContext context,
    Function(T value) cb,
    Map<String, dynamic> updateData,
  }) async {
    if (updateData == null) {
      if (key == null || value == null) throw ArgumentError();
      updateData = {
        '$catalogName.$_name.$key': value,
      };
    }

    final db = context.read<Database>();

    return db.update(Collections.menu, updateData).then((_) {
      TextSnackBar.success(context);

      final catalog = context.read<CatalogModel>();
      catalog.changeProduct();

      if (cb != null) {
        cb(value);
      }
    }).catchError((_) {
      TextSnackBar.failed(context);
    });
  }

  // GETTER

  bool get isReady => _name != null;

  String get name => _name ?? '';
  int get index => _index;
  num get price => _price;
  num get cost => _cost;
}
