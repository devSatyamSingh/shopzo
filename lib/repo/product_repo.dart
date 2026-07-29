import '../helper/app_exception.dart';
import '../helper/network/network_api_services.dart';
import '../helper/response/api_response.dart';
import '../model/product_detail_model.dart';
import '../model/product_list_model.dart';
import '../res/api_urls.dart';

/// Shopzo — Product Repository.
class ProductRepository {
  final NetworkApiServices _apiServices = NetworkApiServices();

  /// GET /websiteProducts — used by Home (Trending Now, Flash Deals,
  /// Top Picks) and category listing screens.
  Future<ApiResponse<List<ProductListModel>>> getWebsiteProducts({
    int page = 1,
    int limit = 20,
    String? categoryId,
    String? search,
  }) async {
    try {
      final url = ApiUrl.websiteProducts(
        page: page,
        limit: limit,
        categoryId: categoryId,
        search: search,
      );
      final response = await _apiServices.getGetApiResponse(url);
      final map = response as Map<String, dynamic>;
      final dynamic rawData = map['data'];

      // API has returned this either as a plain array, or as
      // { products: [...], total, page, limit } — handle both safely.
      List<dynamic> rawList;
      if (rawData is List) {
        rawList = rawData;
      } else if (rawData is Map && rawData['products'] is List) {
        rawList = rawData['products'] as List<dynamic>;
      } else {
        rawList = const [];
      }

      final products =
      rawList.map((e) => ProductListModel.fromJson(e as Map<String, dynamic>)).toList();
      return ApiResponse.completed(products);
    } on AppException catch (e) {
      return ApiResponse.error(e.message.isNotEmpty ? e.message : e.toString());
    } catch (e) {
      return ApiResponse.error('Something went wrong. Please try again.');
    }
  }

  /// GET /products/:id — full detail with variants + attributes + reviews.
  Future<ApiResponse<ProductDetailModel>> getProductById(String id) async {
    try {
      final response = await _apiServices.getGetApiResponse(ApiUrl.productById(id));
      final data = (response as Map<String, dynamic>)['data'] as Map<String, dynamic>? ?? {};
      return ApiResponse.completed(ProductDetailModel.fromJson(data));
    } on AppException catch (e) {
      return ApiResponse.error(e.message.isNotEmpty ? e.message : e.toString());
    } catch (e) {
      return ApiResponse.error('Something went wrong. Please try again.');
    }
  }
}