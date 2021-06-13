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

  void addIngredient(OrderIngredientModel ingredient) {
    var i = 0;
    for (var element in ingredients) {
      if (element.id == ingredient.id) {
        // remove it to push to end, use element.price for old price
        singlePrice -= element.price;
        ingredients.removeAt(i);
        break;
      }
      i++;
    }

    singlePrice += ingredient.price;
    ingredients.add(ingredient);
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

  void removeIngredient(String id) {
    ingredients.removeWhere((e) {
      if (e.id == id) {
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

  OrderProductObject toObject() {
    // including default quantity ingredient
    final allIngredients = <String, OrderIngredientObject>{
      for (var ingredient in product.items)
        ingredient.id: OrderIngredientObject(
          id: ingredient.id,
          name: ingredient.name,
          amount: ingredient.amount,
        )
    };

    var originalPrice = product.price;
    // ingredient with special quantity
    ingredients.forEach((ingredient) {
      originalPrice += ingredient.price;

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
      originalPrice: originalPrice,
      isDiscount: singlePrice < originalPrice,
      ingredients: allIngredients,
    );
  }

  // Custom Listeners for performace
  static void addListener(
    void Function() listener,
    OrderProductListenerTypes type,
  ) {
    listeners[type]!.add(listener);
    print('listener $type added ${listeners[type]!.length}');
  }

  static void notifyListener(OrderProductListenerTypes type) {
    listeners[type]!.forEach((lisnter) => lisnter());
  }

  static void removeListener(
    void Function() listener,
    OrderProductListenerTypes type,
  ) {
    listeners[type]!.remove(listener);
    print('listener $type removed ${listeners[type]!.length}');
  }
}
