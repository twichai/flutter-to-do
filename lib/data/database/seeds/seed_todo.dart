import '../app_database.dart';

Future<void> seedTodos(AppDatabase db) async {
  await db.todoDao.insertTodo(
    TodoTableCompanion.insert(title: 'Sample Task 1'),
  );
  await db.todoDao.insertTodo(
    TodoTableCompanion.insert(title: 'Sample Task 2'),
  );
}
