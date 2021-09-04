import 'package:possystem/helpers/util.dart';
import 'package:possystem/services/storage.dart';

import '../model.dart';
import '../objects/menu_object.dart';
import '../repository.dart';
import '../repository/menu.dart';
import 'product.dart';

class Catalog extends NotifyModel<CatalogObject>
    with
        OrderableModel<CatalogObject>,
        Repository<Product>,
        NotifyRepository<Product>,
        OrderablRepository<Product> {
  /// The time of added to menu
  final DateTime createdAt;

  @override
  final String logCode = 'menu.catalog';

  @override
  final Stores storageStore = Stores.menu;

  Catalog({
    String? id,
    String name = 'catalog',
    int index = 0,
    DateTime? createdAt,
    Map<String, Product>? products,
  })  : createdAt = createdAt ?? DateTime.now(),
        super(id) {
    this.name = name;
    this.index = index;
    replaceItems(products ?? {});
  }

  factory Catalog.fromObject(CatalogObject object) {
    return Catalog(
      id: object.id,
      index: object.index!,
      name: object.name,
      createdAt: object.createdAt,
      products: {
        for (var product in object.products)
          product.id!: Product.fromObject(product)
      },
    ).._preparePorducts();
  }

  String? get createdDate => Util.timeToDate(createdAt);

  @override
  Future<void> addItemToStorage(Product child) {
    return Storage.instance.set(storageStore, {
      child.prefix: child.toObject().toMap(),
    });
  }

  /// Get similarity from product
  ///
  /// Use product's score, if possible, instead of ingredient/quantity's score
  Iterable<MapEntry<Product, double>> getItemsSimilarity(String pattern) sync* {
    for (final product in items) {
      final score = product.getSimilarity(pattern);
      yield MapEntry(
        product,
        score > 0
            ? score * 1.5
            : product.getItemsSimilarity(pattern).toDouble(),
      );
    }
  }

  @override
  void notifyItem() {
    notifyListeners();
    Menu.instance.notifyItem();
  }

  @override
  void removeFromRepo() => Menu.instance.removeItem(id);

  @override
  CatalogObject toObject() => CatalogObject(
        id: id,
        index: index,
        name: name,
        createdAt: createdAt,
        products: items.map((e) => e.toObject()).toList(),
      );

  void _preparePorducts() => items.forEach((e) => e.catalog = this);
}
