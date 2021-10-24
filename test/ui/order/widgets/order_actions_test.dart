import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/cashier/changer/changer_modal.dart';
import 'package:possystem/ui/order/widgets/order_actions.dart';

import '../../../mocks/mock_providers.dart';
import '../../../mocks/mock_widgets.dart';
import '../../../mocks/mock_repos.dart';

void main() {
  test('should leave history', () async {
    when(cart.isHistoryMode).thenReturn(true);

    expect(OrderActions.actions().length, equals(1));
    await OrderActions.execAction(
        MockBuildContext(), OrderActionTypes.leave_history);

    verify(cart.leaveHistoryMode());
  });

  testWidgets('show last without ordering', (tester) async {
    when(cart.isEmpty).thenReturn(true);
    when(cart.stash()).thenAnswer((_) => Future.value(true));
    when(cart.popHistory()).thenAnswer((_) => Future.value(true));

    await tester.pumpWidget(Container(child: Builder(builder: (context) {
      return FutureBuilder(
        future: OrderActions.execAction(context, OrderActionTypes.show_last),
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
          onPressed: () => OrderActions.execAction(
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
          onPressed: () => OrderActions.execAction(
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

  testWidgets('show changer', (tester) async {
    when(currency.unitList).thenReturn([]);
    when(cashier.favoriteIsEmpty).thenReturn(true);

    await tester.pumpWidget(MaterialApp(
        routes: {
          Routes.cashierChanger: (_) => ChangerModal(),
        },
        home: Scaffold(
          body: Builder(builder: (context) {
            return TextButton(
              onPressed: () => OrderActions.execAction(
                context,
                OrderActionTypes.changer,
              ),
              child: Text('hi'),
            );
          }),
        )));

    await tester.tap(find.text('hi'));
    await tester.pumpAndSettle();

    // leave changer
    await tester.tap(find.byIcon(KIcons.back));
    await tester.pumpAndSettle();

    expect(find.text('hi'), findsOneWidget);
  });

  testWidgets('drop without ordering', (tester) async {
    when(cart.isEmpty).thenReturn(true);
    when(cart.stash()).thenAnswer((_) => Future.value(true));
    when(cart.drop()).thenAnswer((_) => Future.value(true));

    await tester.pumpWidget(Container(child: Builder(builder: (context) {
      return FutureBuilder(
        future: OrderActions.execAction(context, OrderActionTypes.drop_stash),
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
          onPressed: () => OrderActions.execAction(
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
          onPressed: () => OrderActions.execAction(
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
    initializeRepos();
    initializeProviders();
  });
}
