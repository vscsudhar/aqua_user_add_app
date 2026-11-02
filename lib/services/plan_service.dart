import '../app/app.locator.dart';
import '../models/plan_model.dart';
import 'api_service.dart';

class PlanService {
  final ApiService _apiService;

  PlanService([ApiService? apiService])
      : _apiService = apiService ?? locator<ApiService>();

  Future<List<PlanModel>> getPlans() async {
    final response = await _apiService.get<List<PlanModel>>(
      '/super-admin/plans',
      fromData: (data) {
        final list = data as List<dynamic>? ?? [];
        return list.map((p) => PlanModel.fromJson(p as Map<String, dynamic>)).toList();
      },
    );

    if (response.isSuccess && response.data != null) {
      return response.data!;
    } else {
      throw ApiException(message: response.message.isNotEmpty ? response.message : 'Failed to fetch plans');
    }
  }

  Future<PlanModel> createPlan({
    required String name,
    String? description,
    required double price,
    required String duration,
    required int maxUsers,
    String status = 'active',
  }) async {
    final response = await _apiService.post<PlanModel>(
      '/super-admin/plans',
      data: {
        'name': name.trim(),
        'description': description?.trim(),
        'price': price,
        'duration': duration.trim(),
        'max_users': maxUsers,
        'status': status,
      },
      fromData: (data) => PlanModel.fromJson(data as Map<String, dynamic>),
    );

    if (response.isSuccess && response.data != null) {
      return response.data!;
    } else {
      throw ApiException(message: response.message.isNotEmpty ? response.message : 'Failed to create plan');
    }
  }

  Future<PlanModel> updatePlan(
    int id, {
    required String name,
    String? description,
    required double price,
    required String duration,
    required int maxUsers,
    required String status,
  }) async {
    final response = await _apiService.put<PlanModel>(
      '/super-admin/plans/$id',
      data: {
        'name': name.trim(),
        'description': description?.trim(),
        'price': price,
        'duration': duration.trim(),
        'max_users': maxUsers,
        'status': status,
      },
      fromData: (data) => PlanModel.fromJson(data as Map<String, dynamic>),
    );

    if (response.isSuccess && response.data != null) {
      return response.data!;
    } else {
      throw ApiException(message: response.message.isNotEmpty ? response.message : 'Failed to update plan');
    }
  }

  Future<PlanModel> toggleStatus(int id) async {
    final response = await _apiService.patch<PlanModel>(
      '/super-admin/plans/$id/toggle-status',
      fromData: (data) => PlanModel.fromJson(data as Map<String, dynamic>),
    );

    if (response.isSuccess && response.data != null) {
      return response.data!;
    } else {
      throw ApiException(message: response.message.isNotEmpty ? response.message : 'Failed to toggle plan status');
    }
  }

  Future<void> deletePlan(int id) async {
    final response = await _apiService.delete('/super-admin/plans/$id');
    if (!response.isSuccess) {
      throw ApiException(message: response.message.isNotEmpty ? response.message : 'Failed to delete plan');
    }
  }
}
