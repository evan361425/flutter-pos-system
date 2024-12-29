// Mocks generated by Mockito 5.4.5 from annotations
// in possystem/test/mocks/mock_bluetooth.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i5;
import 'dart:typed_data' as _i7;
import 'dart:ui' as _i8;

import 'package:flutter/material.dart' as _i4;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i6;
import 'package:packages/bluetooth.dart' as _i2;
import 'package:possystem/components/imageable_container.dart' as _i3;

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

class _FakeFBP_0 extends _i1.SmartFake implements _i2.FBP {
  _FakeFBP_0(Object parent, Invocation parentInvocation) : super(parent, parentInvocation);
}

class _FakeBluetoothDevice_1 extends _i1.SmartFake implements _i2.BluetoothDevice {
  _FakeBluetoothDevice_1(Object parent, Invocation parentInvocation) : super(parent, parentInvocation);
}

class _FakePrinterManufactory_2 extends _i1.SmartFake implements _i2.PrinterManufactory {
  _FakePrinterManufactory_2(Object parent, Invocation parentInvocation) : super(parent, parentInvocation);
}

class _FakeImageableController_3 extends _i1.SmartFake implements _i3.ImageableController {
  _FakeImageableController_3(Object parent, Invocation parentInvocation) : super(parent, parentInvocation);
}

class _FakeGlobalKey_4<T extends _i4.State<_i4.StatefulWidget>> extends _i1.SmartFake implements _i4.GlobalKey<T> {
  _FakeGlobalKey_4(Object parent, Invocation parentInvocation) : super(parent, parentInvocation);
}

/// A class which mocks [Bluetooth].
///
/// See the documentation for Mockito's code generation for more information.
class MockBluetooth extends _i1.Mock implements _i2.Bluetooth {
  MockBluetooth() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.FBP get blue => (super.noSuchMethod(
        Invocation.getter(#blue),
        returnValue: _FakeFBP_0(this, Invocation.getter(#blue)),
      ) as _i2.FBP);

  @override
  _i5.Stream<List<_i2.BluetoothDevice>> startScan() => (super.noSuchMethod(
        Invocation.method(#startScan, []),
        returnValue: _i5.Stream<List<_i2.BluetoothDevice>>.empty(),
      ) as _i5.Stream<List<_i2.BluetoothDevice>>);

  @override
  _i5.Future<_i2.BluetoothDevice> connect(String? address) => (super.noSuchMethod(
        Invocation.method(#connect, [address]),
        returnValue: _i5.Future<_i2.BluetoothDevice>.value(
          _FakeBluetoothDevice_1(
            this,
            Invocation.method(#connect, [address]),
          ),
        ),
      ) as _i5.Future<_i2.BluetoothDevice>);

  @override
  _i5.Future<List<_i2.BluetoothDevice>> pairedDevices() => (super.noSuchMethod(
        Invocation.method(#pairedDevices, []),
        returnValue: _i5.Future<List<_i2.BluetoothDevice>>.value(
          <_i2.BluetoothDevice>[],
        ),
      ) as _i5.Future<List<_i2.BluetoothDevice>>);

  @override
  _i5.Future<void> stopScan() => (super.noSuchMethod(
        Invocation.method(#stopScan, []),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
}

/// A class which mocks [Printer].
///
/// See the documentation for Mockito's code generation for more information.
class MockPrinter extends _i1.Mock implements _i2.Printer {
  MockPrinter() {
    _i1.throwOnMissingStub(this);
  }

  @override
  String get address => (super.noSuchMethod(
        Invocation.getter(#address),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.getter(#address),
        ),
      ) as String);

  @override
  _i2.PrinterManufactory get manufactory => (super.noSuchMethod(
        Invocation.getter(#manufactory),
        returnValue: _FakePrinterManufactory_2(
          this,
          Invocation.getter(#manufactory),
        ),
      ) as _i2.PrinterManufactory);

  @override
  set device(_i2.BluetoothDevice? _device) => super.noSuchMethod(
        Invocation.setter(#device, _device),
        returnValueForMissingStub: null,
      );

  @override
  set writer(_i2.BluetoothCharacteristic? _writer) => super.noSuchMethod(
        Invocation.setter(#writer, _writer),
        returnValueForMissingStub: null,
      );

  @override
  set reader(_i2.BluetoothCharacteristic? _reader) => super.noSuchMethod(
        Invocation.setter(#reader, _reader),
        returnValueForMissingStub: null,
      );

  @override
  bool get connected => (super.noSuchMethod(Invocation.getter(#connected), returnValue: false) as bool);

  @override
  _i5.Stream<_i2.PrinterStatus> get statusStream => (super.noSuchMethod(
        Invocation.getter(#statusStream),
        returnValue: _i5.Stream<_i2.PrinterStatus>.empty(),
      ) as _i5.Stream<_i2.PrinterStatus>);

  @override
  bool get hasListeners => (super.noSuchMethod(Invocation.getter(#hasListeners), returnValue: false) as bool);

  @override
  _i5.Future<bool> connect() => (super.noSuchMethod(
        Invocation.method(#connect, []),
        returnValue: _i5.Future<bool>.value(false),
      ) as _i5.Future<bool>);

  @override
  _i5.Future<void> disconnect() => (super.noSuchMethod(
        Invocation.method(#disconnect, []),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Stream<double> draw(
    _i7.Uint8List? image, {
    _i2.PrinterDensity? density = _i2.PrinterDensity.normal,
  }) =>
      (super.noSuchMethod(
        Invocation.method(#draw, [image], {#density: density}),
        returnValue: _i5.Stream<double>.empty(),
      ) as _i5.Stream<double>);

  @override
  void addListener(_i8.VoidCallback? listener) => super.noSuchMethod(
        Invocation.method(#addListener, [listener]),
        returnValueForMissingStub: null,
      );

  @override
  void removeListener(_i8.VoidCallback? listener) => super.noSuchMethod(
        Invocation.method(#removeListener, [listener]),
        returnValueForMissingStub: null,
      );

  @override
  void dispose() => super.noSuchMethod(
        Invocation.method(#dispose, []),
        returnValueForMissingStub: null,
      );

  @override
  void notifyListeners() => super.noSuchMethod(
        Invocation.method(#notifyListeners, []),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [BluetoothDevice].
///
/// See the documentation for Mockito's code generation for more information.
class MockBluetoothDevice extends _i1.Mock implements _i2.BluetoothDevice {
  MockBluetoothDevice() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.Stream<bool> get connectionState => (super.noSuchMethod(
        Invocation.getter(#connectionState),
        returnValue: _i5.Stream<bool>.empty(),
      ) as _i5.Stream<bool>);

  @override
  bool get connected => (super.noSuchMethod(Invocation.getter(#connected), returnValue: false) as bool);

  @override
  String get name => (super.noSuchMethod(
        Invocation.getter(#name),
        returnValue: _i6.dummyValue<String>(this, Invocation.getter(#name)),
      ) as String);

  @override
  int get mtu => (super.noSuchMethod(Invocation.getter(#mtu), returnValue: 0) as int);

  @override
  String get address => (super.noSuchMethod(
        Invocation.getter(#address),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.getter(#address),
        ),
      ) as String);

  @override
  _i5.Future<void> connect() => (super.noSuchMethod(
        Invocation.method(#connect, []),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> disconnect() => (super.noSuchMethod(
        Invocation.method(#disconnect, []),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i2.BluetoothService? getService(int? id) =>
      (super.noSuchMethod(Invocation.method(#getService, [id])) as _i2.BluetoothService?);

  @override
  _i5.Stream<_i2.BluetoothSignal> createSignalStream({
    Duration? interval = const Duration(minutes: 1),
  }) =>
      (super.noSuchMethod(
        Invocation.method(#createSignalStream, [], {#interval: interval}),
        returnValue: _i5.Stream<_i2.BluetoothSignal>.empty(),
      ) as _i5.Stream<_i2.BluetoothSignal>);
}

/// A class which mocks [PrinterManufactory].
///
/// See the documentation for Mockito's code generation for more information.
class MockPrinterManufactory extends _i1.Mock implements _i2.PrinterManufactory {
  MockPrinterManufactory() {
    _i1.throwOnMissingStub(this);
  }

  @override
  int get serviceUuid => (super.noSuchMethod(Invocation.getter(#serviceUuid), returnValue: 0) as int);

  @override
  int get writerChar => (super.noSuchMethod(Invocation.getter(#writerChar), returnValue: 0) as int);

  @override
  int get readerChar => (super.noSuchMethod(Invocation.getter(#readerChar), returnValue: 0) as int);

  @override
  int get widthMM => (super.noSuchMethod(Invocation.getter(#widthMM), returnValue: 0) as int);

  @override
  int get widthBits => (super.noSuchMethod(Invocation.getter(#widthBits), returnValue: 0) as int);

  @override
  _i7.Uint8List prepare() => (super.noSuchMethod(
        Invocation.method(#prepare, []),
        returnValue: _i7.Uint8List(0),
      ) as _i7.Uint8List);

  @override
  _i7.Uint8List toCommands(
    _i7.Uint8List? image, {
    required _i2.PrinterDensity? density,
  }) =>
      (super.noSuchMethod(
        Invocation.method(#toCommands, [image], {#density: density}),
        returnValue: _i7.Uint8List(0),
      ) as _i7.Uint8List);

  @override
  _i5.Future<_i2.PrinterStatus> getStatus({
    required _i2.BluetoothCharacteristic? writer,
    required _i2.BluetoothCharacteristic? reader,
  }) =>
      (super.noSuchMethod(
        Invocation.method(#getStatus, [], {
          #writer: writer,
          #reader: reader,
        }),
        returnValue: _i5.Future<_i2.PrinterStatus>.value(
          _i2.PrinterStatus.good,
        ),
      ) as _i5.Future<_i2.PrinterStatus>);
}

/// A class which mocks [ImageableManger].
///
/// See the documentation for Mockito's code generation for more information.
class MockImageableManger extends _i1.Mock implements _i3.ImageableManger {
  MockImageableManger() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.ImageableController create() => (super.noSuchMethod(
        Invocation.method(#create, []),
        returnValue: _FakeImageableController_3(
          this,
          Invocation.method(#create, []),
        ),
      ) as _i3.ImageableController);
}

/// A class which mocks [ImageableController].
///
/// See the documentation for Mockito's code generation for more information.
class MockImageableController extends _i1.Mock implements _i3.ImageableController {
  MockImageableController() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.GlobalKey<_i4.State<_i4.StatefulWidget>> get key => (super.noSuchMethod(
        Invocation.getter(#key),
        returnValue: _FakeGlobalKey_4<_i4.State<_i4.StatefulWidget>>(
          this,
          Invocation.getter(#key),
        ),
      ) as _i4.GlobalKey<_i4.State<_i4.StatefulWidget>>);

  @override
  _i5.Future<List<_i3.ConvertibleImage>?> toImage({
    required List<int>? widths,
  }) =>
      (super.noSuchMethod(
        Invocation.method(#toImage, [], {#widths: widths}),
        returnValue: _i5.Future<List<_i3.ConvertibleImage>?>.value(),
      ) as _i5.Future<List<_i3.ConvertibleImage>?>);
}
