import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/todo_entity.dart';
import '../../data/repositories/todo_repository.dart';

class UpdateTodoUseCase implements UseCase<TodoEntity, TodoEntity> {
  final TodoRepository repository;

  const UpdateTodoUseCase(this.repository);

  @override
  Future<Result<TodoEntity, Failure>> call(TodoEntity todo) async {
    if (!todo.isValid) {
      return const Error(DatabaseFailure('Todo title cannot be empty'));
    }

    try {
      final updatedTodo = await repository.updateTodo(todo);
      return Success(updatedTodo);
    } on DatabaseFailure catch (failure) {
      return Error(failure);
    } catch (e) {
      return Error(DatabaseFailure('Failed to update todo: $e'));
    }
  }
}
