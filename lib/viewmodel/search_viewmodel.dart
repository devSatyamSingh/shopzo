import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/search_product_model.dart';
import '../model/search_suggestion_model.dart';
import '../repo/search_repo.dart';

enum SuggestionStatus { idle, loading, loaded, error }

enum SearchResultStatus { idle, loading, loaded, error }

// ---------------- RECOMMENDED FOR YOU ----------------
enum RecommendedStatus { idle, loading, loaded, error }

class SearchViewModel extends ChangeNotifier {
  final SearchRepository _repository = SearchRepository();

  static const String _recentSearchKey = 'recent_searches';
  static const int _pageSize = 20;

  RecommendedStatus _recommendedStatus = RecommendedStatus.idle;
  RecommendedStatus get recommendedStatus => _recommendedStatus;
  bool get isRecommendedLoading => _recommendedStatus == RecommendedStatus.loading;

  List<SearchProductModel> _recommended = [];
  List<SearchProductModel> get recommended => _recommended;


  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _safeNotify() {
    if (!_isDisposed) notifyListeners();
  }

  // ---------------- QUERY STATE ----------------
  String _currentQuery = '';
  String get currentQuery => _currentQuery;

  bool _hasSubmittedSearch = false;
  bool get hasSubmittedSearch => _hasSubmittedSearch;

  Timer? _debounceTimer;

  // ---------------- RECENT SEARCHES ----------------
  List<String> _recentSearches = [];
  List<String> get recentSearches => List.unmodifiable(_recentSearches);

  Future<void> loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    _recentSearches = prefs.getStringList(_recentSearchKey) ?? [];
    _safeNotify();
  }

  Future<void> _addToRecentSearches(String query) async {
    if (query.trim().isEmpty) return;
    _recentSearches.removeWhere((e) => e.toLowerCase() == query.toLowerCase());
    _recentSearches.insert(0, query);
    if (_recentSearches.length > 10) {
      _recentSearches = _recentSearches.sublist(0, 10);
    }
    _safeNotify();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentSearchKey, _recentSearches);
  }

  Future<void> removeRecentSearch(int index) async {
    _recentSearches.removeAt(index);
    _safeNotify();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentSearchKey, _recentSearches);
  }

  Future<void> clearRecentSearches() async {
    _recentSearches = [];
    _safeNotify();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentSearchKey);
  }

  /// Suggestion tap pe seedha product detail khulta hai (screen se), lekin
  /// us term ko recent-search me bhi save karna hai taaki agli baar
  /// "Recent Searches" me dikhe — Flipkart isi tarah karta hai.
  Future<void> onSuggestionSelected(String label) async {
    await _addToRecentSearches(label);
  }

  // ---------------- SUGGESTIONS (typeahead) ----------------
  SuggestionStatus _suggestionStatus = SuggestionStatus.idle;
  SuggestionStatus get suggestionStatus => _suggestionStatus;
  bool get isSuggestionLoading => _suggestionStatus == SuggestionStatus.loading;

  List<SearchSuggestionModel> _suggestions = [];
  List<SearchSuggestionModel> get suggestions => _suggestions;

  /// Search bar me har keystroke pe call karo. Khud hi debounce (300ms)
  /// aur minimum-2-character rule handle karta hai.
  void onQueryChanged(String query) {
    _currentQuery = query;
    _hasSubmittedSearch = false;
    _debounceTimer?.cancel();

    final trimmed = query.trim();
    if (trimmed.length < 2) {
      _suggestions = [];
      _suggestionStatus = SuggestionStatus.idle;
      _safeNotify();
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _fetchSuggestions(trimmed);
    });
    _safeNotify();
  }

  Future<void> _fetchSuggestions(String query) async {
    _suggestionStatus = SuggestionStatus.loading;
    _safeNotify();

    final result = await _repository.getSearchSuggestions(query, limit: 8);
    if (_isDisposed) return;

    // Race-condition guard: jab tak response aaya, tab tak user aage type
    // kar chuka ho sakta hai — purane response ko discard karo.
    if (query != _currentQuery.trim()) return;

    if (result.isCompleted && result.data != null) {
      _suggestions = result.data!;
      _suggestionStatus = SuggestionStatus.loaded;
    } else {
      _suggestions = [];
      _suggestionStatus = SuggestionStatus.error;
    }
    _safeNotify();
  }

  // ---------------- FILTERS ----------------
  String? _sortBy; // e.g. 'price_asc' | 'price_desc' | 'newest' — backend se confirm karna
  String? get sortBy => _sortBy;

  double? _minPrice;
  double? _maxPrice;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;

  bool get hasActiveSort => _sortBy != null;
  bool get hasActivePriceFilter => _minPrice != null || _maxPrice != null;

  void setSort(String? sort) {
    _sortBy = sort;
    if (_hasSubmittedSearch) _fetchResults(reset: true);
    _safeNotify();
  }

  void setPriceRange(double? min, double? max) {
    _minPrice = min;
    _maxPrice = max;
    if (_hasSubmittedSearch) _fetchResults(reset: true);
    _safeNotify();
  }

  void clearFilters() {
    _sortBy = null;
    _minPrice = null;
    _maxPrice = null;
    if (_hasSubmittedSearch) _fetchResults(reset: true);
    _safeNotify();
  }

  // ---------------- FULL SEARCH RESULTS ----------------
  SearchResultStatus _resultStatus = SearchResultStatus.idle;
  SearchResultStatus get resultStatus => _resultStatus;
  bool get isResultLoading => _resultStatus == SearchResultStatus.loading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<SearchProductModel> _results = [];
  List<SearchProductModel> get results => _results;

  int _currentPage = 1;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  /// Enter dabane ya search icon tap karne pe call hota hai — poori
  /// listing API se results grid load karta hai.
  Future<void> submitSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    _currentQuery = trimmed;
    _hasSubmittedSearch = true;
    _debounceTimer?.cancel();
    _suggestions = [];
    _suggestionStatus = SuggestionStatus.idle;

    await _addToRecentSearches(trimmed);
    await _fetchResults(reset: true);
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore || _resultStatus != SearchResultStatus.loaded) {
      return;
    }
    _isLoadingMore = true;
    _safeNotify();
    _currentPage++;
    await _fetchResults(reset: false);
  }

  Future<void> _fetchResults({required bool reset}) async {
    if (reset) {
      _currentPage = 1;
      _hasMore = true;
      _results = [];
      _errorMessage = null;
      _resultStatus = SearchResultStatus.loading;
      _safeNotify();
    }

    final result = await _repository.searchProducts(
      query: _currentQuery,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      sort: _sortBy,
      page: _currentPage,
      limit: _pageSize,
    );

    if (_isDisposed) return;

    if (result.isCompleted && result.data != null) {
      final newItems = result.data!;
      if (reset) {
        _results = newItems;
      } else {
        _results = [..._results, ...newItems];
      }
      _hasMore = newItems.length == _pageSize;
      _resultStatus = SearchResultStatus.loaded;
    } else {
      if (reset) {
        _resultStatus = SearchResultStatus.error;
        _errorMessage = result.message ?? 'Failed to load results';
      }
      // loadMore fail ho jaye toh purane results screen pe rehne do —
      // sirf loader hata do, poora screen error state me mat le jao.
    }

    _isLoadingMore = false;
    _safeNotify();
  }


  Future<void> loadRecommended() async {
    _recommendedStatus = RecommendedStatus.loading;
    _safeNotify();

    final result = await _repository.getRecommendedProducts(limit: 10);
    if (_isDisposed) return;

    if (result.isCompleted && result.data != null) {
      _recommended = result.data!;
      _recommendedStatus = RecommendedStatus.loaded;
    } else {
      _recommended = [];
      _recommendedStatus = RecommendedStatus.error;
    }
    _safeNotify();
  }

  Future<void> retry() => _fetchResults(reset: true);

  /// Search field ka "X" clear button — sab kuch reset karke discovery
  /// view (recent + discover) pe wapas le jaata hai.
  void clearSearch() {
    _currentQuery = '';
    _hasSubmittedSearch = false;
    _suggestions = [];
    _suggestionStatus = SuggestionStatus.idle;
    _results = [];
    _resultStatus = SearchResultStatus.idle;
    _sortBy = null;
    _minPrice = null;
    _maxPrice = null;
    _debounceTimer?.cancel();
    _safeNotify();
  }
}