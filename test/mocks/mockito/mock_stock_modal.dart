import 'dart:async' as _i10;
import 'dart:ui' as _i13;

import 'package:mockito/mockito.dart' as _i1;
import 'package:possystem/models/objects/order_object.dart' as _i12;
import 'package:possystem/models/repository/stock_model.dart' as _i11;
import 'package:possystem/models/stock/ingredient_model.dart' as _i5;
import 'package:possystem/services/storage.dart' as _i4;

/// A class which mocks [StockModel].
///
/// See the documentation for Mockito's code generation for more information.
class MockStockModel extends _i1.Mock implements _i11.StockModel {
  MockStockModel() {
    _i1.throwOnMissingStub(this);
  }

  @override
  bool get hasListeners =>
      (super.noSuchMethod(Invocation.getter(#hasListeners), returnValue: false)
          as bool);
  @override
  bool get isEmpty =>
      (super.noSuchMethod(Invocation.getter(#isEmpty), returnValue: false)
          as bool);
  @override
  bool get isNotEmpty =>
      (super.noSuchMethod(Invocation.getter(#isNotEmpty), returnValue: false)
          as bool);
  @override
  bool get isReady =>
      (super.noSuchMethod(Invocation.getter(#isReady), returnValue: false)
          as bool);
  @override
  set isReady(bool? _isReady) =>
      super.noSuchMethod(Invocation.setter(#isReady, _isReady),
          returnValueForMissingStub: null);
  @override
  String get itemCode =>
      (super.noSuchMethod(Invocation.getter(#itemCode), returnValue: '')
          as String);
  @override
  List<_i5.IngredientModel> get itemList =>
      (super.noSuchMethod(Invocation.getter(#itemList),
          returnValue: <_i5.IngredientModel>[]) as List<_i5.IngredientModel>);
  @override
  Iterable<_i5.IngredientModel> get items => (super.noSuchMethod(
      Invocation.getter(#items),
      returnValue: <_i5.IngredientModel>[]) as Iterable<_i5.IngredientModel>);
  @override
  int get length =>
      (super.noSuchMethod(Invocation.getter(#length), returnValue: 0) as int);
  @override
  _i4.Stores get storageStore =>
      (super.noSuchMethod(Invocation.getter(#storageStore),
          returnValue: _i4.Stores.menu) as _i4.Stores);
  @override
  void addItem(_i5.IngredientModel? item) =>
      super.noSuchMethod(Invocation.method(#addItem, [item]),
          returnValueForMissingStub: null);
  @override
  _i10.Future<void> addItemToStorage(_i5.IngredientModel? item) =>
      (super.noSuchMethod(Invocation.method(#addItemToStorage, [item]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future.value()) as _i10.Future<void>);
  @override
  void addListener(_i13.VoidCallback? listener) =>
      super.noSuchMethod(Invocation.method(#addListener, [listener]),
          returnValueForMissingStub: null);
  @override
  _i10.Future<void> applyAmounts(Map<String, num>? amounts) =>
      (super.noSuchMethod(Invocation.method(#applyAmounts, [amounts]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future.value()) as _i10.Future<void>);
  @override
  _i5.IngredientModel buildModel(String? id, Map<String, Object?>? value) =>
      (super.noSuchMethod(Invocation.method(#buildModel, [id, value]),
          returnValue: _FakeIngredientModel()) as _i5.IngredientModel);
  @override
  void dispose() => super.noSuchMethod(Invocation.method(#dispose, []),
      returnValueForMissingStub: null);
  @override
  _i5.IngredientModel? getItem(String? id) =>
      (super.noSuchMethod(Invocation.method(#getItem, [id]))
          as _i5.IngredientModel?);
  @override
  bool hasItem(String? id) =>
      (super.noSuchMethod(Invocation.method(#hasItem, [id]), returnValue: false)
          as bool);
  @override
  bool hasName(String? id) =>
      (super.noSuchMethod(Invocation.method(#hasName, [id]), returnValue: false)
          as bool);
  @override
  _i10.Future<void> initialize() =>
      (super.noSuchMethod(Invocation.method(#initialize, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future.value()) as _i10.Future<void>);
  @override
  void notifyItem() => super.noSuchMethod(Invocation.method(#notifyItem, []),
      returnValueForMissingStub: null);
  @override
  void notifyListeners() =>
      super.noSuchMethod(Invocation.method(#notifyListeners, []),
          returnValueForMissingStub: null);
  @override
  _i10.Future<void> order(_i12.OrderObject? data,
          {_i12.OrderObject? oldData}) =>
      (super.noSuchMethod(
          Invocation.method(#order, [data], {#oldData: oldData}),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future.value()) as _i10.Future<void>);
  @override
  void removeItem(String? id) =>
      super.noSuchMethod(Invocation.method(#removeItem, [id]),
          returnValueForMissingStub: null);
  @override
  void removeListener(_i13.VoidCallback? listener) =>
      super.noSuchMethod(Invocation.method(#removeListener, [listener]),
          returnValueForMissingStub: null);
  @override
  void replaceItems(Map<String, _i5.IngredientModel>? map) =>
      super.noSuchMethod(Invocation.method(#replaceItems, [map]),
          returnValueForMissingStub: null);
  @override
  _i10.Future<void> setItem(_i5.IngredientModel? item) =>
      (super.noSuchMethod(Invocation.method(#setItem, [item]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future.value()) as _i10.Future<void>);
  @override
  List<_i5.IngredientModel> sortBySimilarity(String? text) =>
      (super.noSuchMethod(Invocation.method(#sortBySimilarity, [text]),
          returnValue: <_i5.IngredientModel>[]) as List<_i5.IngredientModel>);
}

class _FakeIngredientModel extends _i1.Fake implements _i5.IngredientModel {}
