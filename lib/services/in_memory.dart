import 'package:flutter/material.dart';
import 'package:possystem/services/database.dart';

/// This is the main class access/call for any UI widgets that require to perform
/// any CRUD activities operation in Firestore database.
class InMemory extends Document<InMemorySnapshot> {
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
        'data': [data],
      };
    } else {
      queue['data'].add(data);
    }
    print('${CollectionName[collection]} length: ${_data[collection].length}');
  }

  @override
  Future<InMemorySnapshot> pop(Collections collection, [remove = true]) async {
    final queue = _data[collection] ?? {'data': []};
    final List<Map<String, dynamic>> data = queue['data'];
    final value =
        data.isEmpty ? null : (remove ? data.removeLast() : data.last);

    print('${CollectionName[collection]} length: ${data.length}');

    return InMemorySnapshot(value);
  }

  @override
  Future<int> length(Collections collection) async {
    final queue = _data[collection];
    return queue == null ? 0 : (queue['data'].length);
  }
}

class InMemorySnapshot extends Snapshot {
  InMemorySnapshot(this._data);
  final Map<String, dynamic> _data;

  @override
  Map<String, dynamic> data() => _data;
}
