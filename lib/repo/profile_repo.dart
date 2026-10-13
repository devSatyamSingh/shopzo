import '../../helper/network/network_api_services.dart';
import '../../helper/response/api_response.dart';
import '../../helper/app_exception.dart';
import '../../res/api_urls.dart';
import '../model/profile_model.dart';

class ProfileRepository {
  final NetworkApiServices _apiServices = NetworkApiServices();

  /// GET /api/v1/customer/profile
  Future<ApiResponse<ProfileModel>> getProfile() async {
    try {
      final response = await _apiServices.getGetApiResponse(ApiUrl.customerProfile);
      final data = (response is Map ? response['data'] : null) as Map<String, dynamic>?;

      if (data == null) {
        return ApiResponse.error('Could not load profile.');
      }
      return ApiResponse.completed(ProfileModel.fromJson(data));
    } on AppException catch (e) {
      return ApiResponse.error(e.message.isNotEmpty ? e.message : 'Failed to load profile.');
    } catch (e) {
      return ApiResponse.error('Failed to load profile. Please try again.');
    }
  }

  /// PUT /api/v1/customer/profile — body: name, phone, email, dob, gender
  /// Only send fields that changed / are provided.
  Future<ApiResponse<ProfileModel>> updateProfile({
    required String name,
    required String phone,
    required String email,
    DateTime? dob,
    String? gender, // send as MALE / FEMALE / OTHER
  }) async {
    try {
      final body = <String, dynamic>{
        'name': name.trim(),
        'phone': phone.trim(),
        'email': email.trim(),
        if (dob != null)
          'dob': DateTime.utc(dob.year, dob.month, dob.day).toIso8601String(),
        if (gender != null && gender.trim().isNotEmpty) 'gender': gender.trim().toUpperCase(),
      };

      final response = await _apiServices.getPutApiResponse(ApiUrl.customerProfile, body);
      final data = (response is Map ? response['data'] : null) as Map<String, dynamic>?;

      if (data == null) {
        return ApiResponse.error('Could not update profile. Please try again.');
      }
      return ApiResponse.completed(ProfileModel.fromJson(data));
    } on AppException catch (e) {
      return ApiResponse.error(e.message.isNotEmpty ? e.message : 'Failed to update profile.');
    } catch (e) {
      return ApiResponse.error('Failed to update profile. Please try again.');
    }
  }
}