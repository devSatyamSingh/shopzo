import 'package:flutter/material.dart';
import '../../model/product/product_detail_model.dart';
import '../../repo/product/product_repo.dart';

enum ProductDetailStatus { idle, loading, loaded, error }

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

  Future<void> fetchProduct(String id) async {
    _status = ProductDetailStatus.loading;
    _productId = id;
    _errorMessage = null;
    _selectedAttributes.clear();
    _selectedVariant = null;
    _quantity = 1;
    notifyListeners();

    final result = await _repository.getProductById(id);

    if (result.isCompleted && result.data != null) {
      _product = result.data!;
      _status = ProductDetailStatus.loaded;

      if (_product!.hasVariants) {
        // preselect the first in-stock variant, else just the first one
        final initial = _product!.variants.firstWhere(
              (v) => v.inStock,
          orElse: () => _product!.variants.first,
        );
        _selectedAttributes.addAll(initial.attributeMap);
        _selectedVariant = initial;
        _defaultAttributes.addAll(initial.attributeMap);
      }
    } else {
      _errorMessage = result.message ?? 'Failed to load product';
      _status = ProductDetailStatus.error;
    }
    notifyListeners();
  }


  /// Same as selectAttribute, but if the tapped value is already selected,
  /// it deselects and reverts that attribute back to its default value.
  void toggleAttribute(String attributeName, String value) {
    if (_product == null) return;

    if (_selectedAttributes[attributeName] == value) {
      // Already selected -> tap again -> revert to default
      final defaultValue = _defaultAttributes[attributeName];
      if (defaultValue != null) {
        _selectedAttributes[attributeName] = defaultValue;
      } else {
        _selectedAttributes.remove(attributeName);
      }
    } else {
      // Not selected -> select it
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

  /// Called when the user taps an attribute chip (e.g. "600ml" under
  /// "Net Quantity"). Re-resolves the matching variant, if any exists
  /// for the current combination of selections.
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

  /// Whether picking [value] for [attributeName], on top of the current
  /// selections, still resolves to a real variant. Used to grey out
  /// dead-end combinations in the UI.
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
    if (max > 0 && qty > max) return;
    _quantity = qty;
    notifyListeners();
  }

  // ---------------- DERIVED STATE USED DIRECTLY BY THE UI ----------------

  bool get hasVariants => _product?.hasVariants ?? false;

  /// True once the user has picked one value for every attribute group
  /// and it resolves to a real, purchasable variant.
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

  int get effectiveStock =>
      _selectedVariant != null ? _selectedVariant!.stock : (_product?.stock ?? 0);

  bool get isInStock => hasVariants ? (_selectedVariant?.inStock ?? false) : effectiveStock > 0;

  bool get isLowStock =>
      effectiveStock > 0 && effectiveStock <= (_product?.lowStockThreshold ?? 0);

  /// Images shown in the gallery: selected variant's own images if it has
  /// any, else the product's images. Exactly as many as the API returned
  /// — no padding, no placeholders.
  List<String> get effectiveImages {
    if (_selectedVariant != null && _selectedVariant!.images.isNotEmpty) {
      return _selectedVariant!.images;
    }
    return _product?.images ?? [];
  }
}