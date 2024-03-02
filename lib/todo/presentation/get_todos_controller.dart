import 'package:riv_todo_adv_example/todo/data/database_todo_repository.dart';
import 'package:riv_todo_adv_example/todo/domain/todo.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'get_todos_controller.g.dart';

// This is the controller that will be used in the UI to get the todos
// by wrapping this in a riverpod stream provider, Riverpod handles the lifecycle of the stream
// and we can use AsyncValue in the UI to handle the state of the stream
// controllers for READING stuff are really easy
@riverpod
Stream<List<Todo>> getTodosController(GetTodosControllerRef ref) {
  return ref.read(databaseTodoRepositoryProvider).getTodos();
}
