class UserModel {
  final int id;
  final String name;
  final String username;
  final String? email;
  final String phone;
  final String nik;
  final String role;
  final String status;
  final double penalty;
  final String? profile;
  final bool? phoneVerified;

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    this.email,
    required this.phone,
    required this.nik,
    required this.role,
    required this.status,
    required this.penalty,
    this.profile,
    this.phoneVerified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'],
      phone: json['phone'] ?? '',
      nik: json['nik'] ?? '',
      role: json['role'] ?? 'user',
      status: json['status'] ?? 'active',
      penalty: (json['penalty'] ?? 0).toDouble(),
      profile: json['profile'],
      phoneVerified: json['phone_verified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'phone': phone,
      'nik': nik,
      'role': role,
      'status': status,
      'penalty': penalty,
      'profile': profile,
      'phone_verified': phoneVerified,
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? username,
    String? email,
    String? phone,
    String? nik,
    String? role,
    String? status,
    double? penalty,
    String? profile,
    bool? phoneVerified,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      nik: nik ?? this.nik,
      role: role ?? this.role,
      status: status ?? this.status,
      penalty: penalty ?? this.penalty,
      profile: profile ?? this.profile,
      phoneVerified: phoneVerified ?? this.phoneVerified,
    );
  }

  bool get isAdmin => role == 'admin';
  bool get isActive => status == 'active';
}
