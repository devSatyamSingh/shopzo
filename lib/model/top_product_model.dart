class TopProductCategory {
  final String id;
  final String name;
  final String slug;

  const TopProductCategory({required this.id, required this.name, required this.slug});

  factory TopProductCategory.fromJson(Map<String, dynamic> json) {
    return TopProductCategory(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
    );
  }
}

class TopProductModel {
  final String id;
  final String name;
  final String slug;
  final String? image;
  final double displayPrice;
  final bool hasVariants;
  final bool inStock;
  final double avgRating;
  final int reviewCount;
  final DateTime? createdAt;
  final TopProductCategory? category;

  const TopProductModel({
    required this.id,
    required this.name,
    required this.slug,
    this.image,
    required this.displayPrice,
    required this.hasVariants,
    required this.inStock,
    required this.avgRating,
    required this.reviewCount,
    this.createdAt,
    this.category,
  });

  factory TopProductModel.fromJson(Map<String, dynamic> json) {
    return TopProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      image: json['image']?.toString(),
      displayPrice: (json['displayPrice'] as num?)?.toDouble() ?? 0,
      hasVariants: json['hasVariants'] == true,
      inStock: json['inStock'] == true,
      avgRating: (json['avgRating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      category: json['category'] != null
          ? TopProductCategory.fromJson(json['category'] as Map<String, dynamic>)
          : null,
    );
  }
}