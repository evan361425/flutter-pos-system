import 'package:mockito/mockito.dart' as _i1;
import 'package:possystem/models/objects/order_object.dart' as _i7;
import 'package:possystem/models/order/order_product_model.dart' as _i8;

class _FakeDateTime extends _i1.Fake implements DateTime {}

/// A class which mocks [OrderObject].
///
/// See the documentation for Mockito's code generation for more information.
class MockOrderObject extends _i1.Mock implements _i7.OrderObject {
  MockOrderObject() {
    _i1.throwOnMissingStub(this);
  }

  @override
  set paid(num? _paid) => super.noSuchMethod(Invocation.setter(#paid, _paid),
      returnValueForMissingStub: null);
  @override
  num get totalPrice =>
      (super.noSuchMethod(Invocation.getter(#totalPrice), returnValue: 0)
          as num);
  @override
  int get totalCount =>
      (super.noSuchMethod(Invocation.getter(#totalCount), returnValue: 0)
          as int);
  @override
  DateTime get createdAt => (super.noSuchMethod(Invocation.getter(#createdAt),
      returnValue: _FakeDateTime()) as DateTime);
  @override
  Iterable<_i7.OrderProductObject> get products =>
      (super.noSuchMethod(Invocation.getter(#products),
              returnValue: <_i7.OrderProductObject>[])
          as Iterable<_i7.OrderProductObject>);
  @override
  List<_i8.OrderProductModel> parseToProduct() => (super.noSuchMethod(
      Invocation.method(#parseToProduct, []),
      returnValue: <_i8.OrderProductModel>[]) as List<_i8.OrderProductModel>);
  @override
  Map<String, Object?> toMap() =>
      (super.noSuchMethod(Invocation.method(#toMap, []),
          returnValue: <String, Object?>{}) as Map<String, Object?>);
}
