class UserModel {
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.role,
  });

  final int id;
  final String name;
  final String email;
  final String? phone;
  final int? role;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      role: json['role'] as int?,
    );
  }
}
