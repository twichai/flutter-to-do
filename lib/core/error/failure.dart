abstract class Failure {
  const Failure();
}

class DatabaseFailure extends Failure {
  final String message;

  const DatabaseFailure(this.message);

  @override
  String toString() => 'DatabaseFailure: $message';
}

class CacheFailure extends Failure {
  final String message;

  const CacheFailure(this.message);

  @override
  String toString() => 'CacheFailure: $message';
}

class NetworkFailure extends Failure {
  final String message;

  const NetworkFailure(this.message);

  @override
  String toString() => 'NetworkFailure: $message';
}
