import 'package:flutter/material.dart';
import '../model/top_product_model.dart';
import '../repo/top_product_repo.dart';

enum TopProductStatus { loading, loaded, error }

class BestSellerViewModel extends ChangeNotifier {
  final TopProductRepository _repository = TopProductRepository();

  List<TopProductModel> _products = [];
  List<TopProductModel> get products => List.unmodifiable(_products);

  TopProductStatus _status = TopProductStatus.loading;
  TopProductStatus get status => _status;
  bool get isLoading => _status == TopProductStatus.loading;
  bool get hasError => _status == TopProductStatus.error;
  bool get isEmpty => _status == TopProductStatus.loaded && _products.isEmpty;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchBestSellers({int limit = 20, bool showLoader = true}) async {
    if (showLoader) {
      _status = TopProductStatus.loading;
      notifyListeners();
    }

    final response = await _repository.getBestSellers(limit: limit);

    if (response.isCompleted) {
      _products = response.data ?? [];
      _status = TopProductStatus.loaded;
      _errorMessage = null;
    } else {
      _status = TopProductStatus.error;
      _errorMessage = response.message ?? 'Failed to load best sellers';
    }
    notifyListeners();
  }
}