import 'package:flutter/material.dart';
import '../../model/order/order_model.dart';
import '../../repo/order/order_repo.dart';

class OrderViewModel extends ChangeNotifier {
  final OrderRepository _repository = OrderRepository();

  List<OrderModel> _orders = [];
  List<OrderModel> get orders => List.unmodifiable(_orders);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasLoadedOnce = false;
  bool get hasLoadedOnce => _hasLoadedOnce;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isEmpty => _hasLoadedOnce && _orders.isEmpty;

  List<OrderModel> ordersByStatus(OrderStatus? status) {
    if (status == null) return orders;
    return _orders.where((o) => o.status == status).toList();
  }

  Future<void> fetchOrders({bool showLoader = true}) async {
    if (showLoader) {
      _isLoading = true;
      notifyListeners();
    }

    final response = await _repository.getAllOrders();

    if (response.isCompleted) {
      _orders = response.data ?? [];
      _hasLoadedOnce = true;
      _errorMessage = null;
    } else {
      _errorMessage = response.message ?? 'Failed to load orders';
    }

    _isLoading = false;
    notifyListeners();
  }
  Future<void> refresh() => fetchOrders(showLoader: false);
}