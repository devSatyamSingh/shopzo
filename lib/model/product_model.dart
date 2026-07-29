import 'product_list_model.dart';

/// Shopzo — shared product model used by all product-card sections
/// (Flash Deals, Top Picks For You, Trending Now).
///
/// `image` holds either a network URL (real API product) or an asset
/// path — ProductCard auto-detects which one it is.
class ProductModel {
  final String? id;
  final String image;
  final String name;
  final double price;
  final double? originalPrice;
  final double? rating;
  final int? reviewCount;
  final String? badgeText;
  final bool isWishlisted;
  final String? category;
  final String? gender;

  const ProductModel({
    this.id,
    required this.image,
    required this.name,
    required this.price,
    this.originalPrice,
    this.rating,
    this.reviewCount,
    this.badgeText,
    this.isWishlisted = false,
    this.category,
    this.gender,
  });

  /// Converts a real API product (from GET /websiteProducts) into the
  /// shape ProductCard expects.
  factory ProductModel.fromApi(ProductListModel m) {
    return ProductModel(
      id: m.id,
      image: m.image ?? '',
      name: m.name,
      price: m.displayPrice,
      rating: m.avgRating > 0 ? m.avgRating : null,
      reviewCount: m.reviewCount > 0 ? m.reviewCount : null,
      category: m.category?.name,
    );
  }

  int? get discountPercent {
    if (originalPrice == null || originalPrice! <= price) return null;
    return (((originalPrice! - price) / originalPrice!) * 100).round();
  }

  String get formattedPrice => '₹${_format(price)}';
  String? get formattedOriginalPrice =>
      originalPrice == null ? null : '₹${_format(originalPrice!)}';

  static String _format(double value) {
    final whole = value.toStringAsFixed(0);
    return whole.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (m) => ',',
    );
  }
}