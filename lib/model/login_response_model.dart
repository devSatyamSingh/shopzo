import 'package:shopzo/model/user_model.dart';


class LoginResponseModel {
  final CustomerModel customer;
  final String accessToken;
  final String refreshToken;

  LoginResponseModel({
    required this.customer,
    required this.accessToken,
    required this.refreshToken,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return LoginResponseModel(
      customer: CustomerModel.fromJson(
        data['customer'] as Map<String, dynamic>? ?? {},
      ),
      accessToken: data['accessToken']?.toString() ?? '',
      refreshToken: data['refreshToken']?.toString() ?? '',
    );
  }
}