// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../res/api_urls.dart';
import '../../routes/route_name.dart';
import '../../utils/app_storage.dart';
import '../../utils/utils.dart';
import '../app_exception.dart';
import 'package:http_parser/http_parser.dart';
import 'base_api_services.dart';

class NetworkApiServices extends BaseApiServices {
  static const Duration _timeout = Duration(seconds: 20);
  static const Duration _uploadTimeout = Duration(seconds: 60);

  // Prevents multiple parallel requests from all firing their own
  // refresh call the instant a token expires — they share one refresh.
  static Future<bool>? _refreshInFlight;

  Map<String, String> _jsonHeaders() {
    final token = AppStorage.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Map<String, String> _formDataHeaders() {
    final token = AppStorage.getAccessToken();
    return {
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  void _log(String tag, Object message) {
    if (kDebugMode) debugPrint('[$tag] $message');
  }

  /// Runs [request]. If it throws UnauthorisedException (401/403 — expired
  /// access token), tries ONE silent refresh and retries [request] once.
  /// If the refresh itself fails (refresh token also expired/invalid),
  /// clears the session and bounces the user to Login automatically.
  Future<dynamic> _withAuthRetry(Future<dynamic> Function() request) async {
    try {
      return await request();
    } on UnauthorisedException {
      final refreshed = await _refreshAccessToken();
      if (refreshed) {
        return await request();
      }
      await AppStorage.logout();
      AppUtils.navigatorKey.currentState?.pushNamedAndRemoveUntil(
        RouteName.login,
            (route) => false,
      );
      rethrow;
    }
  }

  Future<bool> _refreshAccessToken() {
    // If a refresh is already running, wait for that one instead of firing another.
    _refreshInFlight ??= _doRefreshAccessToken();
    return _refreshInFlight!.whenComplete(() => _refreshInFlight = null);
  }

  Future<bool> _doRefreshAccessToken() async {
    final refreshToken = AppStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      final response = await http
          .post(
        Uri.parse(ApiUrl.refreshToken),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'refreshToken': refreshToken}),
      )
          .timeout(_timeout);

      _log('REFRESH', '${response.statusCode} | ${response.body}');

      if (response.statusCode != 200) return false;

      final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      final data = (body is Map ? body['data'] : null) as Map<String, dynamic>?;
      final newAccessToken = data?['accessToken']?.toString();
      final newRefreshToken = data?['refreshToken']?.toString();

      if (newAccessToken == null || newAccessToken.isEmpty) return false;

      await AppStorage.updateTokens(
        accessToken: newAccessToken,
        refreshToken: (newRefreshToken != null && newRefreshToken.isNotEmpty)
            ? newRefreshToken
            : refreshToken,
      );
      return true;
    } catch (e) {
      _log('REFRESH ✗', e);
      return false;
    }
  }

  // GET
  @override
  Future<dynamic> getGetApiResponse(String url) async {
    _log('GET →', url);
    try {
      return await _withAuthRetry(() async {
        final response =
        await http.get(Uri.parse(url), headers: _jsonHeaders()).timeout(_timeout);
        _log('GET ✓', '${response.statusCode} | ${response.body}');
        return _returnRequest(response);
      });
    } on SocketException {
      throw NoInternetException();
    } on TimeoutException {
      throw RequestTimeoutException();
    } on FormatException {
      throw ServerException('Received an invalid response from the server');
    } on AppException {
      rethrow;
    } catch (e) {
      _log('GET ✗', e);
      throw FetchDataException(e.toString());
    }
  }

  // POST
  @override
  Future<dynamic> getPostApiResponse(String url, dynamic data) async {
    _log('POST →', '$url | body: ${jsonEncode(data)}');
    try {
      return await _withAuthRetry(() async {
        final response = await http
            .post(Uri.parse(url), headers: _jsonHeaders(), body: jsonEncode(data))
            .timeout(_timeout);
        _log('POST ✓', '${response.statusCode} | ${response.body}');
        return _returnRequest(response);
      });
    } on SocketException {
      throw NoInternetException();
    } on TimeoutException {
      throw RequestTimeoutException();
    } on FormatException {
      throw ServerException('Received an invalid response from the server');
    } on AppException {
      rethrow;
    } catch (e) {
      _log('POST ✗', e);
      throw FetchDataException(e.toString());
    }
  }

  // PUT
  @override
  Future<dynamic> getPutApiResponse(String url, dynamic data) async {
    _log('PUT →', '$url | body: ${jsonEncode(data)}');
    try {
      return await _withAuthRetry(() async {
        final response = await http
            .put(Uri.parse(url), headers: _jsonHeaders(), body: jsonEncode(data))
            .timeout(_timeout);
        _log('PUT ✓', '${response.statusCode} | ${response.body}');
        return _returnRequest(response);
      });
    } on SocketException {
      throw NoInternetException();
    } on TimeoutException {
      throw RequestTimeoutException();
    } on FormatException {
      throw ServerException('Received an invalid response from the server');
    } on AppException {
      rethrow;
    } catch (e) {
      _log('PUT ✗', e);
      throw FetchDataException(e.toString());
    }
  }

  // PATCH
  @override
  Future<dynamic> getPatchApiResponse(String url, dynamic data) async {
    _log('PATCH →', '$url | body: ${jsonEncode(data)}');
    try {
      return await _withAuthRetry(() async {
        final response = await http
            .patch(Uri.parse(url), headers: _jsonHeaders(), body: jsonEncode(data))
            .timeout(_timeout);
        _log('PATCH ✓', '${response.statusCode} | ${response.body}');
        return _returnRequest(response);
      });
    } on SocketException {
      throw NoInternetException();
    } on TimeoutException {
      throw RequestTimeoutException();
    } on FormatException {
      throw ServerException('Received an invalid response from the server');
    } on AppException {
      rethrow;
    } catch (e) {
      _log('PATCH ✗', e);
      throw FetchDataException(e.toString());
    }
  }

  // DELETE
  @override
  Future<dynamic> getDeleteApiResponse(String url) async {
    _log('DELETE →', url);
    try {
      return await _withAuthRetry(() async {
        final response =
        await http.delete(Uri.parse(url), headers: _jsonHeaders()).timeout(_timeout);
        _log('DELETE ✓', '${response.statusCode} | ${response.body}');
        return _returnRequest(response);
      });
    } on SocketException {
      throw NoInternetException();
    } on TimeoutException {
      throw RequestTimeoutException();
    } on FormatException {
      throw ServerException('Received an invalid response from the server');
    } on AppException {
      rethrow;
    } catch (e) {
      _log('DELETE ✗', e);
      throw FetchDataException(e.toString());
    }
  }

  // MULTIPART / FORM-DATA (profile photo, ID docs, product images…)
  // getFormDataApiResponse ko replace karo:
// MULTIPART / FORM-DATA (profile photo, ID docs, product images…)
  @override
  Future<dynamic> getFormDataApiResponse(
      String url,
      Map<String, dynamic> fields, {
        Map<String, File>? files,
        Map<String, List<File>>? multiFiles,
        String method = 'POST',
      }) async {
    _log('FORM-DATA($method) →', '$url | fields: $fields | files: ${files?.keys} | multiFiles: ${multiFiles?.keys}');
    try {
      return await _withAuthRetry(() async {
        final request = http.MultipartRequest(method, Uri.parse(url));
        request.headers.addAll(_formDataHeaders());

        fields.forEach((key, value) {
          if (value != null) request.fields[key] = value.toString();
        });

        if (files != null) {
          for (final entry in files.entries) {
            request.files.add(await _buildMultipartFile(entry.key, entry.value));
          }
        }

        if (multiFiles != null) {
          for (final entry in multiFiles.entries) {
            for (final file in entry.value) {
              request.files.add(await _buildMultipartFile(entry.key, file));
            }
          }
        }

        final streamed = await request.send().timeout(_uploadTimeout);
        final response = await http.Response.fromStream(streamed).timeout(_uploadTimeout);

        _log('FORM-DATA ✓', '${response.statusCode} | ${response.body}');
        return _returnRequest(response);
      });
    } on SocketException {
      throw NoInternetException();
    } on TimeoutException {
      throw RequestTimeoutException();
    } on FormatException {
      throw ServerException('Received an invalid response from the server');
    } on AppException {
      rethrow;
    } catch (e) {
      _log('FORM-DATA ✗', e);
      throw FetchDataException(e.toString());
    }
  }


  Future<http.MultipartFile> _buildMultipartFile(String field, File file) async {
    final path = file.path;
    final ext = path.contains('.') ? path.split('.').last.toLowerCase() : '';
    final mimeType = switch (ext) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      'heic' => 'image/heic',
      _ => 'image/jpeg',
    };
    final fileName = 'upload_${DateTime.now().millisecondsSinceEpoch}.${ext.isNotEmpty ? ext : 'jpg'}';

    return http.MultipartFile.fromPath(
      field,
      path,
      filename: fileName,
      contentType: MediaType.parse(mimeType),
    );
  }

  // SHARED RESPONSE HANDLING
  dynamic _returnRequest(http.Response response) {
    final dynamic responseData =
    response.body.isNotEmpty ? jsonDecode(response.body) : <String, dynamic>{};

    final String serverMessage = (responseData is Map && responseData['message'] != null)
        ? responseData['message'].toString()
        : '';

    switch (response.statusCode) {
      case 200:
      case 201:
      case 202:
      case 204:
        return responseData;

      case 400:
        throw BadRequestException(
          serverMessage.isNotEmpty ? serverMessage : 'Invalid request',
        );

      case 401:
      case 403:
        throw UnauthorisedException(
          serverMessage.isNotEmpty ? serverMessage : 'Session expired, please log in again',
        );

      case 404:
        throw NotFoundException(
          serverMessage.isNotEmpty ? serverMessage : 'API endpoint not found',
        );

      case 422:
        throw InvalidInputException(
          serverMessage.isNotEmpty ? serverMessage : 'Invalid input',
        );

      case 500:
      case 502:
      case 503:
        throw ServerException(
          serverMessage.isNotEmpty ? serverMessage : 'Server error, please try again later',
        );

      default:
        throw FetchDataException(
          serverMessage.isNotEmpty ? serverMessage : 'Something went wrong',
        );
    }
  }
}