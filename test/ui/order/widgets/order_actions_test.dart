import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/ui/order/widgets/order_actions.dart';

import '../../../mocks/mock_cart.dart';
import '../../../mocks/mock_widgets.dart';

void main() {
  test('should leave history', () async {
    when(cart.isHistoryMode).thenReturn(true);

    expect(OrderActions.actions(MockBuildContext()).length, equals(1));
    await OrderActions.onAction(
        MockBuildContext(), OrderActionTypes.leave_history);

    verify(cart.leaveHistoryMode());
  });

  testWidgets('show last without ordering', (tester) async {
    when(cart.isEmpty).thenReturn(true);
    when(cart.stash()).thenAnswer((_) => Future.value(true));
    when(cart.popHistory()).thenAnswer((_) => Future.value(true));

    await tester.pumpWidget(Container(child: Builder(builder: (context) {
      return FutureBuilder(
        future: OrderActions.onAction(context, OrderActionTypes.show_last),
        builder: (_, __) => Container(),
      );
    })));

    verify(cart.popHistory());
  });

  testWidgets('no last with ordering and stashable', (tester) async {
    when(cart.isEmpty).thenReturn(false);
    when(cart.stash()).thenAnswer((_) => Future.value(true));
    when(cart.popHistory()).thenAnswer((_) => Future.value(false));

    await tester.pumpWidget(MaterialApp(home: Scaffold(
      body: Builder(builder: (context) {
        return TextButton(
          onPressed: () => OrderActions.onAction(
            context,
            OrderActionTypes.show_last,
          ),
          child: Text('hi'),
        );
      }),
    )));

    await tester.tap(find.text('hi'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ElevatedButton));

    verify(cart.popHistory());
  });

  testWidgets('show last with ordering and not stashable', (tester) async {
    when(cart.isEmpty).thenReturn(false);
    when(cart.stash()).thenAnswer((_) => Future.value(false));

    await tester.pumpWidget(MaterialApp(home: Scaffold(
      body: Builder(builder: (context) {
        return TextButton(
          onPressed: () => OrderActions.onAction(
            context,
            OrderActionTypes.show_last,
          ),
          child: Text('hi'),
        );
      }),
    )));

    await tester.tap(find.text('hi'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ElevatedButton));

    verifyNever(cart.popHistory());
  });

  testWidgets('drop without ordering', (tester) async {
    when(cart.isEmpty).thenReturn(true);
    when(cart.stash()).thenAnswer((_) => Future.value(true));
    when(cart.drop()).thenAnswer((_) => Future.value(true));

    await tester.pumpWidget(Container(child: Builder(builder: (context) {
      return FutureBuilder(
        future: OrderActions.onAction(context, OrderActionTypes.drop_stash),
        builder: (_, __) => Container(),
      );
    })));

    verify(cart.drop());
  });

  testWidgets('drop with ordering and stashable', (tester) async {
    when(cart.isEmpty).thenReturn(false);
    when(cart.stash()).thenAnswer((_) => Future.value(true));
    when(cart.drop()).thenAnswer((_) => Future.value(false));

    await tester.pumpWidget(MaterialApp(home: Scaffold(
      body: Builder(builder: (context) {
        return TextButton(
          onPressed: () => OrderActions.onAction(
            context,
            OrderActionTypes.drop_stash,
          ),
          child: Text('hi'),
        );
      }),
    )));

    await tester.tap(find.text('hi'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ElevatedButton));

    verify(cart.drop());
  });

  testWidgets('drop with ordering and not stashable', (tester) async {
    when(cart.isEmpty).thenReturn(false);
    when(cart.stash()).thenAnswer((_) => Future.value(false));

    await tester.pumpWidget(MaterialApp(home: Scaffold(
      body: Builder(builder: (context) {
        return TextButton(
          onPressed: () => OrderActions.onAction(
            context,
            OrderActionTypes.drop_stash,
          ),
          child: Text('hi'),
        );
      }),
    )));

    await tester.tap(find.text('hi'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ElevatedButton));

    verifyNever(cart.drop());
  });

  setUpAll(() {
    initializeCart();
  });
}
