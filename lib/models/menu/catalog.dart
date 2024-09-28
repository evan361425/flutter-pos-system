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
        ModelImage<CatalogObject>,
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
    super.id,
    super.status = ModelStatus.normal,
    super.name = 'catalog',
    int index = 0,
    String? imagePath,
    DateTime? createdAt,
    Map<String, Product>? products,
  }) : createdAt = createdAt ?? DateTime.now() {
    this.index = index;
    this.imagePath = imagePath;
    if (products != null) replaceItems(products);
  }

  factory Catalog.fromObject(CatalogObject object) {
    return Catalog(
      id: object.id,
      index: object.index!,
      name: object.name,
      createdAt: object.createdAt,
      imagePath: object.imagePath,
      products: {for (var product in object.products) product.id!: Product.fromObject(product)},
    )..prepareItem();
  }

  factory Catalog.fromRow(
    Catalog? ori,
    List<String> row, {
    required int index,
  }) {
    final status = ori == null ? ModelStatus.staged : ModelStatus.normal;

    return Catalog(
      id: ori?.id,
      name: row[0],
      index: index,
      status: status,
    );
  }

  @override
  Menu get repository => Menu.instance;

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
        score > 0 ? score * 1.5 : product.getItemsSimilarity(pattern).toDouble(),
      );
    }
  }

  @override
  void notifyItems() {
    notifyListeners();
    Menu.instance.notifyItems();
  }

  @override
  CatalogObject toObject() => CatalogObject(
        id: id,
        index: index,
        name: name,
        createdAt: createdAt,
        imagePath: imagePath,
        products: items.map((e) => e.toObject()).toList(),
      );
}
