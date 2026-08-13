
import '../helper/network/network_api_services.dart';
import '../helper/response/api_response.dart';
import '../model/search_product_model.dart';
import '../model/search_suggestion_model.dart';
import '../res/api_urls.dart';

class SearchRepository {
  final NetworkApiServices _apiServices = NetworkApiServices();


  Future<ApiResponse<List<SearchSuggestionModel>>> getSearchSuggestions(
      String query, {
        int limit = 8,
      }) async {
    try {
      final response = await _apiServices.getGetApiResponse(ApiUrl.searchSuggestions(query, limit: limit));

      final data = response['data'];
      final productsJson = (data is Map && data['products'] is List)
          ? data['products'] as List
          : <dynamic>[];

      final list = productsJson
          .map((e) => SearchSuggestionModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return ApiResponse.completed(list);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<List<SearchProductModel>>> searchProducts({
    required String query,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    String? sort,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiServices.getGetApiResponse(
        ApiUrl.websiteProducts(
          page: page,
          limit: limit,
          categoryId: categoryId,
          search: query,
          minPrice: minPrice,
          maxPrice: maxPrice,
          sort: sort,
        ),
      );

      final data = response['data'];
      final productsJson = (data is Map && data['products'] is List)
          ? data['products'] as List
          : <dynamic>[];

      final list = productsJson
          .map((e) => SearchProductModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return ApiResponse.completed(list);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Home/search-idle screen ke "Recommended for You" section ke liye.
  /// Auth optional — token bheja to personalized, nahi to bestseller fallback.
  /// Note: response shape yahan seedha array hai: {"data": [...]}
  /// (websiteProducts jaisa {"data":{"products":[...]}} nested nahi hai).
  Future<ApiResponse<List<SearchProductModel>>> getRecommendedProducts({
    int limit = 10,
  }) async {
    try {
      final response =
      await _apiServices.getGetApiResponse(ApiUrl.recommendedProducts(limit: limit));

      final data = response['data'];
      final list = (data is List ? data : <dynamic>[])
          .map((e) => SearchProductModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return ApiResponse.completed(list);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}