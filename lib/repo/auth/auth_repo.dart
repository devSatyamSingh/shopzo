import '../../helper/app_exception.dart';
import '../../helper/network/network_api_services.dart';
import '../../helper/response/api_response.dart';
import '../../model/auth/login_model.dart';
import '../../model/auth/login_response_model.dart';
import '../../model/auth/register_model.dart';
import '../../model/auth/user_model.dart';
import '../../res/api_urls.dart';
import '../../utils/app_storage.dart';

class AuthRepository {
  final NetworkApiServices _apiServices = NetworkApiServices();

  Future<ApiResponse<LoginResponseModel>> login(LoginRequestModel request) async {
    try {
      final response = await _apiServices.getPostApiResponse(
        ApiUrl.login,
        request.toJson(),
      );
      final loginResponse = LoginResponseModel.fromJson(response as Map<String, dynamic>);
      return ApiResponse.completed(loginResponse);
    } on AppException catch (e) {
      return ApiResponse.error(e.message.isNotEmpty ? e.message : e.toString());
    } catch (e) {
      return ApiResponse.error('Something went wrong. Please try again.');
    }
  }

  /// Register API does NOT return tokens — only the created customer.
  /// Caller must route the user to Login after this succeeds.
  Future<ApiResponse<CustomerModel>> register(RegisterRequestModel request) async {
    try {
      final response = await _apiServices.getPostApiResponse(
        ApiUrl.register,
        request.toJson(),
      );
      final data = (response as Map<String, dynamic>)['data'] as Map<String, dynamic>? ?? {};
      final customer = CustomerModel.fromJson(data);
      return ApiResponse.completed(customer);
    } on AppException catch (e) {
      return ApiResponse.error(e.message.isNotEmpty ? e.message : e.toString());
    } catch (e) {
      return ApiResponse.error('Something went wrong. Please try again.');
    }
  }

  /// Invalidates the refresh token server-side. Best-effort — local
  /// session is cleared by AuthViewModel regardless of the result, so a
  /// flaky network never traps the user in a "can't log out" state.
  Future<ApiResponse<bool>> logout() async {
    try {
      final refreshToken = AppStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return ApiResponse.completed(true);
      }
      await _apiServices.getPostApiResponse(
        ApiUrl.logout,
        {'refreshToken': refreshToken},
      );
      return ApiResponse.completed(true);
    } on AppException catch (e) {
      return ApiResponse.error(e.message.isNotEmpty ? e.message : e.toString());
    } catch (e) {
      return ApiResponse.error('Something went wrong.');
    }
  }
}