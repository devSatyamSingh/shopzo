import '../category/category_model.dart';

/// ---------------- ATTRIBUTE (e.g. "Net Quantity", "Packaging Type") ----------------
class ProductAttributeModel {
  final String id;
  final String name;

  ProductAttributeModel({required this.id, required this.name});

  factory ProductAttributeModel.fromJson(Map<String, dynamic> json) {
    return ProductAttributeModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

/// ---------------- ATTRIBUTE VALUE (e.g. "500ml", "Tube") ----------------
class ProductAttributeValueModel {
  final String id;
  final String value;
  final ProductAttributeModel attribute;

  ProductAttributeValueModel({
    required this.id,
    required this.value,
    required this.attribute,
  });

  factory ProductAttributeValueModel.fromJson(Map<String, dynamic> json) {
    return ProductAttributeValueModel(
      id: json['id']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
      attribute: ProductAttributeModel.fromJson(
        json['attribute'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}

/// ---------------- LINK BETWEEN A VARIANT AND ONE ATTRIBUTE VALUE ----------------
class VariantAttributeValueModel {
  final String id;
  final String variantId;
  final String attributeValueId;
  final ProductAttributeValueModel attributeValue;

  VariantAttributeValueModel({
    required this.id,
    required this.variantId,
    required this.attributeValueId,
    required this.attributeValue,
  });

  factory VariantAttributeValueModel.fromJson(Map<String, dynamic> json) {
    return VariantAttributeValueModel(
      id: json['id']?.toString() ?? '',
      variantId: json['variantId']?.toString() ?? '',
      attributeValueId: json['attributeValueId']?.toString() ?? '',
      attributeValue: ProductAttributeValueModel.fromJson(
        json['attributeValue'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}

/// ---------------- VARIANT (e.g. "500ml" @ ₹100, stock 5) ----------------
class ProductVariantModel {
  final String id;
  final String productId;
  final String name;
  final String sku;
  final double price;
  final int stock;
  final List<String> images;
  final List<VariantAttributeValueModel> attributeValues;

  ProductVariantModel({
    required this.id,
    required this.productId,
    required this.name,
    required this.sku,
    required this.price,
    required this.stock,
    required this.images,
    required this.attributeValues,
  });

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    return ProductVariantModel(
      id: json['id']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0,
      stock: int.tryParse(json['stock']?.toString() ?? '') ?? 0,
      images: (json['images'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      attributeValues: (json['attributeValues'] as List<dynamic>? ?? [])
          .map((e) => VariantAttributeValueModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// e.g. { "Net Quantity": "500ml", "Packaging Type": "Tube" }
  Map<String, String> get attributeMap => {
    for (final av in attributeValues) av.attributeValue.attribute.name: av.attributeValue.value,
  };

  bool get inStock => stock > 0;

  String get formattedPrice {
    final whole = price.toStringAsFixed(0);
    final withCommas = whole.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
    return '₹$withCommas';
  }
}

/// ---------------- REVIEW ----------------
class ProductReviewModel {
  final String id;
  final String productId;
  final String customerId;
  final int rating;
  final String? comment;
  final List<String> images;
  final bool isApproved;
  final String createdAt;
  final String customerName;

  ProductReviewModel({
    required this.id,
    required this.productId,
    required this.customerId,
    required this.rating,
    this.comment,
    required this.images,
    required this.isApproved,
    required this.createdAt,
    required this.customerName,
  });

  factory ProductReviewModel.fromJson(Map<String, dynamic> json) {
    return ProductReviewModel(
      id: json['id']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      rating: int.tryParse(json['rating']?.toString() ?? '') ?? 0,
      comment: json['comment']?.toString(),
      images: (json['images'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      isApproved: json['isApproved'] == true,
      createdAt: json['createdAt']?.toString() ?? '',
      customerName:
      (json['customer'] as Map<String, dynamic>?)?['name']?.toString() ?? 'Anonymous',
    );
  }
}

/// ---------------- FULL PRODUCT DETAIL (GET /products/:id) ----------------
class ProductDetailModel {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String sku;
  final double price;
  final double? costPrice;
  final double? taxRate;
  final List<String> images;
  final bool isActive;
  final bool isReturnable;
  final String? returnPolicyText;
  final int stock;
  final int lowStockThreshold;
  final String categoryId;
  final String createdAt;
  final String updatedAt;
  final CategoryModel? category;
  final List<ProductVariantModel> variants;
  final List<ProductReviewModel> reviews;

  ProductDetailModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.sku,
    required this.price,
    this.costPrice,
    this.taxRate,
    required this.images,
    required this.isActive,
    required this.isReturnable,
    this.returnPolicyText,
    required this.stock,
    required this.lowStockThreshold,
    required this.categoryId,
    required this.createdAt,
    required this.updatedAt,
    this.category,
    required this.variants,
    required this.reviews,
  });

  factory ProductDetailModel.fromJson(Map<String, dynamic> json) {
    return ProductDetailModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString(),
      sku: json['sku']?.toString() ?? '',
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0,
      costPrice: json['costPrice'] != null ? double.tryParse(json['costPrice'].toString()) : null,
      taxRate: json['taxRate'] != null ? double.tryParse(json['taxRate'].toString()) : null,
      images: (json['images'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      isActive: json['isActive'] == true,
      isReturnable: json['isReturnable'] == true,                 // ⬅️ NEW
      returnPolicyText: json['returnPolicyText']?.toString(),
      stock: int.tryParse(json['stock']?.toString() ?? '') ?? 0,
      lowStockThreshold: int.tryParse(json['lowStockThreshold']?.toString() ?? '') ?? 0,
      categoryId: json['categoryId']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      category:
      json['category'] != null ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>) : null,
      variants: (json['variants'] as List<dynamic>? ?? [])
          .map((e) => ProductVariantModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      reviews: (json['reviews'] as List<dynamic>? ?? [])
          .map((e) => ProductReviewModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  bool get hasVariants => variants.isNotEmpty;

  List<ProductReviewModel> get approvedReviews => reviews.where((r) => r.isApproved).toList();

  double get avgRating {
    if (reviews.isEmpty) return 0;
    return reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
  }

  String get formattedPrice {
    final whole = price.toStringAsFixed(0);
    final withCommas = whole.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
    return '₹$withCommas';
  }



  /// Distinct attribute groups across all variants, in first-seen order.
  /// e.g. { "Net Quantity": ["500ml","600ml","100ml","1000ml"], "Packaging Type": ["Tube"] }
  Map<String, List<String>> get attributeOptions {
    final map = <String, List<String>>{};
    for (final v in variants) {
      v.attributeMap.forEach((attrName, value) {
        map.putIfAbsent(attrName, () => []);
        if (!map[attrName]!.contains(value)) map[attrName]!.add(value);
      });
    }
    return map;
  }

  /// Product-level text nahi mila to category-level fallback — jo bhi pehle available ho wahi dikhega
  String? get effectiveReturnPolicyText {
    if (returnPolicyText != null && returnPolicyText!.trim().isNotEmpty) {
      return returnPolicyText;
    }
    if (category?.returnPolicyText != null && category!.returnPolicyText!.trim().isNotEmpty) {
      return category!.returnPolicyText;
    }
    return null;
  }

  /// Return allowed hai ya nahi — product ka flag priority, warna category ka
  bool get effectiveIsReturnable => isReturnable;

  /// MRP jaisa strikethrough price — sirf tabhi dikhana jab costPrice, selling price se zyada ho
  bool get hasDiscount => costPrice != null && costPrice! > price;

  String get formattedCostPrice {
    if (costPrice == null) return '';
    final whole = costPrice!.toStringAsFixed(0);
    final withCommas = whole.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
    return '₹$withCommas';
  }

  int get discountPercent {
    if (!hasDiscount) return 0;
    return (((costPrice! - price) / costPrice!) * 100).round();
  }
}