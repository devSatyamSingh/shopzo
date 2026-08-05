import 'package:flutter/material.dart';
import '../model/wishlist_model.dart';
import '../model/product/product_detail_model.dart';
import '../repo/wishlist_repo.dart';
import '../repo/product/product_repo.dart';

enum WishlistStatus { loading, loaded, error }

class WishlistViewModel extends ChangeNotifier {
  final WishlistRepository _repository = WishlistRepository();
  final ProductRepository _productRepository = ProductRepository();

  List<WishlistItemModel> _items = [];
  List<WishlistItemModel> get items => List.unmodifiable(_items);

  WishlistStatus _status = WishlistStatus.loading;
  WishlistStatus get status => _status;
  bool get isLoading => _status == WishlistStatus.loading;
  bool get hasError => _status == WishlistStatus.error;
  bool get isEmpty => _status == WishlistStatus.loaded && _items.isEmpty;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final Set<String> _removingIds = {};
  bool isRemoving(String id) => _removingIds.contains(id);

  final Set<String> _movingIds = {};
  bool isMoving(String id) => _movingIds.contains(id);

  bool isWishlisted(String productId, {String? variantId}) {
    return _items.any((i) => i.productId == productId && i.variantId == variantId);
  }

  final Map<String, String?> _imageCache = {};
  final Set<String> _fetchingProductIds = {};

  String _imgKey(String productId, String? variantId) => '$productId|${variantId ?? ''}';

  String? imageFor(String productId, {String? variantId}) =>
      _imageCache[_imgKey(productId, variantId)];

  bool isImageLoading(String productId, {String? variantId}) =>
      _fetchingProductIds.contains(productId) &&
          !_imageCache.containsKey(_imgKey(productId, variantId));

  Future<void> fetchWishlist({bool showLoader = true}) async {
    if (showLoader) {
      _status = WishlistStatus.loading;
      notifyListeners();
    }

    final response = await _repository.getWishlist();

    if (response.isCompleted) {
      _items = response.data ?? [];
      _status = WishlistStatus.loaded;
      _errorMessage = null;
      notifyListeners();
      _loadMissingImages(_items); // background me images fetch karo
    } else {
      _status = WishlistStatus.error;
      _errorMessage = response.message ?? 'Failed to load wishlist';
      notifyListeners();
    }
  }

  /// Har unique productId ke liye ek hi baar getProductById() call karta
  /// hai, fir us product ke saare wishlist items (chahe alag-alag variant
  /// hi kyun na ho) ko unki respective variant image (ya product image)
  /// se map kar deta hai.
  Future<void> _loadMissingImages(List<WishlistItemModel> items) async {
    final uniqueProductIds = items
        .map((i) => i.productId)
        .where((pid) => pid.isNotEmpty)
        .toSet();

    final toFetch = uniqueProductIds.where((pid) => !_fetchingProductIds.contains(pid)).toList();
    if (toFetch.isEmpty) return;

    _fetchingProductIds.addAll(toFetch);

    await Future.wait(toFetch.map((productId) async {
      final response = await _productRepository.getProductById(productId);
      if (response.isCompleted && response.data != null) {
        _applyProductImages(response.data!, items);
      }
      _fetchingProductIds.remove(productId);
    }));

    notifyListeners();
  }

  void _applyProductImages(ProductDetailModel product, List<WishlistItemModel> allItems) {
    // Is product ke saare wishlist items (alag-alag variants) nikal lo
    final relatedItems = allItems.where((i) => i.productId == product.id);

    for (final item in relatedItems) {
      String? imageUrl;

      if (item.variantId != null && product.hasVariants) {
        final matchingVariant = product.variants.where((v) => v.id == item.variantId);
        if (matchingVariant.isNotEmpty && matchingVariant.first.images.isNotEmpty) {
          imageUrl = matchingVariant.first.images.first;
        }
      }

      // Variant image na mile to product-level image pe fallback
      imageUrl ??= product.images.isNotEmpty ? product.images.first : null;

      _imageCache[_imgKey(item.productId, item.variantId)] = imageUrl;
    }
  }

  Future<bool> removeItem(WishlistItemModel item) async {
    _removingIds.add(item.id);
    notifyListeners();

    final response = await _repository.toggleWishlist(productId: item.productId, variantId: item.variantId);

    _removingIds.remove(item.id);

    if (response.isCompleted) {
      _items.removeWhere((i) => i.id == item.id);
      notifyListeners();
      return true;
    } else {
      notifyListeners();
      return false;
    }
  }

  Future<bool?> toggleFromProductDetail({
    required String productId,
    String? variantId,
    String? productName,
    String? variantName,
    String? slug,
    double? displayPrice,
    int? stock,
  }) async {
    final response = await _repository.toggleWishlist(productId: productId, variantId: variantId);
    if (!response.isCompleted) return null;

    final nowWishlisted = response.data ?? false;

    if (nowWishlisted) {
      _items.add(WishlistItemModel(
        id: 'local_${productId}_${variantId ?? ''}',
        productId: productId,
        variantId: variantId,
        name: productName ?? '',
        variantName: variantName,
        slug: slug ?? '',
        displayPrice: displayPrice ?? 0,
        stock: stock ?? 0,
        isAvailable: true,
      ));
      notifyListeners();
      _loadMissingImages(_items); // naye item ki image bhi fetch kar lo
    } else {
      _items.removeWhere((i) => i.productId == productId && i.variantId == variantId);
      notifyListeners();
    }
    return nowWishlisted;
  }

  Future<bool> moveToCart(WishlistItemModel item) async {
    _movingIds.add(item.id);
    notifyListeners();

    final response = await _repository.moveToCart(item.id);

    _movingIds.remove(item.id);

    if (response.isCompleted && (response.data ?? false)) {
      _items.removeWhere((i) => i.id == item.id);
      notifyListeners();
      return true;
    } else {
      notifyListeners();
      return false;
    }
  }
}