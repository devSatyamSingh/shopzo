import 'package:flutter/material.dart';
import '../helper/response/api_response.dart';
import '../model/cart_model.dart';
import '../repo/cart_repo.dart';
import '../utils/utils.dart'; // AppUtils — matches import used in network_api_services.dart


class CartViewModel extends ChangeNotifier {
  final CartRepository _repository;

  CartViewModel({CartRepository? repository})
      : _repository = repository ?? CartRepository();

  ApiResponse<CartModel> _cartState = ApiResponse.completed(CartModel.empty());
  ApiResponse<CartModel> get cartState => _cartState;

  bool _hasLoadedOnce = false;
  bool get hasLoadedOnce => _hasLoadedOnce;

  CartModel get cart => _cartState.data ?? CartModel.empty();
  bool get isLoading => _cartState.isLoading;
  bool get isError => _cartState.isError;
  String? get errorMessage => _cartState.message;
  bool get isEmpty => cart.isEmpty;
  int get itemCount => cart.itemCount;
  double get subtotal => cart.subtotal;

  final Set<String> _updatingItemIds = {};
  bool isItemUpdating(String itemId) => _updatingItemIds.contains(itemId);

  final Set<String> _addingProductIds = {};
  bool isAdding(String productId) => _addingProductIds.contains(productId);


  bool isInCart(String productId, {String? variantId}) =>
      cart.findItem(productId, variantId) != null;

  int quantityInCart(String productId, {String? variantId}) =>
      cart.findItem(productId, variantId)?.quantity ?? 0;


  Future<void> fetchCart({bool showLoader = true}) async {
    if (showLoader) {
      _cartState = ApiResponse.loading();
      notifyListeners();
    }

    final response = await _repository.getCart();
    _cartState = response;
    if (response.isCompleted) _hasLoadedOnce = true;
    notifyListeners();
  }

  Future<bool> addToCart({
    required String productId,
    String? variantId,
    int quantity = 1,
    BuildContext? context,
    bool silent = false,
  }) async {
    _addingProductIds.add(productId);
    notifyListeners();

    final response = await _repository.addToCart(
      productId: productId,
      variantId: variantId,
      quantity: quantity,
    );

    if (response.isCompleted) {
      _cartState = response;
      _hasLoadedOnce = true;
      if (!silent) AppUtils.success(context, 'Item added to cart');
    } else {
      AppUtils.error(context,
          response.message ?? 'Something went wrong while adding to cart.');
    }

    _addingProductIds.remove(productId);
    notifyListeners();
    return response.isCompleted;
  }


  Future<void> updateQuantity({
    required String itemId,
    required int quantity,
    BuildContext? context,
  }) async {
    if (quantity < 1) return;

    final previousState = _cartState; // for revert on failure

    _updatingItemIds.add(itemId);
    notifyListeners();

    final response = await _repository.updateCartItem(itemId: itemId, quantity: quantity);

    if (response.isCompleted) {
      _cartState = response;
    } else {
      _cartState = previousState; // revert optimistic UI
      AppUtils.error(context, response.message ?? 'Something went wrong while updating quantity.');
    }

    _updatingItemIds.remove(itemId);
    notifyListeners();
  }

  /// Convenience wrappers for the +/- buttons in CartScreen's stepper
  Future<void> incrementQuantity(CartItemModel item, {BuildContext? context}) {
    return updateQuantity(itemId: item.id, quantity: item.quantity + 1, context: context);
  }

  Future<void> decrementQuantity(CartItemModel item, {BuildContext? context}) {
    if (item.quantity <= 1) {
      // going below 1 should remove the item, not silently no-op
      return removeItem(itemId: item.id, context: context);
    }
    return updateQuantity(itemId: item.id, quantity: item.quantity - 1, context: context);
  }

  /// ------------------------------------------------------------
  /// Remove a single line item.
  /// ------------------------------------------------------------
  Future<void> removeItem({required String itemId, BuildContext? context}) async {
    _updatingItemIds.add(itemId);
    notifyListeners();

    final response = await _repository.removeCartItem(itemId: itemId);

    if (response.isCompleted) {
      _cartState = response;
      AppUtils.success(context, 'Item removed from cart');
    } else {
      AppUtils.error(context, response.message ?? 'Something went wrong while removing the item.');
    }

    _updatingItemIds.remove(itemId);
    notifyListeners();
  }

  /// ------------------------------------------------------------
  /// Clear the entire cart (e.g. after successful order placement,
  /// or from a "Clear Cart" action).
  /// ------------------------------------------------------------
  Future<void> clearCart({BuildContext? context, bool silent = false}) async {
    _cartState = ApiResponse.loading();
    notifyListeners();

    final response = await _repository.clearCart();
    _cartState = response;

    if (response.isCompleted) {
      if (!silent) AppUtils.success(context, 'Cart cleared');
    } else {
      if (!silent) AppUtils.error(context, response.message ?? 'Something went wrong while clearing your cart.');
    }

    notifyListeners();
  }

  /// Reset local state on logout — call this from your logout flow
  /// so the next user doesn't briefly see the previous user's cart.
  void resetOnLogout() {
    _cartState = ApiResponse.completed(CartModel.empty());
    _hasLoadedOnce = false;
    _updatingItemIds.clear();
    _addingProductIds.clear();
    notifyListeners();
  }
}