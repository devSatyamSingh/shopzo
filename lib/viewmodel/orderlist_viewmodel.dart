import 'package:flutter/material.dart';
import '../model/order_model.dart';
import '../repo/order_repo.dart';

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

  /// Filter tabs (All / Processing / Shipped / Delivered wagera) ke liye —
  /// null pass karo to sab orders milenge
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

  /// Naya order place hone ke turant baad list ko refresh karne ke liye
  /// (e.g. checkout success ke baad OrdersScreen pe aaye to fresh dikhe)
  Future<void> refresh() => fetchOrders(showLoader: false);
}