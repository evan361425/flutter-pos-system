import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/models/menu/search_product_match.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/models/stock/quantity.dart';

import '../../mocks/mock_cache.dart';
import '../../mocks/mock_storage.dart';

void main() {
  group('SearchProductMatch', () {
    late Catalog catalog;
    late Product product;
    late ProductIngredient ingredient1;
    late ProductIngredient ingredient2;
    late ProductQuantity quantity1;
    late ProductQuantity quantity2;
    late Ingredient stockIngredient1;
    late Ingredient stockIngredient2;
    late Quantity stockQuantity1;
    late Quantity stockQuantity2;

    setUp(() {
      initializeCache();
      initializeStorage();
      
      Stock.instance = Stock();
      Menu.instance = Menu();
      
      // Create stock ingredients and quantities
      stockIngredient1 = Ingredient(name: 'Tomato Sauce');
      stockIngredient2 = Ingredient(name: 'Mozzarella Cheese');
      stockQuantity1 = Quantity(name: 'Extra Large');
      stockQuantity2 = Quantity(name: 'Small');
      
      // Create product ingredients and quantities
      ingredient1 = ProductIngredient(ingredient: stockIngredient1);
      ingredient2 = ProductIngredient(ingredient: stockIngredient2);
      quantity1 = ProductQuantity(quantity: stockQuantity1);
      quantity2 = ProductQuantity(quantity: stockQuantity2);
      
      // Set up relationships
      ingredient1.replaceItems({quantity1.id: quantity1, quantity2.id: quantity2});
      
      // Create catalog and product
      catalog = Catalog(name: 'Italian Food');
      product = Product(name: 'Pizza Margherita');
      
      // Set up relationships
      catalog.replaceItems({product.id: product});
      product.repository = catalog;
    });

    test('should identify product name matches', () {
      final match = SearchProductMatch.analyze(product, 'pizza');

      expect(match.productNameMatches, isTrue);
      expect(match.catalogNameMatches, isFalse);
      expect(match.hasMatches, isTrue);
      expect(match.hasIngredientOrQuantityMatches, isFalse);
      expect(match.hasDetailedMatches, isFalse);
    });

    test('should identify catalog name matches', () {
      final match = SearchProductMatch.analyze(product, 'italian');

      expect(match.productNameMatches, isFalse);
      expect(match.catalogNameMatches, isTrue);
      expect(match.hasMatches, isTrue);
      expect(match.hasDetailedMatches, isTrue);
    });

    test('should identify ingredient name matches', () {
      product.replaceItems({ingredient1.id: ingredient1, ingredient2.id: ingredient2});
      
      final match = SearchProductMatch.analyze(product, 'tomato');

      expect(match.productNameMatches, isFalse);
      expect(match.catalogNameMatches, isFalse);
      expect(match.hasMatches, isTrue);
      expect(match.hasIngredientOrQuantityMatches, isTrue);
      expect(match.hasDetailedMatches, isTrue);
      expect(match.ingredientMatches, hasLength(1));
      expect(match.ingredientMatches.first.ingredient, equals(ingredient1));
      expect(match.ingredientMatches.first.nameMatches, isTrue);
    });

    test('should identify quantity name matches', () {
      product.replaceItems({ingredient1.id: ingredient1});
      
      final match = SearchProductMatch.analyze(product, 'large');

      expect(match.productNameMatches, isFalse);
      expect(match.catalogNameMatches, isFalse);
      expect(match.hasMatches, isTrue);
      expect(match.hasIngredientOrQuantityMatches, isTrue);
      expect(match.hasDetailedMatches, isTrue);
      expect(match.ingredientMatches, hasLength(1));
      expect(match.ingredientMatches.first.quantityMatches, hasLength(1));
      expect(match.ingredientMatches.first.quantityMatches.first.quantity, equals(quantity1));
    });

    test('should be case insensitive', () {
      final match = SearchProductMatch.analyze(product, 'PIZZA');

      expect(match.productNameMatches, isTrue);
      expect(match.hasMatches, isTrue);
    });

    test('should handle no matches', () {
      product.replaceItems({ingredient1.id: ingredient1});
      
      final match = SearchProductMatch.analyze(product, 'burger');

      expect(match.productNameMatches, isFalse);
      expect(match.catalogNameMatches, isFalse);
      expect(match.hasMatches, isFalse);
      expect(match.hasIngredientOrQuantityMatches, isFalse);
      expect(match.hasDetailedMatches, isFalse);
      expect(match.ingredientMatches, isEmpty);
    });

    test('should handle empty pattern', () {
      final match = SearchProductMatch.analyze(product, '');

      expect(match.productNameMatches, isFalse);
      expect(match.catalogNameMatches, isFalse);
      expect(match.hasMatches, isFalse);
      expect(match.searchPattern, isEmpty);
    });
  });
}