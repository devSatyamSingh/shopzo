// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../app_exception.dart';
import 'base_api_services.dart';

class NetworkApiServices extends BaseApiServices {
  static const Duration _timeout = Duration(seconds: 20);
  static const Duration _uploadTimeout = Duration(seconds: 60);

  Future<String?> _getToken() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString('token');
  }

  Future<Map<String, String>> _jsonHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, String>> _formDataHeaders() async {
    final token = await _getToken();
    return {
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  void _log(String tag, Object message) {
    if (kDebugMode) debugPrint('[$tag] $message');
  }

  // GET
  @override
  Future<dynamic> getGetApiResponse(String url) async {
    _log('GET →', url);
    try {
      final headers = await _jsonHeaders();
      final response = await http.get(Uri.parse(url), headers: headers).timeout(_timeout);
      _log('GET ✓', '${response.statusCode} | ${response.body}');
      return _returnRequest(response);
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
      final headers = await _jsonHeaders();
      final response = await http
          .post(Uri.parse(url), headers: headers, body: jsonEncode(data))
          .timeout(_timeout);
      _log('POST ✓', '${response.statusCode} | ${response.body}');
      return _returnRequest(response);
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
      final headers = await _jsonHeaders();
      final response = await http
          .put(Uri.parse(url), headers: headers, body: jsonEncode(data))
          .timeout(_timeout);
      _log('PUT ✓', '${response.statusCode} | ${response.body}');
      return _returnRequest(response);
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
      final headers = await _jsonHeaders();
      final response = await http
          .patch(Uri.parse(url), headers: headers, body: jsonEncode(data))
          .timeout(_timeout);
      _log('PATCH ✓', '${response.statusCode} | ${response.body}');
      return _returnRequest(response);
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
      final headers = await _jsonHeaders();
      final response = await http.delete(Uri.parse(url), headers: headers).timeout(_timeout);
      _log('DELETE ✓', '${response.statusCode} | ${response.body}');
      return _returnRequest(response);
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
  @override
  Future<dynamic> getFormDataApiResponse(
      String url,
      Map<String, dynamic> fields, {
        Map<String, File>? files,
        String method = 'POST',
      }) async {
    _log('FORM-DATA($method) →', '$url | fields: $fields | files: ${files?.keys}');
    try {
      final request = http.MultipartRequest(method, Uri.parse(url));
      request.headers.addAll(await _formDataHeaders());

      fields.forEach((key, value) {
        if (value != null) request.fields[key] = value.toString();
      });

      if (files != null) {
        for (final entry in files.entries) {
          request.files.add(
            await http.MultipartFile.fromPath(entry.key, entry.value.path),
          );
        }
      }

      final streamed = await request.send().timeout(_uploadTimeout);
      final response = await http.Response.fromStream(streamed).timeout(_uploadTimeout);

      _log('FORM-DATA ✓', '${response.statusCode} | ${response.body}');
      return _returnRequest(response);
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

  // SHARED RESPONSE HANDLING
  dynamic _returnRequest(http.Response response) {
    final dynamic responseData =
    response.body.isNotEmpty ? jsonDecode(response.body) : <String, dynamic>{};

    final String serverMessage =
    (responseData is Map && responseData['message'] != null)
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