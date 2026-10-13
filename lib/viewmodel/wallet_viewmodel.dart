import 'package:flutter/material.dart';
import '../model/wallet_model.dart';
import '../repo/wallet_repo.dart';

enum WalletFilter { all, credit, debit }

class WalletViewModel extends ChangeNotifier {
  final WalletRepository _repo = WalletRepository();
  static const int _limit = 20;

  WalletModel? _wallet;
  WalletModel? get wallet => _wallet;
  double get balance => _wallet?.balance ?? 0;

  final List<WalletTransactionModel> _all = [];
  PaginationModel? _pagination;

  bool _isLoading = false; // first load
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  bool _hasLoadedOnce = false;
  bool get hasLoadedOnce => _hasLoadedOnce;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  WalletFilter _filter = WalletFilter.all;
  WalletFilter get filter => _filter;

  bool get hasMore => _pagination?.hasMore ?? false;

  List<WalletTransactionModel> get transactions {
    switch (_filter) {
      case WalletFilter.credit:
        return _all.where((t) => t.isCredit).toList();
      case WalletFilter.debit:
        return _all.where((t) => !t.isCredit).toList();
      case WalletFilter.all:
        return List.unmodifiable(_all);
    }
  }

  bool get isEmpty => _hasLoadedOnce && transactions.isEmpty;

  Future<void> load({bool showLoader = true}) async {
    if (showLoader) {
      _isLoading = true;
      notifyListeners();
    }

    final results = await Future.wait([
      _repo.getMyWallet(),
      _repo.getTransactions(page: 1, limit: _limit),
    ]);

    final walletRes = results[0] as dynamic;
    final txRes = results[1] as dynamic;

    if (walletRes.isCompleted) {
      _wallet = walletRes.data as WalletModel?;
      _errorMessage = null;
    } else {
      _errorMessage = walletRes.message as String?;
    }

    if (txRes.isCompleted && txRes.data != null) {
      final page = txRes.data as WalletTransactionsPage;
      _all
        ..clear()
        ..addAll(page.items);
      _pagination = page.pagination;
    } else if (_wallet == null) {
      _errorMessage ??= txRes.message as String?;
    }

    _hasLoadedOnce = _wallet != null || _all.isNotEmpty;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() => load(showLoader: false);

  Future<void> loadMore() async {
    if (_isLoadingMore || !hasMore) return;
    _isLoadingMore = true;
    notifyListeners();

    final next = (_pagination?.page ?? 1) + 1;
    final res = await _repo.getTransactions(page: next, limit: _limit);
    if (res.isCompleted && res.data != null) {
      _all.addAll(res.data!.items);
      _pagination = res.data!.pagination;
    }
    _isLoadingMore = false;
    notifyListeners();
  }

  Future<void> setFilter(WalletFilter f) async {
    _filter = f;
    notifyListeners();
    var guard = 0;
    while (transactions.length < 8 && hasMore && guard < 3) {
      await loadMore();
      guard++;
    }
  }
}