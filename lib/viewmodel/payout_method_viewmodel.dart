import 'package:flutter/material.dart';
import '../model/payout_method_model.dart';
import '../repo/payout_method_repo.dart';

/// List + delete
class PayoutMethodViewModel extends ChangeNotifier {
  final PayoutMethodRepository _repo = PayoutMethodRepository();

  List<PayoutMethodModel> _methods = [];
  List<PayoutMethodModel> get methods => List.unmodifiable(_methods);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasLoadedOnce = false;
  bool get hasLoadedOnce => _hasLoadedOnce;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _deletingId;
  String? get deletingId => _deletingId;

  String? actionMessage; // delete ka success/error message

  bool get isEmpty => _hasLoadedOnce && _methods.isEmpty;

  Future<void> fetch({bool showLoader = true}) async {
    if (showLoader) {
      _isLoading = true;
      notifyListeners();
    }
    final res = await _repo.getPayoutMethods();
    if (res.isCompleted) {
      _methods = res.data ?? [];
      _hasLoadedOnce = true;
      _errorMessage = null;
    } else {
      _errorMessage = res.message;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() => fetch(showLoader: false);

  Future<bool> delete(String id) async {
    _deletingId = id;
    actionMessage = null;
    notifyListeners();

    final res = await _repo.deletePayoutMethod(id);
    if (res.isCompleted) {
      _methods.removeWhere((m) => m.id == id);
      actionMessage = res.message ?? 'Payout method deleted';
    } else {
      actionMessage = res.message;
    }
    _deletingId = null;
    notifyListeners();
    return res.isCompleted;
  }
}

/// Add UPI form
class AddPayoutMethodViewModel extends ChangeNotifier {
  final PayoutMethodRepository _repo = PayoutMethodRepository();

  bool _isAdding = false;
  bool get isAdding => _isAdding;

  String? errorMessage;
  PayoutMethodModel? created;

  static final RegExp _upiRegex = RegExp(r'^[a-zA-Z0-9.\-_]{2,}@[a-zA-Z]{2,}$');

  static bool isValidUpi(String v) => _upiRegex.hasMatch(v.trim());

  Future<bool> add({required String upiId, String? label}) async {
    if (!isValidUpi(upiId)) {
      errorMessage = 'Valid UPI ID daalein (e.g. name@okhdfcbank)';
      notifyListeners();
      return false;
    }
    _isAdding = true;
    errorMessage = null;
    notifyListeners();

    final res = await _repo.addUpi(upiId: upiId, label: label);

    _isAdding = false;
    if (res.isCompleted && res.data != null) {
      created = res.data;
      notifyListeners();
      return true;
    }
    errorMessage = res.message;
    notifyListeners();
    return false;
  }
}