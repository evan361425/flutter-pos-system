import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/customer/customer_setting.dart';
import 'package:possystem/models/customer/customer_setting_option.dart';
import 'package:possystem/models/objects/customer_object.dart';
import 'package:possystem/models/repository/customer_settings.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:possystem/settings/setting.dart';
import 'package:possystem/ui/customer/customer_screen.dart';
import 'package:provider/provider.dart';

import '../../mocks/mock_cache.dart';
import '../../mocks/mock_database.dart';
import '../../test_helpers/translator.dart';

void main() {
  group('Customer Screen', () {
    testWidgets('Add setting', (tester) async {
      final settings = CustomerSettings()..replaceItems({});
      when(database.push(any, any)).thenAnswer((_) => Future.value(1));

      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: settings,
        child: MaterialApp(routes: Routes.routes, home: const CustomerScreen()),
      ));

      await tester.tap(find.byKey(const Key('empty_body')));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('customer_setting.name')), 'cs-1');
      await tester.tap(find.byKey(const Key('modal.save')));
      // save to storage
      await tester.pumpAndSettle();
      // pop
      await tester.pumpAndSettle();

      final w =
          find.byKey(const Key('customer_settings.1')).evaluate().first.widget;
      expect(((w as ExpansionTile).title as Text).data, equals('cs-1'));

      final setting = settings.items.first;
      expect(setting.defaultOption, isNull);
      expect(setting.index, equals(1));
      expect(setting.mode, equals(CustomerSettingOptionMode.statOnly));

      verify(database.push(
        CustomerSetting.table,
        argThat(equals({'name': 'cs-1', 'index': 1, 'mode': 0})),
      ));
    });

    Future<void> buildAppWithSettings(WidgetTester tester) async {
      final setting1 = CustomerSetting(
          id: '1',
          name: 'cs-1',
          index: 1,
          mode: CustomerSettingOptionMode.changePrice,
          options: {
            '1': CustomerSettingOption(
                id: '1',
                name: 'cso-1',
                index: 1,
                isDefault: true,
                modeValue: 10),
            '2': CustomerSettingOption(
                id: '2', name: 'cso-2', index: 2, modeValue: -10),
            '3': CustomerSettingOption(
                id: '3', name: 'cso-3', index: 3, modeValue: 0),
            '4': CustomerSettingOption(id: '4', name: 'cso-4', index: 4),
          })
        ..prepareItem();
      final setting2 = CustomerSetting(
          id: '2',
          name: 'cs-2',
          index: 2,
          mode: CustomerSettingOptionMode.changeDiscount,
          options: {
            '5': CustomerSettingOption(id: '5', name: 'cso-5', modeValue: 110),
            '6': CustomerSettingOption(id: '6', name: 'cso-6', modeValue: 60),
            '7': CustomerSettingOption(id: '7', name: 'cso-7', modeValue: 55),
          })
        ..prepareItem();
      final settings = CustomerSettings()
        ..replaceItems({
          '1': setting1,
          '2': setting2,
          '3': CustomerSetting(id: '3', name: 'cs-3', index: 3),
        });

      when(cache.get(any)).thenReturn(null);
      final currency = CurrencySetting();

      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: settings),
          ChangeNotifierProvider.value(
              value: SettingsProvider([currency])..loadSetting()),
        ],
        child: MaterialApp(
            darkTheme: ThemeData.dark(),
            themeMode: ThemeMode.dark,
            routes: Routes.routes,
            home: const CustomerScreen()),
      ));
    }

    testWidgets('Edit setting', (tester) async {
      await buildAppWithSettings(tester);
      when(database.update(
        CustomerSetting.table,
        1,
        argThat(equals({'name': 'new', 'mode': 2})),
        keyName: anyNamed('keyName'),
      )).thenAnswer((_) => Future.value(1));
      // need to setup option
      when(database.update(
        CustomerSetting.optionTable,
        1,
        argThat(equals({'modeValue': null})),
        keyName: anyNamed('keyName'),
      )).thenAnswer((_) => Future.value(1));
      // open expansion
      await tester.tap(find.byKey(const Key('customer_settings.1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('customer_settings.1.more')));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.text_fields_sharp));
      await tester.pumpAndSettle();

      // repeat name
      await tester.enterText(
          find.byKey(const Key('customer_setting.name')), 'cs-2');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('customer_setting.name')), 'new');
      await tester.tap(find.byKey(const Key('customer_setting.modes.1')));
      await tester.tap(find.byKey(const Key('customer_setting.modes.2')));
      await tester.tap(find.byKey(const Key('modal.save')));
      await tester.pumpAndSettle();

      final w =
          find.byKey(const Key('customer_settings.1')).evaluate().first.widget;
      expect(((w as ExpansionTile).title as Text).data, equals('new'));

      final setting = CustomerSettings.instance.items.first;
      expect(setting.mode, equals(CustomerSettingOptionMode.values[2]));
      expect(setting.items.every((option) => option.modeValue == null), isTrue);
    });

    testWidgets('Delete setting', (tester) async {
      await buildAppWithSettings(tester);
      when(database.update(
        CustomerSetting.table,
        1,
        argThat(equals({'isDelete': 1})),
        keyName: anyNamed('keyName'),
      )).thenAnswer((_) => Future.value(1));

      await tester.tap(find.byKey(const Key('customer_settings.1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('customer_settings.1.more')));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(KIcons.delete));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('delete_dialog.confirm')));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('customer_settings.1')), findsNothing);
      expect(CustomerSettings.instance.length, equals(2));
    });

    testWidgets('Reorder setting', (tester) async {
      await buildAppWithSettings(tester);
      when(database.batchUpdate(
        CustomerSetting.table,
        argThat(equals([
          {'index': 1},
          {'index': 2},
        ])),
        where: argThat(equals('id = ?'), named: 'where'),
        whereArgs: argThat(
            equals([
              ['2'],
              ['1'],
            ]),
            named: 'whereArgs'),
      )).thenAnswer((_) => Future.value([]));

      await tester.tap(find.byKey(const Key('customer_settings.action')));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.reorder_sharp));
      await tester.pumpAndSettle();
      final rect = tester.getRect(find.byKey(const Key('reorder.0')));

      await tester.drag(
        find.byIcon(Icons.reorder_sharp).first,
        Offset(0, rect.height + rect.top),
      );
      await tester.tap(find.byKey(const Key('reorder.save')));
      await tester.pumpAndSettle();

      final y1 =
          tester.getCenter(find.byKey(const Key('customer_settings.1'))).dy;
      final y2 =
          tester.getCenter(find.byKey(const Key('customer_settings.2'))).dy;
      final itemList = CustomerSettings.instance.itemList;
      expect(y1, greaterThan(y2));
      expect(itemList[0].id, equals('2'));
      expect(itemList[1].id, equals('1'));
      expect(itemList[2].id, equals('3'));
    });

    testWidgets('Add option', (tester) async {
      await buildAppWithSettings(tester);
      when(database.update(
        CustomerSetting.optionTable,
        1,
        argThat(equals({'isDefault': 0})),
        keyName: anyNamed('keyName'),
      )).thenAnswer((realInvocation) => Future.value(1));
      when(database.push(
        CustomerSetting.optionTable,
        argThat(equals({
          'customerSettingId': 1,
          'name': 'cso-new',
          'index': 5,
          'isDefault': 1,
          'modeValue': 10,
        })),
      )).thenAnswer((realInvocation) => Future.value(100));

      await tester.tap(find.byKey(const Key('customer_settings.1')));
      await tester.pumpAndSettle();
      // show [CustomerSettingOptionMode.changePrice] modeValue
      await tester.tap(find.byKey(const Key('customer_setting.1.2')));
      await tester.pumpAndSettle();
      expect(
          tester
              .widget<TextFormField>(
                  find.byKey(const Key('customer_setting_option.modeValue')))
              .controller
              ?.text,
          equals('-10'));
      await tester.tap(find.byIcon(KIcons.back));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('customer_settings.1.add')));
      await tester.pumpAndSettle();

      fbk(String key) => find.byKey(Key('customer_setting_option.$key'));

      // repeat name
      await tester.enterText(fbk('name'), 'cso-1');
      await tester.tap(find.byKey(const Key('modal.save')));
      await tester.pumpAndSettle();

      // reset default
      await tester.tap(fbk('isDefault'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm_dialog.confirm')));

      await tester.enterText(fbk('name'), 'cso-new');
      await tester.enterText(fbk('modeValue'), '10');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('customer_setting.1.100')), findsOneWidget);
      expect(CustomerSettings.instance.items.first.length, equals(5));
    });

    testWidgets('Edit option', (tester) async {
      await buildAppWithSettings(tester);
      when(database.update(
        CustomerSetting.optionTable,
        7,
        argThat(equals({
          'name': 'cso-new',
          'isDefault': 1,
          'modeValue': 0,
        })),
      )).thenAnswer((realInvocation) => Future.value(1));

      // show [CustomerSettingOptionMode.statOnly] data
      await tester.tap(find.byKey(const Key('customer_settings.3')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('customer_settings.3.add')));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(KIcons.back));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('customer_settings.2')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('customer_setting.2.7')));
      await tester.pumpAndSettle();

      fbk(String key) => find.byKey(Key('customer_setting_option.$key'));

      // repeat name
      await tester.enterText(fbk('name'), 'cso-new');
      await tester.tap(fbk('isDefault'));
      await tester.enterText(fbk('modeValue'), '0');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      final w =
          find.byKey(const Key('customer_setting.2.7')).evaluate().first.widget;
      expect(((w as ListTile).title as Text).data, equals('cso-new'));

      final setting = CustomerSettings.instance.getItem('2')!;
      final option = setting.getItem('7')!;
      expect(setting.defaultOption!.id, equals('7'));
      expect(option.isDefault, isTrue);
      expect(option.modeValue, isZero);
    });

    testWidgets('Delete option', (tester) async {
      await buildAppWithSettings(tester);
      when(database.update(
        CustomerSetting.optionTable,
        1,
        argThat(equals({'isDelete': 1})),
      )).thenAnswer((realInvocation) => Future.value(1));

      // show [CustomerSettingOptionMode.statOnly] data
      await tester.tap(find.byKey(const Key('customer_settings.1')));
      await tester.pumpAndSettle();
      await tester.longPress(find.byKey(const Key('customer_setting.1.1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(KIcons.delete));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('delete_dialog.confirm')));
      await tester.pumpAndSettle();

      final setting = CustomerSettings.instance.items.first;
      expect(find.byKey(const Key('customer_setting.1.1')), findsNothing);
      expect(setting.length, equals(3));
      expect(setting.defaultOption, isNull);
    });

    testWidgets('Reorder option', (tester) async {
      await buildAppWithSettings(tester);
      when(database.batchUpdate(
        CustomerSetting.optionTable,
        argThat(equals([
          {'index': 1},
          {'index': 2},
          {'index': 3},
        ])),
        where: argThat(equals('id = ?'), named: 'where'),
        whereArgs: argThat(
            equals([
              ['2'],
              ['3'],
              ['1'],
            ]),
            named: 'whereArgs'),
      )).thenAnswer((_) => Future.value([]));

      await tester.tap(find.byKey(const Key('customer_settings.1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('customer_settings.1.more')));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.reorder_sharp));
      await tester.pumpAndSettle();

      await tester.drag(
          find.byIcon(Icons.reorder_sharp).first, const Offset(0, 200));
      await tester.tap(find.byKey(const Key('reorder.save')));
      await tester.pumpAndSettle();

      final y1 =
          tester.getCenter(find.byKey(const Key('customer_setting.1.1'))).dy;
      final y2 =
          tester.getCenter(find.byKey(const Key('customer_setting.1.2'))).dy;
      final itemList = CustomerSettings.instance.items.first.itemList;
      expect(y1, greaterThan(y2));
      expect(itemList[0].id, equals('2'));
      expect(itemList[1].id, equals('3'));
      expect(itemList[2].id, equals('1'));
      expect(itemList[3].id, equals('4'));
    });

    setUpAll(() {
      initializeCache();
      initializeDatabase();
      initializeTranslator();
    });
  });
}
