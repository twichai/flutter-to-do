import '../../domain/entities/todo_entity.dart';

abstract class TodoRepository {
  Future<List<TodoEntity>> getTodos();
  Future<TodoEntity> addTodo(String title);
  Future<TodoEntity> updateTodo(TodoEntity todo);
  Future<void> deleteTodo(int id);
  Stream<List<TodoEntity>> watchTodos();
}
