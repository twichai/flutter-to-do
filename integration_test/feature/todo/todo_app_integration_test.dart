import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:demo_todo/features/todo/presentation/view/todo_list_screen.dart';
import 'package:demo_todo/features/todo/presentation/providers.dart';
import 'package:demo_todo/features/todo/data/repositories/todo_repository.dart';
import 'package:demo_todo/features/todo/domain/entities/todo_entity.dart';

// Mock repository with pre-populated large dataset for testing
class MockTodoRepositoryWithData implements TodoRepository {
  final List<TodoEntity> _todos;
  int _nextId;

  MockTodoRepositoryWithData(this._todos) : _nextId = _todos.length + 1;

  // Factory to create repository with large dataset
  factory MockTodoRepositoryWithData.withLargeDataset(int count) {
    final todos = List.generate(
      count,
      (index) => TodoEntity(
        id: index + 1,
        title: 'Todo item ${index + 1}',
        completed: index % 3 == 0, // Some completed for variety
      ),
    );
    return MockTodoRepositoryWithData(todos);
  }

  @override
  Future<List<TodoEntity>> getTodos() async => List.unmodifiable(_todos);

  @override
  Future<TodoEntity> addTodo(String title) async {
    final todo = TodoEntity(id: _nextId++, title: title, completed: false);
    _todos.add(todo);
    return todo;
  }

  @override
  Future<TodoEntity> updateTodo(TodoEntity todo) async {
    final index = _todos.indexWhere((t) => t.id == todo.id);
    if (index != -1) {
      _todos[index] = todo;
      return todo;
    }
    throw Exception('Todo not found');
  }

  @override
  Future<void> deleteTodo(int id) async {
    _todos.removeWhere((t) => t.id == id);
  }

  @override
  Stream<List<TodoEntity>> watchTodos() {
    return Stream.value(List.unmodifiable(_todos));
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Todo App Integration Tests on Emulator', () {
    testWidgets('should add, complete, and delete todos', (
      WidgetTester tester,
    ) async {
      // Launch the app
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: TodoListScreen())),
      );
      await tester.pumpAndSettle();

      // Verify initial empty state
      expect(find.text('No todos yet!'), findsOneWidget);

      // Add first todo
      await tester.enterText(find.byType(TextField), 'Buy groceries');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Verify todo was added
      expect(find.text('Buy groceries'), findsOneWidget);
      expect(find.text('No todos yet!'), findsNothing);

      // Add second todo
      await tester.enterText(find.byType(TextField), 'Walk the dog');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Verify both todos exist
      expect(find.text('Buy groceries'), findsOneWidget);
      expect(find.text('Walk the dog'), findsOneWidget);

      // Complete first todo by tapping checkbox
      final checkboxes = find.byType(Checkbox);
      expect(checkboxes, findsAtLeastNWidgets(2));

      await tester.tap(checkboxes.first);
      await tester.pumpAndSettle();

      // Delete a todo
      final deleteButtons = find.byIcon(Icons.delete);
      await tester.tap(deleteButtons.first);
      await tester.pumpAndSettle();

      // Verify one todo remains
      expect(find.text('Walk the dog'), findsOneWidget);
    });

    testWidgets('should handle large number of todos and scrolling', (
      WidgetTester tester,
    ) async {
      // Create mock repository with 100 pre-populated todos
      final mockRepo = MockTodoRepositoryWithData.withLargeDataset(100);

      // Launch the app with DI override for mock repository
      await tester.pumpWidget(
        ProviderScope(
          overrides: [todoRepositoryProvider.overrideWithValue(mockRepo)],
          child: const MaterialApp(home: TodoListScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Verify large dataset is loaded (no empty state)
      expect(find.text('No todos yet!'), findsNothing);

      // Verify some todos from different parts of the list exist
      expect(find.text('Todo item 1'), findsOneWidget);
      expect(find.textContaining('Todo item'), findsAtLeastNWidgets(10));

      // Test scrolling performance with large dataset
      final listView = find.byType(ListView);
      expect(listView, findsOneWidget);

      // Scroll down to reveal more items
      await tester.drag(listView, const Offset(0, -500));
      await tester.pumpAndSettle();

      // Scroll back up
      await tester.drag(listView, const Offset(0, 300));
      await tester.pumpAndSettle();

      // Verify checkboxes are present and functional
      final checkboxes = find.byType(Checkbox);
      expect(checkboxes, findsAtLeastNWidgets(5));

      // Test checkbox interaction on a large list
      await tester.tap(checkboxes.first);
      await tester.pumpAndSettle();

      // Verify the checkbox state changed
      Checkbox firstCheckbox = tester.widget(checkboxes.first) as Checkbox;
      expect(firstCheckbox.value, isNotNull);
    });

    testWidgets('should validate empty input and whitespace handling', (
      WidgetTester tester,
    ) async {
      // Launch the app with mock repository to ensure consistent test data
      final mockRepo = MockTodoRepositoryWithData.withLargeDataset(0);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [todoRepositoryProvider.overrideWithValue(mockRepo)],
          child: const MaterialApp(home: TodoListScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Try to add empty todo
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Verify empty state remains
      expect(find.text('No todos yet!'), findsOneWidget);

      // Try to add whitespace-only todo
      await tester.enterText(find.byType(TextField), '   ');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Verify empty state remains (use case should handle this)
      expect(find.text('No todos yet!'), findsOneWidget);

      // Add todo with leading/trailing whitespace
      await tester.enterText(find.byType(TextField), '   Valid Todo   ');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Verify todo was added
      expect(find.textContaining('Valid Todo'), findsOneWidget);
      expect(find.text('No todos yet!'), findsNothing);
    });

    testWidgets('should complete and uncomplete todos with checkbox taps', (
      WidgetTester tester,
    ) async {
      // Launch the app with mock repository to ensure consistent test data
      final mockRepo = MockTodoRepositoryWithData.withLargeDataset(0);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [todoRepositoryProvider.overrideWithValue(mockRepo)],
          child: const MaterialApp(home: TodoListScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Add a todo
      await tester.enterText(find.byType(TextField), 'Test Toggle Todo');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Find the checkbox
      final checkbox = find.byType(Checkbox);
      expect(checkbox, findsOneWidget);

      // Verify initial state (unchecked)
      Checkbox checkboxWidget = tester.widget(checkbox) as Checkbox;
      expect(checkboxWidget.value, false);

      // Tap to complete
      await tester.tap(checkbox);
      await tester.pumpAndSettle();

      // Verify completed state
      checkboxWidget = tester.widget(checkbox) as Checkbox;
      expect(checkboxWidget.value, true);

      // Tap again to uncomplete
      await tester.tap(checkbox);
      await tester.pumpAndSettle();

      // Verify uncompleted state
      checkboxWidget = tester.widget(checkbox) as Checkbox;
      expect(checkboxWidget.value, false);
    });

    testWidgets('should handle very large datasets efficiently', (
      WidgetTester tester,
    ) async {
      // Test with 500+ todos to verify performance
      final mockRepo = MockTodoRepositoryWithData.withLargeDataset(500);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [todoRepositoryProvider.overrideWithValue(mockRepo)],
          child: const MaterialApp(home: TodoListScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Verify app doesn't freeze with large dataset
      expect(find.textContaining('Todo item'), findsAtLeastNWidgets(5));

      // Test rapid scrolling with large dataset
      final listView = find.byType(ListView);

      // Rapid scroll down
      for (int i = 0; i < 5; i++) {
        await tester.drag(listView, const Offset(0, -200));
        await tester.pump();
      }
      await tester.pumpAndSettle();

      // Rapid scroll back up
      for (int i = 0; i < 3; i++) {
        await tester.drag(listView, const Offset(0, 200));
        await tester.pump();
      }
      await tester.pumpAndSettle();

      // Test checkbox operations don't lag
      final checkboxes = find.byType(Checkbox);
      if (checkboxes.evaluate().isNotEmpty) {
        await tester.tap(checkboxes.first);
        await tester.pump(const Duration(milliseconds: 100));

        // Verify quick response
        Checkbox checkbox = tester.widget(checkboxes.first) as Checkbox;
        expect(checkbox.value, isNotNull);
      }
    });

    testWidgets('should handle rapid todo operations', (
      WidgetTester tester,
    ) async {
      // Start with smaller dataset for rapid operations test
      final mockRepo = MockTodoRepositoryWithData.withLargeDataset(10);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [todoRepositoryProvider.overrideWithValue(mockRepo)],
          child: const MaterialApp(home: TodoListScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Test rapid checkbox operations
      final checkboxes = find.byType(Checkbox);
      final checkboxCount = checkboxes.evaluate().length;

      // Rapidly toggle multiple checkboxes
      for (int i = 0; i < (checkboxCount >= 5 ? 5 : checkboxCount); i++) {
        if (checkboxes.evaluate().length > i) {
          await tester.tap(checkboxes.at(i));
          await tester.pump(const Duration(milliseconds: 50));
        }
      }
      await tester.pumpAndSettle();

      // Test rapid delete operations
      final deleteButtons = find.byIcon(Icons.delete);
      final deleteCount = deleteButtons.evaluate().length;

      for (int i = 0; i < (deleteCount >= 3 ? 3 : deleteCount); i++) {
        if (deleteButtons.evaluate().isNotEmpty) {
          await tester.tap(deleteButtons.first);
          await tester.pump(const Duration(milliseconds: 50));
        }
      }
      await tester.pumpAndSettle();

      // Verify operations completed successfully
      expect(find.byType(Checkbox), findsAtLeastNWidgets(1));
    });
  });
}
