class RefreshTokenResponseModel {
  final String accessToken;
  final String refreshToken;

  RefreshTokenResponseModel({
    required this.accessToken,
    required this.refreshToken,
  });

  factory RefreshTokenResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return RefreshTokenResponseModel(
      accessToken: data['accessToken']?.toString() ?? '',
      refreshToken: data['refreshToken']?.toString() ?? '',
    );
  }
}