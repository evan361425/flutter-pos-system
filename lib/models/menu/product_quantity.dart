import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/model.dart';
import 'package:possystem/models/objects/menu_object.dart';
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

  /// Only use for set up [quantity]
  final String? storageQuantityId;

  @override
  final String logCode = 'menu.quantity';

  @override
  final Stores storageStore = Stores.menu;

  ProductQuantity({
    String? id,
    Quantity? quantity,
    ProductIngredient? ingredient,
    this.storageQuantityId,
    this.amount = 0,
    this.additionalCost = 0,
    this.additionalPrice = 0,
  }) {
    this.id = id ?? generateId();

    if (ingredient != null) this.ingredient = ingredient;

    if (quantity != null) this.quantity = quantity;
  }

  factory ProductQuantity.fromObject(ProductQuantityObject object) {
    return ProductQuantity(
      id: object.id,
      storageQuantityId: object.quantityId!,
      amount: object.amount!,
      additionalCost: object.additionalCost!,
      additionalPrice: object.additionalPrice!,
    );
  }

  @override
  String get name => quantity.name;

  @override
  String get prefix => '${ingredient.prefix}.quantities.$id';

  @override
  void handleUpdated() {
    ingredient.notifyItem();
  }

  @override
  void removeFromRepo() => ingredient.removeItem(id);

  @override
  ProductQuantityObject toObject() => ProductQuantityObject(
        id: id,
        quantityId: storageQuantityId ?? quantity.id,
        amount: amount,
        additionalCost: additionalCost,
        additionalPrice: additionalPrice,
      );
}
