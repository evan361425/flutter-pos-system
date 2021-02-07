import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:possystem/models/catalog_model.dart';
import 'package:possystem/services/database.dart';
import 'package:provider/provider.dart';

class MenuModel extends ChangeNotifier {
  Map<String, CatalogModel> _catalogs;

  MenuModel(BuildContext context) {
    loadFromDb(context);
  }

  // I/O

  void loadFromDb(BuildContext context) async {
    var db = context.read<Database>();
    var snapshot = await db.get(Collections.menu);
    // TODO: handle exception
    _catalogs = buildFromMap(snapshot.data());

    notifyListeners();
  }

  Map<String, CatalogModel> buildFromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }

    try {
      var catalogs = data.map((key, value) {
        if (value is Map) {
          return MapEntry(key, CatalogModel.fromMap(key, value));
        } else {
          throw TypeError();
        }
      });

      return catalogs;
    } catch (err) {
      Logger().e(err);
      // TODO: error handler
      return null;
    }
  }

  Map<String, dynamic> toMap() {
    return _catalogs.map((key, CatalogModel catalog) {
      return MapEntry(key, catalog.toMap());
    });
  }

  // STATE CHANGER

  Future<void> add(CatalogModel catalog, BuildContext context) async {
    if (!catalog.isReady) throw UnsupportedError('Catalog is not ready');

    final db = context.read<Database>();
    await db.update(Collections.menu, {
      catalog.name: catalog.toMap(),
    });

    _catalogs[catalog.name] = catalog;
    notifyListeners();

    return catalog;
  }

  // HELPER

  bool isReady() => _catalogs != null;

  bool has(String key) {
    return _catalogs.containsKey(key);
  }

  // SETTER

  void changeCatalog({String oldName, String newName}) {
    if (oldName != newName) {
      _catalogs[newName] = _catalogs[oldName];
      _catalogs.remove(oldName);
    }

    notifyListeners();
  }

  // GETTER

  List<CatalogModel> get catalogs {
    final catalogs = _catalogs.values.toList();
    catalogs.sort((a, b) => a.index.compareTo(b.index));
    return catalogs;
  }

  int get length => _catalogs.length;
}
