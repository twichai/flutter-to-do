import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/todo_entity.dart';
import '../../data/repositories/todo_repository.dart';

class GetTodosUseCase implements NoParamsUseCase<List<TodoEntity>> {
  final TodoRepository repository;

  const GetTodosUseCase(this.repository);

  @override
  Future<Result<List<TodoEntity>, Failure>> call() async {
    try {
      final todos = await repository.getTodos();
      return Success(todos);
    } on DatabaseFailure catch (failure) {
      return Error(failure);
    } catch (e) {
      return Error(DatabaseFailure('Failed to get todos: $e'));
    }
  }
}
