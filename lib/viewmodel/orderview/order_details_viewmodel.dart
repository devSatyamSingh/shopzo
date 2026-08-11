import 'dart:async';

import 'package:flutter/material.dart';
import '../../model/order/order_model.dart';
import '../../model/order/return_model.dart';
import '../../repo/order/order_repo.dart';
import '../../repo/order/return_repo.dart';

enum OrderDetailStatus { loading, loaded, error }

class OrderDetailViewModel extends ChangeNotifier {
  final OrderRepository _repository = OrderRepository();
  final ReturnRepository _returnRepo = ReturnRepository();

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

  // orderItemId -> uski latest return/exchange request (agar hai to)
  Map<String, ReturnModel> _returnsByOrderItem = {};
  Map<String, ReturnModel> get returnsByOrderItem => _returnsByOrderItem;

  Future<void> fetchOrder(String orderId) async {
    _orderId = orderId;
    _status = OrderDetailStatus.loading;
    notifyListeners();

    final response = await _repository.getOrderById(orderId);

    if (response.isCompleted && response.data != null) {
      _order = response.data;
      _status = OrderDetailStatus.loaded;
      _errorMessage = null;

      unawaited(_loadReturnsForItems());
    } else {
      _errorMessage = response.message ?? 'Failed to load order';
      _status = OrderDetailStatus.error;
    }
    notifyListeners();
  }

  Future<void> _loadReturnsForItems() async {
    if (_order == null) return;
    final res = await _returnRepo.getAllReturns();
    if (res.isCompleted && res.data != null) {
      final map = <String, ReturnModel>{};
      for (final r in res.data!) {
        // cancelled request dobara return allow karna chahiye,
        // isliye cancelled ko map me mat rakho — baaki sab (requested/approved/rejected/completed) rakho
        if (r.status == ReturnStatus.cancelled) continue;
        // agar same item ka multiple entries hain to sabse latest wala rakho
        final existing = map[r.orderItemId];
        if (existing == null ||
            (r.createdAt != null &&
                existing.createdAt != null &&
                r.createdAt!.isAfter(existing.createdAt!))) {
          map[r.orderItemId] = r;
        }
      }
      _returnsByOrderItem = map;
      notifyListeners();
    }
  }

  Future<bool> cancelOrder(String reason) async {
    if (_order == null) return false;
    _isCancelling = true;
    _cancelError = null;
    notifyListeners();

    final response = await _repository.cancelOrder(_order!.id, reason);

    if (response.isCompleted) {
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