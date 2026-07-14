/// Shopzo — generic API response wrapper.
/// Every repo method should return ApiResponse<T> so the ViewModel
/// layer can handle success/error/loading in one consistent way.
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int? statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
  });

  factory ApiResponse.success(T data, {String message = "Success", int? statusCode}) {
    return ApiResponse(success: true, message: message, data: data, statusCode: statusCode);
  }

  factory ApiResponse.error(String message, {int? statusCode}) {
    return ApiResponse(success: false, message: message, data: null, statusCode: statusCode);
  }

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      statusCode: json['status_code'],
    );
  }
}

/// Simple state wrapper for ViewModels (idle / loading / success / error)
enum ViewState { idle, loading, success, error }
