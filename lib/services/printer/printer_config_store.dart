import 'package:flutter/foundation.dart';
import 'package:possystem/models/printer_config.dart';
import 'package:possystem/services/storage.dart';

class PrinterConfigStore extends ChangeNotifier {
  PrinterConfigStore._();

  static final PrinterConfigStore instance = PrinterConfigStore._();

  static const String _record = 'managed_printer_configs';

  bool _initialized = false;
  bool get initialized => _initialized;

  final List<PrinterConfig> _items = [];

  List<PrinterConfig> get items => List.unmodifiable(_items);

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    await reload();
  }

  Future<void> reload() async {
    final data = await Storage.instance.get(Stores.printers, _record);
    _items
      ..clear()
      ..addAll(
        data.values
            .whereType<Map>()
            .map((e) => PrinterConfig.fromMap(Map<String, Object?>.from(e)))
            .where((e) => e.id.isNotEmpty),
      );
    _items.sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }

  Future<void> save(PrinterConfig config) async {
    final index = _items.indexWhere((e) => e.id == config.id);
    if (index == -1) {
      _items.add(config);
    } else {
      _items[index] = config;
    }
    _items.sort((a, b) => a.name.compareTo(b.name));

    await _persistAll();
    notifyListeners();
  }

  Future<void> delete(String id) async {
    _items.removeWhere((e) => e.id == id);
    await _persistAll();
    notifyListeners();
  }

  Future<void> _persistAll() {
    return Storage.instance.add(Stores.printers, _record, {
      for (final item in _items) item.id: item.toMap(),
    });
  }
}
