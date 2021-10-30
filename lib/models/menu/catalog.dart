import 'package:possystem/helpers/util.dart';
import 'package:possystem/services/storage.dart';

import '../model.dart';
import '../objects/menu_object.dart';
import '../repository.dart';
import '../repository/menu.dart';
import 'product.dart';

class Catalog extends Model<CatalogObject>
    with
        ModelStorage<CatalogObject>,
        ModelOrderable<CatalogObject>,
        Repository<Product>,
        RepositoryStorage<Product>,
        RepositoryOrderable<Product> {
  /// The time of added to menu
  final DateTime createdAt;

  @override
  final Stores storageStore = Stores.menu;

  @override
  final RepositoryStorageType repoType = RepositoryStorageType.repoModel;

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
    if (products != null) replaceItems(products);
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
    )..prepareItem();
  }

  String? get createdDate => Util.timeToDate(createdAt);

  @override
  Menu get repository => Menu.instance;

  @override
  set repository(Repository repo) {}

  @override
  void notifyItems() {
    notifyListeners();
    Menu.instance.notifyItems();
  }

  @override
  Product buildItem(String id, Map<String, Object?> value) {
    throw UnimplementedError();
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
  CatalogObject toObject() => CatalogObject(
        id: id,
        index: index,
        name: name,
        createdAt: createdAt,
        products: items.map((e) => e.toObject()).toList(),
      );
}
