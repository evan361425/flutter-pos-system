import 'dart:developer';

import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/objects/order_attribute_object.dart';
import 'package:possystem/models/order/order_attribute.dart';
import 'package:possystem/models/order/order_attribute_option.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/translator.dart';

Future<void> setupExampleMenu() async {
  if (Menu.instance.isNotEmpty) return;

  log('setting stock', name: 'example menu');
  for (final e in [
    Ingredient(id: 'cheese', name: '🧀 ${S.menuExampleIngredientCheese}', currentAmount: 30, totalAmount: 30),
    Ingredient(id: 'lettuce', name: '🥬 ${S.menuExampleIngredientLettuce}', currentAmount: 70, totalAmount: 70),
    Ingredient(id: 'tomato', name: '🍅 ${S.menuExampleIngredientTomato}', currentAmount: 100, totalAmount: 100),
    Ingredient(id: 'bun', name: '🍞 ${S.menuExampleIngredientBun}', currentAmount: 50, totalAmount: 50),
    Ingredient(id: 'chili', name: '🌶 ${S.menuExampleIngredientChili}', currentAmount: 500, totalAmount: 500),
    Ingredient(id: 'ham', name: '🍖 ${S.menuExampleIngredientHam}', currentAmount: 5, totalAmount: 5),
    Ingredient(id: 'cola', name: '🥤 ${S.menuExampleIngredientCola}', currentAmount: 20, totalAmount: 20),
    Ingredient(id: 'coffee', name: '☕️ ${S.menuExampleIngredientCoffee}', currentAmount: 50, totalAmount: 50),
    Ingredient(id: 'fries', name: '🍟 ${S.menuExampleIngredientFries}', currentAmount: 3, totalAmount: 3),
    Ingredient(id: 'straw', name: S.menuExampleIngredientStraw, currentAmount: 50, totalAmount: 50),
    Ingredient(id: 'plasticBag', name: S.menuExampleIngredientPlasticBag, currentAmount: 50, totalAmount: 50),
  ]) {
    await Stock.instance.addItem(e);
  }

  log('setting quantities', name: 'example menu');
  for (final e in [
    Quantity(id: 'none', name: S.menuExampleQuantityNone, defaultProportion: 0),
    Quantity(id: 'small', name: S.menuExampleQuantitySmall, defaultProportion: 0.5),
    Quantity(id: 'large', name: S.menuExampleQuantityLarge, defaultProportion: 1.5),
  ]) {
    await Quantities.instance.addItem(e);
  }

  log('setting menu', name: 'example menu');
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  for (final e in [
    Catalog.fromObject(CatalogObject.build({
      "id": "burger",
      "index": 1,
      "name": '🍔 ${S.menuExampleCatalogBurger}',
      "createdAt": now,
      "products": {
        "cheese-burger": {
          "price": 80,
          "cost": 40,
          "index": 1,
          "name": S.menuExampleProductCheeseBurger,
          "createdAt": now,
          "ingredients": {
            "cb-ingredient1": {
              "ingredientId": "cheese",
              "amount": 0.3,
              "quantities": <String, Object?>{
                "cb1-quantity1": {"quantityId": "large", "amount": 0.5, "additionalCost": 5, "additionalPrice": 10},
                "cb1-quantity2": {"quantityId": "small", "amount": 0.1},
              }
            },
            "cb-ingredient2": {"ingredientId": "bun", "amount": 1},
            "cb-ingredient3": {
              "ingredientId": "lettuce",
              "amount": 1,
              "quantities": <String, Object?>{
                "cb3-quantity2": {"quantityId": "none", "amount": 0},
              }
            },
          },
        },
        "veg-burger": {
          "price": 60,
          "cost": 30,
          "index": 2,
          "name": S.menuExampleProductVeggieBurger,
          "createdAt": now,
          "ingredients": {
            "vb-ingredient1": {
              "ingredientId": "tomato",
              "amount": 0.2,
              "quantities": <String, Object?>{
                "vb1-quantity1": {"quantityId": "more", "amount": 0.5, "additionalCost": 2, "additionalPrice": 5},
                "vb1-quantity2": {"quantityId": "less", "amount": 0.1},
              },
            },
            "vb-ingredient2": {"ingredientId": "bun", "amount": 1},
            "vb-ingredient3": {
              "ingredientId": "lettuce",
              "amount": 1,
              "quantities": <String, Object?>{
                "cb3-quantity2": {"quantityId": "none", "amount": 0},
              }
            },
          }
        },
        "ham-burger": {
          "price": 100,
          "cost": 50,
          "index": 3,
          "name": S.menuExampleProductHamBurger,
          "createdAt": now,
          "ingredients": {
            "hb-ingredient1": {
              "ingredientId": "ham",
              "amount": 0.3,
              "quantities": <String, Object?>{
                "hb1-quantity1": {"quantityId": "more", "amount": 0.6, "additionalCost": 10, "additionalPrice": 30},
              },
            },
            "hb-ingredient2": {"ingredientId": "bun", "amount": 1},
            "hb-ingredient3": {
              "ingredientId": "lettuce",
              "amount": 1,
              "quantities": <String, Object?>{
                "cb3-quantity2": {"quantityId": "none", "amount": 0},
              }
            },
          }
        },
      },
    })),
    Catalog.fromObject(CatalogObject.build({
      "id": "drink",
      "index": 2,
      "name": '🍻 ${S.menuExampleCatalogDrink}',
      "createdAt": now,
      "products": {
        "cola": {
          "price": 30,
          "cost": 20,
          "index": 1,
          "name": S.menuExampleProductCola,
          "createdAt": now,
          "ingredients": {
            "cola-ingredient1": {"ingredientId": "cola", "amount": 1},
            "coffee-ingredient2": {"ingredientId": "straw", "amount": 1},
          },
        },
        "coffee": {
          "price": 50,
          "cost": 20,
          "index": 2,
          "name": S.menuExampleProductCoffee,
          "createdAt": now,
          "ingredients": {
            "coffee-ingredient1": {"ingredientId": "coffee", "amount": 1},
          },
        },
      },
    })),
    Catalog.fromObject(CatalogObject.build({
      "id": "side",
      "index": 3,
      "name": '🍰 ${S.menuExampleCatalogSide}',
      "createdAt": now,
      "products": {
        "fries": {
          "price": 50,
          "cost": 25,
          "index": 1,
          "name": S.menuExampleProductFries,
          "createdAt": now,
          "ingredients": {
            "fries-ingredient1": {
              "ingredientId": "fries",
              "amount": 0.1,
              "quantities": <String, Object?>{
                "fries1-quantity1": {"quantityId": "more", "amount": 0.2, "additionalCost": 5, "additionalPrice": 10},
              },
            },
          },
        },
      },
    })),
    Catalog.fromObject(CatalogObject.build({
      "id": "other",
      "index": 4,
      "name": '🛍 ${S.menuExampleCatalogOther}',
      "createdAt": now,
      "products": {
        "plastic-bag": {
          "price": 5,
          "cost": 2,
          "index": 1,
          "name": S.menuExampleProductPlasticBag,
          "createdAt": now,
          "ingredients": {
            "plastic-bag-ingredient1": {"ingredientId": "plasticBag", "amount": 1},
          },
        },
        "straw": {
          "price": 5,
          "cost": 0.1,
          "index": 2,
          "name": S.menuExampleProductStraw,
          "createdAt": now,
          "ingredients": {
            "straw-ingredient1": {"ingredientId": "straw", "amount": 1},
          },
        },
      },
    })),
  ]) {
    await Menu.instance.addItem(e);
  }
}

Future<void> setupExampleOrderAttrs() async {
  if (OrderAttributes.instance.isNotEmpty) return;

  log('setting order attributes', name: 'example order attrs');
  for (final e in [
    OrderAttribute(
      id: 'age',
      name: S.orderAttributeExampleAge,
      index: 1,
      mode: OrderAttributeMode.statOnly,
      options: {
        'child': OrderAttributeOption(id: 'child', name: '${S.orderAttributeExampleAgeChild} (0-12)', index: 1),
        'adult': OrderAttributeOption(
            id: 'adult', name: '${S.orderAttributeExampleAgeAdult} (13-60)', index: 2, isDefault: true),
        'senior': OrderAttributeOption(id: 'senior', name: '${S.orderAttributeExampleAgeSenior} (60+)', index: 3),
      },
    )..prepareItem(),
    OrderAttribute(
      id: 'place',
      name: S.orderAttributeExamplePlace,
      index: 2,
      mode: OrderAttributeMode.changeDiscount,
      options: {
        'takeout':
            OrderAttributeOption(id: 'takeout', name: S.orderAttributeExamplePlaceTakeout, index: 1, isDefault: true),
        'dine-in':
            OrderAttributeOption(id: 'dine-in', name: S.orderAttributeExamplePlaceDineIn, index: 2, modeValue: 1.1),
      },
    )..prepareItem(),
    OrderAttribute(
      id: 'eco-friendly',
      name: S.orderAttributeExampleEcoFriendly,
      index: 3,
      mode: OrderAttributeMode.changePrice,
      options: {
        'reuseable-bag': OrderAttributeOption(
            id: 'reuseable-bag', name: S.orderAttributeExampleEcoFriendlyReusableBag, index: 1, modeValue: -5),
        'reuseable-bottle': OrderAttributeOption(
            id: 'reuseable-bottle', name: S.orderAttributeExampleEcoFriendlyReusableBottle, index: 1, modeValue: -30),
      },
    )..prepareItem(),
  ]) {
    await OrderAttributes.instance.addItem(e);
  }
}
