import '../helper/network/network_api_services.dart';
import '../helper/response/api_response.dart';
import '../helper/app_exception.dart';
import '../model/order_model.dart';

class OrderRepository {
  final NetworkApiServices _apiServices = NetworkApiServices();

  static const String _ordersUrl = 'https://madhu.fctesting.shop/api/v1/orders';
  static const String _placeOrderUrl = 'https://madhu.fctesting.shop/api/v1/orders/online';
  static const String _previewOrderUrl = 'https://madhu.fctesting.shop/api/v1/orders/preview';

  Future<ApiResponse<OrderModel>> placeOrder({
    required List<OrderRequestItem> items,
    required String addressId,
    String? couponCode,
    required List<String> cartItemIds,
    String paymentMethod = 'COD',
  }) async {
    try {
      final body = <String, dynamic>{
        'items': items.map((e) => e.toJson()).toList(),
        'addressId': addressId,
        if (couponCode != null && couponCode.trim().isNotEmpty)
          'couponCode': couponCode.trim(),
        'cartItemIds': cartItemIds,
        'paymentMethod': paymentMethod,
      };

      final response = await _apiServices.getPostApiResponse(_placeOrderUrl, body);
      final data = (response is Map ? response['data'] : null) as Map<String, dynamic>?;

      if (data == null) {
        return ApiResponse.error('Order could not be created. Please try again.');
      }
      return ApiResponse.completed(OrderModel.fromJson(data));
    } on AppException catch (e) {
      return ApiResponse.error(e.message.isNotEmpty ? e.message : 'Failed to place order.');
    } catch (e) {
      return ApiResponse.error('Failed to place order. Please try again.');
    }
  }

  /// POST /api/v1/orders/preview — see previous message for full docs
  Future<ApiResponse<dynamic>> previewOrder({
    required List<OrderRequestItem> items,
    String? addressId,
    String? couponCode,
  }) async {
    // (unchanged from previous implementation — kept here for completeness)
    throw UnimplementedError('Use the version already added in the previous step');
  }

  /// GET /api/v1/orders — logged-in customer ke saare orders, latest pehle
  Future<ApiResponse<List<OrderModel>>> getAllOrders() async {
    try {
      final response = await _apiServices.getGetApiResponse(_ordersUrl);
      final data = (response is Map ? response['data'] : null) as List<dynamic>?;

      if (data == null) return ApiResponse.completed(<OrderModel>[]);

      final orders = data
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList();

      // Server generally latest-first bhejta hai, safe side ke liye yaha
      // bhi sort kar lete hain
      orders.sort((a, b) =>
          (b.createdAt ?? DateTime(2000)).compareTo(a.createdAt ?? DateTime(2000)));

      return ApiResponse.completed(orders);
    } on AppException catch (e) {
      return ApiResponse.error(e.message.isNotEmpty ? e.message : 'Failed to load orders.');
    } catch (e) {
      return ApiResponse.error('Failed to load orders. Please try again.');
    }
  }

  /// GET /api/v1/orders/:id — full detail (nested product/variant/
  /// customer/address included)
  Future<ApiResponse<OrderModel>> getOrderById(String orderId) async {
    try {
      final response = await _apiServices.getGetApiResponse('$_ordersUrl/$orderId');
      final data = (response is Map ? response['data'] : null) as Map<String, dynamic>?;

      if (data == null) {
        return ApiResponse.error('Order not found.');
      }
      return ApiResponse.completed(OrderModel.fromJson(data));
    } on AppException catch (e) {
      return ApiResponse.error(e.message.isNotEmpty ? e.message : 'Failed to load order.');
    } catch (e) {
      return ApiResponse.error('Failed to load order. Please try again.');
    }
  }

  /// POST /api/v1/orders/:id/cancel — body: { "reason": "..." }
  Future<ApiResponse<bool>> cancelOrder(String orderId, String reason) async {
    try {
      final response = await _apiServices.getPostApiResponse(
        '$_ordersUrl/$orderId/cancel',
        {'reason': reason},
      );
      final success = (response is Map && response['data'] != null);
      if (!success) {
        return ApiResponse.error('Could not cancel order. Please try again.');
      }
      return ApiResponse.completed(true);
    } on AppException catch (e) {
      return ApiResponse.error(e.message.isNotEmpty ? e.message : 'Failed to cancel order.');
    } catch (e) {
      return ApiResponse.error('Failed to cancel order. Please try again.');
    }
  }
}