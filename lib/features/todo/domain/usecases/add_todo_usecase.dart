import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/todo_entity.dart';
import '../../data/repositories/todo_repository.dart';

class AddTodoParams {
  final String title;

  const AddTodoParams({required this.title});
}

class AddTodoUseCase implements UseCase<TodoEntity, AddTodoParams> {
  final TodoRepository repository;

  const AddTodoUseCase(this.repository);

  @override
  Future<Result<TodoEntity, Failure>> call(AddTodoParams params) async {
    if (params.title.trim().isEmpty) {
      return const Error(DatabaseFailure('Todo title cannot be empty'));
    }

    try {
      final todo = await repository.addTodo(params.title);
      return Success(todo);
    } on DatabaseFailure catch (failure) {
      return Error(failure);
    } catch (e) {
      return Error(DatabaseFailure('Failed to add todo: $e'));
    }
  }
}
