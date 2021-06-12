import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/menu/product_quantity_model.dart';
import 'package:possystem/models/model.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/repository/stock_model.dart';
import 'package:possystem/models/stock/ingredient_model.dart';
import 'package:possystem/services/storage.dart';

import '../repository.dart';
import 'product_model.dart';

class ProductIngredientModel
    with Model<ProductIngredientObject>, Repository<ProductQuantityModel> {
  /// connect to parent object
  late final ProductModel product;

  /// connect to stock.
  /// When it set, [MenuModel.stockMode] must be true
  late IngredientModel ingredient;

  /// ingredient per product
  num amount;

  ProductIngredientModel({
    String? id,
    IngredientModel? ingredient,
    ProductModel? product,
    num? amount,
    Map<String, ProductQuantityModel>? quantities,
  }) : amount = amount ?? 0 {
    replaceChilds(quantities ?? {});

    if (id != null) this.id = id;

    if (ingredient != null) {
      this.id = ingredient.id;
      this.ingredient = ingredient;
    }
    if (product != null) this.product = product;
  }

  factory ProductIngredientModel.fromObject(ProductIngredientObject object) =>
      ProductIngredientModel(
        id: object.id,
        amount: object.amount,
        quantities: {
          for (var quantity in object.quantities)
            quantity.id!: ProductQuantityModel.fromObject(quantity)
        },
      ).._prepareQuantities();

  @override
  String get childCode => 'menu.quantity';

  @override
  String get code => 'menu.ingredient';

  String get name => ingredient.name;

  @override
  String get prefix => '${product.prefix}.ingredients.$id';

  @override
  Stores get storageStore => Stores.menu;

  @override
  Future<void> addChildToStorage(ProductQuantityModel child) {
    return Storage.instance.set(storageStore, {
      child.prefix: child.toObject().toMap(),
    });
  }

  /// change stock ingredient
  Future<void> changeIngredient(String newId) async {
    await remove();

    setIngredient(StockModel.instance.getChild(newId)!);

    await product.setChild(this);
  }

  @override
  void notifyChild() {
    product.setChild(this);
  }

  @override
  void removeFromRepo() => product.removeChild(id);

  void setIngredient(IngredientModel model) {
    ingredient = model;
    id = model.id;
  }

  @override
  ProductIngredientObject toObject() => ProductIngredientObject(
        id: id,
        amount: amount,
        quantities: childs.map((e) => e.toObject()),
      );

  @override
  String toString() => '$product.$name';

  @override
  Future<void> update(ProductIngredientObject ingredient) async {
    final updateData = ingredient.diff(this);

    if (updateData['id'] != null) return updateData['id'] as Future<void>;

    if (updateData.isEmpty) return Future.value();

    info(toString(), '$code.update');
    await product.setChild(this);

    return Storage.instance.set(storageStore, updateData);
  }

  void _prepareQuantities() {
    childs.forEach((e) {
      e.ingredient = this;
    });
  }
}
