import '../helper/app_exception.dart';
import '../helper/network/network_api_services.dart';
import '../helper/response/api_response.dart';
import '../model/address_model.dart';
import '../res/api_urls.dart';


/// Shopzo — Address Repository.
class AddressRepository {
  final NetworkApiServices _apiServices = NetworkApiServices();

  Future<ApiResponse<List<AddressModel>>> getMyAddresses() async {
    try {
      final response = await _apiServices.getGetApiResponse(ApiUrl.addresses);
      final list = (response as Map<String, dynamic>)['data'] as List<dynamic>? ?? [];
      final addresses =
      list.map((e) => AddressModel.fromJson(e as Map<String, dynamic>)).toList();
      return ApiResponse.completed(addresses);
    } on AppException catch (e) {
      return ApiResponse.error(e.message.isNotEmpty ? e.message : e.toString());
    } catch (e) {
      return ApiResponse.error('Something went wrong. Please try again.');
    }
  }

  Future<ApiResponse<AddressModel>> createAddress(AddressRequestModel request) async {
    try {
      final response = await _apiServices.getPostApiResponse(ApiUrl.addresses, request.toJson());
      final data = (response as Map<String, dynamic>)['data'] as Map<String, dynamic>? ?? {};
      return ApiResponse.completed(AddressModel.fromJson(data));
    } on AppException catch (e) {
      return ApiResponse.error(e.message.isNotEmpty ? e.message : e.toString());
    } catch (e) {
      return ApiResponse.error('Something went wrong. Please try again.');
    }
  }

  Future<ApiResponse<AddressModel>> updateAddress(String id, AddressRequestModel request) async {
    try {
      final response =
      await _apiServices.getPutApiResponse(ApiUrl.addressById(id), request.toJson());
      final data = (response as Map<String, dynamic>)['data'] as Map<String, dynamic>? ?? {};
      return ApiResponse.completed(AddressModel.fromJson(data));
    } on AppException catch (e) {
      return ApiResponse.error(e.message.isNotEmpty ? e.message : e.toString());
    } catch (e) {
      return ApiResponse.error('Something went wrong. Please try again.');
    }
  }

  Future<ApiResponse<bool>> deleteAddress(String id) async {
    try {
      await _apiServices.getDeleteApiResponse(ApiUrl.addressById(id));
      return ApiResponse.completed(true);
    } on AppException catch (e) {
      return ApiResponse.error(e.message.isNotEmpty ? e.message : e.toString());
    } catch (e) {
      return ApiResponse.error('Something went wrong. Please try again.');
    }
  }
}