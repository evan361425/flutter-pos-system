import 'package:flutter/widgets.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/models/model.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/repository.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/services/storage.dart';

class Menu extends ChangeNotifier with Repository<Catalog>, RepositoryStorage<Catalog>, RepositoryOrderable<Catalog> {
  static late Menu instance;

  @override
  final Stores storageStore = Stores.menu;

  Menu() {
    instance = this;
  }

  List<Catalog> get notEmptyItems => itemList.where((e) => e.isNotEmpty).toList();

  Iterable<Product> get products sync* {
    for (final catalog in itemList) {
      for (final product in catalog.itemList) {
        yield product;
      }
    }
  }

  @override
  void abortStaged() {
    super.abortStaged();
    Quantities.instance.abortStaged();
    Stock.instance.abortStaged();
  }

  @override
  Catalog buildItem(String id, Map<String, Object?> value) {
    return Catalog.fromObject(
      CatalogObject.build({
        'id': id,
        ...value,
      }),
    );
  }

  @override
  Future<void> commitStaged({save = true, bool reset = true}) async {
    await Stock.instance.commitStaged(reset: false);
    await Quantities.instance.commitStaged(reset: false);
    await super.commitStaged();
  }

  List<ProductIngredient> getIngredients(String ingredientId) {
    final result = <ProductIngredient>[];

    for (var catalog in items) {
      for (var product in catalog.items) {
        for (var ing in product.items) {
          if (ing.ingredient.id == ingredientId) {
            result.add(ing);
          }
        }
      }
    }

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

  Product? getProductByName(String name) {
    for (var catalog in items) {
      final product = catalog.getItemByName(name);
      if (product != null) {
        return product;
      }
    }
    return null;
  }

  List<ProductQuantity> getQuantities(String quantityId) {
    final result = <ProductQuantity>[];

    for (var catalog in items) {
      for (var product in catalog.items) {
        for (var ingredient in product.items) {
          for (var qua in ingredient.items) {
            if (qua.quantity.id == quantityId) {
              result.add(qua);
            }
          }
        }
      }
    }

    return result;
  }

  bool hasProductByName(String name) {
    return items.any((catalog) => catalog.hasName(name));
  }

  Future<void> removeIngredients(String id) {
    return _removeBatch(getIngredients(id));
  }

  Future<void> removeQuantities(String id) {
    return _removeBatch(getQuantities(id));
  }

  /// Search products by [text].
  ///
  /// If text not provided, it will get latest searched products and sorted products
  ///
  /// [limit] will fire list.take.
  Iterable<ProductMatch> searchProducts({int limit = 10, String? text}) {
    final products = text == null || text.isEmpty
        ? _getSortedSearchedHistory().map((e) => ProductMatch(product: e))
        : _getSortedSimilarities(text);
    return products.take(limit);
  }

  Iterable<ProductMatch> _getProductSimilarities(String pattern) sync* {
    for (final catalog in items) {
      for (final item in catalog.getItemsSimilarity(pattern)) {
        yield item;
      }
    }
  }

  /// Get desc history of searching
  ///
  /// If not enough, return by product asc index
  Iterable<Product> _getSortedSearchedHistory() sync* {
    // products have been searched
    yield* items.expand((catalog) => catalog.items.where((product) => product.searchedAt != null)).toList()
      ..sort((item1, item2) => item2.searchedAt!.compareTo(item1.searchedAt!));

    // products have not been searched
    yield* itemList.expand((catalog) => catalog.itemList.where((product) => product.searchedAt == null));
  }

  /// Get desc similarity value of products
  Iterable<ProductMatch> _getSortedSimilarities(String pattern) {
    return _getProductSimilarities(pattern).where((item) => item.score > 0).toList()
      ..sort((item1, item2) => item2.score.compareTo(item1.score));
  }

  Future<void> _removeBatch(List<Model> items) async {
    if (items.isEmpty) return;

    await Storage.instance.set(storageStore, {
      for (final item in items) item.prefix: null,
    });

    for (var item in items) {
      item.repository.removeItem(item.id);
    }
  }
}
