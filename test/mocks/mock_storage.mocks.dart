// Mocks generated by Mockito 5.4.6 from annotations
// in possystem/test/mocks/mock_storage.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;

import 'package:mockito/mockito.dart' as _i1;
import 'package:possystem/services/storage.dart' as _i3;
import 'package:sembast/sembast_io.dart' as _i2;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeDatabase_0 extends _i1.SmartFake implements _i2.Database {
  _FakeDatabase_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeStorageSanitizedData_1 extends _i1.SmartFake implements _i3.StorageSanitizedData {
  _FakeStorageSanitizedData_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [Storage].
///
/// See the documentation for Mockito's code generation for more information.
class MockStorage extends _i1.Mock implements _i3.Storage {
  MockStorage() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.Database get db => (super.noSuchMethod(
        Invocation.getter(#db),
        returnValue: _FakeDatabase_0(
          this,
          Invocation.getter(#db),
        ),
      ) as _i2.Database);

  @override
  set db(_i2.Database? _db) => super.noSuchMethod(
        Invocation.setter(
          #db,
          _db,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i4.Future<void> add(
    _i3.Stores? storeId,
    String? recordId,
    Map<String, Object?>? data,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #add,
          [
            storeId,
            recordId,
            data,
          ],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<Map<String, Object?>> get(
    _i3.Stores? storeId, [
    String? record,
  ]) =>
      (super.noSuchMethod(
        Invocation.method(
          #get,
          [
            storeId,
            record,
          ],
        ),
        returnValue: _i4.Future<Map<String, Object?>>.value(<String, Object?>{}),
      ) as _i4.Future<Map<String, Object?>>);

  @override
  _i4.Future<void> initialize({_i3.StorageOpener? opener}) => (super.noSuchMethod(
        Invocation.method(
          #initialize,
          [],
          {#opener: opener},
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> reset(
    _i3.Stores? storeId, [
    _i4.Future<void> Function(String)? del,
  ]) =>
      (super.noSuchMethod(
        Invocation.method(
          #reset,
          [
            storeId,
            del,
          ],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i3.StorageSanitizedData sanitize(Map<String, Object?>? data) => (super.noSuchMethod(
        Invocation.method(
          #sanitize,
          [data],
        ),
        returnValue: _FakeStorageSanitizedData_1(
          this,
          Invocation.method(
            #sanitize,
            [data],
          ),
        ),
      ) as _i3.StorageSanitizedData);

  @override
  _i4.Future<void> set(
    _i3.Stores? storeId,
    Map<String, Object?>? data,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #set,
          [
            storeId,
            data,
          ],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> setAll(
    _i3.Stores? storeId,
    Map<String, Object?>? data,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #setAll,
          [
            storeId,
            data,
          ],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);
}
