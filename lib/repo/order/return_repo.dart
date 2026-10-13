import 'dart:io';
import '../../helper/network/network_api_services.dart';
import '../../helper/response/api_response.dart';
import '../../helper/app_exception.dart';
import '../../model/order/return_model.dart';
import '../../res/api_urls.dart';

class ReturnRepository {
  final NetworkApiServices _apiServices = NetworkApiServices();

  /// POST /api/v1/website/returns — multipart (images ke liye)
  Future<ApiResponse<ReturnModel>> createReturnRequest({
    required String orderItemId,
    required ReturnRequestType type,
    required String reason,
    String? reasonNote,
    required int quantity,
    required ReturnRefundTo refundTo,
    String? payoutMethodId,
    String? exchangeProductId,
    String? exchangeVariantId,
    List<File> images = const [],
  }) async {
    try {
      final isExchange = type == ReturnRequestType.exchange;
      final fields = <String, String>{
        'orderItemId': orderItemId,
        'type': type.apiValue,
        'reason': reason,
        if (reasonNote != null && reasonNote.trim().isNotEmpty) 'reasonNote': reasonNote.trim(),
        'quantity': quantity.toString(),
        'refundTo': refundTo.apiValue,
        if (refundTo == ReturnRefundTo.upi &&
            payoutMethodId != null &&
            payoutMethodId.isNotEmpty)
          'payoutMethodId': payoutMethodId,
        if (isExchange && exchangeProductId != null && exchangeProductId.isNotEmpty)
          'exchangeProductId': exchangeProductId,
        if (isExchange && exchangeVariantId != null && exchangeVariantId.isNotEmpty)
          'exchangeVariantId': exchangeVariantId,
      };

      final response = await _apiServices.getFormDataApiResponse(
        ApiUrl.returns,
        fields,
        multiFiles: images.isNotEmpty ? {'images': images} : null,
        method: 'POST',
      );

      final backendMsg = (response is Map ? response['message']?.toString() : null);
      final dataMap = _extractSingle(response);
      if (dataMap == null) {
        return ApiResponse.error(backendMsg ?? 'Something went wrong. Please try again.');
      }
      return ApiResponse.completed(ReturnModel.fromJson(dataMap), message: backendMsg);
    } on AppException catch (e) {
      return ApiResponse.error(e.message.isNotEmpty ? e.message : 'Return request failed.');
    } catch (_) {
      return ApiResponse.error('Return request failed. Please try again.');
    }
  }

  Future<ApiResponse<List<ReturnModel>>> getAllReturns() async {
    try {
      final response = await _apiServices.getGetApiResponse(ApiUrl.returns);
      final data = (response is Map ? response['data'] : null) as List<dynamic>?;
      if (data == null) return ApiResponse.completed(<ReturnModel>[]);
      final list = data.map((e) => ReturnModel.fromJson(e as Map<String, dynamic>)).toList();
      list.sort((a, b) => (b.createdAt ?? DateTime(2000)).compareTo(a.createdAt ?? DateTime(2000)));
      return ApiResponse.completed(list);
    } on AppException catch (e) {
      return ApiResponse.error(e.message.isNotEmpty ? e.message : 'Failed to load return requests.');
    } catch (e) {
      return ApiResponse.error('Failed to load return requests. Please try again.');
    }
  }

  Future<ApiResponse<ReturnModel>> getReturnById(String id) async {
    try {
      final response = await _apiServices.getGetApiResponse(ApiUrl.returnById(id));
      final dataMap = _extractSingle(response);
      if (dataMap == null) {
        return ApiResponse.error('Return request not found.');
      }
      return ApiResponse.completed(ReturnModel.fromJson(dataMap));
    } on AppException catch (e) {
      return ApiResponse.error(e.message.isNotEmpty ? e.message : 'Failed to load return request.');
    } catch (e) {
      return ApiResponse.error('Failed to load return request. Please try again.');
    }
  }

  Future<ApiResponse<bool>> cancelReturn(String id) async {
    try {
      final response = await _apiServices.getPatchApiResponse(ApiUrl.cancelReturn(id), {});
      final success = (response is Map && response['success'] == true);
      final backendMsg = (response is Map ? response['message']?.toString() : null);
      if (!success) {
        return ApiResponse.error(backendMsg ?? 'Could not cancel return request.');
      }
      return ApiResponse.completed(true, message: backendMsg);
    } on AppException catch (e) {
      return ApiResponse.error(e.message.isNotEmpty ? e.message : 'Failed to cancel return request.');
    } catch (e) {
      return ApiResponse.error('Failed to cancel return request. Please try again.');
    }
  }

  Map<String, dynamic>? _extractSingle(dynamic response) {
    final data = (response is Map ? response['data'] : null);
    if (data is Map<String, dynamic>) return data;
    if (data is List && data.isNotEmpty && data.first is Map<String, dynamic>) {
      return data.first as Map<String, dynamic>;
    }
    return null;
  }
}