import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/ui/menu/catalog/widgets/product_orderable_list.dart';

import '../../../../mocks/mock_repos.dart';
import '../../../../mocks/mock_storage.dart';
import '../../../../mocks/mock_widgets.dart';

void main() {
  testWidgets('should reordering', (tester) async {
    final pro1 = Product(name: 'pro1', id: 'pro1', index: 0);
    final pro2 = Product(name: 'pro2', id: 'pro2', index: 1);
    final catalog = Catalog(
      name: 'name',
      id: 'id',
      products: {'pro1': pro1, 'pro2': pro2},
    );
    pro1.catalog = catalog;
    pro2.catalog = catalog;
    when(storage.set(any, any)).thenAnswer((_) => Future.value());

    await tester.pumpWidget(
      bindWithNavigator(ProductOrderableList(catalog: catalog)),
    );

    await tester.tap(find.text('save'));
    await tester.pumpAndSettle();
  });

  setUpAll(() {
    initializeRepos();
    initializeStorage();
  });
}
