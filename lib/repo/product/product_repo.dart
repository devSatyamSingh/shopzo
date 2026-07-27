import '../../helper/app_exception.dart';
import '../../helper/network/network_api_services.dart';
import '../../helper/response/api_response.dart';
import '../../model/product_by_category/product_model.dart';
import '../../res/api_urls.dart';

/// Shopzo — Product Repository.
class ProductRepository {
  final NetworkApiServices _apiServices = NetworkApiServices();

  /// Category filtering works for ANY level — pass a leaf category's id
  /// (e.g. Jeans, Skincare) and the backend returns only that category's
  /// products, since every product already carries its own categoryId.
  Future<ApiResponse<ProductListResult>> getProducts({
    required int page,
    int limit = 20,
    String? categoryId,
    String? search,
  }) async {
    try {
      final url = ApiUrl.products(
        page: page,
        limit: limit,
        categoryId: categoryId,
        search: search,
      );
      final response = await _apiServices.getGetApiResponse(url);
      final map = response as Map<String, dynamic>;

      final list = (map['data'] as List<dynamic>? ?? [])
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final pagination =
      PaginationModel.fromJson(map['pagination'] as Map<String, dynamic>? ?? {});

      return ApiResponse.completed(
        ProductListResult(products: list, pagination: pagination),
      );
    } on AppException catch (e) {
      return ApiResponse.error(e.message.isNotEmpty ? e.message : e.toString());
    } catch (e) {
      return ApiResponse.error('Something went wrong. Please try again.');
    }
  }
}