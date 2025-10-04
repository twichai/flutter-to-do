import 'package:flutter_test/flutter_test.dart';
import 'package:demo_todo/core/error/failure.dart';
import 'package:demo_todo/core/usecases/usecase.dart';
import 'package:demo_todo/features/todo/domain/entities/todo_entity.dart';
import 'package:demo_todo/features/todo/domain/usecases/get_todos_usecase.dart';
import 'package:demo_todo/features/todo/domain/usecases/add_todo_usecase.dart';
import 'package:demo_todo/features/todo/domain/usecases/update_todo_usecase.dart';
import 'package:demo_todo/features/todo/domain/usecases/delete_todo_usecase.dart';
import 'package:demo_todo/features/todo/data/repositories/todo_repository.dart';

// Simple mock repository for testing without complex dependencies
class MockTodoRepository implements TodoRepository {
  final List<TodoEntity> _todos = [];
  int _nextId = 1;

  @override
  Future<List<TodoEntity>> getTodos() async {
    return List.from(_todos);
  }

  @override
  Future<TodoEntity> addTodo(String title) async {
    final todo = TodoEntity(id: _nextId++, title: title);
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
    throw const DatabaseFailure('Todo not found');
  }

  @override
  Future<void> deleteTodo(int id) async {
    _todos.removeWhere((todo) => todo.id == id);
  }

  @override
  Stream<List<TodoEntity>> watchTodos() {
    return Stream.value(List.from(_todos));
  }

  // Helper methods for testing
  void clear() {
    _todos.clear();
    _nextId = 1;
  }

  void throwError() {
    throw const DatabaseFailure('Test error');
  }
}

void main() {
  late MockTodoRepository mockRepository;
  late GetTodosUseCase getTodosUseCase;
  late AddTodoUseCase addTodoUseCase;
  late UpdateTodoUseCase updateTodoUseCase;
  late DeleteTodoUseCase deleteTodoUseCase;

  setUp(() {
    mockRepository = MockTodoRepository();
    getTodosUseCase = GetTodosUseCase(mockRepository);
    addTodoUseCase = AddTodoUseCase(mockRepository);
    updateTodoUseCase = UpdateTodoUseCase(mockRepository);
    deleteTodoUseCase = DeleteTodoUseCase(mockRepository);
  });

  tearDown(() {
    mockRepository.clear();
  });

  group('GetTodosUseCase', () {
    test('should return empty list when no todos exist', () async {
      // Act
      final result = await getTodosUseCase.call();

      // Assert
      expect(result, isA<Success<List<TodoEntity>, Failure>>());
      expect(result.value, isEmpty);
    });

    test('should return list of todos when todos exist', () async {
      // Arrange
      await mockRepository.addTodo('Todo 1');
      await mockRepository.addTodo('Todo 2');

      // Act
      final result = await getTodosUseCase.call();

      // Assert
      expect(result, isA<Success<List<TodoEntity>, Failure>>());
      expect(result.value, hasLength(2));
      expect(result.value?[0].title, 'Todo 1');
      expect(result.value?[1].title, 'Todo 2');
    });
  });

  group('AddTodoUseCase', () {
    test('should add todo successfully with valid title', () async {
      // Arrange
      const params = AddTodoParams(title: 'New Todo');

      // Act
      final result = await addTodoUseCase.call(params);

      // Assert
      expect(result, isA<Success<TodoEntity, Failure>>());
      expect(result.value?.title, 'New Todo');
      expect(result.value?.completed, false);
      expect(result.value?.id, greaterThan(0));

      // Verify it was actually added
      final allTodos = await mockRepository.getTodos();
      expect(allTodos, hasLength(1));
    });

    test('should return error when title is empty', () async {
      // Arrange
      const params = AddTodoParams(title: '');

      // Act
      final result = await addTodoUseCase.call(params);

      // Assert
      expect(result, isA<Error<TodoEntity, Failure>>());
      expect(result.error, isA<DatabaseFailure>());

      // Verify nothing was added
      final allTodos = await mockRepository.getTodos();
      expect(allTodos, isEmpty);
    });

    test('should return error when title is only whitespace', () async {
      // Arrange
      const params = AddTodoParams(title: '   ');

      // Act
      final result = await addTodoUseCase.call(params);

      // Assert
      expect(result, isA<Error<TodoEntity, Failure>>());
      expect(result.error, isA<DatabaseFailure>());
    });

    test('should trim whitespace from title', () async {
      // Arrange
      const params = AddTodoParams(title: '  Clean Title  ');

      // Act
      final result = await addTodoUseCase.call(params);

      // Assert
      expect(result, isA<Success<TodoEntity, Failure>>());
      // The repository should receive the trimmed title
      final allTodos = await mockRepository.getTodos();
      expect(allTodos[0].title, 'Clean Title');
    });
  });

  group('UpdateTodoUseCase', () {
    test('should update todo successfully', () async {
      // Arrange
      final addedTodo = await mockRepository.addTodo('Original Title');
      final updatedTodo = addedTodo.copyWith(
        title: 'Updated Title',
        completed: true,
      );

      // Act
      final result = await updateTodoUseCase.call(updatedTodo);

      // Assert
      expect(result, isA<Success<TodoEntity, Failure>>());
      expect(result.value?.title, 'Updated Title');
      expect(result.value?.completed, true);

      // Verify it was actually updated
      final allTodos = await mockRepository.getTodos();
      expect(allTodos[0].title, 'Updated Title');
      expect(allTodos[0].completed, true);
    });

    test('should return error when todo has empty title', () async {
      // Arrange
      const invalidTodo = TodoEntity(id: 1, title: '', completed: false);

      // Act
      final result = await updateTodoUseCase.call(invalidTodo);

      // Assert
      expect(result, isA<Error<TodoEntity, Failure>>());
      expect(result.error, isA<DatabaseFailure>());
    });

    test('should toggle completion status', () async {
      // Arrange
      final originalTodo = await mockRepository.addTodo('Test Todo');
      final toggledTodo = originalTodo.toggleCompleted();

      // Act
      final result = await updateTodoUseCase.call(toggledTodo);

      // Assert
      expect(result, isA<Success<TodoEntity, Failure>>());
      expect(result.value?.completed, true);

      final allTodos = await mockRepository.getTodos();
      expect(allTodos[0].completed, true);
    });
  });

  group('DeleteTodoUseCase', () {
    test('should delete todo successfully', () async {
      // Arrange
      await mockRepository.addTodo('Todo to Delete');
      const params = DeleteTodoParams(id: 1);

      // Act
      final result = await deleteTodoUseCase.call(params);

      // Assert
      expect(result, isA<Success<void, Failure>>());

      // Verify it was actually deleted
      final allTodos = await mockRepository.getTodos();
      expect(allTodos, isEmpty);
    });

    test('should handle deletion of non-existent todo gracefully', () async {
      // Arrange
      const params = DeleteTodoParams(id: 999);

      // Act
      final result = await deleteTodoUseCase.call(params);

      // Assert
      expect(result, isA<Success<void, Failure>>());
    });

    test('should delete correct todo when multiple exist', () async {
      // Arrange
      await mockRepository.addTodo('Todo 1'); // id: 1
      await mockRepository.addTodo('Todo 2'); // id: 2
      await mockRepository.addTodo('Todo 3'); // id: 3

      const params = DeleteTodoParams(id: 2);

      // Act
      final result = await deleteTodoUseCase.call(params);

      // Assert
      expect(result, isA<Success<void, Failure>>());

      // Verify correct todo was deleted
      final allTodos = await mockRepository.getTodos();
      expect(allTodos, hasLength(2));
      expect(allTodos[0].title, 'Todo 1');
      expect(allTodos[1].title, 'Todo 3');
    });
  });

  group('Integration tests', () {
    test('should support complete CRUD workflow', () async {
      // Create
      final addResult = await addTodoUseCase.call(
        const AddTodoParams(title: 'Integration Test Todo'),
      );
      expect(addResult, isA<Success<TodoEntity, Failure>>());
      final todoId = addResult.value!.id;

      // Read
      final getResult = await getTodosUseCase.call();
      expect(getResult, isA<Success<List<TodoEntity>, Failure>>());
      expect(getResult.value, hasLength(1));

      // Update
      final originalTodo = getResult.value![0];
      final updatedTodo = originalTodo.copyWith(
        title: 'Updated Integration Test',
        completed: true,
      );
      final updateResult = await updateTodoUseCase.call(updatedTodo);
      expect(updateResult, isA<Success<TodoEntity, Failure>>());

      // Verify update
      final getAfterUpdate = await getTodosUseCase.call();
      expect(getAfterUpdate.value![0].title, 'Updated Integration Test');
      expect(getAfterUpdate.value![0].completed, true);

      // Delete
      final deleteResult = await deleteTodoUseCase.call(
        DeleteTodoParams(id: todoId),
      );
      expect(deleteResult, isA<Success<void, Failure>>());

      // Verify deletion
      final getFinal = await getTodosUseCase.call();
      expect(getFinal.value, isEmpty);
    });

    test('should handle multiple todos correctly', () async {
      // Add multiple todos
      await addTodoUseCase.call(const AddTodoParams(title: 'First Todo'));
      await addTodoUseCase.call(const AddTodoParams(title: 'Second Todo'));
      await addTodoUseCase.call(const AddTodoParams(title: 'Third Todo'));

      // Verify all added
      final result = await getTodosUseCase.call();
      expect(result.value, hasLength(3));

      // Update middle todo
      final todos = result.value!;
      final updatedSecond = todos[1].copyWith(completed: true);
      await updateTodoUseCase.call(updatedSecond);

      // Delete first todo
      await deleteTodoUseCase.call(DeleteTodoParams(id: todos[0].id));

      // Verify final state
      final finalResult = await getTodosUseCase.call();
      expect(finalResult.value, hasLength(2));
      expect(finalResult.value![0].title, 'Second Todo');
      expect(finalResult.value![0].completed, true);
      expect(finalResult.value![1].title, 'Third Todo');
    });

    test('should handle edge cases in workflow', () async {
      // Try to add invalid todos
      final emptyResult = await addTodoUseCase.call(
        const AddTodoParams(title: ''),
      );
      expect(emptyResult, isA<Error<TodoEntity, Failure>>());

      final whitespaceResult = await addTodoUseCase.call(
        const AddTodoParams(title: '   '),
      );
      expect(whitespaceResult, isA<Error<TodoEntity, Failure>>());

      // Add valid todo
      await addTodoUseCase.call(const AddTodoParams(title: 'Valid Todo'));

      // Try to update with invalid title
      const invalidUpdate = TodoEntity(id: 1, title: '', completed: true);
      final updateResult = await updateTodoUseCase.call(invalidUpdate);
      expect(updateResult, isA<Error<TodoEntity, Failure>>());

      // Original should remain unchanged
      final getResult = await getTodosUseCase.call();
      expect(getResult.value![0].title, 'Valid Todo');
      expect(getResult.value![0].completed, false);
    });
  });
}
