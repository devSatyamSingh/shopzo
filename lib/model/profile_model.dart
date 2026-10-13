class ProfileModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final DateTime? dob;
  final String? gender; // raw from API: MALE / FEMALE / OTHER
  final DateTime? createdAt;

  const ProfileModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.dob,
    this.gender,
    this.createdAt,
  });

  /// UI-friendly gender label ("Male" instead of "MALE")
  String? get genderLabel {
    if (gender == null || gender!.trim().isEmpty) return null;
    final g = gender!.toUpperCase();
    switch (g) {
      case 'MALE':
        return 'Male';
      case 'FEMALE':
        return 'Female';
      case 'OTHER':
        return 'Other';
      default:
        return gender;
    }
  }

  static DateTime? _parseDate(dynamic v) {
    final d = DateTime.tryParse(v?.toString() ?? '');
    if (d == null) return null;
    // sirf date part rakho, timezone shift se bachne ke liye
    return DateTime(d.year, d.month, d.day);
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      dob: _parseDate(json['dob']),
      gender: json['gender']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }

  ProfileModel copyWith({
    String? name,
    String? phone,
    String? email,
    DateTime? dob,
    String? gender,
  }) {
    return ProfileModel(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      createdAt: createdAt,
    );
  }
}