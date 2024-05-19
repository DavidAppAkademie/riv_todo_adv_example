import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riv_todo_adv_example/features/todo/domain/todo.dart';
import 'package:riv_todo_adv_example/features/todo/presentation/add_todo_controller.dart';
import 'package:riv_todo_adv_example/features/todo/presentation/get_todos_controller.dart';
import 'package:riv_todo_adv_example/utils/async_value_ui.dart';

class TodoScreen extends ConsumerWidget {
  const TodoScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.listen is just like ref.watch, but it does not rebuild the widget when the state changes
    // whenever the addTodoControllerProvider changes to an error state, it will show an alert dialog
    ref.listen<AsyncValue>(
      addTodoControllerProvider,
      (_, state) {
        state.showAlertDialogOnError(context);
      },
    );

    // we use this state to check if the addTodoControllerProvider is currently loading
    // if it is, we disable the button
    final addTodoState = ref.watch(addTodoControllerProvider);

    return SafeArea(
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Flexible(
                  flex: 3,
                  child: Center(
                    // now this is the benefit of using AsyncValue (or wrapping the Stream in a provider)
                    // no StreamBuilder needed
                    // instead we have an AsyncValue that enables us to use the 3 states: data, error, loading
                    child: ref.watch(getTodosControllerProvider).when(
                      data: (todoList) {
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: todoList.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(todoList[index].title),
                              subtitle: Text(todoList[index].description),
                            );
                          },
                        );
                      },
                      error: (error, stackTrace) {
                        return Center(child: Text('Error: $error'));
                      },
                      loading: () {
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Flexible(
                  flex: 1,
                  child: ElevatedButton(
                    // we disable the button when the addTodoControllerProvider is loading
                    onPressed: addTodoState.isLoading
                        ? null
                        : () async {
                            // bool result determines if the todo was added successfully
                            final result = await ref
                                .read(addTodoControllerProvider.notifier)
                                .addTodo(
                                  const Todo(
                                    title: 'Random Title',
                                    description: 'Random Description',
                                  ),
                                );
                            // show success message if the todo was added successfully
                            // no need to show an error message, because errors
                            // are handled by the `.listen` at the top of the build method
                            if (result) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Todo added successfully'),
                                  ),
                                );
                              }
                            }
                          },
                    child: const Text('Add Random Todo'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
