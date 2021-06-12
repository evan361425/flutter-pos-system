import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/menu/product_ingredient_model.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/repository/quantity_repo.dart';
import 'package:possystem/models/stock/quantity_model.dart';
import 'package:possystem/services/storage.dart';

class ProductQuantityModel {
  late String id;

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
    required this.amount,
    required this.additionalCost,
    required this.additionalPrice,
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

  String get name => quantity.name;

  String get prefix => '${ingredient.prefix}.quantities.$id';

  Future<void> changeQuantity(String newId) async {
    await remove();

    setQuantity(QuantityRepo.instance.getChild(newId)!);

    await ingredient.setQuantity(this);
  }

  Future<void> remove() async {
    info(toString(), 'menu.quantity.remove');
    await Storage.instance.set(Stores.menu, {prefix: null});

    ingredient.removeQuantity(id);
  }

  void setQuantity(QuantityModel model) {
    quantity = model;
    id = model.id;
  }

  ProductQuantityObject toObject() => ProductQuantityObject(
        id: id,
        amount: amount,
        additionalCost: additionalCost,
        additionalPrice: additionalPrice,
      );

  @override
  String toString() => '$ingredient.$name';

  Future<void> update(ProductQuantityObject quantity) async {
    final updateData = await quantity.diff(this);

    if (updateData.isEmpty) return Future.value();

    info(toString(), 'menu.quantity.update');
    await ingredient.setQuantity(this);

    return Storage.instance.set(Stores.menu, updateData);
  }
}
