/// Model for the full search-results grid.
/// Matches GET /v1/websiteProducts?search=&category=&minPrice=&maxPrice=&sort=&page=&limit=
/// response shape: { "data": { "products": [ {...} ] } }
class SearchProductCategory {
  final String id;
  final String name;
  final String slug;

  SearchProductCategory({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory SearchProductCategory.fromJson(Map<String, dynamic> json) {
    return SearchProductCategory(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
    );
  }
}

class SearchProductModel {
  final String id;
  final String name;
  final String slug;
  final String? image;
  final double displayPrice;
  final bool hasVariants;
  final bool inStock;
  final double avgRating;
  final int reviewCount;
  final SearchProductCategory? category;

  SearchProductModel({
    required this.id,
    required this.name,
    required this.slug,
    this.image,
    required this.displayPrice,
    required this.hasVariants,
    required this.inStock,
    required this.avgRating,
    required this.reviewCount,
    this.category,
  });

  factory SearchProductModel.fromJson(Map<String, dynamic> json) {
    return SearchProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      image: json['image'] as String?,
      displayPrice: (json['displayPrice'] is num)
          ? (json['displayPrice'] as num).toDouble()
          : double.tryParse('${json['displayPrice']}') ?? 0,
      hasVariants: json['hasVariants'] == true,
      // 'inStock' backend response me kabhi missing bhi ho sakta hai (jaise
      // getAllWebsiteProducts ke sample me nahi tha) — isliye default true
      // taaki galti se sab out-of-stock na dikh jaye.
      inStock: json['inStock'] is bool ? json['inStock'] as bool : true,
      avgRating: (json['avgRating'] is num)
          ? (json['avgRating'] as num).toDouble()
          : 0,
      reviewCount: (json['reviewCount'] is num)
          ? (json['reviewCount'] as num).toInt()
          : 0,
      category: json['category'] != null
          ? SearchProductCategory.fromJson(
          json['category'] as Map<String, dynamic>)
          : null,
    );
  }

  String get formattedPrice {
    final whole = displayPrice.toStringAsFixed(0);
    final withCommas =
    whole.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
    return '₹$withCommas';
  }
}