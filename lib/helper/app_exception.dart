/// Shopzo — custom exception wrapper so every API/repo layer throws
/// one consistent, human-readable exception type.
class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException(this.message, {this.statusCode});

  @override
  String toString() => message;

  factory AppException.fromStatusCode(int? statusCode, [String? serverMessage]) {
    switch (statusCode) {
      case 400:
        return AppException(serverMessage ?? "Bad request. Please check your input.", statusCode: 400);
      case 401:
        return AppException(serverMessage ?? "Session expired. Please login again.", statusCode: 401);
      case 403:
        return AppException(serverMessage ?? "You don't have permission to do this.", statusCode: 403);
      case 404:
        return AppException(serverMessage ?? "Requested data not found.", statusCode: 404);
      case 409:
        return AppException(serverMessage ?? "This item is out of stock or unavailable.", statusCode: 409);
      case 422:
        return AppException(serverMessage ?? "Validation failed. Please check your details.", statusCode: 422);
      case 500:
        return AppException(serverMessage ?? "Something went wrong. Please try again.", statusCode: 500);
      default:
        return AppException(serverMessage ?? "Unexpected error occurred.", statusCode: statusCode);
    }
  }

  factory AppException.noInternet() =>
      AppException("No internet connection. Please check your network.");

  factory AppException.timeout() =>
      AppException("Request timed out. Please try again.");
}
