import 'package:possystem/models/menu/product_ingredient_model.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/repository/quantity_repo.dart';
import 'package:possystem/models/stock/quantity_model.dart';
import 'package:possystem/services/storage.dart';

class ProductQuantityModel {
  String id;

  /// connect to parent object
  ProductIngredientModel ingredient;

  /// connect to stock.
  /// When it set, [MenuModel.stockMode] must be true
  QuantityModel quantity;

  /// ingredient per product
  num amount;

  /// finalCost = product.cost + additionalCost
  num additionalCost;

  /// finalPrice = product.price + additionPrice
  num additionalPrice;

  ProductQuantityModel({
    this.id,
    this.quantity,
    this.ingredient,
    this.amount = 0,
    this.additionalCost = 0,
    this.additionalPrice = 0,
  }) {
    id ??= quantity?.id;
  }

  factory ProductQuantityModel.fromObject(ProductQuantityObject object) =>
      ProductQuantityModel(
        id: object.id,
        amount: object.amount,
        additionalCost: object.additionalCost,
        additionalPrice: object.additionalPrice,
      );

  String get prefix => '${ingredient.prefix}.quantities.$id';

  void changeQuantity(String newId) async {
    await remove();

    id = newId;
    quantity = QuantityRepo.instance.getQuantity(id);
    print('change quantity to ${quantity.name}');

    return Storage.instance.set(Stores.menu, {prefix: toObject().toMap()});
  }

  Future<void> remove() async {
    print('remove product quantity ${quantity.name}');
    await Storage.instance.set(Stores.menu, {prefix: null});

    ingredient.removeQuantity(id);
  }

  ProductQuantityObject toObject() => ProductQuantityObject(
        id: id,
        amount: amount,
        additionalCost: additionalCost,
        additionalPrice: additionalPrice,
      );

  Future<void> update(ProductQuantityObject quantity) {
    final updateData = quantity.diff(this);

    if (updateData.isEmpty) return Future.value();

    ingredient.updateQuantity(this);

    return Storage.instance.set(Stores.menu, updateData);
  }
}
