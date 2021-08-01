import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/model.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/repository.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/services/storage.dart';

import 'product.dart';

class Catalog extends NotifyModel<CatalogObject>
    with
        OrderableModel<CatalogObject>,
        Repository<Product>,
        NotifyRepository<Product>,
        OrderablRepository<Product> {
  /// catalog's name
  @override
  String name;

  /// when it has been added to menu
  final DateTime createdAt;

  Catalog({
    DateTime? createdAt,
    String? id,
    int index = 0,
    required this.name,
    Map<String, Product>? products,
  })  : createdAt = createdAt ?? DateTime.now(),
        super(id) {
    this.index = index;
    replaceItems(products ?? {});
  }

  factory Catalog.fromObject(CatalogObject object) => Catalog(
        id: object.id,
        index: object.index!,
        name: object.name,
        createdAt: object.createdAt,
        products: {
          for (var product in object.products)
            product.id!: Product.fromObject(product)
        },
      ).._preparePorducts();

  @override
  String get code => 'menu.catalog';

  String? get createdDate => Util.timeToDate(createdAt);

  @override
  String get itemCode => 'menu.product';

  @override
  Stores get storageStore => Stores.menu;

  @override
  Future<void> addItemToStorage(Product child) {
    return Storage.instance.set(storageStore, {
      child.prefix: child.toObject().toMap(),
    });
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
        products: items.map((e) => e.toObject()),
      );

  @override
  String toString() => name;

  void _preparePorducts() => items.forEach((e) => e.catalog = this);

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
}
