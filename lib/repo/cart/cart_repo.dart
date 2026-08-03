import '../../helper/network/base_api_services.dart';
import '../../helper/network/network_api_services.dart';
import '../../helper/app_exception.dart'; // matches network_api_services.dart's own '../app_exception.dart' import
import '../../helper/response/api_response.dart';
import '../../res/api_urls.dart';
import '../../model/cart/cart_model.dart';

class CartRepository {
  final BaseApiServices _apiServices;

  CartRepository({BaseApiServices? apiServices})
      : _apiServices = apiServices ?? NetworkApiServices();

  Future<ApiResponse<CartModel>> getCart() async {
    try {
      final response = await _apiServices.getGetApiResponse(ApiUrl.cart);
      final data = (response is Map ? response['data'] : null)
      as Map<String, dynamic>? ??
          {};
      return ApiResponse.completed(CartModel.fromJson(data));
    } on AppException catch (e) {
      return ApiResponse.error(e.message.isNotEmpty ? e.message : e.prefix);
    } catch (_) {
      return ApiResponse.error('Something went wrong while loading your cart.');
    }
  }

  Future<ApiResponse<CartModel>> addToCart({
    required String productId,
    String? variantId,
    int quantity = 1,
  }) async {
    try {
      final body = <String, dynamic>{
        'productId': productId,
        'quantity': quantity,
        if (variantId != null && variantId.trim().isNotEmpty)
          'variantId': variantId,
      };

      final response =
      await _apiServices.getPostApiResponse(ApiUrl.cartItems, body);
      final data = (response is Map ? response['data'] : null)
      as Map<String, dynamic>? ??
          {};
      return ApiResponse.completed(CartModel.fromJson(data));
    } on AppException catch (e) {
      return ApiResponse.error(e.message.isNotEmpty ? e.message : e.prefix);
    } catch (_) {
      return ApiResponse.error('Something went wrong while adding to cart.');
    }
  }

  Future<ApiResponse<CartModel>> updateCartItem({
    required String itemId,
    required int quantity,
  }) async {
    try {
      final response = await _apiServices.getPatchApiResponse(
        ApiUrl.cartItem(itemId),
        {'quantity': quantity},
      );
      final data = (response is Map ? response['data'] : null)
      as Map<String, dynamic>? ??
          {};
      return ApiResponse.completed(CartModel.fromJson(data));
    } on AppException catch (e) {
      return ApiResponse.error(e.message.isNotEmpty ? e.message : e.prefix);
    } catch (_) {
      return ApiResponse.error('Something went wrong while updating quantity.');
    }
  }

  Future<ApiResponse<CartModel>> removeCartItem({required String itemId}) async {
    try {
      final response =
      await _apiServices.getDeleteApiResponse(ApiUrl.cartItem(itemId));
      final data = (response is Map ? response['data'] : null)
      as Map<String, dynamic>? ??
          {};
      return ApiResponse.completed(CartModel.fromJson(data));
    } on AppException catch (e) {
      return ApiResponse.error(e.message.isNotEmpty ? e.message : e.prefix);
    } catch (_) {
      return ApiResponse.error('Something went wrong while removing the item.');
    }
  }

  Future<ApiResponse<CartModel>> clearCart() async {
    try {
      final response = await _apiServices.getDeleteApiResponse(ApiUrl.cart);
      final data = (response is Map ? response['data'] : null)
      as Map<String, dynamic>? ??
          {};
      return ApiResponse.completed(CartModel.fromJson(data));
    } on AppException catch (e) {
      return ApiResponse.error(e.message.isNotEmpty ? e.message : e.prefix);
    } catch (_) {
      return ApiResponse.error('Something went wrong while clearing your cart.');
    }
  }
}