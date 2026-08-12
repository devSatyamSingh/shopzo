import '../../helper/app_exception.dart';
import '../../helper/network/network_api_services.dart';
import '../../helper/response/api_response.dart';
import '../../model/product/product_detail_model.dart';
import '../../model/product/product_list_model.dart';
import '../../res/api_urls.dart';

class ProductRepository {
  final NetworkApiServices _apiServices = NetworkApiServices();

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

  /// GET /websiteProducts/:slug — sirf "relatedProducts" nikalne ke liye use ho raha hai,
  /// kyunki getProductById is field ko return nahi karta.
  Future<ApiResponse<List<RelatedProductModel>>> getRelatedProductsBySlug(String slug) async {
    try {
      final response = await _apiServices.getGetApiResponse(ApiUrl.websiteProductBySlug(slug));
      final data = (response as Map<String, dynamic>)['data'] as Map<String, dynamic>? ?? {};
      final List<dynamic> rawList = (data['relatedProducts'] as List<dynamic>?) ?? [];

      final related = rawList
          .map((e) => RelatedProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResponse.completed(related);
    } on AppException catch (e) {
      return ApiResponse.error(e.message.isNotEmpty ? e.message : e.toString());
    } catch (e) {
      return ApiResponse.error('Something went wrong. Please try again.');
    }
  }
}