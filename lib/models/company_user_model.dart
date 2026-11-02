class CompanyUserModel {
  final int id;
  final int companyId;
  final String name;
  final String email;
  final String? username;
  final String? phone;
  final String role;
  final bool isActive;
  final String? createdAt;

  const CompanyUserModel({
    required this.id,
    required this.companyId,
    required this.name,
    required this.email,
    this.username,
    this.phone,
    required this.role,
    this.isActive = true,
    this.createdAt,
  });

  factory CompanyUserModel.fromJson(Map<String, dynamic> json) {
    return CompanyUserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      companyId: json['company_id'] is int
          ? json['company_id']
          : int.tryParse(json['company_id']?.toString() ?? '') ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      username: json['username'] as String?,
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? 'staff',
      isActive: json['is_active'] is bool ? json['is_active'] : json['is_active'] == 1,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'name': name,
      'email': email,
      'username': username,
      'phone': phone,
      'role': role,
      'is_active': isActive,
      'created_at': createdAt,
    };
  }

  CompanyUserModel copyWith({
    int? id,
    int? companyId,
    String? name,
    String? email,
    String? username,
    String? phone,
    String? role,
    bool? isActive,
    String? createdAt,
  }) {
    return CompanyUserModel(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      email: email ?? this.email,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

