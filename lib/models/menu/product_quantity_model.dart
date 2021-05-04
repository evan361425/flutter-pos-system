import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/menu/product_ingredient_model.dart';
import 'package:possystem/models/repository/quantity_repo.dart';
import 'package:possystem/models/stock/quantity_model.dart';
import 'package:possystem/services/database.dart';

class ProductQuantityModel {
  ProductQuantityModel({
    this.id,
    this.quantity,
    this.amount = 0,
    this.additionalCost = 0,
    this.additionalPrice = 0,
  }) : assert(quantity != null || id != null) {
    id ??= quantity.id;
  }

  String id;
  num amount;
  num additionalCost;
  num additionalPrice;
  QuantityModel quantity;

  factory ProductQuantityModel.fromObject(ProductQuantityObject object) {
    return ProductQuantityModel(
      id: object.id,
      amount: object.amount,
      additionalCost: object.additionalCost,
      additionalPrice: object.additionalPrice,
    );
  }

  ProductQuantityObject toObject() {
    return ProductQuantityObject(
      id: id,
      amount: amount,
      additionalCost: additionalCost,
      additionalPrice: additionalPrice,
    );
  }

  // STATE CHANGE

  Future<void> update(
    ProductIngredientModel ingredient,
    ProductQuantityObject quantity,
  ) {
    final updateData = quantity.diff(ingredient, this);

    if (updateData.isEmpty) return Future.value();

    ingredient.updateQuantity(this);

    return Database.instance.update(Collections.menu, updateData);
  }

  void changeQuantity(ProductIngredientModel ingredient, String id) {
    ingredient.removeQuantity(this);
    this.id = id;
    quantity = QuantityRepo.instance[id];
  }

  // GETTER
  @override
  bool operator ==(Object other) {
    return other is ProductQuantityModel ? other.id == id : false;
  }

  bool get isNotReady => id == null;
}
