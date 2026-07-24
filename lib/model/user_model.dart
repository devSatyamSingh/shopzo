/// Shopzo — customer object returned by register/login APIs.
class CustomerModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String createdAt;
  final String updatedAt;

  CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}