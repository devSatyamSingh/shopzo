class BannerModel {
  final String id;
  final String title;
  final String imageUrl;
  final String? linkUrl;
  final int sortOrder;

  const BannerModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.linkUrl,
    required this.sortOrder,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      linkUrl: (json['linkUrl'] as String?)?.trim().isNotEmpty == true ? json['linkUrl'].toString() : null,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }
}