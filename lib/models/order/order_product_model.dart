import 'package:possystem/models/menu/product_ingredient_model.dart';
import 'package:possystem/models/menu/product_model.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/order/order_ingredient_model.dart';

enum OrderProductListenerTypes {
  count,
  selection,
}

class OrderProductModel {
  static final listeners = <OrderProductListenerTypes, List<void Function()>>{
    OrderProductListenerTypes.count: [],
    OrderProductListenerTypes.selection: [],
  };

  ProductModel product;
  bool isSelected = false;
  num singlePrice;
  int count;
  final List<OrderIngredientModel> ingredients;

  OrderProductModel(
    this.product, {
    int? count,
    num? singlePrice,
    List<OrderIngredientModel>? ingredients,
  })  : singlePrice = singlePrice ?? product.price,
        ingredients = ingredients ?? [],
        count = count ?? 1;
  Iterable<String> get ingredientNames => ingredients.map((e) => e.toString());

  num get price => count * singlePrice;
  void addIngredient(OrderIngredientModel newOne) {
    var i = 0;
    for (var oldOne in ingredients) {
      if (oldOne == newOne) {
        singlePrice -= oldOne.price;
        ingredients.removeAt(i);
        break;
      }
      i++;
    }

    singlePrice += newOne.price;
    ingredients.add(newOne);
  }

  void decrement([int value = 1]) => setCount(-value);

  OrderIngredientModel? getIngredientOf(String? id) {
    try {
      return ingredients.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  void increment([int value = 1]) => setCount(value);

  void removeIngredient(ProductIngredientModel? ingredient) {
    ingredients.removeWhere((e) {
      if (e.ingredient.id == ingredient!.id) {
        singlePrice -= e.price;
        return true;
      }
      return false;
    });
  }

  void setCount(int value) {
    count += value;
    notifyListener(OrderProductListenerTypes.count);
  }

  bool toggleSelected([bool? checked]) {
    checked ??= !isSelected;
    final changed = isSelected != checked;

    if (changed) {
      isSelected = checked;
      notifyListener(OrderProductListenerTypes.selection);
    }

    return changed;
  }

  // Custom Listeners for performace

  OrderProductObject toObject() {
    // including default quantity ingredient
    final allIngredients = <String, OrderIngredientObject>{
      for (var ingredientEntry in product.ingredients.entries)
        ingredientEntry.key: OrderIngredientObject(
          id: ingredientEntry.key,
          name: ingredientEntry.value.ingredient.name,
          amount: ingredientEntry.value.amount,
        )
    };
    // ingredient with special quantity
    ingredients.forEach((ingredient) {
      allIngredients[ingredient.id]!.update(
        additionalCost: ingredient.cost,
        additionalPrice: ingredient.price,
        amount: ingredient.amount,
        quantityId: ingredient.quantity.id,
        quantityName: ingredient.quantity.name,
      );
    });

    return OrderProductObject(
      singlePrice: singlePrice,
      count: count,
      productId: product.id,
      productName: product.name,
      isDiscount: singlePrice != product.price,
      ingredients: allIngredients,
    );
  }

  static void addListener(
    void Function() listener, [
    OrderProductListenerTypes? type,
  ]) {
    if (type != null) return listeners[type]!.add(listener);

    listeners[OrderProductListenerTypes.count]!.add(listener);
    listeners[OrderProductListenerTypes.selection]!.add(listener);
  }

  static void notifyListener([OrderProductListenerTypes? type]) {
    if (type != null) return listeners[type]!.forEach((lisnter) => lisnter());

    listeners[OrderProductListenerTypes.count]!.forEach((e) => e());
    listeners[OrderProductListenerTypes.selection]!.forEach((e) => e());
  }

  static void removeListener(void Function() listener) {
    listeners[OrderProductListenerTypes.count]!.remove(listener);
    listeners[OrderProductListenerTypes.selection]!.remove(listener);
  }
}
