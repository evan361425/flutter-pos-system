import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/components/style/circular_loading.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/models/repository/quantity_repo.dart';
import 'package:possystem/ui/stock/quantity/quantity_screen.dart';
import 'package:provider/provider.dart';

import '../../../mocks/mocks.dart';
import '../../../mocks/providers.dart';

void main() {
  testWidgets('should show loading when not ready', (tester) async {
    when(quantities.isReady).thenReturn(false);

    await tester.pumpWidget(MultiProvider(providers: [
      ChangeNotifierProvider<QuantityRepo>.value(value: quantities),
    ], child: MaterialApp(home: QuantityScreen())));

    expect(find.byType(CircularLoading), findsOneWidget);
  });

  testWidgets('should show empty body when empty', (tester) async {
    when(quantities.isReady).thenReturn(true);
    when(quantities.isEmpty).thenReturn(true);

    await tester.pumpWidget(MultiProvider(providers: [
      ChangeNotifierProvider<QuantityRepo>.value(value: quantities),
    ], child: MaterialApp(home: QuantityScreen())));

    expect(find.byType(EmptyBody), findsOneWidget);
  });

  setUpAll(() {
    initializeProviders();
  });
}
