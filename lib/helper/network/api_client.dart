// import 'package:dio/dio.dart';
// import '../../res/api_urls.dart';
// import '../app_exception.dart';
//
// /// Shopzo — single Dio instance used across the whole app.
// /// Handles: base URL, auth token header, timeouts, and converts every
// /// Dio error into our own AppException so UI code never touches DioException.
// ///
// /// Add to pubspec.yaml:
// ///   dio: ^5.7.0
// class ApiClient {
//   ApiClient._();
//
//   static String? _authToken;
//   static String? _tenantId;
//
//   static void setAuthToken(String token) => _authToken = token;
//   static void setTenantId(String tenantId) => _tenantId = tenantId;
//   static void clearAuth() => _authToken = null;
//
//   static final Dio _dio = Dio(
//     BaseOptions(
//       baseUrl: ApiUrls.baseUrl,
//       connectTimeout: const Duration(seconds: 20),
//       receiveTimeout: const Duration(seconds: 20),
//       headers: {"Content-Type": "application/json"},
//     ),
//   )..interceptors.add(
//       InterceptorsWrapper(
//         onRequest: (options, handler) {
//           if (_authToken != null) {
//             options.headers["Authorization"] = "Bearer $_authToken";
//           }
//           if (_tenantId != null) {
//             options.headers["X-Tenant-Id"] = _tenantId;
//           }
//           return handler.next(options);
//         },
//       ),
//     );
//
//   static Future<Response> get(String url, {Map<String, dynamic>? query}) async {
//     try {
//       return await _dio.get(url, queryParameters: query);
//     } on DioException catch (e) {
//       throw _handleError(e);
//     }
//   }
//
//   static Future<Response> post(String url, {dynamic data}) async {
//     try {
//       return await _dio.post(url, data: data);
//     } on DioException catch (e) {
//       throw _handleError(e);
//     }
//   }
//
//   static Future<Response> put(String url, {dynamic data}) async {
//     try {
//       return await _dio.put(url, data: data);
//     } on DioException catch (e) {
//       throw _handleError(e);
//     }
//   }
//
//   static Future<Response> delete(String url, {dynamic data}) async {
//     try {
//       return await _dio.delete(url, data: data);
//     } on DioException catch (e) {
//       throw _handleError(e);
//     }
//   }
//
//   static AppException _handleError(DioException e) {
//     if (e.type == DioExceptionType.connectionTimeout ||
//         e.type == DioExceptionType.receiveTimeout) {
//       return AppException.timeout();
//     }
//     if (e.type == DioExceptionType.connectionError) {
//       return AppException.noInternet();
//     }
//     final statusCode = e.response?.statusCode;
//     final serverMessage = e.response?.data is Map
//         ? (e.response?.data['message'] as String?)
//         : null;
//     return AppException.fromStatusCode(statusCode, serverMessage);
//   }
// }
