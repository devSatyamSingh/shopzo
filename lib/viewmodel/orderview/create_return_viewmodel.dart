import 'dart:io';
import 'package:flutter/material.dart';
import '../../model/order/return_model.dart';
import '../../model/payout_method_model.dart';
import '../../repo/order/return_repo.dart';
import '../../repo/payout_method_repo.dart';
import '../../repo/product/product_repo.dart';

enum CreateReturnStatus { idle, submitting, success, error }

class SimpleVariantOption {
  final String id;
  final String name;
  const SimpleVariantOption({required this.id, required this.name});
}

class CreateReturnViewModel extends ChangeNotifier {
  final ReturnRepository _returnRepo = ReturnRepository();
  final ProductRepository _productRepo = ProductRepository();
  final PayoutMethodRepository _payoutRepo = PayoutMethodRepository();

  CreateReturnStatus _status = CreateReturnStatus.idle;
  CreateReturnStatus get status => _status;
  bool get isSubmitting => _status == CreateReturnStatus.submitting;
  bool get isSuccess => _status == CreateReturnStatus.success;

  bool _loadingVariants = false;
  bool get isLoadingVariants => _loadingVariants;
  bool _variantsLoaded = false;

  bool _loadingPayouts = false;
  bool get isLoadingPayouts => _loadingPayouts;
  bool _payoutsLoaded = false;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ReturnModel? _createdReturn;
  ReturnModel? get createdReturn => _createdReturn;

  // ---- form state ----
  ReturnRequestType requestType = ReturnRequestType.returnOnly;
  String? reason;
  String reasonNote = '';
  int quantity = 1;
  String? selectedExchangeVariantId;
  ReturnRefundTo? refundTo; // koi default nahi
  String? selectedPayoutMethodId;
  final List<File> images = [];

  List<SimpleVariantOption> exchangeVariants = [];
  List<PayoutMethodModel> payoutMethods = [];

  static const List<String> reasonOptions = [
    'Size issue',
    'Damaged product',
    'Wrong item delivered',
    'Quality not as expected',
    'Item no longer needed',
    'Others',
  ];

  // ---------------- type ----------------
  void setRequestType(ReturnRequestType type,
      {required String productId, String? currentVariantId}) {
    requestType = type;
    selectedExchangeVariantId = null;
    _errorMessage = null;
    notifyListeners();
    if (type == ReturnRequestType.exchange && !_variantsLoaded) {
      fetchExchangeVariants(productId, currentVariantId: currentVariantId);
    }
  }

  // ---------------- refund destination ----------------
  void setRefundTo(ReturnRefundTo v) {
    refundTo = v;
    selectedPayoutMethodId = null;
    _errorMessage = null;
    notifyListeners();
    if (v == ReturnRefundTo.upi) fetchPayoutMethods();
  }

  void setPayoutMethod(String? id) {
    selectedPayoutMethodId = id;
    notifyListeners();
  }

  Future<void> fetchPayoutMethods({bool force = false}) async {
    if (_payoutsLoaded && !force) return;
    _loadingPayouts = true;
    notifyListeners();
    final res = await _payoutRepo.getPayoutMethods();
    if (res.isCompleted) {
      payoutMethods = res.data ?? [];
      _payoutsLoaded = true;
      // sirf ek UPI saved hai to auto-select
      if (payoutMethods.length == 1) selectedPayoutMethodId = payoutMethods.first.id;
    }
    _loadingPayouts = false;
    notifyListeners();
  }

  // ---------------- simple setters ----------------
  void setReason(String? v) {
    reason = v;
    notifyListeners();
  }

  void setReasonNote(String v) {
    reasonNote = v; // optional field, rebuild ki zarurat nahi
  }

  void setQuantity(int v, {required int max}) {
    if (v < 1) v = 1;
    if (v > max) v = max;
    quantity = v;
    notifyListeners();
  }

  void setExchangeVariant(String? id) {
    selectedExchangeVariantId = id;
    notifyListeners();
  }

  void addImage(File file) {
    if (images.length >= 3) return;
    images.add(file);
    notifyListeners();
  }

  void removeImage(File file) {
    images.remove(file);
    notifyListeners();
  }

  Future<void> fetchExchangeVariants(String productId, {String? currentVariantId}) async {
    _loadingVariants = true;
    notifyListeners();
    try {
      final result = await _productRepo.getProductById(productId);
      if (result.isCompleted && result.data != null) {
        final dynamic product = result.data;
        final List<dynamic> variants = (product.variants as List?) ?? [];
        exchangeVariants = variants
            .where((v) => v.id.toString() != currentVariantId)
            .map((v) => SimpleVariantOption(id: v.id.toString(), name: v.name.toString()))
            .toList();
        _variantsLoaded = true;
      }
    } catch (_) {
      // fetch fail ho ya variants na ho: exchange sirf exchangeProductId ke saath jayega
    }
    _loadingVariants = false;
    notifyListeners();
  }

  bool get canSubmit => !_loadingVariants && !_loadingPayouts;

  bool _fail(String msg) {
    _errorMessage = msg;
    _status = CreateReturnStatus.error;
    notifyListeners();
    return false;
  }

  bool validate() {
    if (reason == null || reason!.trim().isEmpty) {
      return _fail('Please select a reason');
    }

    if (refundTo == null) {
      return _fail('Where would you like your refund? Please select Wallet or UPI');
    }

    if (refundTo == ReturnRefundTo.upi &&
        (selectedPayoutMethodId == null || selectedPayoutMethodId!.isEmpty)) {
      return _fail('Please select a UPI payment method');
    }

    // Variant is required only when the product has alternate variants
    if (requestType == ReturnRequestType.exchange &&
        exchangeVariants.isNotEmpty &&
        (selectedExchangeVariantId == null ||
            selectedExchangeVariantId!.isEmpty)) {
      return _fail('Please select a variant for the exchange');
    }

    return true;
  }

  Future<bool> submit({required String orderItemId, required String productId}) async {
    if (!validate()) return false;
    _status = CreateReturnStatus.submitting;
    _errorMessage = null;
    notifyListeners();

    final isExchange = requestType == ReturnRequestType.exchange;

    final response = await _returnRepo.createReturnRequest(
      orderItemId: orderItemId,
      type: requestType,
      reason: reason!.trim(),
      reasonNote: reasonNote,
      quantity: quantity,
      refundTo: refundTo!,
      payoutMethodId: refundTo == ReturnRefundTo.upi ? selectedPayoutMethodId : null,
      exchangeProductId: isExchange ? productId : null,
      exchangeVariantId: isExchange && exchangeVariants.isNotEmpty
          ? selectedExchangeVariantId
          : null,
      images: images,
    );

    if (response.isCompleted && response.data != null) {
      _createdReturn = response.data;
      _status = CreateReturnStatus.success;
      notifyListeners();
      return true;
    }
    _errorMessage = response.message;
    _status = CreateReturnStatus.error;
    notifyListeners();
    return false;
  }
}