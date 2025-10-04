import '../error/failure.dart';

abstract class UseCase<Type, Params> {
  Future<Result<Type, Failure>> call(Params params);
}

abstract class NoParamsUseCase<Type> {
  Future<Result<Type, Failure>> call();
}

// Result type for better error handling
sealed class Result<T, E> {
  const Result();
}

class Success<T, E> extends Result<T, E> {
  final T value;
  const Success(this.value);
}

class Error<T, E> extends Result<T, E> {
  final E error;
  const Error(this.error);
}

// Extension methods for Result
extension ResultExtension<T, E> on Result<T, E> {
  bool get isSuccess => this is Success<T, E>;
  bool get isError => this is Error<T, E>;

  T? get value => switch (this) {
    Success<T, E> success => success.value,
    Error<T, E> _ => null,
  };

  E? get error => switch (this) {
    Success<T, E> _ => null,
    Error<T, E> error => error.error,
  };
}
