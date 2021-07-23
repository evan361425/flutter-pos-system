import 'dart:async' as _i10;
import 'dart:ui' as _i13;

import 'package:mockito/mockito.dart' as _i1;
import 'package:possystem/models/repository/stock_batch_repo.dart' as _i19;
import 'package:possystem/models/stock/stock_batch_model.dart' as _i7;
import 'package:possystem/services/storage.dart' as _i4;

class _FakeStockBatchModel extends _i1.Fake implements _i7.StockBatchModel {}

/// A class which mocks [StockBatchRepo].
///
/// See the documentation for Mockito's code generation for more information.
class MockStockBatchRepo extends _i1.Mock implements _i19.StockBatchRepo {
  MockStockBatchRepo() {
    _i1.throwOnMissingStub(this);
  }

  @override
  String get itemCode =>
      (super.noSuchMethod(Invocation.getter(#itemCode), returnValue: '')
          as String);
  @override
  _i4.Stores get storageStore =>
      (super.noSuchMethod(Invocation.getter(#storageStore),
          returnValue: _i4.Stores.menu) as _i4.Stores);
  @override
  bool get isEmpty =>
      (super.noSuchMethod(Invocation.getter(#isEmpty), returnValue: false)
          as bool);
  @override
  bool get isNotEmpty =>
      (super.noSuchMethod(Invocation.getter(#isNotEmpty), returnValue: false)
          as bool);
  @override
  List<_i7.StockBatchModel> get itemList =>
      (super.noSuchMethod(Invocation.getter(#itemList),
          returnValue: <_i7.StockBatchModel>[]) as List<_i7.StockBatchModel>);
  @override
  Iterable<_i7.StockBatchModel> get items => (super.noSuchMethod(
      Invocation.getter(#items),
      returnValue: <_i7.StockBatchModel>[]) as Iterable<_i7.StockBatchModel>);
  @override
  int get length =>
      (super.noSuchMethod(Invocation.getter(#length), returnValue: 0) as int);
  @override
  bool get isReady =>
      (super.noSuchMethod(Invocation.getter(#isReady), returnValue: false)
          as bool);
  @override
  set isReady(bool? _isReady) =>
      super.noSuchMethod(Invocation.setter(#isReady, _isReady),
          returnValueForMissingStub: null);
  @override
  bool get hasListeners =>
      (super.noSuchMethod(Invocation.getter(#hasListeners), returnValue: false)
          as bool);
  @override
  _i7.StockBatchModel buildModel(String? id, Map<String, Object?>? value) =>
      (super.noSuchMethod(Invocation.method(#buildModel, [id, value]),
          returnValue: _FakeStockBatchModel()) as _i7.StockBatchModel);
  @override
  bool hasBatch(String? name) =>
      (super.noSuchMethod(Invocation.method(#hasBatch, [name]),
          returnValue: false) as bool);
  @override
  void addItem(_i7.StockBatchModel? item) =>
      super.noSuchMethod(Invocation.method(#addItem, [item]),
          returnValueForMissingStub: null);
  @override
  _i10.Future<void> addItemToStorage(_i7.StockBatchModel? item) =>
      (super.noSuchMethod(Invocation.method(#addItemToStorage, [item]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future.value()) as _i10.Future<void>);
  @override
  _i7.StockBatchModel? getItem(String? id) =>
      (super.noSuchMethod(Invocation.method(#getItem, [id]))
          as _i7.StockBatchModel?);
  @override
  bool hasItem(String? id) =>
      (super.noSuchMethod(Invocation.method(#hasItem, [id]), returnValue: false)
          as bool);
  @override
  void notifyItem() => super.noSuchMethod(Invocation.method(#notifyItem, []),
      returnValueForMissingStub: null);
  @override
  void removeItem(String? id) =>
      super.noSuchMethod(Invocation.method(#removeItem, [id]),
          returnValueForMissingStub: null);
  @override
  void replaceItems(Map<String, _i7.StockBatchModel>? map) =>
      super.noSuchMethod(Invocation.method(#replaceItems, [map]),
          returnValueForMissingStub: null);
  @override
  _i10.Future<void> setItem(_i7.StockBatchModel? item) =>
      (super.noSuchMethod(Invocation.method(#setItem, [item]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future.value()) as _i10.Future<void>);
  @override
  _i10.Future<void> initialize() =>
      (super.noSuchMethod(Invocation.method(#initialize, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future.value()) as _i10.Future<void>);
  @override
  void addListener(_i13.VoidCallback? listener) =>
      super.noSuchMethod(Invocation.method(#addListener, [listener]),
          returnValueForMissingStub: null);
  @override
  void removeListener(_i13.VoidCallback? listener) =>
      super.noSuchMethod(Invocation.method(#removeListener, [listener]),
          returnValueForMissingStub: null);
  @override
  void dispose() => super.noSuchMethod(Invocation.method(#dispose, []),
      returnValueForMissingStub: null);
  @override
  void notifyListeners() =>
      super.noSuchMethod(Invocation.method(#notifyListeners, []),
          returnValueForMissingStub: null);
}
