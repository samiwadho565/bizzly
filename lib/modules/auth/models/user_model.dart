class UserModel {
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.role,
    this.imageUrl,
  });

  final int id;
  final String name;
  final String email;
  final String? phone;
  final int? role;
  final String? imageUrl;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      role: json['role'] as int?,
      imageUrl: json['image']?.toString() ??
          json['profile_image']?.toString() ??
          json['avatar']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'image': imageUrl,
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    int? role,
    String? imageUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
