import 'package:flutter/material.dart';
import '../../model/product/product_list_model.dart';
import '../../repo/product/product_repo.dart';

enum ProductListStatus { idle, loading, loaded, error }

class ProductListViewModel extends ChangeNotifier {
  final ProductRepository _repository = ProductRepository();

  ProductListStatus _status = ProductListStatus.idle;
  ProductListStatus get status => _status;
  bool get isLoading => _status == ProductListStatus.loading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<ProductListModel> _products = [];
  List<ProductListModel> get products => _products;

  Future<void> fetchProducts({bool forceRefresh = false}) async {
    if (_status == ProductListStatus.loaded && !forceRefresh) return;

    _status = ProductListStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getWebsiteProducts();

    if (result.isCompleted && result.data != null) {
      _products = result.data!;
      _status = ProductListStatus.loaded;
    } else {
      _errorMessage = result.message ?? 'Failed to load products';
      _status = ProductListStatus.error;
    }
    notifyListeners();
  }
}