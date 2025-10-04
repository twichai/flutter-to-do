import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/todo_repository.dart';

class DeleteTodoParams {
  final int id;

  const DeleteTodoParams({required this.id});
}

class DeleteTodoUseCase implements UseCase<void, DeleteTodoParams> {
  final TodoRepository repository;

  const DeleteTodoUseCase(this.repository);

  @override
  Future<Result<void, Failure>> call(DeleteTodoParams params) async {
    try {
      await repository.deleteTodo(params.id);
      return const Success(null);
    } on DatabaseFailure catch (failure) {
      return Error(failure);
    } catch (e) {
      return Error(DatabaseFailure('Failed to delete todo: $e'));
    }
  }
}
