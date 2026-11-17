class SuperAdminUser {
  final int id;
  final String name;
  final String email;
  final String? username;
  final String? phone;
  final String? profileImage;
  final String role;
  final bool isActive;
  final String? createdAt;
  final int? companyId;
  final String? companyName;
  final String? updatedAt;

  const SuperAdminUser({
    required this.id,
    required this.name,
    required this.email,
    this.username,
    this.phone,
    this.profileImage,
    required this.role,
    required this.isActive,
    this.createdAt,
    this.companyId,
    this.companyName,
    this.updatedAt,
  });

  factory SuperAdminUser.fromJson(Map<String, dynamic> json) {
    return SuperAdminUser(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      username: json['username'] as String?,
      phone: json['phone'] as String?,
      profileImage: json['profile_image'] as String? ?? json['avatar_url'] as String?,
      role: json['role'] as String? ?? 'super_admin',
      isActive: json['is_active'] == true || json['is_active'] == 1,
      createdAt: json['created_at'] as String?,
      companyId: json['company_id'] is int
          ? json['company_id']
          : int.tryParse(json['company_id']?.toString() ?? ''),
      companyName: json['company_name'] as String? ?? (json['company'] is Map ? json['company']['name'] as String? : null),
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'username': username,
      'phone': phone,
      'profile_image': profileImage,
      'role': role,
      'is_active': isActive,
      'created_at': createdAt,
      'company_id': companyId,
      'company_name': companyName,
      'updated_at': updatedAt,
    };
  }

  SuperAdminUser copyWith({
    int? id,
    String? name,
    String? email,
    String? username,
    String? phone,
    String? profileImage,
    String? role,
    bool? isActive,
    String? createdAt,
    int? companyId,
    String? companyName,
    String? updatedAt,
  }) {
    return SuperAdminUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isSuperAdmin => role == 'super_admin';
}
