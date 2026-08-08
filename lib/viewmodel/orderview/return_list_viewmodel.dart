import 'package:flutter/material.dart';
import '../../model/order/return_model.dart';
import '../../repo/order/return_repo.dart';

class ReturnListViewModel extends ChangeNotifier {
  final ReturnRepository _repository = ReturnRepository();

  List<ReturnModel> _returns = [];
  List<ReturnModel> get returns => List.unmodifiable(_returns);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasLoadedOnce = false;
  bool get hasLoadedOnce => _hasLoadedOnce;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isEmpty => _hasLoadedOnce && _returns.isEmpty;

  Future<void> fetchReturns({bool showLoader = true}) async {
    if (showLoader) {
      _isLoading = true;
      notifyListeners();
    }

    final response = await _repository.getAllReturns();

    if (response.isCompleted) {
      _returns = response.data ?? [];
      _hasLoadedOnce = true;
      _errorMessage = null;
    } else {
      _errorMessage = response.message ?? 'Failed to load return requests';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() => fetchReturns(showLoader: false);
}