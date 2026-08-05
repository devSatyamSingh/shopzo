import '../../helper/network/network_api_services.dart';
import '../../helper/response/api_response.dart';
import '../../helper/app_exception.dart';
import '../../res/api_urls.dart';
import '../model/wishlist_model.dart';

class WishlistRepository {
  final NetworkApiServices _apiServices = NetworkApiServices();

  /// GET /api/v1/website/wishlist
  Future<ApiResponse<List<WishlistItemModel>>> getWishlist() async {
    try {
      final response = await _apiServices.getGetApiResponse(ApiUrl.wishlist);
      final data = (response is Map ? response['data'] : null) as List<dynamic>?;

      if (data == null) return ApiResponse.completed(<WishlistItemModel>[]);

      final items = data.map((e) => WishlistItemModel.fromJson(e as Map<String, dynamic>)).toList();
      return ApiResponse.completed(items);
    } on AppException catch (e) {
      return ApiResponse.error(e.message.isNotEmpty ? e.message : 'Failed to load wishlist.');
    } catch (e) {
      return ApiResponse.error('Failed to load wishlist. Please try again.');
    }
  }

  /// POST /api/v1/website/wishlist/toggle — body: { productId, variantId? }
  /// Returns true if item is now wishlisted, false if it was removed.
  Future<ApiResponse<bool>> toggleWishlist({required String productId, String? variantId}) async {
    try {
      final body = <String, dynamic>{
        'productId': productId,
        if (variantId != null && variantId.isNotEmpty) 'variantId': variantId,
      };

      final response = await _apiServices.getPostApiResponse(ApiUrl.wishlistToggle, body);
      final data = (response is Map ? response['data'] : null) as Map<String, dynamic>?;

      if (data == null) {
        return ApiResponse.error('Could not update wishlist. Please try again.');
      }
      return ApiResponse.completed(data['wishlisted'] == true);
    } on AppException catch (e) {
      return ApiResponse.error(e.message.isNotEmpty ? e.message : 'Failed to update wishlist.');
    } catch (e) {
      return ApiResponse.error('Failed to update wishlist. Please try again.');
    }
  }

  /// POST /api/v1/website/wishlist/:id/move-to-cart
  Future<ApiResponse<bool>> moveToCart(String wishlistItemId) async {
    try {
      final response = await _apiServices.getPostApiResponse(ApiUrl.wishlistMoveToCart(wishlistItemId), {});
      final data = (response is Map ? response['data'] : null) as Map<String, dynamic>?;

      if (data == null) {
        return ApiResponse.error('Could not move item to cart. Please try again.');
      }
      return ApiResponse.completed(data['moved'] == true);
    } on AppException catch (e) {
      return ApiResponse.error(e.message.isNotEmpty ? e.message : 'Failed to move item to cart.');
    } catch (e) {
      return ApiResponse.error('Failed to move item to cart. Please try again.');
    }
  }
}