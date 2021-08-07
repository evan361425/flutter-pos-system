import 'package:flutter/widgets.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/models/model.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/repository.dart';
import 'package:possystem/services/storage.dart';

class Menu extends ChangeNotifier
    with
        Repository<Catalog>,
        NotifyRepository<Catalog>,
        OrderablRepository<Catalog>,
        InitilizableRepository<Catalog> {
  static Menu instance = Menu();

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

  /// Get desc similarity value of products
  List<MapEntry<Product, double>> getSortedSimilarities(String pattern) {
    return getProductSimilarities(pattern)
        .where((entry) => entry.value > 0)
        .toList()
          ..sort((ent1, ent2) => ent2.value.compareTo(ent1.value));
  }

  Iterable<MapEntry<Product, double>> getProductSimilarities(
      String pattern) sync* {
    for (final catalog in items) {
      for (final entry in catalog.getItemsSimilarity(pattern)) {
        yield entry;
      }
    }
  }

  Future<void> removeIngredients(String id) {
    final ingredients = getIngredients(id);

    return _remove(ingredients.map((e) => e.product), ingredients);
  }

  Future<void> removeQuantities(String id) {
    final quantities = getQuantities(id);

    return _remove(quantities.map((e) => e.ingredient), quantities);
  }

  Iterable<Product> searchProducts({int limit = 10, String? text}) sync* {
    var count = 0;
    if (text == null) {
      for (final catalog in items) {
        for (final product in catalog.items) {
          if (++count > limit) return;
          yield product;
        }
      }
      return;
    } else if (text.isNotEmpty) {
      for (final entry in getSortedSimilarities(text)) {
        if (++count > limit) return;
        yield entry.key;
      }
    }
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
