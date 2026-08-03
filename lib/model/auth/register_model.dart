class RegisterRequestModel {
  final String name;
  final String phone;
  final String email;
  final String password;

  RegisterRequestModel({
    required this.name,
    required this.phone,
    this.email = '',
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'password': password,
    };
  }
}