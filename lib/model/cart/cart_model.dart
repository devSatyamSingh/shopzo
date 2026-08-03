class CartItemModel {
  final String id;
  final String productId;
  final String productName;
  final String productSlug;
  final String? image;
  final String? variantId;
  final String? variantSku;
  final int quantity;
  final double unitPrice;
  final double lineTotal;
  final int availableStock;
  final bool isActive;
  final bool inStockEnough;

  const CartItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productSlug,
    this.image,
    this.variantId,
    this.variantSku,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    required this.availableStock,
    required this.isActive,
    required this.inStockEnough,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      productName: json['productName']?.toString() ?? '',
      productSlug: json['productSlug']?.toString() ?? '',
      image: json['image']?.toString(),
      variantId: json['variantId']?.toString(),
      variantSku: json['variantSku']?.toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      lineTotal: (json['lineTotal'] as num?)?.toDouble() ?? 0.0,
      availableStock: (json['availableStock'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      inStockEnough: json['inStockEnough'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productSlug': productSlug,
      'image': image,
      'variantId': variantId,
      'variantSku': variantSku,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'lineTotal': lineTotal,
      'availableStock': availableStock,
      'isActive': isActive,
      'inStockEnough': inStockEnough,
    };
  }

  CartItemModel copyWith({int? quantity, double? lineTotal}) {
    return CartItemModel(
      id: id,
      productId: productId,
      productName: productName,
      productSlug: productSlug,
      image: image,
      variantId: variantId,
      variantSku: variantSku,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice,
      lineTotal: lineTotal ?? this.lineTotal,
      availableStock: availableStock,
      isActive: isActive,
      inStockEnough: inStockEnough,
    );
  }

  bool get isUnavailable => !isActive;

  bool get isLowStock => availableStock > 0 && availableStock <= 3;
}

class CartModel {
  final String cartId;
  final List<CartItemModel> items;
  final double subtotal;
  final int itemCount;

  const CartModel({
    required this.cartId,
    required this.items,
    required this.subtotal,
    required this.itemCount,
  });

  factory CartModel.empty() =>
      const CartModel(cartId: '', items: [], subtotal: 0, itemCount: 0);

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      cartId: json['cartId']?.toString() ?? '',
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal:
          (json['subtotal'] as num?)?.toDouble() ??
          _deriveSubtotal(json['items'] as List<dynamic>? ?? []),
      itemCount:
          (json['itemCount'] as num?)?.toInt() ??
          _deriveItemCount(json['items'] as List<dynamic>? ?? []),
    );
  }

  static double _deriveSubtotal(List<dynamic> rawItems) {
    double total = 0;
    for (final e in rawItems) {
      total +=
          ((e as Map<String, dynamic>)['lineTotal'] as num?)?.toDouble() ?? 0.0;
    }
    return total;
  }

  static int _deriveItemCount(List<dynamic> rawItems) {
    int count = 0;
    for (final e in rawItems) {
      count += ((e as Map<String, dynamic>)['quantity'] as num?)?.toInt() ?? 0;
    }
    return count;
  }

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  int get totalLines => items.length;

  CartItemModel? findItem(String productId, String? variantId) {
    for (final item in items) {
      final sameProduct = item.productId == productId;
      final sameVariant = (variantId == null || variantId.isEmpty)
          ? (item.variantId == null || item.variantId!.isEmpty)
          : item.variantId == variantId;
      if (sameProduct && sameVariant) return item;
    }
    return null;
  }

  CartModel copyWith({
    String? cartId,
    List<CartItemModel>? items,
    double? subtotal,
    int? itemCount,
  }) {
    return CartModel(
      cartId: cartId ?? this.cartId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      itemCount: itemCount ?? this.itemCount,
    );
  }
}
