import '../../helper/app_exception.dart';
import '../../helper/network/network_api_services.dart';
import '../../helper/response/api_response.dart';
import '../../res/api_urls.dart';
import '../model/support_ticket_model.dart';

class SupportRepository {
  final NetworkApiServices _apiServices = NetworkApiServices();

  /// GET /website/support — logged-in customer ke sabhi tickets
  Future<ApiResponse<List<SupportTicketModel>>> getMyTickets() async {
    try {
      final response = await _apiServices.getGetApiResponse(ApiUrl.mySupportTickets);
      final map = response as Map<String, dynamic>;
      final List<dynamic> rawList = (map['data'] as List<dynamic>?) ?? [];

      final tickets = rawList
          .map((e) => SupportTicketModel.fromJson(e as Map<String, dynamic>))
          .toList();

      // Naye ticket sabse upar dikhane ke liye createdAt ke hisaab se descending sort
      tickets.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return ApiResponse.completed(tickets);
    } on AppException catch (e) {
      return ApiResponse.error(e.message.isNotEmpty ? e.message : e.toString());
    } catch (e) {
      return ApiResponse.error('Something went wrong. Please try again.');
    }
  }

  /// POST /website/support — naya ticket create karta hai
  /// ⚠️ method name "getPostApiResponse" assumption hai — apni NetworkApiServices
  /// class me exact POST method ka naam check karke yahan use karna.
  Future<ApiResponse<SupportTicketModel>> createTicket({
    required String title,
    required String description,
  }) async {
    try {
      final response = await _apiServices.getPostApiResponse(
        ApiUrl.createSupportTicket,
        {
          'title': title,
          'description': description,
        },
      );
      final map = response as Map<String, dynamic>;
      final data = map['data'] as Map<String, dynamic>? ?? {};
      return ApiResponse.completed(SupportTicketModel.fromJson(data));
    } on AppException catch (e) {
      return ApiResponse.error(e.message.isNotEmpty ? e.message : e.toString());
    } catch (e) {
      return ApiResponse.error('Something went wrong. Please try again.');
    }
  }
}