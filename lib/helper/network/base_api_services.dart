import 'dart:io';

abstract class BaseApiServices {
  Future<dynamic> getGetApiResponse(String url);

  Future<dynamic> getPostApiResponse(String url, dynamic data);

  Future<dynamic> getPutApiResponse(String url, dynamic data);

  Future<dynamic> getPatchApiResponse(String url, dynamic data);

  Future<dynamic> getDeleteApiResponse(String url);

  Future<dynamic> getFormDataApiResponse(
      String url,
      Map<String, dynamic> fields, {
        Map<String, File>? files,
        Map<String, List<File>>? multiFiles,
        String method = 'POST',
      });
}