class AppException implements Exception {
  final String message;
  const AppException(this.message);
  @override
  String toString() => message;
}

class NotFoundException extends AppException {
  const NotFoundException(super.message);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message);
}

class AlreadyExistsException extends AppException {
  const AlreadyExistsException(super.message);
}

class ServerException extends AppException {
  const ServerException(super.message);
}

class InsufficientCoinsException extends AppException {
  const InsufficientCoinsException() : super('Yetersiz coin');
}
