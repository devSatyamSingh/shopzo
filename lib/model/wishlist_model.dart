class WishlistItemModel {
  final String id;
  final String productId;
  final String? variantId;
  final String name;
  final String? variantName;
  final String slug;
  final double displayPrice;
  final int stock;
  final bool isAvailable;
  final DateTime? createdAt;

  const WishlistItemModel({
    required this.id,
    required this.productId,
    this.variantId,
    required this.name,
    this.variantName,
    required this.slug,
    required this.displayPrice,
    required this.stock,
    required this.isAvailable,
    this.createdAt,
  });

  String get displayName => variantName != null && variantName!.isNotEmpty ? '$name ($variantName)' : name;

  factory WishlistItemModel.fromJson(Map<String, dynamic> json) {
    return WishlistItemModel(
      id: json['id']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      variantId: json['variantId']?.toString(),
      name: json['name']?.toString() ?? '',
      variantName: json['variantName']?.toString(),
      slug: json['slug']?.toString() ?? '',
      displayPrice: double.tryParse(json['displayPrice']?.toString() ?? '0') ?? 0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      isAvailable: json['isAvailable'] == true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}