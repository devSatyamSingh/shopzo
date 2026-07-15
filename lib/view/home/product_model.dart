/// Shopzo — shared product model used by all product-card sections
/// (Flash Deals, Top Picks For You, Trending Now).
class ProductModel {
  final String image;
  final String name;
  final double price;
  final double? originalPrice;
  final double? rating;
  final int? reviewCount;
  final String? badgeText; // e.g. "NEW", "BESTSELLER"
  final bool isWishlisted;

  const ProductModel({
    required this.image,
    required this.name,
    required this.price,
    this.originalPrice,
    this.rating,
    this.reviewCount,
    this.badgeText,
    this.isWishlisted = false,
  });

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