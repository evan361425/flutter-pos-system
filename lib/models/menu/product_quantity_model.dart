import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/menu/product_ingredient_model.dart';
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

  factory ProductQuantityModel.fromMap(ProductQuantityObject map) {
    return ProductQuantityModel(
      id: map.id,
      amount: map.amount,
      additionalCost: map.additionalCost,
      additionalPrice: map.additionalPrice,
    );
  }

  ProductQuantityObject toMap() {
    return ProductQuantityObject(
      id: id,
      amount: amount,
      additionalCost: additionalCost,
      additionalPrice: additionalPrice,
    );
  }

  // STATE CHANGE

  void update(
    ProductIngredientModel ingredient,
    ProductQuantityModel quantity,
  ) {
    final updateData = getUpdateData(ingredient, quantity);

    if (updateData.isEmpty) return;

    Database.instance.update(Collections.menu, updateData);
  }

  Map<String, dynamic> getUpdateData(
    ProductIngredientModel ingredient,
    ProductQuantityModel quantity,
  ) {
    final prefix = '${ingredient.prefixQuantities}.$id';
    final updateData = <String, dynamic>{};
    if (quantity.amount != amount) {
      amount = quantity.amount;
      updateData['$prefix.amount'] = amount;
    }
    if (quantity.additionalCost != additionalCost) {
      additionalCost = quantity.additionalCost;
      updateData['$prefix.additionalCost'] = additionalCost;
    }
    if (quantity.additionalPrice != additionalPrice) {
      additionalPrice = quantity.additionalPrice;
      updateData['$prefix.additionalPrice'] = additionalPrice;
    }
    // final
    if (quantity.id != id) {
      ingredient.removeQuantity(quantity);

      id = quantity.id;
      this.quantity = quantity.quantity;

      updateData.clear();
    }

    return updateData;
  }

  // GETTER
  @override
  bool operator ==(Object other) {
    return other is ProductQuantityModel ? other.id == id : false;
  }

  bool get isNotReady => id == null;
}
