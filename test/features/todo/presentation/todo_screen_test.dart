import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riv_todo_adv_example/features/todo/data/database_todo_repository.dart';
import 'package:riv_todo_adv_example/features/todo/domain/todo.dart';
import 'package:riv_todo_adv_example/features/todo/presentation/todo_screen.dart';

/// A testing utility which creates a [ProviderContainer] and automatically
/// disposes it at the end of the test.
ProviderContainer createContainer({
  ProviderContainer? parent,
  List<Override> overrides = const [],
  List<ProviderObserver>? observers,
}) {
  // Create a ProviderContainer, and optionally allow specifying parameters.
  final container = ProviderContainer(
    parent: parent,
    overrides: overrides,
    observers: observers,
  );

  // When the test ends, dispose the container.
  addTearDown(container.dispose);

  return container;
}

class MockTodoRepository implements DatabaseTodoRepository {
  final List<Todo> _todos = [
    const Todo(title: "Test", description: "Test"),
  ];

  final bool getTodosSuccess;
  final bool addTodoSuccess;

  MockTodoRepository(
      {required this.getTodosSuccess, required this.addTodoSuccess});

  @override
  Future<void> addTodo({required Todo todo}) async {
    await Future.delayed(const Duration(milliseconds: 50));
    if (!addTodoSuccess) throw Exception("Fake exception");
    return _todos.add(todo);
  }

  @override
  Stream<List<Todo>> getTodos() {
    if (!getTodosSuccess) return Stream.error(Exception("Fake exception"));
    return Stream.periodic(
      Durations.short1,
      (_) => _todos,
    );
  }
}

void main() {
  group('Test todos feature', () {
    group('Test reading todos', () {
      testWidgets('Test getting todos (success)', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              databaseTodoRepositoryProvider.overrideWithValue(
                MockTodoRepository(getTodosSuccess: true, addTodoSuccess: true),
              ),
            ],
            child: const MaterialApp(home: TodoScreen()),
          ),
        );
        // Assert loading state
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Act
        await tester.pumpAndSettle(); // Allow the future to complete

        // Assert data state
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text('Test'),
            findsNWidgets(2)); // Title and description both contain 'Test'
      });
      testWidgets('Test getting todos (failure)', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              databaseTodoRepositoryProvider.overrideWithValue(
                MockTodoRepository(
                    getTodosSuccess: false, addTodoSuccess: true),
              ),
            ],
            child: const MaterialApp(home: TodoScreen()),
          ),
        );
        // Assert loading state
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Act
        await tester.pumpAndSettle(); // Allow the future to complete

        expect(find.text('Test'),
            findsNothing); // Title and description both contain 'Test'

        // Assert data state
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.textContaining('Fake exception'), findsOneWidget);
      });
    });

    group('Test writing todos', () {
      testWidgets('Test adding todo (success)', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              databaseTodoRepositoryProvider.overrideWithValue(
                MockTodoRepository(getTodosSuccess: true, addTodoSuccess: true),
              ),
            ],
            child: const MaterialApp(home: TodoScreen()),
          ),
        );

        // Wait for the initial todos to load
        await tester.pumpAndSettle();

        expect(find.text('Test'),
            findsNWidgets(2)); // Title and description both contain 'Test'
        // Assert the button is enabled initially
        expect(find.byType(ElevatedButton), findsOneWidget);
        expect(
            tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled,
            isTrue);

        // Tap the add button
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump(); // Start the add todo process

        // Assert the button is disabled immediately after click
        expect(
            tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled,
            isFalse);

        // Wait for the add todo process to complete
        await tester.pump(const Duration(milliseconds: 100));

        // Assert the success message is shown
        expect(find.text('Todo added successfully'), findsOneWidget);
        // Assert the button is enabled again
        expect(
            tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled,
            isTrue);

        // Wait for the add todo process to complete
        await tester.pumpAndSettle();

        // Assert new todo added
        expect(find.text('Test'),
            findsNWidgets(2)); // Title and description both contain 'Test'
        expect(find.text('Random Title'), findsOneWidget); // newly added todo
      });

      testWidgets('Test adding todo (failure)', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              databaseTodoRepositoryProvider.overrideWithValue(
                MockTodoRepository(
                    getTodosSuccess: true, addTodoSuccess: false),
              ),
            ],
            child: const MaterialApp(home: TodoScreen()),
          ),
        );

        // Wait for the initial todos to load
        await tester.pumpAndSettle();

        expect(find.text('Test'),
            findsNWidgets(2)); // Title and description both contain 'Test'
        // Assert the button is enabled initially
        expect(find.byType(ElevatedButton), findsOneWidget);
        expect(
            tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled,
            isTrue);

        // Tap the add button
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump(); // Start the add todo process

        // Assert the button is disabled immediately after click
        expect(
            tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled,
            isFalse);

        // Wait for the add todo process to complete
        await tester.pump(const Duration(milliseconds: 100));

        // Assert the success message is shown
        expect(find.textContaining('Error'), findsOneWidget);
        // Assert the button is enabled again
        expect(
            tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled,
            isTrue);

        // Wait for the add todo process to complete
        await tester.pumpAndSettle();

        // Assert new todo added
        expect(find.text('Test'),
            findsNWidgets(2)); // Title and description both contain 'Test'
        expect(find.text('Random Title'), findsNothing); // newly added todo
      });
    });
  });
}
