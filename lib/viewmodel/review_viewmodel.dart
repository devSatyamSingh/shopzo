import 'dart:io';
import 'package:flutter/material.dart';
import '../model/review_model.dart';
import '../repo/review_repo.dart';

class ReviewViewModel extends ChangeNotifier {
  final ReviewRepository _repository = ReviewRepository();

  // productId -> approved reviews
  final Map<String, List<ReviewModel>> _reviewsByProduct = {};
  List<ReviewModel> reviewsFor(String productId) =>
      List.unmodifiable(_reviewsByProduct[productId] ?? const []);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _submitError;
  String? get submitError => _submitError;

  /// Jab tak admin approve nahi karta, GET reviews API me naya review
  /// nahi aata. Submit hone ke turant baad is productId ko yaha mark kar
  /// dete hain — UI isse "Review submitted, pending approval" dikha sake,
  /// screen refresh/re-navigate hone par bhi jab tak approve na ho jaaye.
  final Set<String> _pendingApprovalProductIds = {};
  bool isPendingApproval(String productId) =>
      _pendingApprovalProductIds.contains(productId);

  /// Current logged-in customer ne is product pe pehle se review diya hai
  /// ya nahi — [currentCustomerId] apne AuthViewModel/AppStorage se pass
  /// karna (jis se customerId milta ho).
  bool hasUserReviewed(String productId, String? currentCustomerId) {
    if (isPendingApproval(productId)) return true;
    if (currentCustomerId == null) return false;
    return reviewsFor(productId).any((r) => r.customerId == currentCustomerId);
  }

  Future<void> fetchReviews(String productId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _repository.getReviewsByProduct(productId);

    if (response.isCompleted) {
      _reviewsByProduct[productId] = response.data ?? [];
    } else {
      _errorMessage = response.message ?? 'Failed to load reviews';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> submitReview({
    required String productId,
    required int rating,
    String? comment,
    List<File> images = const [],
  }) async {
    _isSubmitting = true;
    _submitError = null;
    notifyListeners();

    final response = await _repository.createReview(
      productId: productId,
      rating: rating,
      comment: comment,
      images: images,
    );

    if (response.isCompleted) {
      _pendingApprovalProductIds.add(productId);
      _isSubmitting = false;
      notifyListeners();
      return true;
    } else {
      _submitError = response.message ?? 'Failed to submit review';
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }
}