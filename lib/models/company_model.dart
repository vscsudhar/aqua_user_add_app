import 'plan_model.dart';
import 'super_admin_user.dart';

class CompanyModel {
  final int id;
  final String companyCode;
  final String name;
  final int? planId;
  final String status;
  final String? email;
  final String? phone;
  final String? address;
  final int usersCount;
  final PlanModel? plan;
  final SuperAdminUser? adminUser;
  final String? createdAt;

  const CompanyModel({
    required this.id,
    required this.companyCode,
    required this.name,
    this.planId,
    required this.status,
    this.email,
    this.phone,
    this.address,
    this.usersCount = 0,
    this.plan,
    this.adminUser,
    this.createdAt,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      companyCode: json['company_code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      planId: json['plan_id'] is int ? json['plan_id'] : int.tryParse(json['plan_id']?.toString() ?? ''),
      status: json['status'] as String? ?? 'active',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      usersCount: json['users_count'] is int ? json['users_count'] : int.tryParse(json['users_count']?.toString() ?? '') ?? 0,
      plan: json['plan'] is Map<String, dynamic> ? PlanModel.fromJson(json['plan'] as Map<String, dynamic>) : null,
      adminUser: json['admin_user'] is Map<String, dynamic>
          ? SuperAdminUser.fromJson(json['admin_user'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_code': companyCode,
      'name': name,
      'plan_id': planId,
      'status': status,
      'email': email,
      'phone': phone,
      'address': address,
      'users_count': usersCount,
      'plan': plan?.toJson(),
      'admin_user': adminUser?.toJson(),
      'created_at': createdAt,
    };
  }

  bool get isActive => status == 'active';
  String get adminEmail => adminUser?.email ?? email ?? '—';
  String get adminName => adminUser?.name ?? 'Admin';
  String get planName => plan?.name ?? 'No Plan';
  int get maxUsers => plan?.maxUsers ?? 0;
}
