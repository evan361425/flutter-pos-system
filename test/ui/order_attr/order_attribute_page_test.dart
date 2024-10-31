import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/objects/order_attribute_object.dart';
import 'package:possystem/models/order/order_attribute.dart';
import 'package:possystem/models/order/order_attribute_option.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/services/storage.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/order_attr/order_attribute_page.dart';
import 'package:provider/provider.dart';

import '../../mocks/mock_cache.dart';
import '../../mocks/mock_storage.dart';
import '../../test_helpers/translator.dart';

void main() {
  group('Order Attribute Page', () {
    testWidgets('Add attribute', (tester) async {
      final attrs = OrderAttributes()..replaceItems({});

      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: attrs,
        child: MaterialApp.router(
          routerConfig: GoRouter(navigatorKey: Routes.rootNavigatorKey, routes: [
            GoRoute(
              path: '/',
              builder: (_, __) => const Scaffold(body: OrderAttributePage()),
            ),
            ...Routes.getDesiredRoute(0).routes,
          ]),
        ),
      ));

      await tester.tap(find.byKey(const Key('empty_body')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('order_attribute.name')), 'attr-1');
      await tester.tap(find.byKey(const Key('modal.save')));
      // save to storage
      await tester.pumpAndSettle();
      // pop
      await tester.pumpAndSettle();

      final id = OrderAttributes.instance.items.first.id;
      final w = find.byKey(Key('order_attributes.$id')).evaluate().first.widget;
      expect(((w as ExpansionTile).title as Text).data, equals('attr-1'));

      final attr = attrs.items.first;
      expect(attr.defaultOption, isNull);
      expect(attr.index, equals(1));
      expect(attr.mode, equals(OrderAttributeMode.statOnly));

      verify(storage.add(
        Stores.orderAttributes,
        argThat(equals(id)),
        argThat(equals({
          'name': 'attr-1',
          'index': 1,
          'mode': 0,
          'options': {},
        })),
      ));
    });

    Future<void> buildAppWithAttributes(WidgetTester tester) async {
      final attr1 = OrderAttribute(id: '1', name: 'cs-1', index: 1, mode: OrderAttributeMode.changePrice, options: {
        '1': OrderAttributeOption(id: '1', name: 'cso-1', index: 1, isDefault: true, modeValue: 10),
        '2': OrderAttributeOption(id: '2', name: 'cso-2', index: 2, modeValue: -10),
        '3': OrderAttributeOption(id: '3', name: 'cso-3', index: 3, modeValue: 0),
        '4': OrderAttributeOption(id: '4', name: 'cso-4', index: 4),
      })
        ..prepareItem();
      final attr2 = OrderAttribute(id: '2', name: 'cs-2', index: 2, mode: OrderAttributeMode.changeDiscount, options: {
        '5': OrderAttributeOption(id: '5', name: 'cso-5', modeValue: 110),
        '6': OrderAttributeOption(id: '6', name: 'cso-6', modeValue: 60),
        '7': OrderAttributeOption(id: '7', name: 'cso-7', modeValue: 55),
      })
        ..prepareItem();
      final attrs = OrderAttributes()
        ..replaceItems({
          '1': attr1,
          '2': attr2,
          '3': OrderAttribute(id: '3', name: 'cs-3', index: 3),
        });

      when(cache.get(any)).thenReturn(null);

      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: attrs),
        ],
        child: MaterialApp.router(
          routerConfig: GoRouter(navigatorKey: Routes.rootNavigatorKey, routes: [
            GoRoute(
              path: '/',
              builder: (_, __) => const Scaffold(body: OrderAttributePage()),
            ),
            ...Routes.getDesiredRoute(0).routes,
          ]),
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.dark,
        ),
      ));
    }

    testWidgets('Edit attribute', (tester) async {
      await buildAppWithAttributes(tester);

      // open expansion
      await tester.tap(find.byKey(const Key('order_attributes.1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('order_attributes.1.more')));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.text_fields_outlined));
      await tester.pumpAndSettle();

      // repeat name
      await tester.enterText(find.byKey(const Key('order_attribute.name')), 'cs-2');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('order_attribute.name')), 'new');
      await tester.tap(find.byKey(Key('choice_chip.${OrderAttributeMode.changePrice}')));
      await tester.tap(find.byKey(Key('choice_chip.${OrderAttributeMode.changeDiscount}')));
      await tester.tap(find.byKey(const Key('modal.save')));
      await tester.pumpAndSettle();

      final w = find.byKey(const Key('order_attributes.1')).evaluate().first.widget;
      expect(((w as ExpansionTile).title as Text).data, equals('new'));

      final attr = OrderAttributes.instance.items.first;
      expect(attr.mode, equals(OrderAttributeMode.values[2]));
      expect(attr.items.every((option) => option.modeValue == null), isTrue);

      verify(storage.set(
        Stores.orderAttributes,
        argThat(equals({
          '1.name': 'new',
          '1.options.1.modeValue': null,
          '1.options.2.modeValue': null,
          '1.options.3.modeValue': null,
          '1.options.4.modeValue': null,
          '1.mode': 2,
        })),
      ));
    });

    testWidgets('Delete attribute', (tester) async {
      await buildAppWithAttributes(tester);

      await tester.tap(find.byKey(const Key('order_attributes.1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('order_attributes.1.more')));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(KIcons.delete));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('delete_dialog.confirm')));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('order_attributes.1')), findsNothing);
      expect(OrderAttributes.instance.length, equals(2));
      verify(storage.set(
        Stores.orderAttributes,
        argThat(equals({'1': null})),
      ));
    });

    testWidgets('Reorder attributes', (tester) async {
      await buildAppWithAttributes(tester);

      await tester.tap(find.byIcon(KIcons.reorder));
      await tester.pumpAndSettle();
      final rect = tester.getRect(find.byKey(const Key('reorder.0')));

      await tester.drag(
        find.byIcon(Icons.reorder_outlined).first,
        Offset(0, rect.height + rect.top),
      );
      await tester.tap(find.byKey(const Key('reorder.save')));
      await tester.pumpAndSettle();

      final y1 = tester.getCenter(find.byKey(const Key('order_attributes.1'))).dy;
      final y2 = tester.getCenter(find.byKey(const Key('order_attributes.2'))).dy;
      final itemList = OrderAttributes.instance.itemList;
      expect(y1, greaterThan(y2));
      expect(itemList[0].id, equals('2'));
      expect(itemList[1].id, equals('1'));
      expect(itemList[2].id, equals('3'));

      verify(storage.set(
        Stores.orderAttributes,
        argThat(equals({'2.index': 1, '1.index': 2})),
      ));
    });

    testWidgets('Add option', (tester) async {
      await buildAppWithAttributes(tester);

      await tester.tap(find.byKey(const Key('order_attributes.1')));
      await tester.pumpAndSettle();

      /// show [OrderAttributeOptionMode.changePrice] modeValue
      await tester.tap(find.byKey(const Key('order_attributes.1.2')));
      await tester.pumpAndSettle();
      expect(tester.widget<TextFormField>(find.byKey(const Key('order_attribute_option.modeValue'))).controller?.text,
          equals('-10'));
      await tester.tap(find.byKey(const Key('pop')).last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('order_attributes.1.add')));
      await tester.pumpAndSettle();

      fbk(String key) => find.byKey(Key('order_attribute_option.$key'));

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

      final id = OrderAttributes.instance.items.first.items.last.id;

      expect(find.byKey(Key('order_attributes.1.$id')), findsOneWidget);
      expect(OrderAttributes.instance.items.first.length, equals(5));

      verify(storage.set(
        Stores.orderAttributes,
        argThat(equals({'1.options.1.isDefault': false})),
      ));
      verify(storage.set(
        Stores.orderAttributes,
        argThat(equals({
          '1.options.$id': {
            'name': 'cso-new',
            'index': 5,
            'isDefault': true,
            'modeValue': 10,
          }
        })),
      ));
    });

    testWidgets('Edit option', (tester) async {
      await buildAppWithAttributes(tester);

      /// show [OrderAttributeOptionMode.statOnly] data
      await tester.tap(find.byKey(const Key('order_attributes.3')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('order_attributes.3.add')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('pop')).last);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('order_attributes.2')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('order_attributes.2.7')));
      await tester.pumpAndSettle();

      fbk(String key) => find.byKey(Key('order_attribute_option.$key'));

      // repeat name
      await tester.enterText(fbk('name'), 'cso-new');
      await tester.tap(fbk('isDefault'));
      await tester.enterText(fbk('modeValue'), '0');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      final w = find.byKey(const Key('order_attributes.2.7')).evaluate().first.widget;
      expect(((w as ListTile).title as Text).data, equals('cso-new'));

      final attr = OrderAttributes.instance.getItem('2')!;
      final option = attr.getItem('7')!;
      expect(attr.defaultOption!.id, equals('7'));
      expect(option.isDefault, isTrue);
      expect(option.modeValue, isZero);

      verify(storage.set(
        Stores.orderAttributes,
        argThat(equals({
          '2.options.7.name': 'cso-new',
          '2.options.7.isDefault': true,
          '2.options.7.modeValue': 0,
        })),
      ));
    });

    testWidgets('Delete option', (tester) async {
      await buildAppWithAttributes(tester);

      // show [OrderAttributeOptionMode.statOnly] data
      await tester.tap(find.byKey(const Key('order_attributes.1')));
      await tester.pumpAndSettle();
      await tester.longPress(find.byKey(const Key('order_attributes.1.1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(KIcons.delete));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('delete_dialog.confirm')));
      await tester.pumpAndSettle();

      final attr = OrderAttributes.instance.items.first;
      expect(find.byKey(const Key('order_attributes.1.1')), findsNothing);
      expect(attr.length, equals(3));
      expect(attr.defaultOption, isNull);

      verify(storage.set(
        Stores.orderAttributes,
        argThat(equals({'1.options.1': null})),
      ));
    });

    testWidgets('Reorder options', (tester) async {
      await buildAppWithAttributes(tester);

      await tester.tap(find.byKey(const Key('order_attributes.1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('order_attributes.1.more')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.orderAttributeOptionTitleReorder));
      await tester.pumpAndSettle();

      await tester.drag(find.byIcon(Icons.reorder_outlined).first, const Offset(0, 200));
      await tester.tap(find.byKey(const Key('reorder.save')));
      await tester.pumpAndSettle();

      final y1 = tester.getCenter(find.byKey(const Key('order_attributes.1.1'))).dy;
      final y2 = tester.getCenter(find.byKey(const Key('order_attributes.1.2'))).dy;
      final itemList = OrderAttributes.instance.items.first.itemList;
      expect(y1, greaterThan(y2));
      expect(itemList[0].id, equals('2'));
      expect(itemList[1].id, equals('3'));
      expect(itemList[2].id, equals('1'));
      expect(itemList[3].id, equals('4'));

      verify(storage.set(
        Stores.orderAttributes,
        argThat(equals(
          {
            '1.options.2.index': 1,
            '1.options.3.index': 2,
            '1.options.1.index': 3,
          },
        )),
      ));
    });

    setUpAll(() {
      initializeCache();
      initializeStorage();
      initializeTranslator();
    });
  });
}
