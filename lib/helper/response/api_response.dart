/// Shopzo — generic API response wrapper.
/// Every Repository method returns `Future<ApiResponse<T>>` (never a
/// raw model, never a raw exception) so every ViewModel can handle
/// loading/success/error the exact same way, for every screen.
enum Status { loading, completed, error }

class ApiResponse<T> {
  final Status status;
  final T? data;
  final String? message;

  ApiResponse._({required this.status, this.data, this.message});

  factory ApiResponse.loading() => ApiResponse._(status: Status.loading);

  factory ApiResponse.completed(T data, {String? message}) =>
      ApiResponse._(status: Status.completed, data: data, message: message);

  factory ApiResponse.error(String message) =>
      ApiResponse._(status: Status.error, message: message);

  bool get isLoading => status == Status.loading;
  bool get isCompleted => status == Status.completed;
  bool get isError => status == Status.error;

  @override
  String toString() => 'Status: $status | Message: $message | Data: $data';
}