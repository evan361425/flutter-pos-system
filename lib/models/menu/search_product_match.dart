import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product_quantity.dart';

/// Represents the details of how a product matches a search pattern
class SearchProductMatch {
  final Product product;
  final String searchPattern;
  final bool productNameMatches;
  final bool catalogNameMatches;
  final List<ProductIngredientMatch> ingredientMatches;

  const SearchProductMatch({
    required this.product,
    required this.searchPattern,
    required this.productNameMatches,
    required this.catalogNameMatches,
    required this.ingredientMatches,
  });

  /// Creates a SearchProductMatch by analyzing how the product matches the pattern
  factory SearchProductMatch.analyze(Product product, String pattern) {
    final patternLower = pattern.toLowerCase();
    final productNameMatches = product.name.toLowerCase().contains(patternLower);
    final catalogNameMatches = product.catalog.name.toLowerCase().contains(patternLower);
    
    final ingredientMatches = <ProductIngredientMatch>[];
    
    for (final ingredient in product.items) {
      final ingredientNameMatches = ingredient.name.toLowerCase().contains(patternLower);
      final quantityMatches = <ProductQuantityMatch>[];
      
      for (final quantity in ingredient.items) {
        if (quantity.name.toLowerCase().contains(patternLower)) {
          quantityMatches.add(ProductQuantityMatch(
            quantity: quantity,
            nameMatches: true,
          ));
        }
      }
      
      if (ingredientNameMatches || quantityMatches.isNotEmpty) {
        ingredientMatches.add(ProductIngredientMatch(
          ingredient: ingredient,
          nameMatches: ingredientNameMatches,
          quantityMatches: quantityMatches,
        ));
      }
    }

    return SearchProductMatch(
      product: product,
      searchPattern: pattern,
      productNameMatches: productNameMatches,
      catalogNameMatches: catalogNameMatches,
      ingredientMatches: ingredientMatches,
    );
  }

  /// Returns true if this product has any matches
  bool get hasMatches => productNameMatches || catalogNameMatches || ingredientMatches.isNotEmpty;

  /// Returns true if the matches include ingredients or quantities (not just product name)
  bool get hasIngredientOrQuantityMatches => ingredientMatches.isNotEmpty;

  /// Returns true if the matches include catalog name or ingredient/quantity matches
  bool get hasDetailedMatches => catalogNameMatches || hasIngredientOrQuantityMatches;
}

/// Represents how a product ingredient matches the search
class ProductIngredientMatch {
  final ProductIngredient ingredient;
  final bool nameMatches;
  final List<ProductQuantityMatch> quantityMatches;

  const ProductIngredientMatch({
    required this.ingredient,
    required this.nameMatches,
    required this.quantityMatches,
  });
}

/// Represents how a product quantity matches the search
class ProductQuantityMatch {
  final ProductQuantity quantity;
  final bool nameMatches;

  const ProductQuantityMatch({
    required this.quantity,
    required this.nameMatches,
  });
}