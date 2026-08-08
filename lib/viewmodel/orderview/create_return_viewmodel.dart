import 'dart:io';
import 'package:flutter/material.dart';
import '../../model/order/return_model.dart';
import '../../repo/order/return_repo.dart';
import '../../repo/product/product_repo.dart'; // apna exact path/class use karna

enum CreateReturnStatus { idle, loadingVariants, submitting, success, error }

class SimpleVariantOption {
  final String id;
  final String name;
  const SimpleVariantOption({required this.id, required this.name});
}

class CreateReturnViewModel extends ChangeNotifier {
  final ReturnRepository _returnRepo = ReturnRepository();
  final ProductRepository _productRepo = ProductRepository();

  CreateReturnStatus _status = CreateReturnStatus.idle;
  CreateReturnStatus get status => _status;
  bool get isSubmitting => _status == CreateReturnStatus.submitting;
  bool get isLoadingVariants => _status == CreateReturnStatus.loadingVariants;
  bool get isSuccess => _status == CreateReturnStatus.success;

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
  final List<File> images = [];

  List<SimpleVariantOption> exchangeVariants = [];

  static const List<String> reasonOptions = [
    'Size issue',
    'Damaged / Defective product',
    'Wrong item delivered',
    'Quality not as expected',
    'Item no longer needed',
    'Others',
  ];

  void setRequestType(ReturnRequestType type,
      {required String productId, String? currentVariantId}) {
    requestType = type;
    selectedExchangeVariantId = null;
    notifyListeners();
    if (type == ReturnRequestType.exchange && exchangeVariants.isEmpty) {
      fetchExchangeVariants(productId, currentVariantId: currentVariantId);
    }
  }

  void setReason(String? v) {
    reason = v;
    notifyListeners();
  }

  void setReasonNote(String v) {
    reasonNote = v;
    notifyListeners();
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
    images.add(file);
    notifyListeners();
  }

  void removeImage(File file) {
    images.remove(file);
    notifyListeners();
  }

  Future<void> fetchExchangeVariants(String productId, {String? currentVariantId}) async {
    _status = CreateReturnStatus.loadingVariants;
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
      }
    } catch (_) {
    }
    _status = CreateReturnStatus.idle;
    notifyListeners();
  }

  bool get canSubmit {
    if (requestType == ReturnRequestType.exchange) {
      if (isLoadingVariants) return false;
      if (exchangeVariants.isEmpty) return false;
    }
    return true;
  }

  bool validate() {
    if (reason == null || reason!.trim().isEmpty) {
      _errorMessage = 'Reason select karein';
      _status = CreateReturnStatus.error;
      notifyListeners();
      return false;
    }
    if (reasonNote.trim().isEmpty) {
      _errorMessage = 'Thoda detail me batayein';
      _status = CreateReturnStatus.error;
      notifyListeners();
      return false;
    }
    if (requestType == ReturnRequestType.exchange &&
        (selectedExchangeVariantId == null || selectedExchangeVariantId!.isEmpty)) {
      _errorMessage = 'Exchange ke liye variant select karein';
      _status = CreateReturnStatus.error;
      notifyListeners();
      return false;
    }
    return true;
  }

  Future<bool> submit({required String orderItemId}) async {
    if (!validate()) return false;
    _status = CreateReturnStatus.submitting;
    _errorMessage = null;
    notifyListeners();

    final response = await _returnRepo.createReturnRequest(
      orderItemId: orderItemId,
      type: requestType,
      reason: reason!.trim(),
      reasonNote: reasonNote.trim(),
      quantity: quantity,
      exchangeVariantId: requestType == ReturnRequestType.exchange ? selectedExchangeVariantId : null,
      images: images,
    );

    if (response.isCompleted && response.data != null) {
      _createdReturn = response.data;
      _status = CreateReturnStatus.success;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message ?? 'Return request create nahi ho payi';
      _status = CreateReturnStatus.error;
      notifyListeners();
      return false;
    }
  }
}