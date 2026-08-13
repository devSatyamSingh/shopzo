import '../../helper/network/network_api_services.dart';
import '../../helper/response/api_response.dart';
import '../../helper/app_exception.dart';
import '../../res/api_urls.dart';
import '../model/top_product_model.dart';

class TopProductRepository {
  final NetworkApiServices _apiServices = NetworkApiServices();

  Future<ApiResponse<List<TopProductModel>>> getBestSellers({int limit = 20}) async {
    return _fetch('${ApiUrl.bestSellers}?limit=$limit', 'Failed to load best sellers.');
  }

  Future<ApiResponse<List<TopProductModel>>> getTrending({int limit = 10}) async {
    return _fetch('${ApiUrl.trendingProducts}?limit=$limit', 'Failed to load top picks.');
  }

  Future<ApiResponse<List<TopProductModel>>> _fetch(String url, String errorFallback) async {
    try {
      final response = await _apiServices.getGetApiResponse(url);
      final data = (response is Map ? response['data'] : null) as List<dynamic>?;

      if (data == null) return ApiResponse.completed(<TopProductModel>[]);

      final products = data.map((e) => TopProductModel.fromJson(e as Map<String, dynamic>)).toList();
      return ApiResponse.completed(products);
    } on AppException catch (e) {
      return ApiResponse.error(e.message.isNotEmpty ? e.message : errorFallback);
    } catch (e) {
      return ApiResponse.error(errorFallback);
    }
  }
}