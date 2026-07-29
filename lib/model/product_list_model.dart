import 'category/category_model.dart';

/// Shopzo — product summary as returned by GET /websiteProducts
/// (used for Home sections: Trending Now, Flash Deals, Top Picks, etc.)
class ProductListModel {
  final String id;
  final String name;
  final String slug;
  final String? image;
  final double displayPrice;
  final bool hasVariants;
  final bool inStock;
  final double avgRating;
  final int reviewCount;
  final String createdAt;
  final CategoryModel? category;

  ProductListModel({
    required this.id,
    required this.name,
    required this.slug,
    this.image,
    required this.displayPrice,
    required this.hasVariants,
    required this.inStock,
    required this.avgRating,
    required this.reviewCount,
    required this.createdAt,
    this.category,
  });

  factory ProductListModel.fromJson(Map<String, dynamic> json) {
    return ProductListModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      image: (json['image'] != null && json['image'].toString().isNotEmpty)
          ? json['image'].toString()
          : null,
      displayPrice: double.tryParse(json['displayPrice']?.toString() ?? '') ?? 0,
      hasVariants: json['hasVariants'] == true,
      inStock: json['inStock'] == true,
      avgRating: double.tryParse(json['avgRating']?.toString() ?? '') ?? 0,
      reviewCount: int.tryParse(json['reviewCount']?.toString() ?? '') ?? 0,
      createdAt: json['createdAt']?.toString() ?? '',
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,
    );
  }

  String get formattedPrice {
    final whole = displayPrice.toStringAsFixed(0);
    final withCommas = whole.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (m) => ',',
    );
    return '₹$withCommas';
  }
}