class PayoutMethodModel {
  final String id;
  final String type; // "UPI"
  final String? label;
  final String? upiMasked;

  const PayoutMethodModel({
    required this.id,
    required this.type,
    this.label,
    this.upiMasked,
  });

  /// Card ka main title: label ho to label, warna masked UPI
  String get title {
    final l = label?.trim() ?? '';
    if (l.isNotEmpty) return l;
    return (upiMasked ?? '').isNotEmpty ? upiMasked! : 'UPI';
  }

  /// Dropdown / chhoti jagah ke liye
  String get displayName {
    final l = label?.trim() ?? '';
    final u = upiMasked ?? '';
    if (l.isNotEmpty && u.isNotEmpty) return '$l • $u';
    return l.isNotEmpty ? l : (u.isNotEmpty ? u : 'UPI');
  }

  factory PayoutMethodModel.fromJson(Map<String, dynamic> json) {
    return PayoutMethodModel(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'UPI',
      label: json['label']?.toString(),
      upiMasked: json['upiMasked']?.toString(),
    );
  }
}