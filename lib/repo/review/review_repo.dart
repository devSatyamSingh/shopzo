import 'dart:io';
import '../../helper/network/network_api_services.dart';
import '../../helper/response/api_response.dart';
import '../../helper/app_exception.dart';
import '../../model/review/review_model.dart';
import '../../res/api_urls.dart';

class ReviewRepository {
  final NetworkApiServices _apiServices = NetworkApiServices();

  Future<ApiResponse<ReviewModel>> createReview({
    required String productId,
    required int rating,
    String? comment,
    List<File> images = const [],
  }) async {
    try {
      final fields = <String, String>{
        'productId': productId,
        'rating': rating.toString(),
        if (comment != null && comment.trim().isNotEmpty) 'comment': comment.trim(),
      };

      final response = await _apiServices.getFormDataApiResponse(
        ApiUrl.reviews,
        fields,
        multiFiles: images.isNotEmpty ? {'images': images} : null,
      );

      final data = (response is Map ? response['data'] : null) as Map<String, dynamic>?;
      if (data == null) {
        return ApiResponse.error('Could not submit review. Please try again.');
      }
      return ApiResponse.completed(ReviewModel.fromJson(data));
    } on AppException catch (e) {
      return ApiResponse.error(e.message.isNotEmpty ? e.message : 'Failed to submit review.');
    } catch (e) {
      return ApiResponse.error('Failed to submit review. Please try again.');
    }
  }

  /// GET /api/v1/reviews/product/:productId
  Future<ApiResponse<List<ReviewModel>>> getReviewsByProduct(String productId) async {
    try {
      final response = await _apiServices.getGetApiResponse(
        ApiUrl.productReviews(productId),
      );
      final data = (response is Map ? response['data'] : null) as List<dynamic>?;

      if (data == null) return ApiResponse.completed(<ReviewModel>[]);

      final reviews = data
          .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
          .where((r) => r.isApproved) // sirf approved reviews UI me dikhao
          .toList();

      return ApiResponse.completed(reviews);
    } on AppException catch (e) {
      return ApiResponse.error(e.message.isNotEmpty ? e.message : 'Failed to load reviews.');
    } catch (e) {
      return ApiResponse.error('Failed to load reviews. Please try again.');
    }
  }
}