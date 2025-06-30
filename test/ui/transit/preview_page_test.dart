import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/models/model.dart';
import 'package:possystem/models/order/order_attribute.dart';
import 'package:possystem/models/order/order_attribute_option.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/models/stock/replenishment.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/formatter/field_formatter.dart';
import 'package:possystem/ui/transit/formatter/formatter.dart';
import 'package:possystem/ui/transit/formatter/plain_text_formatter.dart';
import 'package:possystem/ui/transit/previews/preview_page.dart';

import '../../mocks/mock_storage.dart';
import '../../test_helpers/breakpoint_mocker.dart';

void main() {
  List<FormattedItem>? proxyFormatter(FormattableModel model) {
    final List<Model> items = switch (model) {
      FormattableModel.menu => Menu.instance.itemList.map((e) => e.itemList).expand((e) => e).toList() as List<Model>,
      FormattableModel.stock => Stock.instance.itemList,
      FormattableModel.quantities => Quantities.instance.itemList,
      FormattableModel.replenisher => Replenisher.instance.itemList,
      FormattableModel.orderAttr => OrderAttributes.instance.itemList,
    };

    return items.map((e) => FormattedItem(item: e)).toList();
  }

  Widget buildApp(List<FormattableModel> ables, [PreviewFormatter? formatter]) {
    return MaterialApp(
      home: Scaffold(
        body: PreviewPageWrapper(
          models: ables,
          formatter: formatter ?? proxyFormatter,
        ),
      ),
    );
  }

  group('Transit Import Preview', () {
    for (final device in [Device.desktop, Device.mobile]) {
      group('- ${device.name} -', () {
        testWidgets('empty data', (tester) async {
          await tester.pumpWidget(buildApp([FormattableModel.stock]));
          await tester.pumpAndSettle();

          expect(find.text(S.transitImportErrorPreviewNotFound(FormattableModel.stock.l10nName)), findsOneWidget);
        });

        testWidgets('error data', (tester) async {
          await tester.pumpWidget(buildApp(
            [FormattableModel.stock],
            (FormattableModel able) => [FormattedItem(error: FormatterValidateError('TestError', 'RawData'))],
          ));
          await tester.pumpAndSettle();

          expect(find.text('RawData'), findsOneWidget);
          expect(find.text('TestError'), findsOneWidget);
        });
      });

      testWidgets('commit menu data only', (tester) async {
        final irf = _ImportFromRepo();

        await tester.pumpWidget(buildApp([FormattableModel.menu], irf.formatter));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(ExpansionTile).first);
        await tester.pump();

        void checkName(String text, String status) {
          expect(
            find.text(text + S.transitImportColumnStatus(status), findRichText: true),
            findsOneWidget,
          );
        }

        checkName('p1', 'staged');
        checkName('c1', 'staged');
        checkName('i1', 'stagedIng');
        checkName('q1', 'stagedQua');

        await tester.tap(find.byKey(const Key('transit.import.confirm')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('confirm_dialog.confirm')));
        await tester.pumpAndSettle();

        irf.compares(FormattableModel.menu);
        irf.compares(FormattableModel.stock);
        irf.compares(FormattableModel.quantities);
        expect(Replenisher.instance.isEmpty, isTrue);
        expect(OrderAttributes.instance.isEmpty, isTrue);
      });

      testWidgets('abort data after all checked and confirming', (tester) async {
        // also test empty data workflow
        final irf = _ImportFromRepo();
        late VoidCallback aborter;
        final route = MaterialPageRoute(
          builder: (context) {
            aborter = () => Navigator.of(context).pop();
            return Scaffold(
              body: PreviewPageWrapper(models: FormattableModel.values, formatter: irf.formatter),
            );
          },
        );

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Builder(builder: (context) {
              return TextButton(
                onPressed: () => Navigator.of(context).push(route),
                child: const Text('Go'),
              );
            }),
          ),
        ));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Go'));
        await tester.pumpAndSettle();

        for (final model in FormattableModel.values) {
          await tester.tap(find.text(model.l10nName));
          await tester.pumpAndSettle();
          await tester.tap(find.text(S.transitImportPreviewConfirmVerify));
          await tester.pumpAndSettle();
        }

        await tester.tap(find.byKey(const Key('transit.import.confirm')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('confirm_dialog.cancel')));
        await tester.pumpAndSettle();
        aborter();
        await tester.pumpAndSettle();

        for (final model in FormattableModel.values) {
          final repo = model.toRepository();
          expect(repo.isEmpty, isTrue, reason: 'Repository for $model should be empty after abort');
          expect(repo.stagedItems.isEmpty, isTrue, reason: 'Staged items for $model should be empty after abort');
        }
      });
    }

    testWidgets('preview and commit all models', (tester) async {
      final irf = _ImportFromRepo(() {
        Stock.instance.replaceItems({
          'i1': Stock.instance.getItem('i1')!,
          'i2': Ingredient(id: 'i2', name: 'i2', currentAmount: 10),
        });
      });

      await tester.pumpWidget(buildApp(FormattableModel.values, irf.formatter));
      await tester.pumpAndSettle();

      for (final model in FormattableModel.values) {
        await tester.tap(find.text(model.l10nName));
        await tester.pumpAndSettle();
        await tester.tap(find.text(S.transitImportPreviewConfirmVerify));
        await tester.pumpAndSettle();
      }

      await tester.tap(find.byKey(const Key('transit.import.confirm')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm_dialog.confirm')));
      await tester.pumpAndSettle();

      irf.compares(FormattableModel.menu);
      irf.compares(FormattableModel.stock);
      irf.compares(FormattableModel.quantities);
      irf.compares(FormattableModel.replenisher);
      irf.compares(FormattableModel.orderAttr);
    });
  });

  setUp(() {
    Menu();
    Stock();
    Quantities();
    OrderAttributes();
    Replenisher();
  });

  setUpAll(() {
    initializeStorage();
  });
}

class _ImportFromRepo {
  final Menu menu;
  final Stock stock;
  final Quantities quantities;
  final Replenisher replenisher;
  final OrderAttributes orderAttributes;

  late Menu menuOri;
  late Stock stockOri;
  late Quantities quantitiesOri;
  late Replenisher replenisherOri;
  late OrderAttributes orderAttributesOri;

  _ImportFromRepo._(this.menu, this.stock, this.quantities, this.replenisher, this.orderAttributes);

  factory _ImportFromRepo([VoidCallback? action]) {
    final i1 = Ingredient(id: 'i1', name: 'i1');
    Stock.instance.replaceItems({'i1': i1});

    final q1 = Quantity(id: 'q1', name: 'q1');
    Quantities.instance.replaceItems({'q1': q1});

    final pQ1 = ProductQuantity(id: 'pQ1', quantity: q1);
    final pI1 = ProductIngredient(id: 'pI1', ingredient: i1, quantities: {'pQ1': pQ1});
    pI1.prepareItem();
    final p1 = Product(id: 'p1', name: 'p1', ingredients: {'pI1': pI1});
    p1.prepareItem();
    final c1 = Catalog(id: 'c1', name: 'c1', products: {'p1': p1});
    c1.prepareItem();
    Menu.instance.replaceItems({'c1': c1});

    final r1 = Replenishment(id: 'r1', name: 'r1', data: {'i1': 1});
    Replenisher.instance.replaceItems({'r1': r1});

    final o1 = OrderAttributeOption(id: 'o1', name: 'o1', modeValue: 1);
    final o2 = OrderAttributeOption(id: 'o2', name: 'o2', isDefault: true);
    final cs1 = OrderAttribute(id: 'oa1', name: 'oa1', options: {
      'o1': o1,
      'o2': o2,
    });
    cs1.prepareItem();
    OrderAttributes.instance.replaceItems({'oa1': cs1});

    action?.call();

    final repo = _ImportFromRepo._(
      Menu.instance,
      Stock.instance,
      Quantities.instance,
      Replenisher.instance,
      OrderAttributes.instance,
    );

    Menu();
    Stock();
    Quantities();
    Replenisher();
    OrderAttributes();

    return repo;
  }

  void compares(FormattableModel model) {
    final actual = findPlainTextFormatter(model).getRows();

    switchRepo();
    final expected = findPlainTextFormatter(model).getRows();
    switchBack();

    expect(
      actual.map((e) => e.join(",")).join("\n"),
      equals(expected.map((e) => e.join(",")).join("\n")),
    );
  }

  List<FormattedItem>? formatter(FormattableModel model) {
    final items = switch (model) {
      FormattableModel.menu => menu.itemList.map((e) => e.itemList).expand((e) => e).toList(),
      FormattableModel.stock => stock.itemList,
      FormattableModel.quantities => quantities.itemList,
      FormattableModel.replenisher => replenisher.itemList,
      FormattableModel.orderAttr => orderAttributes.itemList,
    };

    switchRepo();
    final rows = findFieldFormatter(model).getRows();
    switchBack();

    final parser = model.toParser();
    final result = items.mapIndexed((i, e) {
      return FormattedItem(item: parser.parse(rows[i].map((e) => e.toString()).toList(), i + 1));
    }).toList();

    return result;
  }

  void switchRepo() {
    menuOri = Menu.instance;
    stockOri = Stock.instance;
    quantitiesOri = Quantities.instance;
    replenisherOri = Replenisher.instance;
    orderAttributesOri = OrderAttributes.instance;

    Menu.instance = menu;
    Stock.instance = stock;
    Quantities.instance = quantities;
    Replenisher.instance = replenisher;
    OrderAttributes.instance = orderAttributes;
  }

  void switchBack() {
    Menu.instance = menuOri;
    Stock.instance = stockOri;
    Quantities.instance = quantitiesOri;
    Replenisher.instance = replenisherOri;
    OrderAttributes.instance = orderAttributesOri;
  }
}
