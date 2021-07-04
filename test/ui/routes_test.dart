import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/menu/catalog/widgets/product_modal.dart';
import 'package:possystem/ui/menu/product/widgets/product_ingredient_modal.dart';
import 'package:possystem/ui/menu/product/widgets/product_quantity_modal.dart';

import '../mocks/mockito/mock_catalog_model.dart';
import '../mocks/mockito/mock_product_ingredient_model.dart';
import '../mocks/mockito/mock_product_model.dart';
import '../models/menu/product_ingredient_model_test.mocks.dart';

void main() {
  late Widget newWidget;

  Widget createAppWithRoute(String key, [dynamic argument]) {
    return MaterialApp(
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          settings: RouteSettings(arguments: argument),
          builder: (context) {
            newWidget = Routes.routes[key]!(context);
            return newWidget;
          },
        );
      },
    );
  }

  group('#menuProductModal', () {
    testWidgets('should create non-new product modal', (tester) async {
      final catalog = MockCatalogModel();
      final product = MockProductModel();
      when(product.catalog).thenReturn(catalog);
      when(product.name).thenReturn('');
      when(product.price).thenReturn(0);
      when(product.cost).thenReturn(0);

      await tester.pumpWidget(
        createAppWithRoute(Routes.menuProductModal, product),
      );

      expect(newWidget is ProductModal, isTrue);
      expect((newWidget as ProductModal).isNew, isFalse);
    });

    testWidgets('should create new product modal', (tester) async {
      final catalog = MockCatalogModel();

      await tester.pumpWidget(
        createAppWithRoute(Routes.menuProductModal, catalog),
      );

      expect(newWidget is ProductModal, isTrue);
      expect((newWidget as ProductModal).isNew, isTrue);
    });
  });

  group('#menuIngredient', () {
    testWidgets('should create non-new ingredient modal', (tester) async {
      final ingredient = MockProductIngredientModel();
      final product = MockProductModel();
      when(ingredient.product).thenReturn(product);
      when(ingredient.id).thenReturn('');
      when(ingredient.name).thenReturn('');
      when(ingredient.amount).thenReturn(0);

      await tester.pumpWidget(
        createAppWithRoute(Routes.menuIngredient, ingredient),
      );

      expect(newWidget is ProductIngredientModal, isTrue);
      expect((newWidget as ProductIngredientModal).isNew, isFalse);
    });

    testWidgets('should create new ingredient modal', (tester) async {
      final product = MockProductModel();

      await tester.pumpWidget(
        createAppWithRoute(Routes.menuIngredient, product),
      );

      expect(newWidget is ProductIngredientModal, isTrue);
      expect((newWidget as ProductIngredientModal).isNew, isTrue);
    });
  });

  group('#menuQuantity', () {
    testWidgets('should create non-new product modal', (tester) async {
      final ingredient = MockProductIngredientModel();
      final quantity = MockProductQuantityModel();
      when(quantity.ingredient).thenReturn(ingredient);
      when(quantity.name).thenReturn('');
      when(quantity.id).thenReturn('');
      when(quantity.amount).thenReturn(0);
      when(quantity.additionalPrice).thenReturn(0);
      when(quantity.additionalCost).thenReturn(0);

      await tester.pumpWidget(
        createAppWithRoute(Routes.menuQuantity, quantity),
      );

      expect(newWidget is ProductQuantityModal, isTrue);
      expect((newWidget as ProductQuantityModal).isNew, isFalse);
    });

    testWidgets('should create new product modal', (tester) async {
      final ingredient = MockProductIngredientModel();

      await tester.pumpWidget(
        createAppWithRoute(Routes.menuQuantity, ingredient),
      );

      expect(newWidget is ProductQuantityModal, isTrue);
      expect((newWidget as ProductQuantityModal).isNew, isTrue);
    });
  });
}
