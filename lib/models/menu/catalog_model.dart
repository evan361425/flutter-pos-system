import 'package:possystem/helpers/logger.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/model.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/repository.dart';
import 'package:possystem/models/repository/menu_model.dart';
import 'package:possystem/services/storage.dart';

import 'product_model.dart';

class CatalogModel extends Model<CatalogObject>
    with OrderableModel, Repository<ProductModel>, OrderablRepository {
  /// catalog's name
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
    replaceChilds(products ?? {});
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
  String get childCode => 'menu.product';

  @override
  String get code => 'menu.catalog';

  String? get createdDate => Util.timeToDate(createdAt);

  @override
  Stores get storageStore => Stores.menu;

  @override
  void removeFromRepo() => MenuModel.instance.removeChild(id);

  @override
  Future<void> setChild(ProductModel child) async {
    if (!existChild(child.id)) {
      info(child.toString(), '$childCode.add');
      addChild(child);

      final updateData = {child.prefix: child.toObject().toMap()};

      await Storage.instance.set(storageStore, updateData);
    }

    notifyListeners();
  }

  @override
  CatalogObject toObject() => CatalogObject(
        id: id,
        index: index,
        name: name,
        createdAt: createdAt,
        products: childs.map((e) => e.toObject()),
      );

  @override
  String toString() => name;

  void _preparePorducts() => childs.forEach((e) => e.catalog = this);
}
