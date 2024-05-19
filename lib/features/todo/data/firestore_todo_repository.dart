import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riv_todo_adv_example/config/values.dart';
import 'package:riv_todo_adv_example/features/todo/data/database_todo_repository.dart';
import 'package:riv_todo_adv_example/features/todo/domain/todo.dart';

class FirestoreTodoRepository implements DatabaseTodoRepository {
  final FirebaseFirestore _firestore;

  FirestoreTodoRepository(this._firestore) {
    // useEmulators is a global setting for us to use emulators throughout the whole app
    if (useEmulators) {
      _firestore.useFirestoreEmulator(
          emulatorsLocalhostAddress, emulatorsFirestorePort);
    }
  }

  @override
  Future<void> addTodo({required Todo todo}) async {
    await Future.delayed(const Duration(seconds: 1));
    await _firestore.collection('todos').add(todo.toJson());
  }

  @override
  Stream<List<Todo>> getTodos() {
    return _firestore.collection('todos').snapshots().map((snapshot) {
      return snapshot.docs
          .map(
              (documentSnapshot) => Todo.fromDocumentSnapshot(documentSnapshot))
          .toList();
    });
  }
}
