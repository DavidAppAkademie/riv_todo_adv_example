import 'package:riv_todo_adv_example/todo/data/database_todo_repository.dart';
import 'package:riv_todo_adv_example/todo/domain/todo.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'add_todo_controller.g.dart';

// This is the controller that will be used in the UI to add a todo
// Just copy paste this boiler plate whenever you need a controller to WRITE stuff
@riverpod
class AddTodoController extends _$AddTodoController {
  Object? _key;
  @override
  FutureOr<void> build() {
    _key = Object();
    ref.onDispose(() => _key = null);
  }

  Future<bool> addTodo(
    Todo todo,
  ) async {
    state = const AsyncLoading();
    final key = _key;
    final newState = await AsyncValue.guard(() {
      return _addTodo(
        todo,
      );
    });
    if (key == _key) {
      state = newState;
    }
    return !state.hasError;
  }

  Future<void> _addTodo(
    Todo todo,
  ) async {
    return ref.read(databaseTodoRepositoryProvider).addTodo(
          todo: todo,
        );
  }
}
