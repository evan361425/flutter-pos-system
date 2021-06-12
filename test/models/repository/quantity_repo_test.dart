import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/repository/quantity_repo.dart';
import 'package:possystem/models/stock/quantity_model.dart';

import '../../mocks/mock_objects.dart';
import '../../mocks/mock_storage.dart' as storage;
import '../../test_helpers/check_notifier.dart';
import 'quantity_repo_test.mocks.dart';

@GenerateMocks([QuantityModel])
void main() {
  group('#constructor', () {
    test('should success', () {
      when(storage.mock.get(any)).thenAnswer((invocation) => Future.value({
            'id_1': {
              'name': 'name_1',
              'defaultProportion': 1,
            },
            'id_2': {
              'name': 'name_2',
              'defaultProportion': 2,
            }
          }));
      final repo = QuantityRepo();

      var isCalled = false;
      void checkCalled() {
        expect(repo.getQuantity('id_1')?.name, equals('name_1'));
        expect(repo.getQuantity('id_2')?.name, equals('name_2'));
        expect(repo.isReady, isTrue);
        isCalled = true;
      }

      repo.addListener(checkCalled);
      expect(identical(QuantityRepo.instance, repo), isTrue);
      expect(repo.isReady, isFalse);
      Future.delayed(Duration.zero, () => expect(isCalled, isTrue));
    });

    test('should continue if one entry is polluted', () {
      LOG_LEVEL = 0;
      when(storage.mock.get(any)).thenAnswer((invocation) => Future.value({
            'id_1': {
              'name': 123,
              'defaultProportion': 1,
            },
            'id_2': {
              'name': 'name_2',
              'defaultProportion': 2,
            }
          }));
      final repo = QuantityRepo();

      repo.addListener(() {
        expect(repo.getQuantity('id_2')?.name, equals('name_2'));
        expect(repo.getQuantity('id_1'), isNull);
        expect(repo.isReady, isTrue);
      });
    });
  });

  group('Methods', () {
    late QuantityRepo repo;

    test('#getter', () {
      final q_a = MockQuantityModel();
      final q_b = MockQuantityModel();
      repo.quantities = {'a': q_a, 'b': q_b};

      expect(repo.isEmpty, isFalse);
      expect(repo.isNotEmpty, isTrue);
      expect(repo.length, equals(2));
      expect(repo.exist('a'), isTrue);
      expect(repo.exist('c'), isFalse);
      expect(repo.getQuantity('b'), q_b);
      expect(repo.quantityList, equals([q_a, q_b]));
    });

    test('#removeQuantity', () {
      final q_a = MockQuantityModel();
      final q_b = MockQuantityModel();
      repo.quantities = {'a': q_a, 'b': q_b};

      expect(checkNotifierCalled(repo, () => repo.removeQuantity('a')), isTrue);
      expect(checkNotifierCalled(repo, () => repo.removeQuantity('c')), isTrue);

      expect(repo.exist('a'), isFalse);
    });

    group('#setQuantity', () {
      test('should not call storage', () async {
        final q_a = MockQuantityModel();
        repo.quantities = {'a': q_a};
        when(q_a.id).thenReturn('a');
        when(storage.mock.add(any, any, any)).thenThrow(Exception());

        expect(await checkNotifierCalled(repo, () => repo.setQuantity(q_a)),
            isTrue);

        expect(repo.exist('a'), isTrue);
      });

      test('should add quantitiy', () async {
        final q_a = MockQuantityModel();
        final q_b = MockQuantityModel();
        final q_map = mockQuantityObject1.toMap();
        repo.quantities = {'a': q_a};

        when(q_b.toObject()).thenReturn(mockQuantityObject1);
        when(q_b.id).thenReturn('b');
        when(storage.mock.add(any, 'b', q_map))
            .thenAnswer((_) => Future.value());

        final future = checkNotifierCalled(repo, () => repo.setQuantity(q_b));
        expect(await future, isTrue);

        expect(repo.exist('a'), isTrue);
        expect(repo.exist('b'), isTrue);
      });
    });

    group('#sortBySimilarity', () {
      MockQuantityModel createQuantity(String id, int similarity) {
        final quantity = MockQuantityModel();
        when(quantity.getSimilarity(any)).thenReturn(similarity);
        when(quantity.id).thenReturn(id);
        when(quantity.toString()).thenReturn(id);

        return quantity;
      }

      test('should empty result if given empty string', () {
        expect(repo.sortBySimilarity(''), isEmpty);
      });

      test('should get correct quantity', () {
        final q1 = createQuantity('id1', 0);
        final q2 = createQuantity('id2', 2);
        final q3 = createQuantity('id3', 3);
        final q4 = createQuantity('id4', 3);
        final q5 = createQuantity('id5', 4);
        repo.quantities = {
          'id1': q1,
          'id2': q2,
          'id3': q3,
          'id4': q4,
          'id5': q5,
        };

        final result = repo.sortBySimilarity('text');
        expect(result, orderedEquals([q5, q3, q4, q2]));
      });

      test('should get limit quantity', () {
        final quantities = [
          for (var i = 0; i < 20; i++) createQuantity('id$i', i)
        ];
        repo.quantities = {
          for (var quantity in quantities) quantity.id: quantity
        };

        final result = repo.sortBySimilarity('text');
        expect(result.length, equals(10));
      });
    });

    setUp(() {
      when(storage.mock.get(any)).thenAnswer((e) => Future.value({}));
      repo = QuantityRepo();
    });
  });

  setUpAll(() {
    storage.before();
  });

  tearDownAll(() {
    storage.after();
  });
}
