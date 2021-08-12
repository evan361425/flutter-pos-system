import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/components/scaffold/item_list_scaffold.dart';

import '../../mocks/mock_widgets.dart';

void main() {
  testWidgets('should pop only changed', (tester) async {
    int? selected = 1;
    final widget = ItemListScaffold(
      title: 'hi',
      items: ['ab', 'cd', 'ef'],
      selected: selected,
    );

    await tester
        .pumpWidget(bindWithNavigator<int>(widget, (e) => (selected = e)));

    await tester.tap(find.text('cd'));
    await tester.pump();

    expect(find.text('hi'), findsOneWidget);

    await tester.tap(find.text('ab'));
    await tester.pump();

    expect(selected, isZero);
  });
}
