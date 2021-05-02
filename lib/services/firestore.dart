import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:possystem/services/database.dart';

/// This is the main class access/call for any UI widgets that require to perform
/// any CRUD activities operation in Firestore database.
class Firestore extends Database<FirestoreSnapshot> {
  final String uid;
  Firestore({@required this.uid}) : assert(uid != null);

  @override
  Future<FirestoreSnapshot> get(Collections collection) async {
    final snapshot = await FirebaseFirestore.instance
        .collection(CollectionName[collection])
        .doc(uid)
        .get();
    return FirestoreSnapshot(snapshot.data());
  }

  Stream getStream(String collection) {
    return FirebaseFirestore.instance
        .collection(CollectionName[collection])
        .doc(uid)
        .snapshots();
  }

  @override
  Future<void> set(Collections collection, Map<String, dynamic> data) {
    return FirebaseFirestore.instance
        .collection(CollectionName[collection])
        .doc(uid)
        .set(data);
  }

  @override
  Future<void> update(Collections collection, Map<String, dynamic> data) {
    data.entries.forEach((element) {
      if (element.value == null) data[element.key] = FieldValue.delete();
    });

    return FirebaseFirestore.instance
        .collection(CollectionName[collection])
        .doc(uid)
        .update(data);
  }

  @override
  Future<void> push(Collections collection, Map<String, dynamic> data) {
    throw UnimplementedError();
  }

  @override
  Future<FirestoreSnapshot> pop(Collections collection, [remove = true]) {
    throw UnimplementedError();
  }

  @override
  Future<int> length(Collections collection) {
    // TODO: implement length
    throw UnimplementedError();
  }
}

class FirestoreSnapshot extends Snapshot {
  FirestoreSnapshot(this.values);

  final Map<String, dynamic> values;

  @override
  Map<String, dynamic> data() {
    return values;
  }
}
