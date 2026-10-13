import '../../helper/network/network_api_services.dart';
import '../../helper/response/api_response.dart';
import '../../helper/app_exception.dart';
import '../../res/api_urls.dart';
import '../model/payout_method_model.dart';

class PayoutMethodRepository {
  final NetworkApiServices _apiServices = NetworkApiServices();

  /// GET /api/v1/payout-methods
  Future<ApiResponse<List<PayoutMethodModel>>> getPayoutMethods() async {
    try {
      final response = await _apiServices.getGetApiResponse(ApiUrl.payoutMethods);
      final data = (response is Map ? response['data'] : null) as List<dynamic>?;
      final list = (data ?? [])
          .map((e) => PayoutMethodModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResponse.completed(list);
    } on AppException catch (e) {
      return ApiResponse.error(
          e.message.isNotEmpty ? e.message : 'Failed to load payout methods.');
    } catch (_) {
      return ApiResponse.error('Failed to load payout methods. Please try again.');
    }
  }

  Future<ApiResponse<PayoutMethodModel>> addUpi({
    required String upiId,
    String? label,
  }) async {
    try {
      final body = <String, dynamic>{
        'upiId': upiId.trim().toLowerCase(),
        if (label != null && label.trim().isNotEmpty) 'label': label.trim(),
      };
      final response = await _apiServices.getPostApiResponse(ApiUrl.payoutMethods, body);
      final data = (response is Map ? response['data'] : null);
      if (data is! Map<String, dynamic>) {
        final msg = (response is Map ? response['message']?.toString() : null);
        return ApiResponse.error(msg ?? 'Could not add UPI. Please try again.');
      }
      final msg = (response is Map ? response['message']?.toString() : null);
      return ApiResponse.completed(PayoutMethodModel.fromJson(data), message: msg);
    } on AppException catch (e) {
      return ApiResponse.error(e.message.isNotEmpty ? e.message : 'Could not add UPI.');
    } catch (_) {
      return ApiResponse.error('Could not add UPI. Please try again.');
    }
  }

  /// DELETE /api/v1/payout-methods/:id
  Future<ApiResponse<bool>> deletePayoutMethod(String id) async {
    try {
      final response =
      await _apiServices.getDeleteApiResponse(ApiUrl.payoutMethodById(id));
      final success = (response is Map && response['success'] == true);
      final msg = (response is Map ? response['message']?.toString() : null);
      if (!success) return ApiResponse.error(msg ?? 'Could not delete payout method.');
      return ApiResponse.completed(true, message: msg);
    } on AppException catch (e) {
      return ApiResponse.error(
          e.message.isNotEmpty ? e.message : 'Could not delete payout method.');
    } catch (_) {
      return ApiResponse.error('Could not delete payout method. Please try again.');
    }
  }
}