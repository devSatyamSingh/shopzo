/// Shopzo — product object returned by GET /products (list) and, once
/// available, GET /products/:id (detail) — same shape covers both.
class ProductModel {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? sku;
  final double price;
  final double? costPrice;
  final String? taxRate;
  final List<String> images;
  final bool isActive;
  final int stock;
  final int? lowStockThreshold;
  final String categoryId;
  final String? categoryName;

  ProductModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.sku,
    required this.price,
    this.costPrice,
    this.taxRate,
    this.images = const [],
    this.isActive = true,
    this.stock = 0,
    this.lowStockThreshold,
    required this.categoryId,
    this.categoryName,
  });

  String? get primaryImage => images.isNotEmpty ? images.first : null;
  bool get inStock => stock > 0;
  bool get isLowStock => lowStockThreshold != null && stock <= lowStockThreshold!;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final categoryJson = json['category'] as Map<String, dynamic>?;

    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString(),
      sku: json['sku']?.toString(),
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0,
      costPrice: json['costPrice'] != null ? double.tryParse(json['costPrice'].toString()) : null,
      taxRate: json['taxRate']?.toString(),
      images: (json['images'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      isActive: json['isActive'] == true,
      stock: int.tryParse(json['stock']?.toString() ?? '0') ?? 0,
      lowStockThreshold: json['lowStockThreshold'] != null
          ? int.tryParse(json['lowStockThreshold'].toString())
          : null,
      categoryId: json['categoryId']?.toString() ?? '',
      categoryName: categoryJson?['name']?.toString(),
    );
  }
}

/// Shopzo — pagination block that comes alongside `data` in the products
/// list response.
class PaginationModel {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  PaginationModel({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  bool get hasMore => page < totalPages;

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      page: int.tryParse(json['page']?.toString() ?? '1') ?? 1,
      limit: int.tryParse(json['limit']?.toString() ?? '20') ?? 20,
      total: int.tryParse(json['total']?.toString() ?? '0') ?? 0,
      totalPages: int.tryParse(json['totalPages']?.toString() ?? '1') ?? 1,
    );
  }
}

/// Bundles one page of products with its pagination info — what the
/// repository hands back to the ViewModel on every fetch/loadMore call.
class ProductListResult {
  final List<ProductModel> products;
  final PaginationModel pagination;

  ProductListResult({required this.products, required this.pagination});
}