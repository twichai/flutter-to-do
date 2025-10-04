import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/app_database.dart';
import '../data/repositories/todo_repository.dart';
import '../data/repositories/todo_repository_impl.dart';
import '../domain/usecases/get_todos_usecase.dart';
import '../domain/usecases/add_todo_usecase.dart';
import '../domain/usecases/update_todo_usecase.dart';
import '../domain/usecases/delete_todo_usecase.dart';

// Database provider
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

// Repository provider
final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  final database = ref.read(appDatabaseProvider);
  return TodoRepositoryImpl(database);
});

// Use case providers
final getTodosUseCaseProvider = Provider<GetTodosUseCase>((ref) {
  final repository = ref.read(todoRepositoryProvider);
  return GetTodosUseCase(repository);
});

final addTodoUseCaseProvider = Provider<AddTodoUseCase>((ref) {
  final repository = ref.read(todoRepositoryProvider);
  return AddTodoUseCase(repository);
});

final updateTodoUseCaseProvider = Provider<UpdateTodoUseCase>((ref) {
  final repository = ref.read(todoRepositoryProvider);
  return UpdateTodoUseCase(repository);
});

final deleteTodoUseCaseProvider = Provider<DeleteTodoUseCase>((ref) {
  final repository = ref.read(todoRepositoryProvider);
  return DeleteTodoUseCase(repository);
});
