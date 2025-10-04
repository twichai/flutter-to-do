import '../../../../core/error/failure.dart';
import '../../../../data/database/app_database.dart';
import '../../domain/entities/todo_entity.dart';
import 'todo_repository.dart';

class TodoRepositoryImpl implements TodoRepository {
  final AppDatabase database;

  const TodoRepositoryImpl(this.database);

  @override
  Future<List<TodoEntity>> getTodos() async {
    try {
      final todos = await database.todoDao.getAllTodos();
      return todos.map(_mapToEntity).toList();
    } catch (e) {
      throw DatabaseFailure('Failed to get todos: $e');
    }
  }

  @override
  Future<TodoEntity> addTodo(String title) async {
    try {
      final companion = TodoTableCompanion.insert(title: title);
      final id = await database.todoDao.insertTodo(companion);

      // Return the created todo
      return TodoEntity(id: id, title: title, completed: false);
    } catch (e) {
      throw DatabaseFailure('Failed to add todo: $e');
    }
  }

  @override
  Future<TodoEntity> updateTodo(TodoEntity todo) async {
    try {
      final tableData = TodoTableData(
        id: todo.id,
        title: todo.title,
        completed: todo.completed,
      );

      await database.todoDao.updateTodo(tableData);
      return todo;
    } catch (e) {
      throw DatabaseFailure('Failed to update todo: $e');
    }
  }

  @override
  Future<void> deleteTodo(int id) async {
    try {
      await database.todoDao.deleteTodo(id);
    } catch (e) {
      throw DatabaseFailure('Failed to delete todo: $e');
    }
  }

  @override
  Stream<List<TodoEntity>> watchTodos() {
    try {
      return database.todoDao.watchAllTodos().map(
        (todos) => todos.map(_mapToEntity).toList(),
      );
    } catch (e) {
      throw DatabaseFailure('Failed to watch todos: $e');
    }
  }

  // Helper method to map database model to domain entity
  TodoEntity _mapToEntity(TodoTableData data) {
    return TodoEntity(
      id: data.id,
      title: data.title,
      completed: data.completed,
    );
  }
}
