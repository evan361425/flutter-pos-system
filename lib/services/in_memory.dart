import 'package:flutter/material.dart';
import 'package:possystem/services/database.dart';

/// This is the main class access/call for any UI widgets that require to perform
/// any CRUD activities operation in Firestore database.
class InMemory extends Database<InMemorySnapshot> {
  final String uid;
  InMemory({
    @required this.uid,
    Map<Collections, Map<String, dynamic>> data,
  }) : _data = data ?? {};

  final Map<Collections, Map<String, dynamic>> _data;

  @override
  Future<InMemorySnapshot> get(Collections collection) async {
    return InMemorySnapshot(_data[collection]);
  }

  @override
  Future<void> set(Collections collection, Map<String, dynamic> data) {
    return Future.delayed(Duration(seconds: 0));
  }

  @override
  Future<void> update(Collections collection, Map<String, dynamic> data) {
    return Future.delayed(Duration(seconds: 0));
  }

  @override
  Future<void> push(Collections collection, Map<String, dynamic> data) async {
    final queue = _data[collection];
    if (queue == null) {
      _data[collection] = {
        QueueValue: [data],
        QueueLength: 1,
      };
    } else {
      queue[QueueValue].add(data);
      queue[QueueLength]++;
    }
    print('${CollectionName[collection]} length: ${queue[QueueLength]}');
  }

  @override
  Future<InMemorySnapshot> pop(Collections collection, [remove = true]) async {
    final queue = _data[collection];
    final List<Map<String, dynamic>> data =
        queue == null ? List.empty() : queue[QueueValue];
    final value =
        data.isEmpty ? null : (remove ? data.removeLast() : data.last);

    queue[QueueLength] = data.length;

    print('${CollectionName[collection]} length: ${queue[QueueLength]}');

    return InMemorySnapshot(value);
  }

  @override
  Future<int> length(Collections collection) async {
    final queue = _data[collection];
    return queue == null ? 0 : (queue[QueueLength] ?? 0);
  }
}

class InMemorySnapshot extends Snapshot {
  InMemorySnapshot(this._data);
  final Map<String, dynamic> _data;

  @override
  Map<String, dynamic> data() => _data;
}
