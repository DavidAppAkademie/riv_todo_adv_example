import 'package:riv_todo_adv_example/features/todo/domain/todo.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'database_todo_repository.g.dart';

// this is the instance of the abstract repository that will be used in the UI
// in main.dart we will override this with the concrete implementation (FirestoreTodoRepository)
@Riverpod(keepAlive: true)
DatabaseTodoRepository databaseTodoRepository(DatabaseTodoRepositoryRef ref) {
  // * Override this in the main method
  throw UnimplementedError();
}

// this is the abstract repository that will be used in the UI
abstract class DatabaseTodoRepository {
  const DatabaseTodoRepository();
  Future<void> addTodo({required Todo todo});
  Stream<List<Todo>> getTodos();
}
