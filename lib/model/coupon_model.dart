class CouponModel {
  final String code;
  final String discountType; // "PERCENTAGE" or "FLAT"
  final double value;
  final double minOrderValue;
  final DateTime? expiresAt;

  const CouponModel({
    required this.code,
    required this.discountType,
    required this.value,
    required this.minOrderValue,
    this.expiresAt,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      code: json['code']?.toString() ?? '',
      discountType: json['discountType']?.toString() ?? 'FLAT',
      value: double.tryParse(json['value']?.toString() ?? '0') ?? 0,
      minOrderValue: double.tryParse(json['minOrderValue']?.toString() ?? '0') ?? 0,
      expiresAt: DateTime.tryParse(json['expiresAt']?.toString() ?? ''),
    );
  }

  bool get isPercentage => discountType.toUpperCase() == 'PERCENTAGE';

  String get displayTitle => isPercentage
      ? '${value.toStringAsFixed(0)}% OFF'
      : 'FLAT ₹${value.toStringAsFixed(0)} OFF';

  String get displayDescription => 'On orders above ₹${minOrderValue.toStringAsFixed(0)}';

  bool get isExpired => expiresAt != null && expiresAt!.isBefore(DateTime.now());

  /// Only shows a badge if expiry is within 3 days, else null (no clutter)
  String? get expiryLabel {
    if (expiresAt == null) return null;
    final diff = expiresAt!.difference(DateTime.now());
    if (diff.isNegative) return null;
    if (diff.inDays <= 3) {
      return diff.inDays <= 0 ? 'Expiring today' : 'Expiring in ${diff.inDays} day${diff.inDays == 1 ? '' : 's'}';
    }
    return null;
  }

  /// Whether this coupon can even be applied given the current subtotal
  bool isEligibleFor(double subtotal) => !isExpired && subtotal >= minOrderValue;
}

/// Response of POST /api/coupons/validate
class CouponValidationResult {
  final bool valid;
  final String code;
  final String? discountType;
  final double discount;
  final double? finalAmount;
  final String? message;

  const CouponValidationResult({
    required this.valid,
    required this.code,
    this.discountType,
    required this.discount,
    this.finalAmount,
    this.message,
  });

  factory CouponValidationResult.fromJson(Map<String, dynamic> json, {required String fallbackCode}) {
    return CouponValidationResult(
      valid: json['valid'] as bool? ?? false,
      code: json['code']?.toString() ?? fallbackCode,
      discountType: json['discountType']?.toString(),
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      finalAmount: (json['finalAmount'] as num?)?.toDouble(),
      message: json['message']?.toString(),
    );
  }
}