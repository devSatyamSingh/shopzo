class TaxBreakdownItem {
  final String name;   // e.g. "IGST", "CGST", "SGST"
  final double rate;
  final double amount;

  const TaxBreakdownItem({
    required this.name,
    required this.rate,
    required this.amount,
  });

  factory TaxBreakdownItem.fromJson(Map<String, dynamic> json) {
    double num_(dynamic v) => double.tryParse(v?.toString() ?? '0') ?? 0;
    return TaxBreakdownItem(
      name: json['name']?.toString() ?? '',
      rate: num_(json['rate']),
      amount: num_(json['amount']),
    );
  }
}

class OrderPreviewItem {
  final String productId;
  final String? variantId;
  final int quantity;
  final double price;
  final double subtotal;
  final double taxAmount;
  final List<TaxBreakdownItem> taxBreakdown;
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
    required this.taxAmount,
    required this.taxBreakdown,
    required this.productName,
    this.image,
    required this.availableStock,
    required this.inStock,
  });

  /// UI-friendly summary, e.g. "IGST 18%" or "CGST 9% + SGST 9%"
  String get taxBreakdownLabel {
    if (taxBreakdown.isEmpty) return '';
    return taxBreakdown.map((t) => '${t.name} ${t.rate.toStringAsFixed(0)}%').join(' + ');
  }

  double get lineTotal => subtotal + taxAmount;

  factory OrderPreviewItem.fromJson(Map<String, dynamic> json) {
    double num_(dynamic v) => double.tryParse(v?.toString() ?? '0') ?? 0;
    return OrderPreviewItem(
      productId: json['productId']?.toString() ?? '',
      variantId: json['variantId']?.toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      price: num_(json['price']),
      subtotal: num_(json['subtotal']),
      taxAmount: num_(json['taxAmount']),
      taxBreakdown: (json['taxBreakdown'] as List<dynamic>? ?? [])
          .map((e) => TaxBreakdownItem.fromJson(e as Map<String, dynamic>))
          .toList(),
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
  final String? couponApplied;
  final String? couponError;

  const OrderPreviewModel({
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
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
      couponApplied: json['couponApplied']?.toString(),
      couponError: json['couponError']?.toString(),
    );
  }
}