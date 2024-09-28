import 'dart:async';

import 'package:bluetooth/bluetooth.dart' as bt;
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:possystem/app.dart';
import 'package:possystem/components/imageable_container.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/model.dart';
import 'package:possystem/models/model_object.dart';
import 'package:possystem/models/repository.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/services/storage.dart';

typedef BluetoothDevice = bt.BluetoothDevice;
typedef BluetoothSignal = bt.BluetoothSignal;
typedef PrinterStatus = bt.PrinterStatus;
typedef PrinterDensity = bt.PrinterDensity;
typedef PrinterManufactory = bt.PrinterManufactory;

class Printers extends ChangeNotifier with Repository<Printer>, RepositoryStorage<Printer> {
  static late Printers instance;

  PrinterDensity density = PrinterDensity.normal;

  @override
  final Stores storageStore = Stores.printers;

  Printers() {
    instance = this;
  }

  @override
  List<Printer> get itemList => items.sorted((a, b) => a.compareTo(b));

  @override
  RepositoryStorageType get repoType => RepositoryStorageType.repoProperties;

  bool get hasConnected => items.any((e) => e.connected);

  /// Get all the width of the connected printer, and remove the duplicate.
  List<int> get wantedPixelsWidths =>
      items.where((e) => e.connected).map((e) => e.p.manufactory.widthBits).toSet().toList();

  bool hasAddress(String address) => items.any((e) => e.address == address);

  @override
  Printer buildItem(String id, Map<String, Object?> value) {
    return Printer.fromObject(
      PrinterObject.build({
        'id': id,
        ...value,
      }),
    );
  }

  @override
  Future<void> initialize({String? record}) async {
    // follow [Printer.prefix]
    await super.initialize(record: 'printer');

    final data = await Storage.instance.get(storageStore, 'setting');
    density = PrinterDensity.values[data['density'] as int? ?? 0];

    // storage must make sure parent is initialized, so we need to
    // set printer to `{}`, otherwise we will failed to add printer
    // to the storage.
    if (isEmpty && data.isEmpty) {
      await Future.wait([
        Storage.instance.add(storageStore, 'setting', {
          'density': density.index,
        }),
        Storage.instance.add(storageStore, 'printer', {}),
      ]);
    }
  }

  Future<void> saveProperties() async {
    Log.ger('update repo start', storageStore.name, toString());

    await Storage.instance.set(storageStore, {
      'setting': {
        'density': density.index,
      },
    });

    notifyListeners();
  }

  void print(List<ConvertibleImage> images) async {
    final errors = <Object>[];
    final stackTraces = <StackTrace>[];

    final printers = Printers.instance.items.where((e) => e.connected);
    final group = printers.groupListsBy<int>((e) => e.p.manufactory.widthBits);
    final futures = group.entries.map((entry) {
      final image = images.firstWhere((e) => e.width == entry.key);

      return entry.value.map((printer) => printer.draw(image.bytes).drain().onError((e, s) {
            final msg = '${printer.name}: $e';
            errors.add(msg);
            stackTraces.add(s);
            Log.err(msg, 'printer_draw', s);
            return 1;
          }));
    }).expand((e) => e);

    await Future.wait(futures);

    if (errors.isNotEmpty) {
      App.scaffoldMessengerKey.currentState?.clearSnackBars();
      App.scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
        showCloseIcon: true,
        behavior: SnackBarBehavior.floating,
        content: Text(errors.join('\n')),
        width: Routes.homeMode.value.isMobile() ? null : 600,
      ));
    }
  }
}

class Printer extends Model<PrinterObject> with ModelStorage<PrinterObject> implements Comparable<Printer> {
  String address;

  bool autoConnect;

  PrinterProvider provider;

  /// p stands for printer
  ///
  /// It handle the connection and drawing of the printer
  bt.Printer p;

  @override
  final Stores storageStore = Stores.printers;

  @override
  Printers get repository => Printers.instance;

  @override
  String get prefix => 'printer.$id';

  bool get connected => p.connected;

  Printer({
    super.id,
    super.status = ModelStatus.normal,
    super.name = 'printer',
    this.address = '',
    this.autoConnect = false,
    this.provider = PrinterProvider.cat1,
    bt.Printer? other,
  }) : p = bt.Printer(address: address, manufactory: provider.manufactory, other: other) {
    p.addListener(notifyItem);
  }

  factory Printer.fromObject(PrinterObject object) => Printer(
        id: object.id,
        name: object.name!,
        address: object.address!,
        autoConnect: object.autoConnect!,
        provider: PrinterProvider.values[object.provider!],
      );

  @override
  PrinterObject toObject() {
    return PrinterObject(
      id: id,
      name: name,
      address: address,
      autoConnect: autoConnect,
      provider: provider.index,
    );
  }

  @override
  Future<void> remove() async {
    await p.disconnect();

    await super.remove();
  }

  /// Connect printer
  Future<bool> connect() {
    Log.ger('start', 'printer_connect');

    return p.connect();
  }

  /// Disconnect printer, it is ok if not connected
  Future<void> disconnect() {
    Log.ger('start', 'printer_disconnect');

    return p.disconnect();
  }

  /// Draw image to printer.
  ///
  /// Return the progress (in percentage) of the drawing
  Stream<double> draw(Uint8List image) {
    Log.out('start', 'printer_draw');

    return p.draw(image);
  }

  /// Connected printer has a higher priority
  int compareTo(Printer other) {
    int myScore = 0;
    if (connected) {
      myScore -= 2;
    }
    if (autoConnect) {
      myScore -= 1;
    }

    int otherScore = 0;
    if (other.connected) {
      otherScore -= 2;
    }
    if (other.autoConnect) {
      otherScore -= 1;
    }

    // default using ascending order, so smaller score is better
    return myScore.compareTo(otherScore);
  }
}

class PrinterObject extends ModelObject<Printer> {
  final String? id;
  final String? name;
  final String? address;
  final bool? autoConnect;
  final int? provider;

  PrinterObject({
    this.id,
    this.name,
    this.address,
    this.autoConnect,
    this.provider,
  });

  @override
  Map<String, Object> toMap() {
    return {
      'name': name!,
      'address': address!,
      'autoConnect': autoConnect!,
      'provider': provider!,
    };
  }

  @override
  Map<String, Object> diff(Printer model) {
    final result = <String, Object>{};
    final prefix = model.prefix;

    if (name != null && name != model.name) {
      model.name = name!;
      result['$prefix.name'] = name!;
    }
    if (address != null && address != model.address) {
      model.address = address!;
      result['$prefix.address'] = address!;
    }
    if (autoConnect != null && autoConnect != model.autoConnect) {
      model.autoConnect = autoConnect!;
      result['$prefix.autoConnect'] = autoConnect!;
    }
    if (provider != null && provider != model.provider.index) {
      model.provider = PrinterProvider.values[provider!];
      result['$prefix.provider'] = provider!;
    }

    return result;
  }

  factory PrinterObject.build(Map<String, Object?> data) {
    return PrinterObject(
      id: data['id'] as String,
      name: data['name'] as String,
      address: data['address'] as String,
      autoConnect: data['autoConnect'] as bool,
      provider: data['provider'] as int,
    );
  }
}

enum PrinterProvider {
  cat1(bt.CatPrinter(feedPaperByteSize: 1)),
  cat2(bt.CatPrinter(feedPaperByteSize: 2));

  final PrinterManufactory manufactory;

  const PrinterProvider(this.manufactory);

  static PrinterProvider? tryGuess(String name) {
    final v = (PrinterManufactory.tryGuess(name)).toString();

    return PrinterProvider.values.firstWhereOrNull((e) => e.manufactory.toString() == v);
  }
}
