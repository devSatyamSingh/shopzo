import '../../helper/network/network_api_services.dart';
import '../../helper/response/api_response.dart';
import '../../helper/app_exception.dart';
import '../../res/api_urls.dart';
import '../model/banner_model.dart';

class BannerRepository {
  final NetworkApiServices _apiServices = NetworkApiServices();
  
  Future<ApiResponse<List<BannerModel>>> getBanners() async {
    try {
      final response = await _apiServices.getGetApiResponse(ApiUrl.banners);
      final data = (response is Map ? response['data'] : null) as List<dynamic>?;

      if (data == null) return ApiResponse.completed(<BannerModel>[]);

      final banners = data
          .map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      return ApiResponse.completed(banners);
    } on AppException catch (e) {
      return ApiResponse.error(e.message.isNotEmpty ? e.message : 'Failed to load banners.');
    } catch (e) {
      return ApiResponse.error('Failed to load banners. Please try again.');
    }
  }
}