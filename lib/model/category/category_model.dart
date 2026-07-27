
class CategoryModel {
  final String id;
  final String name;
  final String slug;
  final String? image;
  final String? parentId;
  final String? taxRate;
  final int productCount;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.image,
    this.parentId,
    this.taxRate,
    this.productCount = 0,
  });

  /// Top-level category = no parent (Beauty, Fashion, test, etc.)
  bool get isTopLevel => parentId == null;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final count = json['_count'];
    final productCount = (count is Map && count['products'] != null)
        ? int.tryParse(count['products'].toString()) ?? 0
        : 0;

    return CategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      image: (json['image'] != null && json['image'].toString().isNotEmpty)
          ? json['image'].toString()
          : null,
      parentId: json['parentId']?.toString(),
      taxRate: json['taxRate']?.toString(),
      productCount: productCount,
    );
  }
}