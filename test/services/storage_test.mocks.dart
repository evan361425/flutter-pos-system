// Mocks generated by Mockito 5.1.0 from annotations
// in possystem/test/services/storage_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i3;

import 'package:mockito/mockito.dart' as _i1;
import 'package:sembast/src/api/transaction.dart' as _i4;
import 'package:sembast/src/api/v2/database.dart' as _i2;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types

/// A class which mocks [Database].
///
/// See the documentation for Mockito's code generation for more information.
class MockDatabase extends _i1.Mock implements _i2.Database {
  MockDatabase() {
    _i1.throwOnMissingStub(this);
  }

  @override
  int get version =>
      (super.noSuchMethod(Invocation.getter(#version), returnValue: 0) as int);
  @override
  String get path =>
      (super.noSuchMethod(Invocation.getter(#path), returnValue: '') as String);
  @override
  _i3.Future<T> transaction<T>(
          _i3.FutureOr<T>? Function(_i4.Transaction)? action) =>
      (super.noSuchMethod(Invocation.method(#transaction, [action]),
          returnValue: Future<T>.value(null)) as _i3.Future<T>);
  @override
  _i3.Future<dynamic> close() =>
      (super.noSuchMethod(Invocation.method(#close, []),
          returnValue: Future<dynamic>.value()) as _i3.Future<dynamic>);
}
