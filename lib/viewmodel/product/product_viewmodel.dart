import 'package:flutter/material.dart';
import '../../model/product_by_category/product_model.dart';
import '../../repo/product/product_repo.dart';

enum ProductLoadStatus { idle, loading, loadingMore, loaded, error }

/// Shopzo — Product ViewModel, scoped to ONE category's product list.
///
/// This is created fresh per screen (via a local ChangeNotifierProvider in
/// CategoryProductListScreen) — unlike CategoryViewModel, product lists are
/// paginated and category-specific, so sharing one instance app-wide
/// wouldn't make sense.
class ProductViewModel extends ChangeNotifier {
  final ProductRepository _repository = ProductRepository();

  ProductLoadStatus _status = ProductLoadStatus.idle;
  ProductLoadStatus get status => _status;
  bool get isLoading => _status == ProductLoadStatus.loading;
  bool get isLoadingMore => _status == ProductLoadStatus.loadingMore;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<ProductModel> _products = [];
  List<ProductModel> get products => _products;

  String? _categoryId;
  int _currentPage = 1;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  static const int _pageSize = 20;

  /// First load (or pull-to-refresh with forceRefresh: true) for a category.
  Future<void> fetchProducts({required String categoryId, bool forceRefresh = false}) async {
    if (_categoryId == categoryId && _status == ProductLoadStatus.loaded && !forceRefresh) {
      return;
    }

    _categoryId = categoryId;
    _currentPage = 1;
    _hasMore = true;
    _status = ProductLoadStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getProducts(
      page: 1,
      limit: _pageSize,
      categoryId: categoryId,
    );

    if (result.isCompleted && result.data != null) {
      _products = result.data!.products;
      _hasMore = result.data!.pagination.hasMore;
      _status = ProductLoadStatus.loaded;
    } else {
      _errorMessage = result.message ?? 'Failed to load products';
      _status = ProductLoadStatus.error;
    }
    notifyListeners();
  }

  /// Called by the screen's scroll listener when the user nears the
  /// bottom of the grid — appends the next page instead of replacing.
  Future<void> loadMore() async {
    if (!_hasMore || _status == ProductLoadStatus.loadingMore || _categoryId == null) return;

    _status = ProductLoadStatus.loadingMore;
    notifyListeners();

    final nextPage = _currentPage + 1;
    final result = await _repository.getProducts(
      page: nextPage,
      limit: _pageSize,
      categoryId: _categoryId,
    );

    if (result.isCompleted && result.data != null) {
      _products = [..._products, ...result.data!.products];
      _currentPage = nextPage;
      _hasMore = result.data!.pagination.hasMore;
    }
    // On failure, silently stop the loader — the products already shown
    // stay put, and scrolling near the bottom again will retry loadMore().
    _status = ProductLoadStatus.loaded;
    notifyListeners();
  }

  Future<void> refresh() async {
    if (_categoryId == null) return;
    await fetchProducts(categoryId: _categoryId!, forceRefresh: true);
  }
}