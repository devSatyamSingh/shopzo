import '../../helper/network/network_api_services.dart';
import '../../helper/response/api_response.dart';
import '../../helper/app_exception.dart';
import '../../res/api_urls.dart';
import '../model/wallet_model.dart';

class WalletRepository {
  final NetworkApiServices _apiServices = NetworkApiServices();

  Future<ApiResponse<WalletModel>> getMyWallet() async {
    try {
      final response = await _apiServices.getGetApiResponse(ApiUrl.wallet);
      final data = (response is Map ? response['data'] : null);
      if (data is! Map<String, dynamic>) {
        return ApiResponse.error('Wallet not found.');
      }
      return ApiResponse.completed(WalletModel.fromJson(data));
    } on AppException catch (e) {
      return ApiResponse.error(e.message.isNotEmpty ? e.message : 'Failed to load wallet.');
    } catch (_) {
      return ApiResponse.error('Failed to load wallet. Please try again.');
    }
  }

  /// GET /api/v1/website/wallet/transactions?page=&limit=
  Future<ApiResponse<WalletTransactionsPage>> getTransactions({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiServices
          .getGetApiResponse(ApiUrl.walletTransactions(page: page, limit: limit));
      final rawList = (response is Map ? response['data'] : null) as List<dynamic>?;
      final pagination = PaginationModel.fromJson(
        (response is Map ? response['pagination'] : null) as Map<String, dynamic>?,
      );
      final items = (rawList ?? [])
          .map((e) => WalletTransactionModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResponse.completed(
        WalletTransactionsPage(items: items, pagination: pagination),
      );
    } on AppException catch (e) {
      return ApiResponse.error(
          e.message.isNotEmpty ? e.message : 'Failed to load transactions.');
    } catch (_) {
      return ApiResponse.error('Failed to load transactions. Please try again.');
    }
  }
}