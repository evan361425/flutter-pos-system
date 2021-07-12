import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/objects/stock_object.dart';

final mockCatalogObject = CatalogObject.build({
  'id': 'catalog_1',
  'name': 'burger',
  'index': 1,
  'createdAt': 1623639573,
  'products': {
    'product_1': {
      'name': 'ham burger',
      'index': 1,
      'price': 30,
      'cost': 10,
      'createdAt': 1623639573,
      'ingredients': {
        'ingredient_1': {
          'amount': 2,
          'quantities': {
            'quantity_1': {
              'amount': 3,
              'additionalPrice': 5,
              'additionalCost': 2,
            },
            'quantity_2': {
              'amount': 1,
              'additionalPrice': 0,
              'additionalCost': -2,
            }
          },
        },
        'ingredient_2': {
          'amount': 1,
          'quantities': <String, Object?>{},
        },
      },
    },
    'product_2': null, // represent deleted data
  }
});

final mockQuantityObject1 = QuantityObject.build({
  'id': 'quantity_1',
  'name': 'more',
  'defaultProportion': 1.5,
});

final mockQuantityObject2 = QuantityObject.build({
  'id': 'quantity_2',
  'name': 'less',
  'defaultProportion': 0.5,
});

final mockIngredientObject1 = IngredientObject.build({
  'id': 'ingredient_1',
  'name': 'ham',
  'currentAmount': 45,
  'warningAmount': 0,
  'alertAmount': 0,
  'lastAmount': 100,
  'lastAddAmount': 100,
  'updatedTime': 1623639573,
});

final mockIngredientObject2 = IngredientObject.build({
  'id': 'ingredient_2',
  'name': 'bread',
  'currentAmount': 10,
  'warningAmount': 0,
  'alertAmount': 0,
  'lastAmount': 30,
  'lastAddAmount': 15,
  'updatedTime': 1623639573,
});
