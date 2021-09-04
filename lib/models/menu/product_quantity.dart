import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/model.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/services/storage.dart';

class ProductQuantity
    with Model<ProductQuantityObject>, SearchableModel<ProductQuantityObject> {
  /// Connect to parent object
  late final ProductIngredient ingredient;

  /// Connect to stock.
  late Quantity quantity;

  /// Amount of ingredient per product
  num amount;

  /// finalCost = product.cost + additionalCost
  num additionalCost;

  /// finalPrice = product.price + additionPrice
  num additionalPrice;

  @override
  final String logCode = 'menu.quantity';

  @override
  final Stores storageStore = Stores.menu;

  ProductQuantity({
    String? id,
    Quantity? quantity,
    ProductIngredient? ingredient,
    this.amount = 0,
    this.additionalCost = 0,
    this.additionalPrice = 0,
  }) {
    if (id != null) this.id = id;

    if (ingredient != null) this.ingredient = ingredient;

    if (quantity != null) setQuantity(quantity);
  }

  factory ProductQuantity.fromObject(ProductQuantityObject object) =>
      ProductQuantity(
        id: object.id,
        amount: object.amount,
        additionalCost: object.additionalCost,
        additionalPrice: object.additionalPrice,
      );

  @override
  String get name => quantity.name;

  @override
  String get prefix => '${ingredient.prefix}.quantities.$id';

  Future<void> changeQuantity(String newId) async {
    await remove();

    setQuantity(Quantities.instance.getItem(newId)!);

    await ingredient.setItem(this);
  }

  @override
  void removeFromRepo() => ingredient.removeItem(id);

  void setQuantity(Quantity model) {
    quantity = model;
    id = model.id;
  }

  @override
  ProductQuantityObject toObject() => ProductQuantityObject(
        id: id,
        amount: amount,
        additionalCost: additionalCost,
        additionalPrice: additionalPrice,
      );

  @override
  Future<bool> update(
    ProductQuantityObject quantity, {
    String event = 'update',
  }) async {
    final updateData = quantity.diff(this);

    if (updateData['id'] != null) {
      await (updateData['id'] as Future<void>);
      return true;
    }

    if (updateData.isEmpty) return false;

    info(toString(), '$logCode.$event');
    await ingredient.setItem(this);

    await Storage.instance.set(storageStore, updateData);

    return true;
  }
}
