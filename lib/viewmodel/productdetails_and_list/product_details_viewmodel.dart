import 'package:flutter/material.dart';
import '../../model/product/product_detail_model.dart';
import '../../repo/product/product_repo.dart';

enum ProductDetailStatus { idle, loading, loaded, error }
enum RelatedProductsStatus { idle, loading, loaded, error }   // ⬅️ NEW

class ProductDetailViewModel extends ChangeNotifier {
  final ProductRepository _repository = ProductRepository();

  ProductDetailStatus _status = ProductDetailStatus.idle;
  ProductDetailStatus get status => _status;
  bool get isLoading => _status == ProductDetailStatus.loading;
  final Map<String, String> _defaultAttributes = {};
  String _productId = '';
  String get productId => _productId;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ProductDetailModel? _product;
  ProductDetailModel? get product => _product;

  /// Currently chosen value per attribute name, e.g. {"Net Quantity": "500ml"}
  final Map<String, String> _selectedAttributes = {};
  Map<String, String> get selectedAttributes => Map.unmodifiable(_selectedAttributes);

  ProductVariantModel? _selectedVariant;
  ProductVariantModel? get selectedVariant => _selectedVariant;

  int _quantity = 1;
  int get quantity => _quantity;
  double? get effectiveCostPrice => _product?.costPrice;

  bool get hasDiscount =>
      effectiveCostPrice != null && effectiveCostPrice! > effectivePrice;

  String get formattedCostPrice {
    if (effectiveCostPrice == null) return '';
    final whole = effectiveCostPrice!.toStringAsFixed(0);
    final withCommas = whole.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
    return '₹$withCommas';
  }

  int get discountPercent {
    if (!hasDiscount) return 0;
    return (((effectiveCostPrice! - effectivePrice) / effectiveCostPrice!) * 100).round();
  }

  // ---------------- RELATED PRODUCTS (slug-API se) ----------------  ⬅️ NEW
  RelatedProductsStatus _relatedStatus = RelatedProductsStatus.idle;
  RelatedProductsStatus get relatedStatus => _relatedStatus;
  bool get isRelatedLoading => _relatedStatus == RelatedProductsStatus.loading;

  List<RelatedProductModel> _relatedProducts = [];
  List<RelatedProductModel> get relatedProducts => _relatedProducts;

  Future<void> _fetchRelatedProducts(String slug) async {
    if (slug.isEmpty) return;
    _relatedStatus = RelatedProductsStatus.loading;
    _safeNotify();

    final result = await _repository.getRelatedProductsBySlug(slug);
    if (_isDisposed) return;

    if (result.isCompleted && result.data != null) {
      _relatedProducts = result.data!;
      _relatedStatus = RelatedProductsStatus.loaded;
    } else {
      _relatedProducts = [];
      _relatedStatus = RelatedProductsStatus.error;
    }
    _safeNotify();
  }
  // ---------------------------------------------------------------

  bool _isDisposed = false; // ⬅️ ADD

  @override
  void dispose() {              // ⬅️ ADD
    _isDisposed = true;
    super.dispose();
  }

  void _safeNotify() {          // ⬅️ ADD
    if (!_isDisposed) notifyListeners();
  }

  Future<void> fetchProduct(String id) async {
    _status = ProductDetailStatus.loading;
    _productId = id;
    _errorMessage = null;
    _selectedAttributes.clear();
    _selectedVariant = null;
    _quantity = 1;
    _relatedProducts = [];                          // ⬅️ NEW — pehle product ka data clear
    _relatedStatus = RelatedProductsStatus.idle;     // ⬅️ NEW
    _safeNotify();

    final result = await _repository.getProductById(id);
    if (_isDisposed) return;

    if (result.isCompleted && result.data != null) {
      _product = result.data!;
      _status = ProductDetailStatus.loaded;

      if (_product!.hasVariants) {
        final initial = _product!.variants.firstWhere(
              (v) => v.inStock,
          orElse: () => _product!.variants.first,
        );
        _selectedAttributes.addAll(initial.attributeMap);
        _selectedVariant = initial;
        _defaultAttributes.addAll(initial.attributeMap);
      }

      // Main product load hone ke baad, uske slug se related products fetch karo —
      // await nahi kar rahe taaki product screen turant render ho jaye, related
      // products baad me skeleton ke saath aayenge
      _fetchRelatedProducts(_product!.slug);
    } else {
      _errorMessage = result.message ?? 'Failed to load product';
      _status = ProductDetailStatus.error;
    }
    _safeNotify();
  }

  void toggleAttribute(String attributeName, String value) {
    if (_product == null) return;

    if (_selectedAttributes[attributeName] == value) {
      final defaultValue = _defaultAttributes[attributeName];
      if (defaultValue != null) {
        _selectedAttributes[attributeName] = defaultValue;
      } else {
        _selectedAttributes.remove(attributeName);
      }
    } else {
      _selectedAttributes[attributeName] = value;
    }

    final matches = _product!.variants.where((v) {
      final map = v.attributeMap;
      return _selectedAttributes.entries.every((e) => map[e.key] == e.value);
    });

    _selectedVariant = matches.isNotEmpty ? matches.first : null;
    _quantity = 1;
    notifyListeners();
  }

  void selectAttribute(String attributeName, String value) {
    if (_product == null) return;
    _selectedAttributes[attributeName] = value;

    final matches = _product!.variants.where((v) {
      final map = v.attributeMap;
      return _selectedAttributes.entries.every((e) => map[e.key] == e.value);
    });

    _selectedVariant = matches.isNotEmpty ? matches.first : null;
    _quantity = 1;
    notifyListeners();
  }

  bool isAttributeValueAvailable(String attributeName, String value) {
    if (_product == null) return false;
    final trial = Map<String, String>.from(_selectedAttributes)..[attributeName] = value;
    return _product!.variants.any((v) {
      final map = v.attributeMap;
      return trial.entries.every((e) => map[e.key] == e.value);
    });
  }

  void setQuantity(int qty) {
    if (qty < 1) return;
    final max = effectiveStock;
    if (max <= 0) return;
    if (qty > max) return;
    _quantity = qty;
    notifyListeners();
  }


  bool get hasVariants => _product?.hasVariants ?? false;
  bool get isSelectionComplete {
    if (!hasVariants) return true;
    final options = _product!.attributeOptions;
    if (_selectedAttributes.length != options.length) return false;
    return _selectedVariant != null;
  }

  double get effectivePrice =>
      _selectedVariant != null ? _selectedVariant!.price : (_product?.price ?? 0);

  String get effectiveFormattedPrice {
    final whole = effectivePrice.toStringAsFixed(0);
    final withCommas = whole.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
    return '₹$withCommas';
  }

  int get effectiveStock => _selectedVariant != null ? _selectedVariant!.stock : (_product?.stock ?? 0);

  bool get isInStock => hasVariants ? (_selectedVariant?.inStock ?? false) : effectiveStock > 0;

  bool get isLowStock => effectiveStock > 0 && effectiveStock <= (_product?.lowStockThreshold ?? 0);

  List<String> get effectiveImages {
    if (_selectedVariant != null && _selectedVariant!.images.isNotEmpty) {
      return _selectedVariant!.images;
    }
    return _product?.images ?? [];
  }
}