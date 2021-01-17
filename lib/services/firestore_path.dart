/*
This class defines all the possible read/write locations from the Firestore database.
In future, any new path can be added here.
This class work together with FirestoreService and FirestoreDatabase.
 */

class FirestorePath {
  static String todo(String uid, String todoId) => 'users/$uid/todos/$todoId';
  static String todos(String uid) => 'users/$uid/todos';
}
