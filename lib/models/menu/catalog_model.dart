import 'package:flutter/foundation.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/repository/menu_model.dart';
import 'package:possystem/services/storage.dart';

import 'product_model.dart';

class CatalogModel extends ChangeNotifier {
  final String id;

  /// catalog's name
  String name;

  /// index in menu
  int index;

  /// when it has been added to menu
  final DateTime createdAt;

  /// product list
  final Map<String, ProductModel> products;

  CatalogModel({
    DateTime? createdAt,
    String? id,
    required this.index,
    required this.name,
    Map<String, ProductModel>? products,
  })  : createdAt = createdAt ?? DateTime.now(),
        products = products ?? {},
        id = id ?? Util.uuidV4();

  factory CatalogModel.fromObject(CatalogObject object) => CatalogModel(
        id: object.id,
        index: object.index!,
        name: object.name,
        createdAt: object.createdAt,
        products: {
          for (var product in object.products)
            product.id!: ProductModel.fromObject(product)
        },
      ).._preparePorducts();

  String? get createdDate => Util.timeToDate(createdAt);

  bool get isEmpty => products.isEmpty;
  bool get isNotEmpty => products.isNotEmpty;
  int get length => products.length;

  /// Get highest index of products plus 1
  /// 1-index
  int get newIndex =>
      products.values.reduce((a, b) => a.index > b.index ? a : b).index + 1;

  String get prefix => id;

  /// sorted by index
  List<ProductModel> get productList =>
      products.values.toList()..sort((a, b) => a.index.compareTo(b.index));

  bool exist(String id) => products.containsKey(id);

  ProductModel? getProduct(String id) => products[id];

  Future<void> remove() async {
    info(toString(), 'menu.catalog.remove');
    await Storage.instance.set(Stores.menu, {id: null});

    MenuModel.instance.removeCatalog(id);
  }

  /// only remove map value and notify listeners
  /// you should remove product by `product.remove()`
  void removeProduct(String id) {
    products.remove(id);

    notifyListeners();
  }

  Future<void> reorderProducts(List<ProductModel> products) {
    final updateData = <String, Object?>{};
    var i = 1;

    products.forEach((product) {
      updateData.addAll(ProductObject.build({'index': i++}).diff(product));
    });

    notifyListeners();

    return Storage.instance.set(Stores.menu, updateData);
  }

  Future<void> setProduct(ProductModel product) async {
    if (!exist(product.id)) {
      info(product.toString(), 'menu.product.add');
      products[product.id] = product;

      final updateData = {product.prefix: product.toObject().toMap()};

      await Storage.instance.set(Stores.menu, updateData);
    }

    notifyListeners();
  }

  CatalogObject toObject() => CatalogObject(
        id: id,
        index: index,
        name: name,
        createdAt: createdAt,
        products: products.values.map((e) => e.toObject()),
      );

  @override
  String toString() => name;

  Future<void> update(CatalogObject catalog) {
    final updateData = catalog.diff(this);

    if (updateData.isEmpty) return Future.value();

    info(toString(), 'menu.catalog.update');
    notifyListeners();

    return Storage.instance.set(Stores.menu, updateData);
  }

  void _preparePorducts() {
    products.values.forEach((e) {
      e.catalog = this;
    });
  }
}
