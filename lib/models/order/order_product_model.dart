import 'package:possystem/models/menu/product_ingredient_model.dart';
import 'package:possystem/models/menu/product_model.dart';
import 'package:possystem/models/order/order_ingredient_model.dart';

class OrderProductModel {
  OrderProductModel(
    this.product, {
    this.count = 1,
  }) : singlePrice = product.price;

  ProductModel product;
  bool isSelected = false;
  num singlePrice;
  int count;
  final List<OrderIngredientModel> ingredients = [];

  num get price => count * singlePrice;
  Iterable<String> get ingredientNames => ingredients.map((e) => e.toString());

  void increment([int value = 1]) => setCount(value);
  void decrement([int value = 1]) => setCount(-value);
  void setCount(int value) {
    count += value;
    notifyListener(OrderProductListenerTypes.count);
  }

  bool toggleSelected([bool checked]) {
    checked ??= !isSelected;
    final changed = isSelected != checked;

    if (changed) {
      isSelected = checked;
      notifyListener(OrderProductListenerTypes.selection);
    }

    return changed;
  }

  OrderIngredientModel getIngredientOf(String id) {
    try {
      return ingredients.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  void addIngredient(OrderIngredientModel newOne) {
    var i = 0;
    for (var oldOne in ingredients) {
      if (oldOne == newOne) {
        singlePrice +=
            newOne.quantity.additionalPrice - oldOne.quantity.additionalPrice;
        ingredients.removeAt(i);
        break;
      }
      i++;
    }
    ingredients.add(newOne);
  }

  void removeIngredient(ProductIngredientModel ingredient) {
    ingredients.removeWhere((e) => e.ingredient.id == ingredient.id);
  }

  // Custom Listeners for performace

  static final listeners = <OrderProductListenerTypes, List<void Function()>>{
    OrderProductListenerTypes.count: [],
    OrderProductListenerTypes.selection: [],
  };
  static void addListener(
    void Function() listener, [
    OrderProductListenerTypes type,
  ]) {
    if (type != null) return listeners[type].add(listener);

    listeners[OrderProductListenerTypes.count].add(listener);
    listeners[OrderProductListenerTypes.selection].add(listener);
  }

  static void removeListener(void Function() listener) {
    listeners[OrderProductListenerTypes.count].remove(listener);
    listeners[OrderProductListenerTypes.selection].remove(listener);
  }

  static void notifyListener([OrderProductListenerTypes type]) {
    if (type != null) return listeners[type].forEach((lisnter) => lisnter());

    listeners[OrderProductListenerTypes.count].forEach((e) => e());
    listeners[OrderProductListenerTypes.selection].forEach((e) => e());
  }
}

enum OrderProductListenerTypes {
  count,
  selection,
}
