import 'company_model.dart';

class DashboardMetrics {
  final int totalCompanies;
  final int activeCompanies;
  final int inactiveCompanies;
  final int totalRegisteredUsers;
  final int activePlans;
  final List<CompanyModel> recentCompanies;

  const DashboardMetrics({
    required this.totalCompanies,
    required this.activeCompanies,
    required this.inactiveCompanies,
    required this.totalRegisteredUsers,
    required this.activePlans,
    this.recentCompanies = const [],
  });

  factory DashboardMetrics.fromJson(Map<String, dynamic> json) {
    final rawRecent = json['recent_companies'] as List<dynamic>? ?? [];
    return DashboardMetrics(
      totalCompanies: json['total_companies'] is int
          ? json['total_companies']
          : int.tryParse(json['total_companies']?.toString() ?? '') ?? 0,
      activeCompanies: json['active_companies'] is int
          ? json['active_companies']
          : int.tryParse(json['active_companies']?.toString() ?? '') ?? 0,
      inactiveCompanies: json['inactive_companies'] is int
          ? json['inactive_companies']
          : int.tryParse(json['inactive_companies']?.toString() ?? '') ?? 0,
      totalRegisteredUsers: json['total_registered_users'] is int
          ? json['total_registered_users']
          : int.tryParse(json['total_registered_users']?.toString() ?? '') ?? 0,
      activePlans: json['active_plans'] is int
          ? json['active_plans']
          : int.tryParse(json['active_plans']?.toString() ?? '') ?? 0,
      recentCompanies: rawRecent
          .map((c) => CompanyModel.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}
