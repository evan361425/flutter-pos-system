import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/stock/ingredient_model.dart';

import '../../mocks/mocks.dart';
import '../../test_helpers/check_notifier.dart';

void main() {
  test('#fromObject', () {
    final object = IngredientObject(
      id: 'id',
      name: 'name',
      currentAmount: 1,
      lastAddAmount: 2,
      lastAmount: 3,
      updatedAt: DateTime.now(),
    );
    final ingredient = IngredientModel.fromObject(object);
    final newObject = ingredient.toObject();

    expect(ingredient.id, equals(object.id));
    expect(ingredient.name, equals(object.name));
    expect(ingredient.currentAmount, equals(object.currentAmount));
    expect(ingredient.lastAddAmount, equals(object.lastAddAmount));
    expect(ingredient.lastAmount, equals(object.lastAmount));
    expect(ingredient.updatedAt, equals(object.updatedAt));
    expect(identical(ingredient.toObject(), object), isFalse);
    expect(newObject.toMap(), equals(object.toMap()));
  });

  test('#addAmount', () {
    final ingredient = IngredientModel(name: 'name', id: 'id');

    ingredient.addAmount(123);

    verify(stock.applyAmounts({'id': 123}));
  });

  test('#getSimilarity', () {
    final ingredient = IngredientModel(name: 'some-name', id: 'id');

    expect(ingredient.getSimilarity('am'), greaterThan(0));
    expect(ingredient.getSimilarity('om'), greaterThan(0));
    expect(ingredient.getSimilarity('me'), greaterThan(0));
  });

  group('#updateInfo', () {
    test('positive update without default', () {
      final ingredient = IngredientModel(name: 'name', id: 'id');
      final prefix = ingredient.prefix;
      final result = ingredient.updateInfo(10);

      expect(result['$prefix.lastAddAmount'], equals(10));
      expect(result['$prefix.currentAmount'], equals(10));
      expect(result['$prefix.lastAmount'], equals(10));
    });

    test('positive update with default', () {
      final ingredient = IngredientModel(
          name: 'name',
          id: 'id',
          lastAddAmount: 1,
          currentAmount: 2,
          lastAmount: 3);
      final prefix = ingredient.prefix;
      final result = ingredient.updateInfo(10);

      expect(result['$prefix.lastAddAmount'], equals(10));
      expect(result['$prefix.currentAmount'], equals(12));
      expect(result['$prefix.lastAmount'], equals(12));
    });

    test('negative update', () {
      final ingredient1 = IngredientModel(name: 'name', id: 'id');
      final ingredient2 =
          IngredientModel(name: 'name', id: 'id', currentAmount: 3);
      var prefix = ingredient1.prefix;
      var result = ingredient1.updateInfo(-2);

      expect(result['$prefix.lastAddAmount'], isNull);
      expect(result['$prefix.currentAmount'], equals(0));
      expect(result['$prefix.lastAmount'], isNull);

      result = ingredient2.updateInfo(-2);
      expect(result['$prefix.currentAmount'], equals(1));

      result = ingredient2.updateInfo(-2);
      expect(result['$prefix.currentAmount'], equals(0));
    });
  });

  group('Methods With Storage', () {
    test('#remove', () async {
      LOG_LEVEL = 2;
      final ingredient = IngredientModel(name: 'name', id: 'id');
      final expected = {ingredient.prefix: null};

      await ingredient.remove();

      verify(storage.set(any, argThat(equals(expected))));
      verify(stock.removeItem(argThat(equals('id'))));
    });

    group('#update', () {
      test('should not notify or update if not changed', () async {
        final ingredient = IngredientModel(
            name: 'name',
            id: 'id',
            currentAmount: 1,
            warningAmount: 2,
            alertAmount: 3,
            lastAddAmount: 4,
            lastAmount: 5);
        final object = IngredientObject(
            name: 'name',
            currentAmount: 1,
            warningAmount: 2,
            alertAmount: 3,
            lastAddAmount: 4,
            lastAmount: 5);

        final isChecked = await checkNotifierCalled(
            ingredient, () => ingredient.update(object));

        expect(isChecked, isFalse);
        verifyNever(storage.set(any, any));
      });

      test('update without changing ingredient', () async {
        LOG_LEVEL = 2;
        final ingredient = IngredientModel(
            name: 'name',
            id: 'id',
            currentAmount: 1,
            warningAmount: 2,
            alertAmount: 3,
            lastAddAmount: 4,
            lastAmount: 5);
        final object = IngredientObject(
            name: 'name2',
            currentAmount: 2,
            warningAmount: 3,
            alertAmount: 4,
            lastAddAmount: 5,
            lastAmount: 6);

        // Action
        final isChecked = await checkNotifierCalled(
            ingredient, () => ingredient.update(object));

        final prefix = ingredient.prefix;
        final expected = {
          '$prefix.name': 'name2',
          '$prefix.currentAmount': 2,
          '$prefix.warningAmount': 3,
          '$prefix.alertAmount': 4,
          '$prefix.lastAddAmount': 5,
          '$prefix.lastAmount': 6,
          '$prefix.updatedAt': ingredient.updatedAt.toString(),
        };

        expect(isChecked, isTrue);
        verify(storage.set(any, argThat(equals(expected))));
      });
    });
  });

  setUpAll(() {
    initialize();
  });
}
