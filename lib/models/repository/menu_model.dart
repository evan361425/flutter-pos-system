import 'package:flutter/widgets.dart';
import 'package:possystem/models/menu/catalog_model.dart';
import 'package:possystem/models/menu/product_ingredient_model.dart';
import 'package:possystem/models/menu/product_model.dart';
import 'package:possystem/models/menu/product_quantity_model.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/repository.dart';
import 'package:possystem/services/storage.dart';

import 'quantity_repo.dart';
import 'stock_model.dart';

class MenuModel extends ChangeNotifier
    with Repository<CatalogModel>, OrderablRepository, InitilizableRepository {
  static late MenuModel instance;

  /// wheather ingredient/quantity has connect to stock
  bool stockMode = false;

  MenuModel() {
    initialize();

    MenuModel.instance = this;
  }

  @override
  String get childCode => 'menu.catalog';

  @override
  Stores get storageStore => Stores.menu;

  @override
  CatalogModel buildModel(String id, Map<String, Object> value) {
    return CatalogModel.fromObject(
      CatalogObject.build({
        'id': id,
        ...value,
      }),
    );
  }

  List<ProductIngredientModel> getIngredients(String ingredientId) {
    final result = <ProductIngredientModel>[];

    childs.forEach((catalog) {
      catalog.childs.forEach((product) {
        if (product.getIngredient(ingredientId) != null) {
          result.add(product.getIngredient(ingredientId)!);
        }
      });
    });

    return result;
  }

  ProductModel? getProduct(String productId) {
    for (var catalog in childs) {
      final product = catalog.getChild(productId);
      if (product != null) {
        return product;
      }
    }
    return null;
  }

  List<ProductQuantityModel?> getQuantities(String quantityId) {
    final result = <ProductQuantityModel?>[];

    childs.forEach((catalog) {
      catalog.childs.forEach((product) {
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
      !childs.every((catalog) => catalog.name != name);

  bool hasProduct(String name) => !childs.every(
      (catalog) => catalog.childs.every((product) => product.name != name));

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
      for (var quantity in quantities) '${quantity!.prefix}': null
    };

    quantities.forEach((quantity) {
      quantity!.ingredient.removeQuantity(id);
    });

    notifyListeners();

    return Storage.instance.set(Stores.menu, updateData);
  }

  /// inject to make it easy [context.watch]
  void setUpStock(StockModel stock, QuantityRepo quantities) {
    assert(stock.isReady, 'should ready');
    assert(quantities.isReady, 'should ready');

    if (stockMode) return;

    childMap.forEach((catalogId, catalog) {
      catalog.childs.forEach((product) {
        product.ingredients.forEach((ingredientId, ingredient) {
          ingredient.setIngredient(stock.getIngredient(ingredientId)!);
          ingredient.quantities.forEach((quantityId, quantity) {
            quantity.setQuantity(quantities.getChild(quantityId)!);
          });
        });
      });
    });

    stockMode = true;
  }
}
