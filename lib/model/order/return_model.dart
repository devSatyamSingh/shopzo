import 'dart:convert';

const String _kServerBaseUrl = 'https://madhu.fctesting.shop';

String? _resolveImageUrl(String? path) {
  if (path == null || path.isEmpty) return null;
  if (path.startsWith('http')) return path;
  return '$_kServerBaseUrl$path';
}

List<String> _parseImagesField(dynamic raw) {
  if (raw == null) return [];
  if (raw is List) {
    return raw
        .map((e) => _resolveImageUrl(e.toString()) ?? '')
        .where((e) => e.isNotEmpty)
        .toList();
  }
  if (raw is String && raw.trim().isNotEmpty) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .map((e) => _resolveImageUrl(e.toString()) ?? '')
            .where((e) => e.isNotEmpty)
            .toList();
      }
    } catch (_) {
      // JSON nahi hai — ignore
    }
  }
  return [];
}

// ---------------- RETURN TYPE (Return ya Exchange) ----------------
enum ReturnRequestType { returnOnly, exchange }

extension ReturnRequestTypeX on ReturnRequestType {
  String get apiValue =>
      this == ReturnRequestType.exchange ? 'EXCHANGE' : 'RETURN';

  String get label => this == ReturnRequestType.exchange ? 'Exchange' : 'Return';

  static ReturnRequestType fromApi(String? raw) {
    if ((raw ?? '').trim().toUpperCase() == 'EXCHANGE') {
      return ReturnRequestType.exchange;
    }
    return ReturnRequestType.returnOnly;
  }
}

// ---------------- RETURN STATUS ----------------
enum ReturnStatus { requested, approved, rejected, cancelled, completed, unknown }

extension ReturnStatusX on ReturnStatus {
  static ReturnStatus fromApi(String? raw) {
    switch ((raw ?? '').trim().toUpperCase()) {
      case 'REQUESTED':
        return ReturnStatus.requested;
      case 'APPROVED':
        return ReturnStatus.approved;
      case 'REJECTED':
        return ReturnStatus.rejected;
      case 'CANCELLED':
      case 'CANCELED':
        return ReturnStatus.cancelled;
      case 'COMPLETED':
        return ReturnStatus.completed;
      default:
        return ReturnStatus.unknown;
    }
  }
}

// ---------------- NESTED: PRODUCT (return ke andar, list/detail me) ----------------
class ReturnLineProduct {
  final String id;
  final String name;
  final String? slug;
  final String? description;
  final String? sku;
  final double? price;
  final bool? isActive;
  final int? stock;
  final List<String> images;

  const ReturnLineProduct({
    required this.id,
    required this.name,
    this.slug,
    this.description,
    this.sku,
    this.price,
    this.isActive,
    this.stock,
    required this.images,
  });

  String? get thumbnail => images.isNotEmpty ? images.first : null;

  factory ReturnLineProduct.fromJson(Map<String, dynamic> json) {
    return ReturnLineProduct(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString(),
      description: json['description']?.toString(),
      sku: json['sku']?.toString(),
      price: double.tryParse(json['price']?.toString() ?? ''),
      isActive: json['isActive'] as bool?,
      stock: (json['stock'] as num?)?.toInt(),
      images: _parseImagesField(json['images']),
    );
  }
}

// ---------------- NESTED: VARIANT (return ke andar) ----------------
class ReturnLineVariant {
  final String id;
  final String? productId;
  final String name;
  final String? sku;
  final double? price;
  final int? stock;
  final List<String> images;

  const ReturnLineVariant({
    required this.id,
    this.productId,
    required this.name,
    this.sku,
    this.price,
    this.stock,
    required this.images,
  });

  String? get thumbnail => images.isNotEmpty ? images.first : null;

  factory ReturnLineVariant.fromJson(Map<String, dynamic> json) {
    return ReturnLineVariant(
      id: json['id']?.toString() ?? '',
      productId: json['productId']?.toString(),
      name: json['name']?.toString() ?? '',
      sku: json['sku']?.toString(),
      price: double.tryParse(json['price']?.toString() ?? ''),
      stock: (json['stock'] as num?)?.toInt(),
      images: _parseImagesField(json['images']),
    );
  }
}

// ---------------- NESTED: ORDER SUMMARY (return ke andar) ----------------
class ReturnLineOrder {
  final String id;
  final String orderNumber;
  final String? status;
  final double? total;

  const ReturnLineOrder({
    required this.id,
    required this.orderNumber,
    this.status,
    this.total,
  });

  factory ReturnLineOrder.fromJson(Map<String, dynamic> json) {
    return ReturnLineOrder(
      id: json['id']?.toString() ?? '',
      orderNumber: json['orderNumber']?.toString() ?? '',
      status: json['status']?.toString(),
      total: double.tryParse(json['total']?.toString() ?? ''),
    );
  }
}

// ---------------- NESTED: ORDER ITEM (jis product ka return/exchange hua) ----------------
class ReturnOrderItemModel {
  final String id;
  final String? orderId;
  final String productId;
  final String? variantId;
  final int quantity;
  final double price;
  final double subtotal;
  final int returnedQty;
  final ReturnLineProduct? product;
  final ReturnLineVariant? variant;
  final ReturnLineOrder? order;

  const ReturnOrderItemModel({
    required this.id,
    this.orderId,
    required this.productId,
    this.variantId,
    required this.quantity,
    required this.price,
    required this.subtotal,
    required this.returnedQty,
    this.product,
    this.variant,
    this.order,
  });

  String get displayName {
    final name = product?.name ?? 'Product';
    final variantLabel = variant?.name;
    if (variantLabel != null && variantLabel.isNotEmpty) {
      return '$name ($variantLabel)';
    }
    return name;
  }

  String? get displayImage => variant?.thumbnail ?? product?.thumbnail;

  factory ReturnOrderItemModel.fromJson(Map<String, dynamic> json) {
    double num_(dynamic v) => double.tryParse(v?.toString() ?? '0') ?? 0;
    return ReturnOrderItemModel(
      id: json['id']?.toString() ?? '',
      orderId: json['orderId']?.toString(),
      productId: json['productId']?.toString() ?? '',
      variantId: json['variantId']?.toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      price: num_(json['price']),
      subtotal: num_(json['subtotal']),
      returnedQty: (json['returnedQty'] as num?)?.toInt() ?? 0,
      product: json['product'] != null
          ? ReturnLineProduct.fromJson(json['product'] as Map<String, dynamic>)
          : null,
      variant: json['variant'] != null
          ? ReturnLineVariant.fromJson(json['variant'] as Map<String, dynamic>)
          : null,
      order: json['order'] != null
          ? ReturnLineOrder.fromJson(json['order'] as Map<String, dynamic>)
          : null,
    );
  }
}

// ---------------- FULL RETURN/EXCHANGE MODEL ----------------
// Ye ek hi model create / list / detail / cancel — sab response ko handle karta hai
class ReturnModel {
  final String id;
  final String orderItemId;
  final String? customerId;
  final ReturnRequestType type;
  final String reason;
  final String? reasonNote;
  final List<String> images;
  final int quantity;
  final ReturnStatus status;
  final String statusRaw;
  final String? exchangeVariantId;
  final String? exchangeOrderId;
  final String? approvedById;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final ReturnOrderItemModel? orderItem; // create response me nahi aata, list/detail me aata hai
  final ReturnLineVariant? exchangeVariant; // sirf detail me
  final dynamic refund; // abhi raw rakha hai, refund model banana ho to alag se

  const ReturnModel({
    required this.id,
    required this.orderItemId,
    this.customerId,
    required this.type,
    required this.reason,
    this.reasonNote,
    required this.images,
    required this.quantity,
    required this.status,
    required this.statusRaw,
    this.exchangeVariantId,
    this.exchangeOrderId,
    this.approvedById,
    this.createdAt,
    this.updatedAt,
    this.orderItem,
    this.exchangeVariant,
    this.refund,
  });

  bool get isExchange => type == ReturnRequestType.exchange;

  // Jab tak REQUESTED (pending) hai, tabhi cancel allowed — baaki backend khud 400 bhejta hai
  bool get canCancel => status == ReturnStatus.requested;

  factory ReturnModel.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status']?.toString() ?? 'REQUESTED';
    return ReturnModel(
      id: json['id']?.toString() ?? '',
      orderItemId: json['orderItemId']?.toString() ?? '',
      customerId: json['customerId']?.toString(),
      type: ReturnRequestTypeX.fromApi(json['type']?.toString()),
      reason: json['reason']?.toString() ?? '',
      reasonNote: json['reasonNote']?.toString(),
      images: _parseImagesField(json['images']),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      status: ReturnStatusX.fromApi(rawStatus),
      statusRaw: rawStatus,
      exchangeVariantId: json['exchangeVariantId']?.toString(),
      exchangeOrderId: json['exchangeOrderId']?.toString(),
      approvedById: json['approvedById']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
      orderItem: json['orderItem'] != null
          ? ReturnOrderItemModel.fromJson(json['orderItem'] as Map<String, dynamic>)
          : null,
      exchangeVariant: json['exchangeVariant'] != null
          ? ReturnLineVariant.fromJson(json['exchangeVariant'] as Map<String, dynamic>)
          : null,
      refund: json['refund'],
    );
  }
}