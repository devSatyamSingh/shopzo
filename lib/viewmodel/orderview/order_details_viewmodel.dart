import 'package:flutter/material.dart';
import '../../model/order/order_model.dart';
import '../../repo/order/order_repo.dart';

enum OrderDetailStatus { loading, loaded, error }

class OrderDetailViewModel extends ChangeNotifier {
  final OrderRepository _repository = OrderRepository();

  String? _orderId;
  String? get orderId => _orderId;

  bool _isCancelling = false;
  bool get isCancelling => _isCancelling;

  String? _cancelError;
  String? get cancelError => _cancelError;

  OrderModel? _order;
  OrderModel? get order => _order;

  OrderDetailStatus _status = OrderDetailStatus.loading;
  OrderDetailStatus get status => _status;
  bool get isLoading => _status == OrderDetailStatus.loading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchOrder(String orderId) async {
    _orderId = orderId;
    _status = OrderDetailStatus.loading;
    notifyListeners();

    final response = await _repository.getOrderById(orderId);

    if (response.isCompleted && response.data != null) {
      _order = response.data;
      _status = OrderDetailStatus.loaded;
      _errorMessage = null;
    } else {
      _errorMessage = response.message ?? 'Failed to load order';
      _status = OrderDetailStatus.error;
    }
    notifyListeners();
  }

  Future<bool> cancelOrder(String reason) async {
    if (_order == null) return false;
    _isCancelling = true;
    _cancelError = null;
    notifyListeners();

    final response = await _repository.cancelOrder(_order!.id, reason);

    if (response.isCompleted) {
      // re-fetch to get fresh status/refund info from server
      await fetchOrder(_order!.id);
      _isCancelling = false;
      notifyListeners();
      return true;
    } else {
      _cancelError = response.message ?? 'Failed to cancel order';
      _isCancelling = false;
      notifyListeners();
      return false;
    }
  }
}