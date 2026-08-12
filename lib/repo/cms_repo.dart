import '../../helper/app_exception.dart';
import '../../helper/network/network_api_services.dart';
import '../../helper/response/api_response.dart';
import '../../res/api_urls.dart';
import '../model/cms_page_model.dart';

class CmsRepository {
  final NetworkApiServices _apiServices = NetworkApiServices();

  /// GET /website/pages — sabhi pages ki list (type, title, updatedAt)
  Future<ApiResponse<List<CmsPageListItem>>> getAllPages() async {
    try {
      final response = await _apiServices.getGetApiResponse(ApiUrl.websitePages);
      final map = response as Map<String, dynamic>;
      final List<dynamic> rawList = (map['data'] as List<dynamic>?) ?? [];

      final pages =
      rawList.map((e) => CmsPageListItem.fromJson(e as Map<String, dynamic>)).toList();
      return ApiResponse.completed(pages);
    } on AppException catch (e) {
      return ApiResponse.error(e.message.isNotEmpty ? e.message : e.toString());
    } catch (e) {
      return ApiResponse.error('Something went wrong. Please try again.');
    }
  }

  /// GET /website/pages/:type — ek specific page ka full content
  Future<ApiResponse<CmsPageDetailModel>> getPageByType(String type) async {
    try {
      final response = await _apiServices.getGetApiResponse(ApiUrl.pageByType(type));
      final map = response as Map<String, dynamic>;
      final data = map['data'] as Map<String, dynamic>? ?? {};
      return ApiResponse.completed(CmsPageDetailModel.fromJson(data));
    } on AppException catch (e) {
      return ApiResponse.error(e.message.isNotEmpty ? e.message : e.toString());
    } catch (e) {
      return ApiResponse.error('Something went wrong. Please try again.');
    }
  }
}