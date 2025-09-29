import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/components/search_bar_wrapper.dart';
import 'package:possystem/components/style/highlight_text.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/models/menu/search_product_match.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/ui/menu/menu_page.dart';
import 'package:possystem/translator.dart';

import '../../mocks/mock_cache.dart';
import '../../mocks/mock_storage.dart';
import '../../test_helpers/translator.dart';

void main() {
  group('Menu Search Highlighting', () {
    setUpAll(() {
      initializeTranslator();
    });
    
    setUp(() {
      initializeCache();
      initializeStorage();
      
      Stock.instance = Stock();
      Menu.instance = Menu();
    });

    testWidgets('should highlight product name matches', (tester) async {
      // Create test data
      final catalog = Catalog(name: 'Main Menu');
      final product = Product(name: 'Pizza Margherita');
      catalog.replaceItems({product.id: product});
      product.repository = catalog;
      Menu.instance.replaceItems({catalog.id: catalog});

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _SearchAction(withTextFiled: true),
          ),
        ),
      );

      // Enter search text
      await tester.enterText(find.byType(TextField), 'pizza');
      await tester.pump();

      // Verify that HighlightText widget is used and shows the product
      expect(find.byType(HighlightText), findsAtLeastNWidgets(1));
      expect(find.text('Pizza Margherita'), findsOneWidget);
    });

    testWidgets('should show ingredient matches in subtitle', (tester) async {
      // Create test data with ingredients
      final catalog = Catalog(name: 'Main Menu');
      final product = Product(name: 'Pizza');
      final stockIngredient = Ingredient(name: 'Tomato Sauce');
      final ingredient = ProductIngredient(ingredient: stockIngredient);
      
      product.replaceItems({ingredient.id: ingredient});
      catalog.replaceItems({product.id: product});
      product.repository = catalog;
      Menu.instance.replaceItems({catalog.id: catalog});

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _SearchAction(withTextFiled: true),
          ),
        ),
      );

      // Enter search text that matches ingredient
      await tester.enterText(find.byType(TextField), 'tomato');
      await tester.pump();

      // Verify that ingredient match is shown
      expect(find.text('Ingredient: Tomato Sauce'), findsOneWidget);
      expect(find.byType(HighlightText), findsAtLeastNWidgets(1));
    });

    testWidgets('should show catalog matches in subtitle', (tester) async {
      // Create test data
      final catalog = Catalog(name: 'Italian Food');
      final product = Product(name: 'Pizza');
      catalog.replaceItems({product.id: product});
      product.repository = catalog;
      Menu.instance.replaceItems({catalog.id: catalog});

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _SearchAction(withTextFiled: true),
          ),
        ),
      );

      // Enter search text that matches catalog
      await tester.enterText(find.byType(TextField), 'italian');
      await tester.pump();

      // Verify that catalog match is shown
      expect(find.text('Catalog: Italian Food'), findsOneWidget);
    });

    testWidgets('should show quantity matches', (tester) async {
      // Create test data with quantities
      final catalog = Catalog(name: 'Main Menu');
      final product = Product(name: 'Pizza');
      final stockIngredient = Ingredient(name: 'Cheese');
      final stockQuantity = Quantity(name: 'Extra Large');
      final ingredient = ProductIngredient(ingredient: stockIngredient);
      final quantity = ProductQuantity(quantity: stockQuantity);
      
      ingredient.replaceItems({quantity.id: quantity});
      product.replaceItems({ingredient.id: ingredient});
      catalog.replaceItems({product.id: product});
      product.repository = catalog;
      Menu.instance.replaceItems({catalog.id: catalog});

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _SearchAction(withTextFiled: true),
          ),
        ),
      );

      // Enter search text that matches quantity
      await tester.enterText(find.byType(TextField), 'large');
      await tester.pump();

      // Verify that quantity match is shown
      expect(find.text('Cheese (Extra Large)'), findsOneWidget);
    });
  });
}

// Copy the _SearchAction widget for testing
class _SearchAction extends StatelessWidget {
  final bool withTextFiled;

  const _SearchAction({this.withTextFiled = false});

  @override
  Widget build(BuildContext context) {
    return SearchBarWrapper<SearchProductMatch>(
      key: const Key('menu.search'),
      hintText: S.menuSearchHint,
      text: withTextFiled ? '' : null,
      initData: Menu.instance.searchProductsWithMatches(),
      search: (text) async => Menu.instance.searchProductsWithMatches(text: text),
      itemBuilder: _searchItemBuilder,
      emptyBuilder: _searchEmptyBuilder,
    );
  }

  Widget _searchItemBuilder(BuildContext context, SearchProductMatch match) {
    final product = match.product;
    final searchPattern = match.searchPattern;
    
    return ListTile(
      key: Key('search.${product.id}'),
      title: HighlightText(
        text: product.name,
        pattern: searchPattern,
      ),
      subtitle: match.hasDetailedMatches ? _buildMatchDetails(context, match) : null,
      onTap: () => product.searched(),
    );
  }

  Widget _buildMatchDetails(BuildContext context, SearchProductMatch match) {
    final matchTexts = <String>[];
    
    if (match.catalogNameMatches) {
      matchTexts.add('Catalog: ${match.product.catalog.name}');
    }
    
    for (final ingredientMatch in match.ingredientMatches) {
      if (ingredientMatch.nameMatches) {
        matchTexts.add('Ingredient: ${ingredientMatch.ingredient.name}');
      }
      
      for (final quantityMatch in ingredientMatch.quantityMatches) {
        matchTexts.add('${ingredientMatch.ingredient.name} (${quantityMatch.quantity.name})');
      }
    }
    
    if (matchTexts.isEmpty) return null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Matches:', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 2),
        ...matchTexts.map((text) => Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: HighlightText(
            text: '• $text',
            pattern: match.searchPattern,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        )).toList(),
      ],
    );
  }

  Widget _searchEmptyBuilder(BuildContext context, String text) {
    return ListTile(
      title: Text(S.menuSearchNotFound),
      leading: const Icon(KIcons.warn),
    );
  }
}