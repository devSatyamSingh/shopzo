import 'package:flutter/material.dart';
import '../model/coupon_model.dart';
import '../repo/coupon_repo.dart';

class CouponViewModel extends ChangeNotifier {
  final CouponRepository _repository = CouponRepository();

  // ---- Coupon LIST state ----
  List<CouponModel> _coupons = [];
  List<CouponModel> get coupons => _coupons;

  bool _isLoadingList = false;
  bool get isLoadingList => _isLoadingList;

  String? _listError;
  String? get listError => _listError;

  // ---- APPLY / VALIDATE state ----
  bool _isValidating = false;
  bool get isValidating => _isValidating;

  String? _validatingCode;
  String? get validatingCode => _validatingCode;

  CouponModel? _appliedCoupon;
  CouponModel? get appliedCoupon => _appliedCoupon;
  bool get hasCouponApplied => _appliedCoupon != null;

  double _discount = 0;
  double get discount => _discount;

  double? _finalAmount;
  double? get finalAmount => _finalAmount;

  /// The exact subtotal this coupon was validated against. Callers use
  /// this to detect when the underlying cart selection has drifted
  /// (item removed / unselected / quantity changed) and the applied
  /// discount is no longer valid for the current total.
  double? _appliedSubtotal;
  double? get appliedSubtotal => _appliedSubtotal;

  String? _validationMessage;
  String? get validationMessage => _validationMessage;

  bool _lastAttemptSucceeded = false;
  bool get lastAttemptSucceeded => _lastAttemptSucceeded;

  Future<void> fetchCoupons() async {
    _isLoadingList = true;
    _listError = null;
    notifyListeners();

    final result = await _repository.getActiveCoupons();

    if (result.isCompleted && result.data != null) {
      _coupons = result.data!;
    } else {
      _listError = result.message ?? 'Failed to load coupons';
    }
    _isLoadingList = false;
    notifyListeners();
  }

  /// Applies a coupon against a given subtotal.
  /// Caller decides what subtotal means (full cart / single product /
  /// selected items) — this function doesn't care about the source.
  Future<bool> applyCoupon({required String code, required double subtotal}) async {
    if (code.trim().isEmpty) return false;

    final normalizedCode = code.trim().toUpperCase();
    _isValidating = true;
    _validatingCode = normalizedCode;
    _validationMessage = null;
    notifyListeners();

    final result = await _repository.validateCoupon(code: normalizedCode, subtotal: subtotal);

    _isValidating = false;
    _validatingCode = null;

    if (result.isCompleted && result.data != null && result.data!.valid) {
      final data = result.data!;
      _discount = data.discount;
      _finalAmount = data.finalAmount;
      _appliedSubtotal = subtotal;
      _appliedCoupon = CouponModel(
        code: data.code,
        discountType: data.discountType ?? 'FLAT',
        value: data.discount,
        minOrderValue: 0,
      );
      _validationMessage = 'Coupon "${data.code}" applied! You saved ₹${data.discount.toStringAsFixed(0)}';
      _lastAttemptSucceeded = true;
      notifyListeners();
      return true;
    } else {
      _appliedCoupon = null;
      _discount = 0;
      _finalAmount = null;
      _appliedSubtotal = null;
      _validationMessage = result.data?.message ?? result.message ?? 'This coupon is not valid for your order';
      _lastAttemptSucceeded = false;
      notifyListeners();
      return false;
    }
  }

  void removeCoupon() {
    _appliedCoupon = null;
    _discount = 0;
    _finalAmount = null;
    _appliedSubtotal = null;
    _validationMessage = null;
    notifyListeners();
  }

  /// Call this when leaving checkout / starting a fresh order
  void reset() {
    _coupons = [];
    _appliedCoupon = null;
    _discount = 0;
    _finalAmount = null;
    _appliedSubtotal = null;
    _validationMessage = null;
    _isLoadingList = false;
    _isValidating = false;
    _validatingCode = null;
    notifyListeners();
  }
}