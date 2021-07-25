import 'package:flutter/widgets.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/models/model.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/repository.dart';
import 'package:possystem/services/storage.dart';
import 'package:provider/provider.dart';

import 'quantities.dart';
import 'stock.dart';

class Menu extends ChangeNotifier
    with
        Repository<Catalog>,
        NotifyRepository<Catalog>,
        OrderablRepository,
        InitilizableRepository {
  static Menu instance = Menu();

  bool stockMode = false;

  Menu() {
    initialize();

    Menu.instance = this;
  }

  @override
  String get itemCode => 'menu.catalog';

  @override
  Stores get storageStore => Stores.menu;

  @override
  Catalog buildModel(String id, Map<String, Object?> value) {
    return Catalog.fromObject(
      CatalogObject.build({
        'id': id,
        ...value,
      }),
    );
  }

  List<ProductIngredient> getIngredients(String ingredientId) {
    final result = <ProductIngredient>[];

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

  Product? getProduct(String productId) {
    for (var catalog in items) {
      final product = catalog.getItem(productId);
      if (product != null) {
        return product;
      }
    }
    return null;
  }

  List<ProductQuantity> getQuantities(String quantityId) {
    final result = <ProductQuantity>[];

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

    final stock = context.watch<Stock>();
    final quantities = context.watch<Quantities>();
    if (!isReady || !stock.isReady || !quantities.isReady) {
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
