import 'package:flutter/widgets.dart';
import 'package:possystem/models/menu/catalog_model.dart';
import 'package:possystem/models/menu/product_ingredient_model.dart';
import 'package:possystem/models/menu/product_model.dart';
import 'package:possystem/models/menu/product_quantity_model.dart';
import 'package:possystem/models/model.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/repository.dart';
import 'package:possystem/services/storage.dart';
import 'package:provider/provider.dart';

import 'quantity_repo.dart';
import 'stock_model.dart';

class MenuModel extends ChangeNotifier
    with
        Repository<CatalogModel>,
        NotifyRepository<CatalogModel>,
        OrderablRepository,
        InitilizableRepository {
  static late MenuModel instance;

  bool stockMode = false;

  MenuModel() {
    initialize();

    MenuModel.instance = this;
  }

  @override
  String get itemCode => 'menu.catalog';

  @override
  Stores get storageStore => Stores.menu;

  @override
  CatalogModel buildModel(String id, Map<String, Object?> value) {
    return CatalogModel.fromObject(
      CatalogObject.build({
        'id': id,
        ...value,
      }),
    );
  }

  List<ProductIngredientModel> getIngredients(String ingredientId) {
    final result = <ProductIngredientModel>[];

    items.forEach((catalog) {
      catalog.items.forEach((product) {
        final ingredient = product.getItem(ingredientId);
        if (ingredient != null) {
          result.add(ingredient);
        }
      });
    });

    return result;
  }

  ProductModel? getProduct(String productId) {
    for (var catalog in items) {
      final product = catalog.getItem(productId);
      if (product != null) {
        return product;
      }
    }
    return null;
  }

  List<ProductQuantityModel> getQuantities(String quantityId) {
    final result = <ProductQuantityModel>[];

    items.forEach((catalog) {
      catalog.items.forEach((product) {
        product.items.forEach((ingredient) {
          final quantity = ingredient.getItem(quantityId);
          if (quantity != null) {
            result.add(quantity);
          }
        });
      });
    });

    return result;
  }

  bool hasProduct(String name) => !items.every(
      (catalog) => catalog.items.every((product) => product.name != name));

  Future<void> removeIngredients(String id) {
    final ingredients = getIngredients(id);

    return _remove(ingredients.map((e) => e.product), ingredients);
  }

  Future<void> removeQuantities(String id) {
    final quantities = getQuantities(id);

    return _remove(quantities.map((e) => e.ingredient), quantities);
  }

  /// wheather ingredient/quantity has connect to stock
  ///
  /// inject to make it easy [context.watch]
  bool setUpStockMode(BuildContext context) {
    if (stockMode) return true;

    final stock = context.watch<StockModel>();
    final quantities = context.watch<QuantityRepo>();
    if (!stock.isReady || !quantities.isReady) {
      return false;
    }

    items.forEach((catalog) {
      catalog.items.forEach((product) {
        product.items.forEach((ingredient) {
          ingredient.setIngredient(stock.getItem(ingredient.id)!);
          ingredient.items.forEach((quantity) {
            quantity.setQuantity(quantities.getItem(quantity.id)!);
          });
        });
      });
    });

    stockMode = true;
    return true;
  }

  Future<void> _remove(Iterable<Repository> repos, List<Model> items) {
    if (items.isEmpty) return Future.value();

    final updateData = {for (var item in items) item.prefix: null};

    final id = items.first.id;
    repos.forEach((repo) => repo.removeItem(id));

    notifyListeners();

    return Storage.instance.set(Stores.menu, updateData);
  }
}
