import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/menu/product_ingredient_model.dart';
import 'package:possystem/models/model.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/repository/quantity_repo.dart';
import 'package:possystem/models/stock/quantity_model.dart';
import 'package:possystem/services/storage.dart';

class ProductQuantityModel with Model<ProductQuantityObject> {
  /// connect to parent object
  late final ProductIngredientModel ingredient;

  /// connect to stock.
  /// When it set, [MenuModel.stockMode] must be true
  late QuantityModel quantity;

  /// ingredient per product
  num amount;

  /// finalCost = product.cost + additionalCost
  num additionalCost;

  /// finalPrice = product.price + additionPrice
  num additionalPrice;

  ProductQuantityModel({
    String? id,
    QuantityModel? quantity,
    ProductIngredientModel? ingredient,
    this.amount = 0,
    this.additionalCost = 0,
    this.additionalPrice = 0,
  }) {
    if (id != null) this.id = id;

    if (quantity != null) {
      this.id = quantity.id;
      this.quantity = quantity;
    }
    if (ingredient != null) this.ingredient = ingredient;
  }

  factory ProductQuantityModel.fromObject(ProductQuantityObject object) =>
      ProductQuantityModel(
        id: object.id,
        amount: object.amount,
        additionalCost: object.additionalCost,
        additionalPrice: object.additionalPrice,
      );

  @override
  String get code => 'menu.quantity';

  @override
  String get name => quantity.name;

  @override
  String get prefix => '${ingredient.prefix}.quantities.$id';

  @override
  Stores get storageStore => Stores.menu;

  Future<void> changeQuantity(String newId) async {
    await remove();

    setQuantity(QuantityRepo.instance.getItem(newId)!);

    await ingredient.setItem(this);
  }

  @override
  void removeFromRepo() => ingredient.removeItem(id);

  void setQuantity(QuantityModel model) {
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
  String toString() => '$ingredient.$name';

  @override
  Future<void> update(ProductQuantityObject quantity) async {
    final updateData = quantity.diff(this);

    if (updateData['id'] != null) return updateData['id'] as Future<void>;

    if (updateData.isEmpty) return Future.value();

    info(toString(), '$code.update');
    await ingredient.setItem(this);

    return Storage.instance.set(storageStore, updateData);
  }
}
