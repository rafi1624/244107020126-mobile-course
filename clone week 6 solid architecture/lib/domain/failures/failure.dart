/// Domain Failure: Representasi kegagalan / kesalahan bisnis murni Dart
abstract class Failure {
  const Failure(this.message);
  final String message;

  @override
  String toString() => message;
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

