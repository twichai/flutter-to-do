import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/todo_entity.dart';
import '../../domain/usecases/add_todo_usecase.dart';
import '../../domain/usecases/delete_todo_usecase.dart';
import '../providers.dart';

class TodoNotifier extends AsyncNotifier<List<TodoEntity>> {
  @override
  Future<List<TodoEntity>> build() async {
    final getTodosUseCase = ref.read(getTodosUseCaseProvider);
    final result = await getTodosUseCase.call();

    return result.isSuccess ? result.value! : [];
  }

  Future<void> addTodo(String title) async {
    if (title.trim().isEmpty) return;

    final addTodoUseCase = ref.read(addTodoUseCaseProvider);
    final result = await addTodoUseCase.call(AddTodoParams(title: title));

    if (result.isSuccess) {
      // Refresh the list
      ref.invalidateSelf();
    }
  }

  Future<void> updateTodo(TodoEntity todo) async {
    final updateTodoUseCase = ref.read(updateTodoUseCaseProvider);
    final result = await updateTodoUseCase.call(todo);

    if (result.isSuccess) {
      // Refresh the list
      ref.invalidateSelf();
    }
  }

  Future<void> deleteTodo(int id) async {
    final deleteTodoUseCase = ref.read(deleteTodoUseCaseProvider);
    final result = await deleteTodoUseCase.call(DeleteTodoParams(id: id));

    if (result.isSuccess) {
      // Refresh the list
      ref.invalidateSelf();
    }
  }

  Future<void> toggleTodo(TodoEntity todo) async {
    final updatedTodo = todo.toggleCompleted();
    await updateTodo(updatedTodo);
  }
}

// Provider for the TodoNotifier
final todoNotifierProvider =
    AsyncNotifierProvider<TodoNotifier, List<TodoEntity>>(() {
      return TodoNotifier();
    });
