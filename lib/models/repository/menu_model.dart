import 'package:flutter/widgets.dart';
import 'package:possystem/models/menu/catalog_model.dart';
import 'package:possystem/models/menu/product_ingredient_model.dart';
import 'package:possystem/models/menu/product_model.dart';
import 'package:possystem/models/menu/product_quantity_model.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/services/storage.dart';

import 'quantity_repo.dart';
import 'stock_model.dart';

class MenuModel extends ChangeNotifier {
  static MenuModel instance;

  Map<String, CatalogModel> catalogs;

  /// wheather ingredient/quantity has connect to stock
  bool stockMode = false;

  MenuModel() {
    Storage.instance.get(Stores.menu).then((data) {
      catalogs = {};

      if (data != null) {
        try {
          data.forEach((key, value) {
            if (value is Map) {
              catalogs[key] = CatalogModel.fromObject(
                CatalogObject.build({'id': key, ...value}),
              );
            }
          });
        } catch (e, stack) {
          print(e);
          print(stack);
        }
      }

      notifyListeners();
    });
    MenuModel.instance = this;
  }

  /// sorted by index
  List<CatalogModel> get catalogList =>
      catalogs.values.toList()..sort((a, b) => a.index.compareTo(b.index));

  bool get isEmpty => catalogs.isEmpty;
  bool get isNotEmpty => catalogs.isNotEmpty;
  bool get isNotReady => catalogs == null;
  bool get isReady => catalogs != null;
  int get length => catalogs.length;

  /// 1-index
  int get newIndex => catalogs.length + 1;

  bool exist(String id) => catalogs.containsKey(id);

  CatalogModel getCatalog(String id) => exist(id) ? catalogs[id] : null;

  List<ProductIngredientModel> getIngredients(String ingredientId) {
    final result = <ProductIngredientModel>[];

    catalogs.values.forEach((catalog) {
      catalog.products.values.forEach((product) {
        if (product.getIngredient(ingredientId) != null) {
          result.add(product.getIngredient(ingredientId));
        }
      });
    });

    return result;
  }

  ProductModel getProduct(String productId) {
    for (var catalog in catalogs.values) {
      final product = catalog.getProduct(productId);
      if (product != null) {
        return product;
      }
    }
    return null;
  }

  List<ProductQuantityModel> getQuantities(String quantityId) {
    final result = <ProductQuantityModel>[];

    catalogs.values.forEach((catalog) {
      catalog.products.values.forEach((product) {
        product.ingredients.values.forEach((ingredient) {
          if (ingredient.getQuantity(quantityId) != null) {
            result.add(ingredient.getQuantity(quantityId));
          }
        });
      });
    });

    return result;
  }

  bool hasCatalog(String name) =>
      !catalogs.values.every((catalog) => catalog.name != name);

  bool hasProduct(String name) => !catalogs.values.every((catalog) =>
      catalog.products.values.every((product) => product.name != name));

  void removeCatalog(String id) {
    catalogs.remove(id);

    notifyListeners();
  }

  Future<void> removeIngredients(String id) {
    final ingredients = getIngredients(id);

    if (ingredients.isEmpty) return Future.value();

    final updateData = {
      for (var ingredient in ingredients) ingredient.prefix: null
    };

    ingredients.forEach((ingredient) {
      ingredient.product.removeIngredient(id);
    });

    notifyListeners();

    return Storage.instance.set(Stores.menu, updateData);
  }

  Future<void> removeQuantities(String id) {
    final quantities = getQuantities(id);

    if (quantities.isEmpty) return Future.value();

    final updateData = {
      for (var quantity in quantities) '${quantity.prefix}': null
    };

    quantities.forEach((quantity) {
      quantity.ingredient.removeQuantity(id);
    });

    notifyListeners();

    return Storage.instance.set(Stores.menu, updateData);
  }

  Future<void> reorderCatalogs(List<CatalogModel> catalogs) {
    final updateData = <String, int>{};
    var i = 1;

    catalogs.forEach((catalog) {
      updateData.addAll(CatalogObject.build({'index': i++}).diff(catalog));
    });

    notifyListeners();

    return Storage.instance.set(Stores.menu, updateData);
  }

  /// inject to make it easy [context.watch]
  void setUpStock(StockModel stock, QuantityRepo quantities) {
    assert(stock.isReady, 'should ready');
    assert(quantities.isReady, 'should ready');

    if (stockMode) return;

    catalogs.forEach((catalogId, catalog) {
      catalog.products.forEach((productId, product) {
        product.ingredients.forEach((ingredientId, ingredient) {
          ingredient.ingredient = stock.getIngredient(ingredientId);
          ingredient.quantities.forEach((quantityId, quantity) {
            quantity.quantity = quantities.getQuantity(quantityId);
          });
        });
      });
    });

    stockMode = true;
  }

  /// add catalog if not exist and notify listeners
  void updateCatalog(CatalogModel catalog) {
    if (!exist(catalog.id)) {
      catalogs[catalog.id] = catalog;

      Storage.instance.add(Stores.menu, catalog.id, catalog.toObject().toMap());
    }

    notifyListeners();
  }
}
