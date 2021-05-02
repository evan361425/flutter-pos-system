import 'package:flutter/widgets.dart';
import 'package:possystem/models/menu/catalog_model.dart';
import 'package:possystem/models/menu/product_ingredient_model.dart';
import 'package:possystem/models/menu/product_model.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/services/database.dart';

import 'quantity_repo.dart';
import 'stock_model.dart';

class MenuModel extends ChangeNotifier {
  static final MenuModel _instance = MenuModel._constructor();

  static MenuModel get instance => _instance;

  MenuModel._constructor() {
    Database.instance.get(Collections.menu).then((snapshot) {
      buildFromMap(snapshot.data());
      notifyListeners();
    });
  }

  Map<String, CatalogModel> catalogs;
  bool stockMode = false;

  // I/O

  List<CatalogModel> get catalogList {
    final catalogList = catalogs.values.toList();
    catalogList.sort((a, b) => a.index.compareTo(b.index));
    return catalogList;
  }

  bool get isEmpty => catalogs.isEmpty;

  bool get isNotReady => catalogs == null;

  int get newIndex {
    var maxIndex = -1;
    catalogs.forEach((key, catalog) {
      if (catalog.index > maxIndex) {
        maxIndex = catalog.index;
      }
    });
    return maxIndex + 1;
  }

  CatalogModel operator [](String id) => catalogs[id];

  void buildFromMap(Map<String, dynamic> data) {
    catalogs = {};
    if (data == null) return;

    try {
      data.forEach((key, value) {
        if (value is Map) {
          catalogs[key] = CatalogModel.fromMap({'id': key, ...value});
        }
      });
    } catch (e) {
      print(e);
    }
  }

  ProductModel getProduct(String productId) {
    for (var catalog in catalogs.values) {
      final product = catalog[productId];
      if (product != null) {
        return product;
      }
    }
    return null;
  }

  bool has(String id) => catalogs.containsKey(id);

  bool hasCatalog(String name) =>
      !catalogs.values.every((catalog) => catalog.name != name);

  bool hasProduct(String name) => !catalogs.values.every((catalog) =>
      catalog.products.values.every((product) => product.name != name));

  List<ProductIngredientModel> productContainsIngredient(String id) {
    final result = <ProductIngredientModel>[];

    catalogs.values.forEach((catalog) {
      catalog.products.values.forEach((product) {
        if (product.has(id)) result.add(product[id]);
      });
    });

    return result;
  }

  List<ProductIngredientModel> productContainsQuantity(String id) {
    final result = <ProductIngredientModel>[];

    catalogs.values.forEach((catalog) {
      catalog.products.values.forEach((product) {
        product.ingredients.values.forEach((ingredient) {
          if (ingredient.has(id)) result.add(ingredient);
        });
      });
    });

    return result;
  }

  void removeCatalog(String id) {
    catalogs.remove(id);
    Database.instance.update(Collections.menu, {id: null});
    notifyListeners();
  }

  void removeIngredient(String id) {
    final ingredients = productContainsIngredient(id);
    final updateData = {
      for (var ingredient in ingredients) ingredient.prefix: null
    };
    Database.instance.update(Collections.menu, updateData);

    if (updateData.isNotEmpty) {
      ingredients.forEach((ingredient) {
        ingredient.product.ingredients.remove(id);
      });
      notifyListeners();
    }
  }

  void removeQuantity(String id) {
    final ingredients = productContainsQuantity(id);
    final updateData = {
      for (var ingredient in ingredients)
        '${ingredient.prefixQuantities}.$id': null
    };
    Database.instance.update(Collections.menu, updateData);

    if (updateData.isNotEmpty) {
      ingredients.forEach((ingredient) => ingredient.quantities.remove(id));
      notifyListeners();
    }
  }

  Future<void> reorderCatalogs(List<CatalogModel> catalogs) {
    final updateData = <String, dynamic>{};
    var i = 1;

    catalogs.forEach((catalog) {
      updateData.addAll(CatalogObject.build({'index': i++}).diff(catalog));
    });

    notifyListeners();

    return Database.instance.update(Collections.menu, updateData);
  }

  void setUpStock(StockModel stock, QuantityRepo quantities) {
    assert(stock.isReady, 'should ready');
    assert(quantities.isReady, 'should ready');

    if (stockMode) return;

    catalogs.forEach((catalogId, catalog) {
      catalog.products.forEach((productId, product) {
        product.ingredients.forEach((ingredientId, ingredient) {
          ingredient.ingredient = stock[ingredientId];
          ingredient.quantities.forEach((quantityId, quantity) {
            quantity.quantity = quantities[quantityId];
          });
        });
      });
    });
    stockMode = true;
  }

  void updateCatalog(CatalogModel catalog) {
    if (!has(catalog.id)) {
      catalogs[catalog.id] = catalog;

      final updateData = {catalog.id: catalog.toMap().output()};
      Database.instance.update(Collections.menu, updateData);
    }
    notifyListeners();
  }
}
