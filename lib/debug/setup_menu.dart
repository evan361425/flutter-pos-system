import 'dart:developer';

import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/models/stock/quantity.dart';

Future<void> debugSetupMenu() async {
  if (Menu.instance.isNotEmpty) return;

  log('DEBUG setup stock');
  await Stock.instance.addItem(Ingredient(
    id: 'cheese',
    name: 'Cheese',
    currentAmount: 30,
  ));
  await Stock.instance.addItem(Ingredient(
    id: 'vegetable',
    name: 'Vegetable',
    currentAmount: 100,
  ));
  await Stock.instance.addItem(Ingredient(
    id: 'bread',
    name: 'Bread',
    currentAmount: 50,
  ));

  log('DEBUG setup quantities');
  await Quantities.instance.addItem(Quantity(
    id: 'more',
    name: 'More',
    defaultProportion: 1.5,
  ));
  await Quantities.instance.addItem(Quantity(
    id: 'less',
    name: 'Less',
    defaultProportion: 0.8,
  ));

  log('DEBUG setup menu');
  await Menu.instance.addItem(Catalog.fromObject(CatalogObject.build({
    "id": "burger",
    "index": 1,
    "name": "Burger",
    "createdAt": 1648885177,
    "imagePath": null,
    "products": {
      "cheese-burger": {
        "price": 60,
        "cost": 55,
        "index": 1,
        "name": "Cheese Burger",
        "imagePath": null,
        "createdAt": 1648885807,
        "ingredients": {
          "cb-ingredient1": {
            "ingredientId": "cheese",
            "amount": 18,
            "quantities": <String, Object?>{
              "cb-quantity-1": {
                "quantityId": "more",
                "amount": 18,
                "additionalCost": 5,
                "additionalPrice": 15
              },
              "cb-quantity-2": {
                "quantityId": "less",
                "amount": 9.0,
                "additionalCost": 0,
                "additionalPrice": 0
              }
            }
          },
          "cb-ingredient2": {
            "ingredientId": "bread",
            "amount": 15,
            "quantities": <String, Object?>{}
          }
        }
      },
      "veg-burger": {
        "price": 50,
        "cost": 30,
        "index": 2,
        "name": "Veg Burger",
        "imagePath": null,
        "createdAt": 1648885992,
        "ingredients": {
          "vb-ingredient1": {
            "ingredientId": "vegetable",
            "amount": 10,
            "quantities": <String, Object?>{
              "vb-quantity1": {
                "quantityId": "more",
                "amount": 20,
                "additionalCost": 2,
                "additionalPrice": 8
              },
              "vb-quantity2": {
                "quantityId": "less",
                "amount": 5.0,
                "additionalCost": 0,
                "additionalPrice": 0
              }
            }
          },
          "vb-ingredient2": {
            "ingredientId": "bread",
            "amount": 15,
            "quantities": <String, Object?>{}
          }
        }
      },
      "rice-burger": {
        "price": 88,
        "cost": 60,
        "index": 3,
        "name": "Rice Burger",
        "imagePath": null,
        "createdAt": 1648886087,
        "ingredients": <String, Object?>{}
      }
    }
  })));
}
