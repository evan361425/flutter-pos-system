import 'package:flutter/foundation.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/tables/dining_table.dart';
import 'package:possystem/models/tables/room.dart';
import 'package:possystem/services/database.dart';

/// Facade for room / dining-table CRUD and occupancy status.
///
/// Owns every SQLite read/write on `rooms` and `dining_tables`. Callers (Cart
/// stash/checkout hooks, Floor Plan UI) must go through this service — never
/// query those tables directly (Law 1.2 / 1.3).
///
/// Extends [ChangeNotifier] so the Floor Plan can rebuild when a table flips
/// between [TableStatus.available] and [TableStatus.occupied].
class TableManagerService extends ChangeNotifier {
  TableManagerService._();

  static final TableManagerService instance = TableManagerService._();

  static const String roomsTable = 'rooms';
  static const String tablesTable = 'dining_tables';

  Database get _db => Database.instance;

  // ---------------------------------------------------------------------------
  // Rooms
  // ---------------------------------------------------------------------------

  /// All rooms ordered by [Room.sequence] ascending.
  Future<List<Room>> getRooms() async {
    final rows = await _db.query(roomsTable, orderBy: 'sequence ASC, name ASC');
    return rows.map(Room.fromMap).toList();
  }

  /// Single room by UUID, or null if missing.
  Future<Room?> getRoom(String id) async {
    final rows = await _db.query(
      roomsTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Room.fromMap(rows.first);
  }

  /// Insert or update a [Room]. Generates a UUID when [Room.id] is new.
  Future<void> saveRoom(Room room) async {
    final existing = await getRoom(room.id);
    if (existing == null) {
      await _db.push(roomsTable, room.toMap());
      Log.ger('table_room_create', {'id': room.id, 'name': room.name});
    } else {
      await _db.update(roomsTable, room.id, room.toMap());
      Log.ger('table_room_update', {'id': room.id, 'name': room.name});
    }
    notifyListeners();
  }

  /// Deletes a room and every dining table belonging to it.
  Future<void> deleteRoom(String id) async {
    await _db.transaction((txn) async {
      await txn.delete(tablesTable, where: 'room_id = ?', whereArgs: [id]);
      await txn.delete(roomsTable, where: 'id = ?', whereArgs: [id]);
    });
    Log.ger('table_room_delete', {'id': id});
    notifyListeners();
  }

  /// Persists a new display order for rooms ([orderedIds] = room UUIDs).
  Future<void> reorderRooms(List<String> orderedIds) async {
    if (orderedIds.isEmpty) return;

    final data = <Map<String, Object?>>[
      for (var i = 0; i < orderedIds.length; i++) {'sequence': i},
    ];
    final whereArgs = <List<Object>>[
      for (final id in orderedIds) [id],
    ];

    await _db.batchUpdate(
      roomsTable,
      data,
      where: 'id = ?',
      whereArgs: whereArgs,
    );
    Log.ger('table_room_reorder', {'count': orderedIds.length});
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Dining tables
  // ---------------------------------------------------------------------------

  /// Tables, optionally filtered by [roomId], ordered by name.
  Future<List<DiningTable>> getTables({String? roomId}) async {
    final rows = roomId == null
        ? await _db.query(tablesTable, orderBy: 'name ASC')
        : await _db.query(
            tablesTable,
            where: 'room_id = ?',
            whereArgs: [roomId],
            orderBy: 'name ASC',
          );
    return rows.map(DiningTable.fromMap).toList();
  }

  /// Single table by UUID, or null if missing.
  Future<DiningTable?> getTable(String id) async {
    final rows = await _db.query(
      tablesTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return DiningTable.fromMap(rows.first);
  }

  /// Insert or update a [DiningTable].
  Future<void> saveTable(DiningTable table) async {
    final existing = await getTable(table.id);
    if (existing == null) {
      await _db.push(tablesTable, table.toMap());
      Log.ger('table_create', {
        'id': table.id,
        'roomId': table.roomId,
        'name': table.name,
      });
    } else {
      await _db.update(tablesTable, table.id, table.toMap());
      Log.ger('table_update', {
        'id': table.id,
        'roomId': table.roomId,
        'name': table.name,
      });
    }
    notifyListeners();
  }

  /// Deletes a single dining table by UUID.
  Future<void> deleteTable(String id) async {
    await _db.delete(tablesTable, id);
    Log.ger('table_delete', {'id': id});
    notifyListeners();
  }

  /// Flip occupancy status (stash → occupied, checkout → available).
  Future<void> updateTableStatus(String tableId, TableStatus status) async {
    await _db.update(tablesTable, tableId, {'status': status.sqlValue});
    Log.ger('table_status', {'id': tableId, 'status': status.sqlValue});
    notifyListeners();
  }
}
