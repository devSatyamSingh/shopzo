
class OrderPreviewItem {
  final String productId;
  final String? variantId;
  final int quantity;
  final double price;
  final double subtotal;
  final double taxRate;
  final double taxAmount;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final String productName;
  final String? image;
  final int availableStock;
  final bool inStock;

  const OrderPreviewItem({
    required this.productId,
    this.variantId,
    required this.quantity,
    required this.price,
    required this.subtotal,
    required this.taxRate,
    required this.taxAmount,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.productName,
    this.image,
    required this.availableStock,
    required this.inStock,
  });

  factory OrderPreviewItem.fromJson(Map<String, dynamic> json) {
    double num_(dynamic v) => double.tryParse(v?.toString() ?? '0') ?? 0;
    return OrderPreviewItem(
      productId: json['productId']?.toString() ?? '',
      variantId: json['variantId']?.toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      price: num_(json['price']),
      subtotal: num_(json['subtotal']),
      taxRate: num_(json['taxRate']),
      taxAmount: num_(json['taxAmount']),
      cgstAmount: num_(json['cgstAmount']),
      sgstAmount: num_(json['sgstAmount']),
      igstAmount: num_(json['igstAmount']),
      productName: json['productName']?.toString() ?? '',
      image: json['image']?.toString(),
      availableStock: (json['availableStock'] as num?)?.toInt() ?? 0,
      inStock: json['inStock'] == true,
    );
  }
}

class OrderPreviewModel {
  final List<OrderPreviewItem> items;
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final String gstType;
  final String? couponApplied;
  final String? couponError;

  const OrderPreviewModel({
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
    required this.gstType,
    this.couponApplied,
    this.couponError,
  });

  bool get hasCouponApplied => couponApplied != null && couponApplied!.isNotEmpty;
  bool get hasStockIssue => items.any((i) => !i.inStock);

  factory OrderPreviewModel.fromJson(Map<String, dynamic> json) {
    double num_(dynamic v) => double.tryParse(v?.toString() ?? '0') ?? 0;
    return OrderPreviewModel(
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => OrderPreviewItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: num_(json['subtotal']),
      discount: num_(json['discount']),
      tax: num_(json['tax']),
      total: num_(json['total']),
      gstType: json['gstType']?.toString() ?? '',
      couponApplied: json['couponApplied']?.toString(),
      couponError: json['couponError']?.toString(),
    );
  }
}