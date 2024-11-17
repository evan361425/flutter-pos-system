import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/cashier/changer_modal.dart';
import 'package:provider/provider.dart';

import '../../mocks/mock_cache.dart';
import '../../mocks/mock_storage.dart';
import '../../test_helpers/breakpoint_mocker.dart';
import '../../test_helpers/translator.dart';

void main() {
  group('Changer Modal', () {
    num getUnitValue(Finder finder) {
      final w = finder.evaluate().single.widget as DropdownButtonFormField;
      return w.initialValue;
    }

    int? getCountValue(Finder finder) {
      final w = finder.evaluate().single.widget as TextFormField;
      return int.tryParse(w.initialValue ?? '');
    }

    Finder findByK(String key) {
      return find.byKey(Key('changer.custom.$key'));
    }

    Widget buildApp({withRoutes = false}) {
      // setup currency and cashier relation
      when(cache.get(any)).thenReturn(null);
      when(storage.get(any, any)).thenAnswer((_) => Future.value({}));

      CurrencySetting.instance.initialize();
      Cashier.instance.setCurrent(null);

      return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: Cashier.instance),
        ],
        builder: (_, __) => withRoutes
            ? MaterialApp.router(
                routerConfig: GoRouter(navigatorKey: Routes.rootNavigatorKey, routes: [
                  GoRoute(
                    path: '/',
                    builder: (context, __) {
                      return TextButton(
                        onPressed: () => context.pushNamed(Routes.cashierChanger),
                        child: const Text('go to changer'),
                      );
                    },
                  ),
                  ...Routes.getDesiredRoute(0).routes,
                ]),
              )
            : const MaterialApp(home: ChangerModal()),
      );
    }

    for (final device in [Device.mobile, Device.desktop]) {
      group(device.name, () {
        testWidgets('add favorite and failed if not enough', (tester) async {
          deviceAs(device, tester);
          await tester.pumpWidget(buildApp(withRoutes: true));
          await tester.pumpAndSettle();
          await tester.tap(find.text('go to changer'));
          await tester.pumpAndSettle();

          await tester.tap(find.byKey(const Key('empty_body')));
          await tester.pumpAndSettle();

          // no select
          await tester.tap(findByK('add_favorite'));
          await tester.pumpAndSettle();
          expect(find.text(S.invalidNumberPositive(S.cashierChangerCustomUnitLabel)), findsOneWidget);

          // select 10
          await tester.tap(findByK('source.unit'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('10').last);
          await tester.pumpAndSettle();

          expect(getUnitValue(findByK('target.0.unit')), equals(5));
          expect(getCountValue(findByK('target.0.count')), equals(2));

          await tester.tap(findByK('add_favorite'));
          await tester.pumpAndSettle();

          await tester.tap(find.byKey(const Key('changer.apply')));
          await tester.pumpAndSettle();

          expect(find.text(S.cashierChangerErrorNoSelection), findsOneWidget);

          await tester.tap(find.byKey(const Key('changer.favorite.0')));
          await tester.tap(find.byKey(const Key('changer.apply')));
          await tester.pumpAndSettle();

          expect(find.text(S.cashierChangerErrorNotEnough('10')), findsOneWidget);
        });

        testWidgets('delete favorite item', (tester) async {
          deviceAs(device, tester);
          await Cashier.instance.setFavorite(<Map<String, Object?>>[
            {
              'source': {'unit': 5, 'count': 1},
              'targets': [
                {'unit': 1, 'count': 5},
              ],
            },
          ]);

          await tester.pumpWidget(buildApp());

          expect(find.byKey(const Key('changer.favorite.0')), findsOneWidget);

          await tester.tap(find.byIcon(Icons.more_vert_outlined));
          await tester.pumpAndSettle();
          await tester.tap(find.byIcon(KIcons.delete));
          await tester.pumpAndSettle();

          expect(find.byKey(const Key('changer.favorite.0')), findsNothing);
        });

        testWidgets('apply custom', (tester) async {
          deviceAs(device, tester);
          await tester.pumpWidget(buildApp(withRoutes: true));
          when(storage.set(any, any)).thenAnswer((_) => Future.value());
          await tester.pumpAndSettle();
          await tester.tap(find.text('go to changer'));
          await tester.pumpAndSettle();

          setCountUnit(String key, {String? unit, String? count}) async {
            if (count != null) {
              await tester.enterText(findByK('$key.count'), count);
              await tester.pumpAndSettle();
            }
            if (unit != null) {
              await tester.tap(findByK('$key.unit'));
              await tester.pumpAndSettle();
              await tester.tap(find.text(unit).last);
              await tester.pumpAndSettle();
            }
          }

          await tester.tap(find.text(S.cashierChangerCustomTab));
          await tester.pumpAndSettle();
          // change count should also fired target reset
          await setCountUnit('source', unit: '10');

          await tester.enterText(findByK('source.count'), 'abc');
          await tester.tap(find.byKey(const Key('changer.apply')));
          await tester.pumpAndSettle();

          expect(find.text(S.invalidIntegerType(S.cashierChangerCustomCountLabel)), findsOneWidget);

          await tester.enterText(findByK('source.count'), '4');
          await tester.pumpAndSettle();

          expect(getUnitValue(findByK('target.0.unit')), equals(5));
          expect(getCountValue(findByK('target.0.count')), equals(8));

          // add 4 targets, total targets: 5
          await tester.tap(find.byIcon(KIcons.add));
          await tester.tap(find.byIcon(KIcons.add));
          await tester.tap(find.byIcon(KIcons.add));
          await tester.tap(find.byIcon(KIcons.add));
          await tester.pumpAndSettle();
          // remove 1 target, total targets: 4
          await tester.tap(find.byIcon(Icons.remove_circle_outlined).first);
          await tester.pumpAndSettle();

          expect(findByK('target.4.unit'), findsNothing);

          await setCountUnit('target.1', unit: '5', count: '1');
          await setCountUnit('target.2', unit: '1', count: '5');

          // 5*10 is not able to change 10*5 + 1*5 + 5*1
          await tester.tap(find.byKey(const Key('changer.apply')));
          await tester.pumpAndSettle();

          expect(
            find.text('${S.cashierChangerErrorInvalidHead(4, '10')}\n'
                ' •  ${S.cashierChangerErrorInvalidBody(8, '5')}\n'
                ' •  ${S.cashierChangerErrorInvalidBody(1, '5')}\n'
                ' •  ${S.cashierChangerErrorInvalidBody(5, '1')}'),
            findsOneWidget,
          );

          // apply correctly now!
          await setCountUnit('target.0', count: '6');
          await tester.tap(find.byKey(const Key('changer.apply')));
          await tester.pumpAndSettle();

          // should setup current data
          expect(find.text(S.cashierChangerErrorNotEnough('10')), findsOneWidget);

          await Cashier.instance.setUnitCount(10, 10);

          await tester.tap(find.byKey(const Key('changer.apply')));
          await tester.pumpAndSettle();

          expect(find.byKey(const Key('changer.apply')), findsNothing);
          expect(Cashier.instance.at(2).count, equals(6));
          expect(Cashier.instance.at(1).count, equals(7));
          expect(Cashier.instance.at(0).count, equals(5));
        });
      });
    }

    setUp(() {
      Cashier();
    });

    setUpAll(() {
      initializeStorage();
      initializeCache();
      initializeTranslator();
    });
  });
}
