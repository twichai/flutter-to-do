import 'package:flutter_test/flutter_test.dart';
import 'package:demo_todo/features/todo/domain/usecases/add_todo_usecase.dart';
import 'package:demo_todo/features/todo/domain/entities/todo_entity.dart';
import 'package:demo_todo/features/todo/data/repositories/todo_repository.dart';
import 'package:demo_todo/core/usecases/usecase.dart';
import 'package:demo_todo/core/error/failure.dart';

class InMemoryTodoRepository implements TodoRepository {
  final List<TodoEntity> _todos = [];
  int _idCounter = 1;

  @override
  Future<TodoEntity> addTodo(String title) async {
    final todo = TodoEntity(id: _idCounter++, title: title, completed: false);
    _todos.add(todo);
    return todo;
  }

  @override
  Future<List<TodoEntity>> getTodos() async {
    return List.unmodifiable(_todos);
  }

  @override
  Future<TodoEntity> updateTodo(TodoEntity todo) async {
    final idx = _todos.indexWhere((t) => t.id == todo.id);
    if (idx == -1) throw DatabaseFailure('Todo not found');
    _todos[idx] = todo;
    return todo;
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
  late AddTodoUseCase useCase;
  late InMemoryTodoRepository repository;

  setUp(() {
    repository = InMemoryTodoRepository();
    useCase = AddTodoUseCase(repository);
  });

  test('should trim whitespace from title', () async {
    final result = await useCase(const AddTodoParams(title: '   Buy milk   '));
    expect(result.isSuccess, true);
    expect(result.value?.title, 'Buy milk');
  });

  test('should fail when title is empty after trimming', () async {
    final result = await useCase(const AddTodoParams(title: '    '));
    expect(result.isError, true);
    expect(result.error, isA<DatabaseFailure>());
    expect(
      (result.error as DatabaseFailure).message,
      contains('cannot be empty'),
    );
  });

  test('should add todo successfully', () async {
    final result = await useCase(const AddTodoParams(title: 'Read book'));
    expect(result.isSuccess, true);
    expect(result.value?.title, 'Read book');
    expect(result.value?.completed, false);
  });
}
