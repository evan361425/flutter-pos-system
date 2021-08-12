import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/ui/menu/catalog/widgets/product_orderable_list.dart';
import 'package:possystem/ui/menu/widgets/catalog_orderable_list.dart';

import '../../../mocks/mock_repos.dart';
import '../../../mocks/mock_storage.dart';
import '../../../mocks/mock_widgets.dart';

void main() {
  testWidgets('should reordering', (tester) async {
    final cat1 = Catalog(name: 'cat1', id: 'cat1', index: 0);
    final cat2 = Catalog(name: 'cat2', id: 'cat2', index: 1);
    when(storage.set(any, any)).thenAnswer((_) => Future.value());
    when(menu.itemList).thenReturn([cat1, cat2]);

    await tester.pumpWidget(
      bindWithNavigator(CatalogOrderableList()),
    );

    await tester.tap(find.text('save'));
    await tester.pumpAndSettle();
  });

  setUpAll(() {
    initializeRepos();
    initializeStorage();
  });
}
