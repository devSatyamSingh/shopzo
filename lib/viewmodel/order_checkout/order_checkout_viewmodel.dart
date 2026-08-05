import 'package:flutter/material.dart';
import '../../model/address/address_model.dart';
import '../../model/cart/cart_model.dart';
import '../../model/order/order_model.dart';
import '../../model/order_summary/order_preview_model.dart';
import '../../repo/order/order_repo.dart';

class CheckoutLineItem {
  final String? cartItemId;
  final String productId;
  final String? variantId;
  final String productName;
  final String? image;
  final double unitPrice;
  final int quantity;

  const CheckoutLineItem({
    this.cartItemId,
    required this.productId,
    this.variantId,
    required this.productName,
    this.image,
    required this.unitPrice,
    required this.quantity,
  });

  factory CheckoutLineItem.fromCartItem(CartItemModel item) {
    return CheckoutLineItem(
      cartItemId: item.id,
      productId: item.productId,
      variantId: item.variantId,
      productName: item.productName,
      image: item.image,
      unitPrice: item.unitPrice,
      quantity: item.quantity,
    );
  }

  double get lineTotal => unitPrice * quantity;
}

enum PlaceOrderStatus { idle, placing, success, error }
enum PreviewStatus { idle, loading, loaded, error }

class CheckoutViewModel extends ChangeNotifier {
  final OrderRepository _repository = OrderRepository();

  List<CheckoutLineItem> _items = [];
  List<CheckoutLineItem> get items => List.unmodifiable(_items);

  AddressModel? _selectedAddress;
  AddressModel? get selectedAddress => _selectedAddress;

  String? _couponCode;
  String? get couponCode => _couponCode;

  // abhi sirf COD supported hai backend pe
  String _paymentMethod = 'COD';
  String get paymentMethod => _paymentMethod;
  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  // ---------------- ORDER PREVIEW (server-computed summary) ----------------
  OrderPreviewModel? _preview;
  OrderPreviewModel? get preview => _preview;

  PreviewStatus _previewStatus = PreviewStatus.idle;
  PreviewStatus get previewStatus => _previewStatus;
  bool get isPreviewLoading => _previewStatus == PreviewStatus.loading;
  bool get hasPreviewLoadedOnce => _preview != null;
  String? _previewError;
  String? get previewError => _previewError;
  bool get hasCouponApplied => _preview?.hasCouponApplied ?? false;
  String? get couponError => _preview?.couponError;
  bool get hasStockIssue => _preview?.hasStockIssue ?? false;
  double get subtotal => _preview?.subtotal ?? _items.fold(0.0, (s, i) => s + i.lineTotal);
  double get discount => _preview?.discount ?? 0;
  double get tax => _preview?.tax ?? 0;
  double get total => _preview?.total ?? (subtotal - discount).clamp(0, double.infinity);
  int get itemCount => _items.length;
  bool get hasItems => _items.isNotEmpty;
  PlaceOrderStatus _placeOrderStatus = PlaceOrderStatus.idle;
  PlaceOrderStatus get placeOrderStatus => _placeOrderStatus;
  bool get isPlacingOrder => _placeOrderStatus == PlaceOrderStatus.placing;
  String? _placeOrderError;
  String? get placeOrderError => _placeOrderError;
  OrderModel? _lastPlacedOrder;
  OrderModel? get lastPlacedOrder => _lastPlacedOrder;


  void startCheckout(List<CheckoutLineItem> items) {
    _items = List.of(items);
    _selectedAddress = null;
    _couponCode = null;
    _paymentMethod = 'COD';
    _preview = null;
    _previewStatus = PreviewStatus.idle;
    _previewError = null;
    _placeOrderStatus = PlaceOrderStatus.idle;
    _placeOrderError = null;
    _lastPlacedOrder = null;
    notifyListeners();
  }

  void setAddress(AddressModel address) {
    _selectedAddress = address;
    notifyListeners();
    fetchPreview();
  }

  Future<void> applyCoupon(String code) async {
    if (code.trim().isEmpty) return;
    _couponCode = code.trim();
    await fetchPreview();
  }

  void removeCoupon() {
    _couponCode = null;
    fetchPreview();
  }

  Future<void> fetchPreview() async {
    if (_items.isEmpty) return;
    _previewStatus = PreviewStatus.loading;
    _previewError = null;
    notifyListeners();

    final requestItems = _items
        .map((i) => OrderRequestItem(
      productId: i.productId,
      variantId: i.variantId,
      quantity: i.quantity,
    )).toList();

    final result = await _repository.previewOrder(
      items: requestItems,
      addressId: _selectedAddress?.id,
      couponCode: _couponCode,
    );

    if (result.isCompleted && result.data != null) {
      _preview = result.data;
      _previewStatus = PreviewStatus.loaded;
    } else {
      _previewStatus = PreviewStatus.error;
      _previewError = result.message ?? 'Failed to calculate order summary';
    }
    notifyListeners();
  }

  Future<bool> placeOrder() async {
    if (_items.isEmpty) {
      _placeOrderStatus = PlaceOrderStatus.error;
      _placeOrderError = 'No items to order';
      notifyListeners();
      return false;
    }
    if (_selectedAddress == null) {
      _placeOrderStatus = PlaceOrderStatus.error;
      _placeOrderError = 'Please select a delivery address';
      notifyListeners();
      return false;
    }

    _placeOrderStatus = PlaceOrderStatus.placing;
    _placeOrderError = null;
    notifyListeners();

    final requestItems = _items
        .map((i) => OrderRequestItem(
      productId: i.productId,
      variantId: i.variantId,
      quantity: i.quantity,
    ))
        .toList();

    final cartItemIds = _items
        .where((i) => i.cartItemId != null && i.cartItemId!.isNotEmpty)
        .map((i) => i.cartItemId!)
        .toList();

    final result = await _repository.placeOrder(
      items: requestItems,
      addressId: _selectedAddress!.id,
      couponCode: hasCouponApplied ? _couponCode : null,
      cartItemIds: cartItemIds,
      paymentMethod: _paymentMethod,
    );

    if (result.isCompleted && result.data != null) {
      _lastPlacedOrder = result.data;
      _placeOrderStatus = PlaceOrderStatus.success;
      notifyListeners();
      return true;
    } else {
      _placeOrderStatus = PlaceOrderStatus.error;
      _placeOrderError = result.message ?? 'Failed to place order';
      notifyListeners();
      return false;
    }
  }

  List<String> get orderedCartItemIds => _items
      .where((i) => i.cartItemId != null && i.cartItemId!.isNotEmpty)
      .map((i) => i.cartItemId!)
      .toList();


  void reset() {
    _items = [];
    _selectedAddress = null;
    _couponCode = null;
    _paymentMethod = 'COD';
    _preview = null;
    _previewStatus = PreviewStatus.idle;
    _previewError = null;
    _placeOrderStatus = PlaceOrderStatus.idle;
    _placeOrderError = null;
    _lastPlacedOrder = null;
    notifyListeners();
  }
}