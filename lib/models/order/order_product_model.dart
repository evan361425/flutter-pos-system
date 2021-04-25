import 'package:possystem/models/menu/product_ingredient_model.dart';
import 'package:possystem/models/menu/product_model.dart';
import 'package:possystem/models/order/order_ingredient_model.dart';

class OrderProductModel {
  OrderProductModel(
    this.product, {
    this.count = 1,
    num singlePrice,
  }) : singlePrice = singlePrice ?? product.price;

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

  Map<String, dynamic> toMap() {
    final allIngredients = <String, Map<String, dynamic>>{
      for (var e in product.ingredients.entries)
        e.key: {
          'name': e.value.ingredient.name,
          'cost': e.value.cost,
          'amount': e.value.amount,
        }
    };
    ingredients.forEach((e) {
      allIngredients[e.id].addEntries([
        MapEntry('cost', e.cost),
        MapEntry('amount', e.amount),
        MapEntry('price', e.price),
      ]);
    });

    return {
      'singlePrice': singlePrice,
      'count': count,
      'productId': product.id,
      'productName': product.name,
      'isDiscount': singlePrice != product.price,
      'ingredients': allIngredients,
    };
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
        singlePrice -= oldOne.price;
        ingredients.removeAt(i);
        break;
      }
      i++;
    }

    singlePrice += newOne.price;
    ingredients.add(newOne);
  }

  void removeIngredient(ProductIngredientModel ingredient) {
    ingredients.removeWhere((e) {
      if (e.ingredient.id == ingredient.id) {
        singlePrice -= e.price;
        return true;
      }
      return false;
    });
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
