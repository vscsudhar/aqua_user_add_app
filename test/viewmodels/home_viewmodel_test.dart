import 'package:flutter_test/flutter_test.dart';
import 'package:aqua_user/app/app.locator.dart';
import 'package:aqua_user/models/credentials_model.dart';
import 'package:aqua_user/services/admin_auth_service.dart';
import 'package:aqua_user/services/company_service.dart';
import 'package:aqua_user/services/plan_service.dart';
import 'package:aqua_user/services/storage_service.dart';
import 'package:aqua_user/services/api_service.dart';
import 'package:aqua_user/ui/views/home/home_viewmodel.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('HomeViewModel Tests -', () {
    setUp(() {
      registerServices();
      if (!locator.isRegistered<StorageService>()) {
        locator.registerSingleton<StorageService>(StorageService());
      }
      if (!locator.isRegistered<ApiService>()) {
        locator.registerSingleton<ApiService>(ApiService());
      }
      if (!locator.isRegistered<AdminAuthService>()) {
        locator.registerSingleton<AdminAuthService>(AdminAuthService());
      }
      if (!locator.isRegistered<CompanyService>()) {
        locator.registerSingleton<CompanyService>(CompanyService());
      }
      if (!locator.isRegistered<PlanService>()) {
        locator.registerSingleton<PlanService>(PlanService());
      }
    });

    tearDown(() => locator.reset());

    test('Initial active tab should be dashboard', () {
      final model = HomeViewModel();
      expect(model.activeTab, 'dashboard');
    });

    test('Switching tabs updates activeTab state', () {
      final model = HomeViewModel();
      model.setActiveTab('companies');
      expect(model.activeTab, 'companies');

      model.setActiveTab('plans');
      expect(model.activeTab, 'plans');
    });

    test('Credentials model formatting produces expected structure', () {
      const creds = CredentialsModel(
        companyName: 'Test Company',
        companyId: 'CMP-0099',
        adminUserId: 10,
        adminEmail: 'admin@test.com',
        temporaryPassword: 'TempPassword123',
        assignedPlan: 'Growth Plan',
        maxUsers: 15,
        accountStatus: 'active',
      );

      final formatted = creds.toFormattedString();
      expect(formatted.contains('CMP-0099'), true);
      expect(formatted.contains('admin@test.com'), true);
      expect(formatted.contains('TempPassword123'), true);
      expect(formatted.contains('Growth Plan'), true);
    });

    test('Status and Plan filtering updates state', () {
      final model = HomeViewModel();
      model.setStatusFilter('active');
      expect(model.selectedStatus, 'active');

      model.setPlanFilter(2);
      expect(model.selectedPlanId, 2);
    });

    test('Company users state initializes empty and can load', () {
      final model = HomeViewModel();
      expect(model.selectedCompanyUsers.isEmpty, true);
      expect(model.loadingCompanyUsers, false);
    });
  });
}
