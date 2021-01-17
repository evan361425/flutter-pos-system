import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:possystem/models/todo_model.dart';
import 'package:possystem/services/firestore_path.dart';
import 'package:possystem/services/firestore_service.dart';

String documentIdFromCurrentDate() => DateTime.now().toIso8601String();

/*
This is the main class access/call for any UI widgets that require to perform
any CRUD activities operation in Firestore database.
This class work hand-in-hand with FirestoreService and FirestorePath.

Notes:
For cases where you need to have a special method such as bulk update specifically
on a field, then is ok to use custom code and write it here. For example,
setAllTodoComplete is require to change all todos item to have the complete status
changed to true.

 */
class FirestoreDatabase {
  FirestoreDatabase({@required this.uid}) : assert(uid != null);
  final String uid;

  final _firestoreService = FirestoreService.instance;

  //Method to create/update todoModel
  Future<void> setTodo(TodoModel todo) async => await _firestoreService.setData(
        path: FirestorePath.todo(uid, todo.id),
        data: todo.toMap(),
      );

  //Method to delete todoModel entry
  Future<void> deleteTodo(TodoModel todo) async {
    await _firestoreService.deleteData(path: FirestorePath.todo(uid, todo.id));
  }

  //Method to retrieve todoModel object based on the given todoId
  Stream<TodoModel> todoStream({@required String todoId}) =>
      _firestoreService.documentStream(
        path: FirestorePath.todo(uid, todoId),
        builder: (data, documentId) => TodoModel.fromMap(data, documentId),
      );

  //Method to retrieve all todos item from the same user based on uid
  Stream<List<TodoModel>> todosStream() => _firestoreService.collectionStream(
        path: FirestorePath.todos(uid),
        builder: (data, documentId) => TodoModel.fromMap(data, documentId),
      );

  //Method to mark all todoModel to be complete
  Future<void> setAllTodoComplete() async {
    final batchUpdate = Firestore.instance.batch();

    final querySnapshot = await Firestore.instance
        .collection(FirestorePath.todos(uid))
        .getDocuments();

    for (DocumentSnapshot ds in querySnapshot.documents) {
      batchUpdate.updateData(ds.reference, {'complete': true});
    }
    await batchUpdate.commit();
  }

  Future<void> deleteAllTodoWithComplete() async {
    final batchDelete = Firestore.instance.batch();

    final querySnapshot = await Firestore.instance
        .collection(FirestorePath.todos(uid))
        .where('complete', isEqualTo: true)
        .getDocuments();

    for (DocumentSnapshot ds in querySnapshot.documents) {
      batchDelete.delete(ds.reference);
    }
    await batchDelete.commit();
  }
}
