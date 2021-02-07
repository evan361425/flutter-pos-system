import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:possystem/services/database.dart';

/// This is the main class access/call for any UI widgets that require to perform
/// any CRUD activities operation in Firestore database.
class Firestore extends Database<DocumentSnapshot> {
  final String uid;
  Firestore({@required this.uid}) : assert(uid != null);

  @override
  Future<DocumentSnapshot> get(Collections collection) {
    return FirebaseFirestore.instance
        .collection(CollectionName[collection])
        .doc(uid)
        .get();
  }

  Stream getStream(String collection) {
    return FirebaseFirestore.instance
        .collection(CollectionName[collection])
        .doc(uid)
        .snapshots();
  }

  @override
  Future<DocumentSnapshot> set(
      Collections collection, Map<String, dynamic> data) {
    return FirebaseFirestore.instance
        .collection(CollectionName[collection])
        .doc(uid)
        .set(data);
  }

  @override
  Future<void> update(Collections collection, Map<String, dynamic> data) {
    return FirebaseFirestore.instance
        .collection(CollectionName[collection])
        .doc(uid)
        .update(data);
  }
}
