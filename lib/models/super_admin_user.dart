class SuperAdminUser {
  final int id;
  final String name;
  final String email;
  final String? username;
  final String? phone;
  final String role;
  final bool isActive;
  final String? createdAt;

  const SuperAdminUser({
    required this.id,
    required this.name,
    required this.email,
    this.username,
    this.phone,
    required this.role,
    required this.isActive,
    this.createdAt,
  });

  factory SuperAdminUser.fromJson(Map<String, dynamic> json) {
    return SuperAdminUser(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      username: json['username'] as String?,
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? 'super_admin',
      isActive: json['is_active'] == true || json['is_active'] == 1,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'username': username,
      'phone': phone,
      'role': role,
      'is_active': isActive,
      'created_at': createdAt,
    };
  }

  bool get isSuperAdmin => role == 'super_admin';
}
