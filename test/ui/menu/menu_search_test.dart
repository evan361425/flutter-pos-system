import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/menu/menu_search.dart';

import '../../mocks/mock_models.mocks.dart';
import '../../mocks/mock_repos.dart';

void main() {
  testWidgets('should update products when typing', (tester) async {
    when(menu.searchProducts(
      limit: anyNamed('limit'),
      text: argThat(isNull, named: 'text'),
    )).thenReturn([Product(name: 'p1'), Product(name: 'p2')]);

    await tester.pumpWidget(MaterialApp(
      routes: {Routes.menuProduct: (_) => Container()},
      home: MenuSearch(),
    ));

    expect(find.text('p1'), findsOneWidget);

    // now text some value

    // empty result
    when(menu.searchProducts(
      limit: anyNamed('limit'),
      text: argThat(equals('empty'), named: 'text'),
    )).thenReturn([]);
    await tester.enterText(find.byType(TextField), 'empty');
    await tester.pump();

    // finds result
    final product = MockProduct();
    when(menu.searchProducts(
      limit: anyNamed('limit'),
      text: argThat(equals('some-value'), named: 'text'),
    )).thenReturn([product]);
    when(product.name).thenReturn('p3');

    await tester.enterText(find.byType(TextField), 'some-value');
    await tester.pump();

    expect(find.text('p1'), findsNothing);
    expect(find.text('p3'), findsOneWidget);

    await tester.tap(find.text('p3'));
    await tester.pumpAndSettle();

    // should update searchedAt
    verify(product.searched());
  });

  setUpAll(() {
    initializeRepos();
  });
}
