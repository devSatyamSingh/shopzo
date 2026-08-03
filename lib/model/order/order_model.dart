import 'dart:convert';
import '../address/address_model.dart';

const String _kServerBaseUrl = 'https://madhu.fctesting.shop';

String _resolveImageUrl(String path) {
  if (path.isEmpty) return path;
  if (path.startsWith('http')) return path;
  return '$_kServerBaseUrl$path';
}

List<String> _parseImagesField(dynamic raw) {
  if (raw == null) return [];
  if (raw is List) {
    return raw.map((e) => _resolveImageUrl(e.toString())).toList();
  }
  if (raw is String && raw.trim().isNotEmpty) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map((e) => _resolveImageUrl(e.toString())).toList();
      }
    } catch (_) {
      // not valid JSON — ignore
    }
  }
  return [];
}

// ---------------- ORDER STATUS ----------------
enum OrderStatus {
  pending,
  processing,
  completed,
  cancelled,
  refunded,
  unknown,
}

extension OrderStatusX on OrderStatus {
  static OrderStatus fromApi(String? raw) {
    switch ((raw ?? '').trim().toUpperCase()) {
      case 'PENDING':
        return OrderStatus.pending;
      case 'PROCESSING':
        return OrderStatus.processing;
      case 'COMPLETED':
      case 'DELIVERED':
        return OrderStatus.completed;
      case 'CANCELLED':
      case 'CANCELED':
        return OrderStatus.cancelled;
      case 'REFUNDED':
      case 'REFUND':
        return OrderStatus.refunded;
      default:
        return OrderStatus.unknown;
    }
  }
}

// ---------------- REQUEST ITEM (order placement) ----------------
class OrderRequestItem {
  final String productId;
  final String? variantId;
  final int quantity;

  const OrderRequestItem({
    required this.productId,
    this.variantId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      if (variantId != null && variantId!.isNotEmpty) 'variantId': variantId,
      'quantity': quantity,
    };
  }
}

// ---------------- NESTED PRODUCT (order item ke andar) ----------------
class OrderLineProduct {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String sku;
  final bool isActive;
  final int stock;
  final List<String> images;

  const OrderLineProduct({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.sku,
    required this.isActive,
    required this.stock,
    required this.images,
  });

  String? get thumbnail => images.isNotEmpty ? images.first : null;

  factory OrderLineProduct.fromJson(Map<String, dynamic> json) {
    return OrderLineProduct(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString(),
      sku: json['sku']?.toString() ?? '',
      isActive: json['isActive'] == true,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      images: _parseImagesField(json['images']),
    );
  }
}

// ---------------- NESTED VARIANT (order item ke andar) ----------------
class OrderLineVariant {
  final String id;
  final String productId;
  final String name;
  final String sku;
  final int stock;
  final List<String> images;

  const OrderLineVariant({
    required this.id,
    required this.productId,
    required this.name,
    required this.sku,
    required this.stock,
    required this.images,
  });

  String? get thumbnail => images.isNotEmpty ? images.first : null;

  factory OrderLineVariant.fromJson(Map<String, dynamic> json) {
    return OrderLineVariant(
      id: json['id']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      images: _parseImagesField(json['images']),
    );
  }
}

// ---------------- ORDER LINE ITEM (server response) ----------------
class OrderItemModel {
  final String id;
  final String productId;
  final String? variantId;
  final int quantity;
  final double price;
  final double taxRate;
  final double taxAmount;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double subtotal;
  final OrderLineProduct? product; // sirf order-detail API me aata hai
  final OrderLineVariant? variant; // sirf order-detail API me aata hai

  const OrderItemModel({
    required this.id,
    required this.productId,
    this.variantId,
    required this.quantity,
    required this.price,
    required this.taxRate,
    required this.taxAmount,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.subtotal,
    this.product,
    this.variant,
  });

  /// UI ke liye ready-made display fields — variant image/name available
  /// ho to wahi priority, warna product level se le lo.
  String get displayName => variant?.name != null && product != null
      ? '${product!.name} (${variant!.name})'
      : (product?.name ?? 'Product');

  String? get displayImage => variant?.thumbnail ?? product?.thumbnail;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    double num_(dynamic v) => double.tryParse(v?.toString() ?? '0') ?? 0;
    return OrderItemModel(
      id: json['id']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      variantId: json['variantId']?.toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      price: num_(json['price']),
      taxRate: num_(json['taxRate']),
      taxAmount: num_(json['taxAmount']),
      cgstAmount: num_(json['cgstAmount']),
      sgstAmount: num_(json['sgstAmount']),
      igstAmount: num_(json['igstAmount']),
      subtotal: num_(json['subtotal']),
      product: json['product'] != null
          ? OrderLineProduct.fromJson(json['product'] as Map<String, dynamic>)
          : null,
      variant: json['variant'] != null
          ? OrderLineVariant.fromJson(json['variant'] as Map<String, dynamic>)
          : null,
    );
  }
}

// ---------------- PAYMENT ----------------
class OrderPaymentModel {
  final String id;
  final String method;
  final String status;
  final double amount;
  final String? transactionRef;

  const OrderPaymentModel({
    required this.id,
    required this.method,
    required this.status,
    required this.amount,
    this.transactionRef,
  });

  factory OrderPaymentModel.fromJson(Map<String, dynamic> json) {
    return OrderPaymentModel(
      id: json['id']?.toString() ?? '',
      method: json['method']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      transactionRef: json['transactionRef']?.toString(),
    );
  }
}

// ---------------- CUSTOMER (order ke andar summary) ----------------
class OrderCustomerModel {
  final String id;
  final String name;
  final String? phone;
  final String? email;

  const OrderCustomerModel({
    required this.id,
    required this.name,
    this.phone,
    this.email,
  });

  factory OrderCustomerModel.fromJson(Map<String, dynamic> json) {
    return OrderCustomerModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
    );
  }
}

// ---------------- FULL ORDER ----------------
class OrderModel {
  final String id;
  final String orderNumber;
  final String channel;
  final String statusRaw;
  final OrderStatus status;
  final String gstType;
  final String? customerId;
  final String? addressId;
  final String? couponId;
  final double subtotal;
  final double tax;
  final double discount;
  final double total;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<OrderItemModel> orderItems;
  final OrderPaymentModel? payment;
  final OrderCustomerModel? customer; // sirf order-detail API me
  final AddressModel? address; // sirf order-detail API me
  final List<dynamic> refunds; // abhi raw rakha hai

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.channel,
    required this.statusRaw,
    required this.status,
    required this.gstType,
    this.customerId,
    this.addressId,
    this.couponId,
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.total,
    this.createdAt,
    this.updatedAt,
    required this.orderItems,
    this.payment,
    this.customer,
    this.address,
    this.refunds = const [],
  });

  int get itemCount => orderItems.length;
  int get totalQuantity => orderItems.fold(0, (sum, i) => sum + i.quantity);

  String? get firstItemImage =>
      orderItems.isNotEmpty ? orderItems.first.displayImage : null;

  bool get canCancel =>
      status == OrderStatus.pending || status == OrderStatus.processing;

  bool get canReview => status == OrderStatus.completed;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    double num_(dynamic v) => double.tryParse(v?.toString() ?? '0') ?? 0;
    final rawStatus = json['status']?.toString() ?? 'PENDING';
    return OrderModel(
      id: json['id']?.toString() ?? '',
      orderNumber: json['orderNumber']?.toString() ?? '',
      channel: json['channel']?.toString() ?? '',
      statusRaw: rawStatus,
      status: OrderStatusX.fromApi(rawStatus),
      gstType: json['gstType']?.toString() ?? '',
      customerId: json['customerId']?.toString(),
      addressId: json['addressId']?.toString(),
      couponId: json['couponId']?.toString(),
      subtotal: num_(json['subtotal']),
      tax: num_(json['tax']),
      discount: num_(json['discount']),
      total: num_(json['total']),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
      orderItems: (json['orderItems'] as List<dynamic>? ?? [])
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      payment: json['payment'] != null
          ? OrderPaymentModel.fromJson(json['payment'] as Map<String, dynamic>)
          : null,
      customer: json['customer'] != null
          ? OrderCustomerModel.fromJson(
              json['customer'] as Map<String, dynamic>,
            )
          : null,
      address: json['address'] != null
          ? AddressModel.fromJson(json['address'] as Map<String, dynamic>)
          : null,
      refunds: json['refunds'] as List<dynamic>? ?? [],
    );
  }
}
