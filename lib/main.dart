import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riv_todo_adv_example/app.dart';
import 'package:riv_todo_adv_example/firebase_options.dart';
import 'package:riv_todo_adv_example/todo/data/database_todo_repository.dart';
import 'package:riv_todo_adv_example/todo/data/firestore_todo_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // create one instance of Firestore to inject to all the database repositories
  final firestore = FirebaseFirestore.instance;

  // create a container to initially set the implementation of the abstract repository classes
  // in unit tests we can use this to override concrete implementations with mock implementations
  final container = ProviderContainer(
    overrides: [
      databaseTodoRepositoryProvider.overrideWithValue(
        FirestoreTodoRepository(firestore),
      ),
    ],
  );
  runApp(UncontrolledProviderScope(
    container: container,
    child: const App(),
  ));
}
