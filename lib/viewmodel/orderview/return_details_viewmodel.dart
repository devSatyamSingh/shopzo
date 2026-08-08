import 'package:flutter/material.dart';
import '../../model/order/return_model.dart';
import '../../repo/order/return_repo.dart';

enum ReturnDetailStatus { loading, loaded, error }

class ReturnDetailViewModel extends ChangeNotifier {
  final ReturnRepository _repository = ReturnRepository();

  String? _returnId;
  String? get returnId => _returnId;

  ReturnModel? _returnRequest;
  ReturnModel? get returnRequest => _returnRequest;

  ReturnDetailStatus _status = ReturnDetailStatus.loading;
  ReturnDetailStatus get status => _status;
  bool get isLoading => _status == ReturnDetailStatus.loading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isCancelling = false;
  bool get isCancelling => _isCancelling;

  String? _cancelError;
  String? get cancelError => _cancelError;

  Future<void> fetchReturn(String id) async {
    _returnId = id;
    _status = ReturnDetailStatus.loading;
    notifyListeners();

    final response = await _repository.getReturnById(id);

    if (response.isCompleted && response.data != null) {
      _returnRequest = response.data;
      _status = ReturnDetailStatus.loaded;
      _errorMessage = null;
    } else {
      _errorMessage = response.message ?? 'Failed to load return request';
      _status = ReturnDetailStatus.error;
    }
    notifyListeners();
  }

  Future<bool> cancelReturn() async {
    if (_returnRequest == null) return false;
    _isCancelling = true;
    _cancelError = null;
    notifyListeners();

    final response = await _repository.cancelReturn(_returnRequest!.id);

    if (response.isCompleted) {
      await fetchReturn(_returnRequest!.id);
      _isCancelling = false;
      notifyListeners();
      return true;
    } else {
      _cancelError = response.message ?? 'Failed to cancel return request';
      _isCancelling = false;
      notifyListeners();
      return false;
    }
  }
}