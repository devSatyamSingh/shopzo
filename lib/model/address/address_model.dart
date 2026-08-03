/// Shopzo — address object returned by every /addresses endpoint.
/// NOTE: receiver name/phone aren't part of the API yet — once the
/// backend adds them, just add the two fields here + to
/// AddressRequestModel.toJson(), nothing else needs to change.
class AddressModel {
  final String id;
  final String customerId;
  final String type; // 'SHIPPING' or 'BILLING'
  final String line1;
  final String? line2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final bool isDefault;
  final String createdAt;

  AddressModel({
    required this.id,
    required this.customerId,
    required this.type,
    required this.line1,
    this.line2,
    required this.city,
    required this.state,
    required this.postalCode,
    this.country = 'India',
    this.isDefault = false,
    required this.createdAt,
  });

  /// Single-line summary for display on cards / home appbar / etc.
  String get fullAddress {
    return [
      line1,
      if (line2 != null && line2!.isNotEmpty) line2,
      city,
      state,
      postalCode,
    ].join(', ');
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      type: json['type']?.toString() ?? 'SHIPPING',
      line1: json['line1']?.toString() ?? '',
      line2: (json['line2'] != null && json['line2'].toString().isNotEmpty)
          ? json['line2'].toString()
          : null,
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      postalCode: json['postalCode']?.toString() ?? '',
      country: json['country']?.toString() ?? 'India',
      isDefault: json['isDefault'] == true,
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }

  AddressModel copyWith({bool? isDefault}) {
    return AddressModel(
      id: id,
      customerId: customerId,
      type: type,
      line1: line1,
      line2: line2,
      city: city,
      state: state,
      postalCode: postalCode,
      country: country,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt,
    );
  }
}

class AddressRequestModel {
  final String line1;
  final String? line2;
  final String city;
  final String state;
  final String postalCode;
  final String type; // 'SHIPPING' or 'BILLING'
  final bool? isDefault;

  AddressRequestModel({
    required this.line1,
    this.line2,
    required this.city,
    required this.state,
    required this.postalCode,
    this.type = 'SHIPPING',
    this.isDefault,
  });

  Map<String, dynamic> toJson() {
    return {
      'line1': line1,
      if (line2 != null && line2!.isNotEmpty) 'line2': line2,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'type': type,
      if (isDefault != null) 'isDefault': isDefault,
    };
  }
}