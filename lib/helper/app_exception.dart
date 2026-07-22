/// Shopzo — typed exceptions thrown by the network layer.
/// Repositories catch these and map them to user-facing messages
/// (via AppUtils.error) instead of leaking raw HTTP/parsing errors.
class AppException implements Exception {
  final String message;
  final String prefix;

  AppException(this.message, this.prefix);

  @override
  String toString() => message.isEmpty ? prefix : '$prefix: $message';
}

class FetchDataException extends AppException {
  FetchDataException([String message = 'Something went wrong'])
      : super(message, 'Error');
}

class NoInternetException extends AppException {
  NoInternetException([String message = 'No internet connection'])
      : super(message, 'No Internet');
}

class RequestTimeoutException extends AppException {
  RequestTimeoutException([String message = 'Request timed out'])
      : super(message, 'Timeout');
}

class BadRequestException extends AppException {
  BadRequestException([String message = 'Invalid request'])
      : super(message, 'Invalid Request');
}

class UnauthorisedException extends AppException {
  UnauthorisedException([String message = 'Session expired, please log in again'])
      : super(message, 'Unauthorised');
}

class InvalidInputException extends AppException {
  InvalidInputException([String message = 'Invalid input'])
      : super(message, 'Invalid Input');
}

class NotFoundException extends AppException {
  NotFoundException([String message = 'Resource not found'])
      : super(message, 'Not Found');
}

class ServerException extends AppException {
  ServerException([String message = 'Server error, please try again later'])
      : super(message, 'Server Error');
}