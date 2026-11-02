import '../app/app.locator.dart';
import '../models/company_model.dart';
import '../models/company_user_model.dart';
import '../models/credentials_model.dart';
import '../models/dashboard_metrics.dart';
import 'api_service.dart';

class CompanyService {
  final ApiService _apiService;

  CompanyService([ApiService? apiService])
      : _apiService = apiService ?? locator<ApiService>();

  Future<DashboardMetrics> getDashboard() async {
    final response = await _apiService.get<DashboardMetrics>(
      '/super-admin/dashboard',
      fromData: (data) => DashboardMetrics.fromJson(data as Map<String, dynamic>),
    );

    if (response.isSuccess && response.data != null) {
      return response.data!;
    } else {
      throw ApiException(message: response.message.isNotEmpty ? response.message : 'Failed to fetch dashboard metrics');
    }
  }

  Future<List<CompanyModel>> getCompanies({
    String? search,
    String? status,
    int? planId,
  }) async {
    final queryParams = <String, dynamic>{};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (status != null && status != 'all') queryParams['status'] = status;
    if (planId != null) queryParams['plan_id'] = planId;

    final response = await _apiService.get<List<CompanyModel>>(
      '/super-admin/companies',
      queryParameters: queryParams,
      fromData: (data) {
        final list = data as List<dynamic>? ?? [];
        return list.map((c) => CompanyModel.fromJson(c as Map<String, dynamic>)).toList();
      },
    );

    if (response.isSuccess && response.data != null) {
      return response.data!;
    } else {
      throw ApiException(message: response.message.isNotEmpty ? response.message : 'Failed to fetch companies');
    }
  }

  Future<CredentialsModel> createCompany({
    required String name,
    required String adminEmail,
    required String adminPassword,
    required int planId,
    String status = 'active',
    String? adminName,
    String? phone,
    String? address,
  }) async {
    final response = await _apiService.post<CredentialsModel>(
      '/super-admin/companies',
      data: {
        'name': name.trim(),
        'admin_email': adminEmail.trim().toLowerCase(),
        'admin_password': adminPassword,
        'plan_id': planId,
        'status': status,
        'admin_name': adminName?.trim(),
        'phone': phone?.trim(),
        'address': address?.trim(),
      },
      fromData: (data) {
        final map = data as Map<String, dynamic>;
        final creds = map['credentials'] as Map<String, dynamic>;
        return CredentialsModel.fromJson(creds);
      },
    );

    if (response.isSuccess && response.data != null) {
      return response.data!;
    } else {
      throw ApiException(message: response.message.isNotEmpty ? response.message : 'Failed to create company');
    }
  }

  Future<CompanyModel> updateCompany(
    int id, {
    required String name,
    required int planId,
    required String status,
    String? phone,
    String? address,
  }) async {
    final response = await _apiService.put<CompanyModel>(
      '/super-admin/companies/$id',
      data: {
        'name': name.trim(),
        'plan_id': planId,
        'status': status,
        'phone': phone?.trim(),
        'address': address?.trim(),
      },
      fromData: (data) => CompanyModel.fromJson(data as Map<String, dynamic>),
    );

    if (response.isSuccess && response.data != null) {
      return response.data!;
    } else {
      throw ApiException(message: response.message.isNotEmpty ? response.message : 'Failed to update company');
    }
  }

  Future<CompanyModel> toggleStatus(int id) async {
    final response = await _apiService.patch<CompanyModel>(
      '/super-admin/companies/$id/toggle-status',
      fromData: (data) => CompanyModel.fromJson(data as Map<String, dynamic>),
    );

    if (response.isSuccess && response.data != null) {
      return response.data!;
    } else {
      throw ApiException(message: response.message.isNotEmpty ? response.message : 'Failed to toggle company status');
    }
  }

  Future<void> deleteCompany(int id) async {
    final response = await _apiService.delete<dynamic>(
      '/super-admin/companies/$id',
    );

    if (!response.isSuccess) {
      throw ApiException(
        message: response.message.isNotEmpty
            ? response.message
            : 'Failed to delete company',
      );
    }
  }

  Future<Map<String, dynamic>> getCompanyUsers(int companyId) async {
    final response = await _apiService.get<Map<String, dynamic>>(
      '/super-admin/companies/$companyId/users',
      fromData: (data) {
        final map = data as Map<String, dynamic>;
        final rawUsers = map['users'] as List<dynamic>? ?? [];
        final users = rawUsers
            .map((u) => CompanyUserModel.fromJson(u as Map<String, dynamic>))
            .toList();
        final companyInfo = map['company'] as Map<String, dynamic>? ?? {};
        return {
          'company': companyInfo,
          'users': users,
        };
      },
    );

    if (response.isSuccess && response.data != null) {
      return response.data!;
    } else {
      throw ApiException(
        message: response.message.isNotEmpty
            ? response.message
            : 'Failed to retrieve company users',
      );
    }
  }

  Future<Map<String, dynamic>> createCompanyUser({
    required int companyId,
    required String name,
    required String email,
    required String password,
    String role = 'sales_rep',
    String? phone,
    String? username,
  }) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      '/super-admin/companies/$companyId/users',
      data: {
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
        'role': role,
        'phone': phone?.trim(),
        'username': username?.trim(),
      },
      fromData: (data) {
        final map = data as Map<String, dynamic>;
        final user = CompanyUserModel.fromJson(map['user'] as Map<String, dynamic>);
        final creds = map['credentials'] as Map<String, dynamic>? ?? {};
        final remainingSlots = map['remaining_slots'] as int? ?? 0;
        return {
          'user': user,
          'credentials': creds,
          'remaining_slots': remainingSlots,
        };
      },
    );

    if (response.isSuccess && response.data != null) {
      return response.data!;
    } else {
      throw ApiException(
        message: response.message.isNotEmpty
            ? response.message
            : 'Failed to create user for company',
      );
    }
  }

  Future<Map<String, dynamic>> updateCompanyUser({
    required int companyId,
    required int userId,
    String? name,
    String? email,
    String? password,
    String? role,
    String? phone,
  }) async {
    final Map<String, dynamic> payload = {};
    if (name != null && name.trim().isNotEmpty) payload['name'] = name.trim();
    if (email != null && email.trim().isNotEmpty) payload['email'] = email.trim().toLowerCase();
    if (password != null && password.trim().isNotEmpty) payload['password'] = password.trim();
    if (role != null && role.trim().isNotEmpty) payload['role'] = role.trim();
    if (phone != null) payload['phone'] = phone.trim();

    final response = await _apiService.put<Map<String, dynamic>>(
      '/super-admin/companies/$companyId/users/$userId',
      data: payload,
      fromData: (data) {
        final map = data as Map<String, dynamic>;
        final user = CompanyUserModel.fromJson(map['user'] as Map<String, dynamic>);
        final creds = map['credentials'] as Map<String, dynamic>?;
        final passwordChanged = map['password_changed'] as bool? ?? false;
        return {
          'user': user,
          'credentials': creds,
          'password_changed': passwordChanged,
        };
      },
    );

    if (response.isSuccess && response.data != null) {
      return response.data!;
    } else {
      throw ApiException(
        message: response.message.isNotEmpty
            ? response.message
            : 'Failed to update company user',
      );
    }
  }

  Future<CompanyUserModel> toggleCompanyUserStatus(int companyId, int userId) async {
    final response = await _apiService.patch<CompanyUserModel>(
      '/super-admin/companies/$companyId/users/$userId/toggle-status',
      fromData: (data) => CompanyUserModel.fromJson(data as Map<String, dynamic>),
    );

    if (response.isSuccess && response.data != null) {
      return response.data!;
    } else {
      throw ApiException(
        message: response.message.isNotEmpty
            ? response.message
            : 'Failed to toggle user status',
      );
    }
  }

  Future<void> deleteCompanyUser(int companyId, int userId) async {
    final response = await _apiService.delete<dynamic>(
      '/super-admin/companies/$companyId/users/$userId',
    );

    if (!response.isSuccess) {
      throw ApiException(
        message: response.message.isNotEmpty
            ? response.message
            : 'Failed to delete user',
      );
    }
  }
}
