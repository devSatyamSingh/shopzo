import '../../helper/network/network_api_services.dart';
import '../../helper/response/api_response.dart';
import '../../model/coupons/coupon_model.dart';
import '../../helper/app_exception.dart';
import '../../res/api_urls.dart';

class CouponRepository {
  final NetworkApiServices _apiServices = NetworkApiServices();

  Future<ApiResponse<List<CouponModel>>> getActiveCoupons() async {
    try {
      final response = await _apiServices.getGetApiResponse(ApiUrl.activeCoupons);
      final List<dynamic> list = (response is Map ? response['data'] : null) as List<dynamic>? ?? [];
      final coupons = list
          .map((e) => CouponModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResponse.completed(coupons);
    } on AppException catch (e) {
      return ApiResponse.error(e.message.isNotEmpty ? e.message : 'Failed to load coupons.');
    } catch (e) {
      return ApiResponse.error('Failed to load coupons. Please try again.');
    }
  }

  Future<ApiResponse<CouponValidationResult>> validateCoupon({
    required String code,
    required double subtotal,
  }) async {
    try {
      final response = await _apiServices.getPostApiResponse(
        ApiUrl.validateCoupon,
        {
          'code': code,
          'subtotal': subtotal,
        },
      );
      final data = (response is Map ? response['data'] : null) as Map<String, dynamic>? ?? {};
      final result = CouponValidationResult.fromJson(data, fallbackCode: code);
      return ApiResponse.completed(result);
    } on AppException catch (e) {
      // e.g. 422/400 from server -> "Invalid coupon", "Minimum order not met" etc.
      return ApiResponse.error(e.message.isNotEmpty ? e.message : 'Coupon not applicable or invalid.');
    } catch (e) {
      return ApiResponse.error('Coupon not applicable or invalid.');
    }
  }
}