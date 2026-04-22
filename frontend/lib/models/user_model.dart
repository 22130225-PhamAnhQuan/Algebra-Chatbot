class UserModel {
  final int id;
  final String email;
  final String name;
  final String role;
  final bool isActive;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      // Đảm bảo quét hết các key name có thể có từ Backend
      name: json['name'] ?? json['full_name'] ?? json['username'] ?? 'Người dùng',
      role: json['role'] ?? 'USER',
      isActive: json['is_active'] ?? true,
      // Fix lỗi parse ngày tháng
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  UserModel copyWith({String? name, String? email}) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role,
      isActive: isActive,
      createdAt: createdAt,
    );
  }
}