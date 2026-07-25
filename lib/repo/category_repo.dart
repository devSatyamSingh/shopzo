import '../helper/app_exception.dart';
import '../helper/network/network_api_services.dart';
import '../helper/response/api_response.dart';
import '../model/category_model.dart';
import '../res/api_urls.dart';


class CategoryRepository {
  final NetworkApiServices _apiServices = NetworkApiServices();

  Future<ApiResponse<List<CategoryModel>>> getAllCategories() async {
    try {
      final response = await _apiServices.getGetApiResponse(ApiUrl.categories);
      final list = (response as Map<String, dynamic>)['data'] as List<dynamic>? ?? [];
      final categories =
      list.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
      return ApiResponse.completed(categories);
    } on AppException catch (e) {
      return ApiResponse.error(e.message.isNotEmpty ? e.message : e.toString());
    } catch (e) {
      return ApiResponse.error('Something went wrong. Please try again.');
    }
  }

  Future<ApiResponse<CategoryModel>> getCategoryById(String id) async {
    try {
      final response = await _apiServices.getGetApiResponse(ApiUrl.categoryById(id));
      final data = (response as Map<String, dynamic>)['data'] as Map<String, dynamic>? ?? {};
      return ApiResponse.completed(CategoryModel.fromJson(data));
    } on AppException catch (e) {
      return ApiResponse.error(e.message.isNotEmpty ? e.message : e.toString());
    } catch (e) {
      return ApiResponse.error('Something went wrong. Please try again.');
    }
  }
}