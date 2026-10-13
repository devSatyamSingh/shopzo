double _toDouble(dynamic v) => double.tryParse(v?.toString() ?? '') ?? 0;

// ---------------- WALLET ----------------
class WalletModel {
  final double balance;
  const WalletModel({required this.balance});

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(balance: _toDouble(json['balance']));
  }
}

// ---------------- TRANSACTION ----------------
class WalletTransactionModel {
  final String id;
  final bool isCredit;
  final double amount;
  final String title;
  final String? source;
  final String? referenceId;
  final String? status;
  final double? balanceAfter;
  final DateTime? createdAt;

  const WalletTransactionModel({
    required this.id,
    required this.isCredit,
    required this.amount,
    required this.title,
    this.source,
    this.referenceId,
    this.status,
    this.balanceAfter,
    this.createdAt,
  });

  static String _humanize(String raw) {
    final cleaned = raw.replaceAll('_', ' ').trim().toLowerCase();
    if (cleaned.isEmpty) return '';
    return cleaned[0].toUpperCase() + cleaned.substring(1);
  }

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    final typeRaw =
    (json['type'] ?? json['direction'] ?? '').toString().trim().toUpperCase();
    final rawAmount = _toDouble(json['amount']);
    final isCredit = typeRaw.isNotEmpty
        ? (typeRaw == 'CREDIT' || typeRaw == 'CR')
        : rawAmount >= 0;

    final source = (json['source'] ?? json['reason'])?.toString();
    final description =
        (json['description'] ?? json['note'] ?? json['remark'])?.toString() ?? '';

    String title = description.trim();
    if (title.isEmpty && source != null && source.isNotEmpty) {
      title = _humanize(source);
    }
    if (title.isEmpty) title = isCredit ? 'Money added' : 'Money used';

    return WalletTransactionModel(
      id: json['id']?.toString() ?? '',
      isCredit: isCredit,
      amount: rawAmount.abs(),
      title: title,
      source: source,
      referenceId: json['referenceId']?.toString(),
      status: json['status']?.toString(),
      balanceAfter: json['balanceAfter'] != null ? _toDouble(json['balanceAfter']) : null,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '')?.toLocal(),
    );
  }
}

// ---------------- PAGINATION ----------------
class PaginationModel {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const PaginationModel({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  bool get hasMore => page < totalPages;

  factory PaginationModel.fromJson(Map<String, dynamic>? json) {
    return PaginationModel(
      page: (json?['page'] as num?)?.toInt() ?? 1,
      limit: (json?['limit'] as num?)?.toInt() ?? 20,
      total: (json?['total'] as num?)?.toInt() ?? 0,
      totalPages: (json?['totalPages'] as num?)?.toInt() ?? 0,
    );
  }
}

class WalletTransactionsPage {
  final List<WalletTransactionModel> items;
  final PaginationModel pagination;
  const WalletTransactionsPage({required this.items, required this.pagination});
}