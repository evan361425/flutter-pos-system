import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

String documentIdFromCurrentDate() => DateTime.now().toIso8601String();

class Collections {
  static const menu = 'menu';
}

/**
 * This is the main class access/call for any UI widgets that require to perform
 * any CRUD activities operation in Firestore database.
 */
class FirestoreDatabase {
  FirestoreDatabase({@required this.uid}) : assert(uid != null);
  final String uid;

  Future<DocumentSnapshot> get(String collection) {
    return FirebaseFirestore.instance
        .collection(collection)
        .doc(uid)
        .get();
  }

  Future<DocumentSnapshot> set(String collection, Map<String, dynamic> data) {
    return FirebaseFirestore.instance
        .collection(collection)
        .doc(uid)
        .set(data);
  }

  Future<void> update(String collection, Map<String, dynamic> data) {
    return FirebaseFirestore.instance
        .collection(collection)
        .doc(uid)
        .update(data);
  }

  Stream getStream(String collection) {
    return FirebaseFirestore.instance
        .collection(collection)
        .doc(uid)
        .snapshots();
  }
}
