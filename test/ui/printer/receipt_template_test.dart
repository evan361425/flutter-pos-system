import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/components/style/slide_to_delete.dart';
import 'package:possystem/models/printer.dart';
import 'package:possystem/models/receipt_component.dart';
import 'package:possystem/models/repository/receipt_templates.dart';
import 'package:possystem/models/xfile.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/printer/printer_page.dart';

import '../../mocks/mock_cache.dart';
import '../../mocks/mock_storage.dart';
import '../../test_helpers/breakpoint_mocker.dart';
import '../../test_helpers/file_mocker.dart';
import '../../test_helpers/translator.dart';

void main() {
  group('Printer Template', () {
    Widget buildApp([GoRoute? subroute]) {
      return MaterialApp.router(
        routerConfig: GoRouter(
          navigatorKey: Routes.rootNavigatorKey,
          routes: [
            GoRoute(
              path: '/',
              builder: (_, __) => const Scaffold(body: PrinterPage()),
              routes: [
                if (subroute != null) subroute,
                ...Routes.getDesiredRoute(0).routes.map((r) {
                  if (r is GoRoute && subroute != null) {
                    r.routes.removeWhere((rr) => rr is GoRoute && rr.name == subroute.name);
                  }
                  return r;
                }),
              ],
            ),
          ],
        ),
      );
    }

    for (final device in [Device.desktop, Device.mobile]) {
      group(device.name, () {
        testWidgets('Add template with all type of component', (tester) async {
          deviceAs(device, tester);
          await tester.pumpWidget(buildApp());
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const Key('printer.settings')));
          await tester.pumpAndSettle();

          // tap add template
          await tester.tap(find.byKey(const Key('printer.settings.template_create')));
          await tester.pumpAndSettle();
          await tester.enterText(find.byKey(const Key('receipt_tpl.name')), 'AllComponentsTemplate');
          await tester.pumpAndSettle();

          Future<void> addComponent(ReceiptComponentType v, [bool save = true]) async {
            await tester.tap(find.byKey(const Key('receipt_tpl.add_component')));
            await tester.pumpAndSettle();
            await tester.tap(find.text(S.printerReceiptComponentType(v.name)));
            await tester.pumpAndSettle();
            if (save) {
              await tester.tap(find.byKey(const Key('modal.save')).last);
              await tester.pumpAndSettle();
            }
          }

          await addComponent(.textField, false);
          await tester.enterText(find.byKey(const Key('editor_ant.editor')), 'Sample Text');
          await tester.tap(find.byIcon(Icons.data_object));
          await tester.pumpAndSettle();
          await tester.tap(find.text('now'));
          await tester.pumpAndSettle();

          // Date Placeholder
          await tester.tap(find.text('now'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('yMMMd Hms'));
          await tester.pumpAndSettle();
          tester.testTextInput.enterText('yy/mm/d');
          await tester.pumpAndSettle();
          await tester.tap(find.text('OK'));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const Key('modal.save')).last);
          await tester.pumpAndSettle();

          await addComponent(.image);
          await addComponent(.orderTable);
          await addComponent(.discountTable);
          await addComponent(.attributeTable);
          await addComponent(.priceTable);
          await addComponent(.divider);

          await tester.tap(find.byKey(const Key('modal.save')).last);
          await tester.pumpAndSettle();

          expect(find.text('AllComponentsTemplate'), findsOneWidget);
          verify(
            storage.set(
              any,
              argThat(
                predicate((v) {
                  if (v is! Map) return false;
                  final containsTemplate = v.values.any((entry) {
                    if (entry is! Map) return false;
                    final name = entry['name'] as String?;
                    final components = entry['components'] as List<dynamic>?;
                    if (name != 'AllComponentsTemplate' || components == null || components.length != 7) return false;
                    final texts = components[0]['texts'] as List<dynamic>?;
                    return components[0]['type'] == ReceiptComponentType.textField.index &&
                        texts != null &&
                        texts[0]['_part']['type'] == 'styled' &&
                        texts[0]['_part']['text'] == 'Sample Text' &&
                        texts[1]['_part']['type'] == 'meta_placeholder' &&
                        texts[1]['_part']['text'] == 'now' &&
                        texts[1]['_part']['meta'] == 'yy/mm/d' &&
                        components[1]['type'] == ReceiptComponentType.image.index &&
                        components[2]['type'] == ReceiptComponentType.orderTable.index &&
                        components[3]['type'] == ReceiptComponentType.discountTable.index &&
                        components[4]['type'] == ReceiptComponentType.attributeTable.index &&
                        components[5]['type'] == ReceiptComponentType.priceTable.index &&
                        components[6]['type'] == ReceiptComponentType.divider.index;
                  });
                  return containsTemplate;
                }),
              ),
            ),
          ).called(equals(1));
        });
      });
    }

    testWidgets('Edit template with component reordering and deleting', (tester) async {
      await ReceiptTemplates.instance.addItem(
        ReceiptTemplate(
          id: 'tpl1',
          name: 'EditTemplate',
          components: [DividerComponent(height: 1.0), DividerComponent(height: 2.0), DividerComponent(height: 3.0)],
        ),
        save: false,
      );

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('printer.settings')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('EditTemplate'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('receipt_tpl.name')), 'EditTemplate2');
      await tester.pumpAndSettle();

      // Reorder the image component (drag last-to-second)
      await tester.drag(find.byIcon(Icons.reorder_outlined).last, const Offset(0, -20));
      await tester.pumpAndSettle();

      // Delete the image component by dismissing it via SlideToDelete (drag right-to-left)
      await tester.drag(find.byType(SlideToDelete<ReceiptComponent>).at(1), const Offset(-500, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('delete_dialog.confirm')));
      await tester.pumpAndSettle();

      // save changes
      await tester.tap(find.byKey(const Key('modal.save')).last);
      await tester.pumpAndSettle();

      // verify storage.set called to persist order and deletion
      verify(
        storage.set(
          any,
          argThat(
            predicate((v) {
              if (v is! Map) return false;
              if (v['template.tpl1.name'] != 'EditTemplate2') return false;
              if (v['template.tpl1.components'] is! List) return false;
              final invalid = (v['template.tpl1.components'] as List).where((e) {
                if (e is! Map) return true;
                if (e['type'] != ReceiptComponentType.divider.index) return true;
                if (e['height'] == 3) return true;
                return false;
              });
              return invalid.isEmpty;
            }),
          ),
        ),
      ).called(equals(1));

      await tester.drag(find.byKey(const Key('receipt_tpl.tpl1')), const Offset(-500, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('delete_dialog.confirm')));
      await tester.pumpAndSettle();

      verify(
        storage.set(
          any,
          argThat(
            predicate((v) {
              if (v is! Map) return false;
              return v.containsKey('template.tpl1') && v['template.tpl1'] == null;
            }),
          ),
        ),
      ).called(equals(1));
    });

    testWidgets('Open default template and confirm no modal.save button', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // open settings
      await tester.tap(find.byKey(const Key('printer.settings')));
      await tester.pumpAndSettle();

      // open default template item
      await tester.tap(find.text(S.printerReceiptTemplateDefaultName));
      await tester.pumpAndSettle();

      // default template should be view-only: no save button in modal
      expect(find.byKey(const Key('modal.save')), findsNothing);
    });

    testWidgets('Add template validation - repeat name', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Create a template named "RepeatName" first
      await ReceiptTemplates.instance.addItem(
        ReceiptTemplate(id: 'existing', name: 'RepeatName', components: []),
        save: false,
      );

      // open settings
      await tester.tap(find.byKey(const Key('printer.settings')));
      await tester.pumpAndSettle();

      // tap add template
      await tester.tap(find.byKey(const Key('printer.settings.template_create')));
      await tester.pumpAndSettle();

      // fill name with RepeatName
      await tester.enterText(find.byKey(const Key('receipt_tpl.name')), 'RepeatName');
      await tester.pumpAndSettle();

      // save template
      await tester.tap(find.byKey(const Key('modal.save')).last);
      await tester.pumpAndSettle();

      // Should show error for repeat name
      expect(find.text(S.printerReceiptTemplateNameErrorRepeat), findsOneWidget);
    });

    testWidgets('Edit component padding and select it as default template', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await ReceiptTemplates.instance.addItem(
        ReceiptTemplate(id: 'example', name: 'Example', components: []),
        save: false,
      );

      // open settings -> add template
      await tester.tap(find.byKey(const Key('printer.settings')));
      await tester.pumpAndSettle();
      await tester.longPress(find.text('Example'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.printerSettingsTitleTemplateUpdate));
      await tester.pumpAndSettle();

      // add textField component
      await tester.tap(find.byKey(const Key('receipt_tpl.add_component')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.printerReceiptComponentType('textField')));
      await tester.pumpAndSettle();

      // enter negative number in padding
      final paddingField = find.widgetWithText(TextFormField, S.printerReceiptComponentPaddingAll);
      await tester.enterText(paddingField, '3');
      await tester.tap(find.byKey(const Key('modal.save')).last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('modal.save')).last);
      await tester.pumpAndSettle();

      expect(ReceiptTemplates.instance.itemList.last.components.first.padding, const EdgeInsets.all(3));
      verify(
        storage.set(
          any,
          argThat(
            predicate((v) {
              if (v is! Map) return false;
              final c = v['template.example.components'];
              if (c is! List || c[0] is! Map<String, Object?>) return false;
              return c[0]['padding'] == '3,3,3,3';
            }),
          ),
        ),
      ).called(equals(1));

      await tester.tap(find.text('Example'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(SlideToDelete<ReceiptComponent>));
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.printerReceiptComponentPaddingLabel));
      await tester.pumpAndSettle();

      // enter valid number and save
      await tester.enterText(find.widgetWithText(TextFormField, S.printerReceiptComponentPaddingLeft), '1');
      await tester.enterText(find.widgetWithText(TextFormField, S.printerReceiptComponentPaddingTop), '2');
      await tester.enterText(find.widgetWithText(TextFormField, S.printerReceiptComponentPaddingRight), '3');
      await tester.enterText(find.widgetWithText(TextFormField, S.printerReceiptComponentPaddingBottom), '4');
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('modal.save')).last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('modal.save')).last);
      await tester.pumpAndSettle();

      expect(ReceiptTemplates.instance.itemList.last.components.first.padding, const EdgeInsets.fromLTRB(1, 2, 3, 4));
      verify(
        storage.set(
          any,
          argThat(
            predicate((v) {
              if (v is! Map) return false;
              final c = v['template.example.components'];
              if (c is! List || c[0] is! Map<String, Object?>) return false;
              return c[0]['padding'] == '1,2,3,4';
            }),
          ),
        ),
      ).called(equals(1));

      await tester.longPress(find.byKey(const Key('receipt_tpl.example')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.printerReceiptTemplateSelectLabel));
      await tester.pumpAndSettle();

      expect(ReceiptTemplates.instance.selected.id, equals('example'));

      verify(
        storage.set(
          any,
          argThat(
            predicate((v) {
              if (v is! Map) return false;
              final s = v['setting'];
              if (s is! Map<String, Object?>) return false;
              return s['selectedId'] == 'example';
            }),
          ),
        ),
      ).called(equals(1));
      expect(ReceiptTemplates.instance.selected.name, equals('Example'));
    });

    testWidgets('Edit template component specific configurations', (tester) async {
      await tester.pumpWidget(
        buildApp(
          GoRoute(
            name: Routes.imageGallery,
            path: 'imageGallery',
            pageBuilder: (context, __) {
              return MaterialPage(
                child: TextButton(onPressed: () => context.pop('test-image'), child: const Text('choose-image')),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // open settings -> add template
      await tester.tap(find.byKey(const Key('printer.settings')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('printer.settings.template_create')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('receipt_tpl.name')), 'Custom');

      Future<void> addComponent(ReceiptComponentType v) async {
        await tester.tap(find.byKey(const Key('receipt_tpl.add_component')));
        await tester.pumpAndSettle();
        await tester.tap(find.text(S.printerReceiptComponentType(v.name)));
        await tester.pumpAndSettle();
      }

      Future<void> tapCell(String title, String btn, [String? option]) async {
        await tester.tap(find.text(title).last);
        await tester.pumpAndSettle();
        await tester.tap(find.text(btn).last);
        await tester.pumpAndSettle();
        if (option != null) {
          await tester.tap(find.text(option).last);
          await tester.pumpAndSettle();
        }
      }

      Future<void> tapCellAndEnter(String title, String btn, String text) async {
        await tapCell(title, btn);
        await tester.enterText(find.byKey(const Key('text_dialog.text')), text);
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
      }

      await addComponent(.orderTable);
      await tapCellAndEnter(S.printerReceiptTableOrderSinglePrice, S.printerReceiptComponentTableTitleBtn, 'evan');
      await tapCell(S.printerReceiptTableOrderName, S.printerReceiptComponentTableOrderTitleAddCatalog);
      await tapCellAndEnter('evan', S.printerReceiptComponentTableWidthBtn, '66');
      await tester.tap(find.byKey(const Key('modal.save')).last);
      await tester.pumpAndSettle();
      final expected1 = {
        'type': ReceiptComponentType.orderTable.index,
        'columns': [
          {'type': OrderTableColumn.productNameWithCatalogName.index},
          {'type': OrderTableColumn.quantity.index},
          {'type': OrderTableColumn.singlePrice.index, 'title': 'evan', 'width': 66.0},
          {'type': OrderTableColumn.totalPrice.index},
        ],
      };

      await addComponent(.discountTable);
      await tapCell(S.printerReceiptTableDiscountTitle, S.printerReceiptComponentTableDiscountTitleAddCatalog);
      String c = S.printerReceiptTableDiscountOriginPrice;
      await tapCell(c, S.printerReceiptComponentTableInsertBtnLeft, S.printerReceiptTableDiscountQuantity);
      await tapCell(c, S.printerReceiptComponentTableInsertBtnRight, S.printerReceiptTableDiscountSinglePrice);
      await tapCell(c, S.printerReceiptComponentTableMoveBtnLeft);
      await tapCell(c, S.printerReceiptTableDiscountQuantity, S.printerReceiptComponentTableMoveBtnRight);
      await tester.tap(find.byKey(const Key('modal.save')).last);
      await tester.pumpAndSettle();
      final expected2 = {
        'type': ReceiptComponentType.discountTable.index,
        'columns': [
          {'type': DiscountTableColumn.productNameWithCatalogName.index},
          {'type': DiscountTableColumn.originPrice.index},
          {'type': DiscountTableColumn.singlePrice.index},
          {'type': DiscountTableColumn.quantity.index},
        ],
      };

      await addComponent(.attributeTable);
      await tapCell(S.printerReceiptTableAttributeTitle, S.printerReceiptComponentTableAttrTitleAddAttr);
      await tapCell(S.printerReceiptTableAttributeTitle, S.printerReceiptComponentTableAttrTitleRemoveOption);
      await tester.tap(find.byKey(const Key('modal.save')).last);
      await tester.pumpAndSettle();
      final expected3 = {
        'type': ReceiptComponentType.attributeTable.index,
        'columns': [
          {'type': AttributeTableColumn.attrName.index},
          {'type': AttributeTableColumn.adjustment.index},
        ],
      };

      await addComponent(.priceTable);
      await tapCell(S.printerReceiptTablePricePaid, S.printerReceiptComponentTableDeleteBtnRow);
      await tapCell(S.printerReceiptTablePriceChange, S.printerReceiptComponentTableDeleteBtnRow);
      await tapCell(
        S.printerReceiptTablePricePrice,
        S.printerReceiptComponentTableInsertBtnUp,
        S.printerReceiptTablePriceProductsPrice,
      );
      await tapCell(
        S.printerReceiptTablePricePrice,
        S.printerReceiptComponentTableInsertBtnDown,
        S.printerReceiptTablePriceProductsQuantity,
      );
      await tapCellAndEnter(S.printerReceiptTablePriceTotal, S.printerReceiptComponentTableTitleBtn, 'evan');
      await tester.tap(find.byKey(const Key('modal.save')).last);
      await tester.pumpAndSettle();
      final expected4 = {
        'type': ReceiptComponentType.priceTable.index,
        'columns': [
          {'type': PriceTableColumn.total.index, 'title': 'evan'},
          {'type': PriceTableColumn.productsPrice.index},
          {'type': PriceTableColumn.price.index},
          {'type': PriceTableColumn.productsQuantity.index},
        ],
      };

      const XFile('test-image').file.writeAsBytesSync([]);
      await addComponent(.image);
      await tester.tap(find.byKey(const Key('image_holder.edit')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('choose-image'));
      await tester.pumpAndSettle();
      await tester.drag(find.byKey(const Key('receipt_component.slider')), const Offset(20, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('modal.save')).last);
      await tester.pumpAndSettle();
      final expected5 = {'type': ReceiptComponentType.image.index, 'imagePath': 'test-image', 'widthRatio': 0.6};

      // save template
      await tester.tap(find.byKey(const Key('modal.save')));
      await tester.pumpAndSettle();

      final template = ReceiptTemplates.instance.getItemByName('Custom')!;
      expect(template.components.elementAt(0).toJson(), equals(expected1));
      expect(template.components.elementAt(1).toJson(), equals(expected2));
      expect(template.components.elementAt(2).toJson(), equals(expected3));
      expect(template.components.elementAt(3).toJson(), equals(expected4));
      expect(template.components.elementAt(4).toJson(), equals(expected5));
    });

    setUpAll(() {
      Printers().replaceItems({'exist': Printer(id: 'exist', name: 'exist', address: 'address2')});
      ReceiptTemplates.reset();
      initializeStorage();
      initializeCache();
      initializeTranslator();
      initializeFileSystem();
    });

    setUp(() {
      reset(storage);
      reset(cache);
      when(storage.set(any, any)).thenAnswer((_) => Future.value());
      when(storage.add(any, any, any)).thenAnswer((_) => Future.value());
      when(cache.get(any)).thenReturn(true);
      ReceiptTemplates().prepareDefault();
    });
  });
}
