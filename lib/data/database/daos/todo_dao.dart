import 'package:drift/drift.dart';
import '../app_database.dart';

part 'todo_dao.g.dart';

@DriftAccessor(tables: [TodoTable])
class TodoDao extends DatabaseAccessor<AppDatabase> with _$TodoDaoMixin {
  TodoDao(super.db);

  Future<List<TodoTableData>> getAllTodos() => select(todoTable).get();
  Stream<List<TodoTableData>> watchAllTodos() => select(todoTable).watch();
  Future<int> insertTodo(TodoTableCompanion todo) =>
      into(todoTable).insert(todo);
  Future<bool> updateTodo(TodoTableData todo) =>
      update(todoTable).replace(todo);
  Future<int> deleteTodo(int id) =>
      (delete(todoTable)..where((tbl) => tbl.id.equals(id))).go();
}
