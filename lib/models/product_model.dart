import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:possystem/models/models.dart';
import 'package:possystem/services/database.dart';
import 'package:provider/provider.dart';

class ProductModel extends ChangeNotifier {
  String _name;
  int _index;
  num _price;
  num _cost;
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
    };
  }

  // STATE CHANGE

  Future<void> add(IngredientModel ingredient, BuildContext context) async {
    if (!ingredient.isReady) throw UnsupportedError('Product is not ready');

    final db = context.read<Database>();
    await db.update(Collections.menu, {
      '$catalogName.$name.ingredients.${ingredient.name}': ingredient.toMap(),
    });

    ingredients[ingredient.name] = ingredient;
    notifyListeners();
  }

  Future<void> update(
    BuildContext context, {
    String name,
    num price,
    num cost,
  }) async {
    var updateData = <String, dynamic>{};
    if (price != _price) updateData['$catalogName.$name.price'] = price;
    if (cost != _cost) updateData['$catalogName.$name.cost'] = cost;
    if (name != _name) {
      updateData = {
        '$catalogName.$name': toMap(),
        '$catalogName.$_name': FieldValue.delete(),
      };
    }

    final db = context.read<Database>();
    return db.update(Collections.menu, updateData).then((_) {
      final menu = context.read<MenuModel>();

      _price = price;
      _cost = cost;

      if (name == _name) {
        menu[catalogName].changeProduct();
      } else {
        menu[catalogName].changeProduct(oldName: _name, newName: name);
        _name = name;
      }
    });
  }

  void changeIngredient({String old, String last}) {
    if (old != null && last != null && old != last) {
      ingredients[last] = ingredients[old];
      ingredients.remove(old);
    }

    notifyListeners();
  }

  void initial(String name, int index) {
    if (_name != null) throw UnsupportedError('Product has initialized');
    _name = name;
    _index = index;
    notifyListeners();
  }

  // HELPER

  bool has(String name) => ingredients.containsKey(name);

  // GETTER

  bool get isReady => _name != null;

  String get name => _name ?? '';
  int get index => _index;
  num get price => _price;
  num get cost => _cost;
}
