import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/model.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/repository.dart';
import 'package:possystem/models/repository/menu_model.dart';
import 'package:possystem/services/storage.dart';

import 'product_model.dart';

class CatalogModel extends NotifyModel<CatalogObject>
    with
        OrderableModel,
        Repository<ProductModel>,
        NotifyRepository<ProductModel>,
        OrderablRepository {
  /// catalog's name
  @override
  String name;

  /// when it has been added to menu
  final DateTime createdAt;

  CatalogModel({
    DateTime? createdAt,
    String? id,
    required int index,
    required this.name,
    Map<String, ProductModel>? products,
  })  : createdAt = createdAt ?? DateTime.now(),
        super(id) {
    this.index = index;
    replaceItems(products ?? {});
  }

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

  @override
  String get code => 'menu.catalog';

  String? get createdDate => Util.timeToDate(createdAt);

  @override
  String get itemCode => 'menu.product';

  @override
  Stores get storageStore => Stores.menu;

  @override
  Future<void> addItemToStorage(ProductModel child) {
    return Storage.instance.set(storageStore, {
      child.prefix: child.toObject().toMap(),
    });
  }

  @override
  void notifyItem() {
    notifyListeners();
    MenuModel.instance.notifyItem();
  }

  @override
  void removeFromRepo() => MenuModel.instance.removeItem(id);

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
}
