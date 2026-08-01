/// Matches:
///  POST /api/v1/reviews                       (create)
///  GET  /api/v1/reviews/product/:productId     (list for a product)

class ReviewCustomerModel {
  final String id;
  final String name;

  const ReviewCustomerModel({required this.id, required this.name});

  factory ReviewCustomerModel.fromJson(Map<String, dynamic> json) {
    return ReviewCustomerModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

class ReviewModel {
  final String id;
  final String productId;
  final String customerId;
  final int rating;
  final String? comment;
  final List<String> images;
  final bool isApproved;
  final DateTime? createdAt;
  final ReviewCustomerModel? customer; // sirf getReviewsByProduct me aata hai

  const ReviewModel({
    required this.id,
    required this.productId,
    required this.customerId,
    required this.rating,
    this.comment,
    required this.images,
    required this.isApproved,
    this.createdAt,
    this.customer,
  });

  String get customerName => customer?.name ?? 'Customer';

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment']?.toString(),
      images: (json['images'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      isApproved: json['isApproved'] == true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      customer: json['customer'] != null
          ? ReviewCustomerModel.fromJson(json['customer'] as Map<String, dynamic>)
          : null,
    );
  }
}