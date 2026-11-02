import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';

import '../../../models/company_model.dart';
import '../../../models/company_user_model.dart';
import '../../../models/credentials_model.dart';
import '../../../models/dashboard_metrics.dart';
import '../../../models/plan_model.dart';
import '../../../models/super_admin_user.dart';
import '../../../services/admin_auth_service.dart';
import '../../../services/company_service.dart';
import '../../../services/plan_service.dart';

class HomeViewModel extends BaseViewModel {
  final _authService = locator<AdminAuthService>();
  final _companyService = locator<CompanyService>();
  final _planService = locator<PlanService>();
  final _navigationService = locator<NavigationService>();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  String _activeTab = 'dashboard'; // 'dashboard', 'companies', 'plans'
  DashboardMetrics? _metrics;
  List<CompanyModel> _companies = [];
  List<PlanModel> _plans = [];

  String _searchQuery = '';
  String _selectedStatus = 'all';
  int? _selectedPlanId;
  String? _errorMessage;

  String get activeTab => _activeTab;
  DashboardMetrics? get metrics => _metrics;
  List<CompanyModel> get companies => _companies;
  List<PlanModel> get plans => _plans;
  String get searchQuery => _searchQuery;
  String get selectedStatus => _selectedStatus;
  int? get selectedPlanId => _selectedPlanId;
  String? get errorMessage => _errorMessage;
  SuperAdminUser? get currentUser => _authService.currentUser;

  Future<void> init() async {
    await refreshAll();
  }

  void setActiveTab(String tab) {
    _activeTab = tab;
    _errorMessage = null;
    notifyListeners();
    if (tab == 'companies') {
      fetchCompanies();
    } else if (tab == 'plans') {
      fetchPlans();
    } else {
      fetchDashboard();
    }
  }

  Future<void> refreshAll() async {
    setBusy(true);
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.wait([
        fetchDashboard(silent: true),
        fetchCompanies(silent: true),
        fetchPlans(silent: true),
      ]);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  Future<void> fetchDashboard({bool silent = false}) async {
    if (!silent) setBusy(true);
    try {
      _metrics = await _companyService.getDashboard();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (!silent) setBusy(false);
      notifyListeners();
    }
  }

  Future<void> fetchCompanies({bool silent = false}) async {
    if (!silent) setBusy(true);
    try {
      _companies = await _companyService.getCompanies(
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        status: _selectedStatus,
        planId: _selectedPlanId,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (!silent) setBusy(false);
      notifyListeners();
    }
  }

  Future<void> fetchPlans({bool silent = false}) async {
    if (!silent) setBusy(true);
    try {
      _plans = await _planService.getPlans();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (!silent) setBusy(false);
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchCompanies();
  }

  void setStatusFilter(String status) {
    _selectedStatus = status;
    fetchCompanies();
  }

  void setPlanFilter(int? planId) {
    _selectedPlanId = planId;
    fetchCompanies();
  }

  Future<CredentialsModel?> createCompany({
    required String name,
    required String adminEmail,
    required String adminPassword,
    required int planId,
    String status = 'active',
    String? adminName,
    String? phone,
    String? address,
  }) async {
    setBusy(true);
    _errorMessage = null;
    notifyListeners();

    try {
      final creds = await _companyService.createCompany(
        name: name,
        adminEmail: adminEmail,
        adminPassword: adminPassword,
        planId: planId,
        status: status,
        adminName: adminName,
        phone: phone,
        address: address,
      );
      await refreshAll();
      return creds;
    } catch (e) {
      _errorMessage = e.toString();
      setBusy(false);
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateCompany(
    int id, {
    required String name,
    required int planId,
    required String status,
    String? phone,
    String? address,
  }) async {
    setBusy(true);
    _errorMessage = null;
    notifyListeners();

    try {
      await _companyService.updateCompany(
        id,
        name: name,
        planId: planId,
        status: status,
        phone: phone,
        address: address,
      );
      await refreshAll();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      setBusy(false);
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleCompanyStatus(CompanyModel company) async {
    try {
      await _companyService.toggleStatus(company.id);
      await refreshAll();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> deleteCompany(CompanyModel company) async {
    setBusy(true);
    _errorMessage = null;
    notifyListeners();

    try {
      await _companyService.deleteCompany(company.id);
      await refreshAll();
      setBusy(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      setBusy(false);
      notifyListeners();
      return false;
    }
  }

  Future<bool> createPlan({
    required String name,
    String? description,
    required double price,
    required String duration,
    required int maxUsers,
    String status = 'active',
  }) async {
    setBusy(true);
    _errorMessage = null;
    notifyListeners();

    try {
      await _planService.createPlan(
        name: name,
        description: description,
        price: price,
        duration: duration,
        maxUsers: maxUsers,
        status: status,
      );
      await refreshAll();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      setBusy(false);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePlan(
    int id, {
    required String name,
    String? description,
    required double price,
    required String duration,
    required int maxUsers,
    required String status,
  }) async {
    setBusy(true);
    _errorMessage = null;
    notifyListeners();

    try {
      await _planService.updatePlan(
        id,
        name: name,
        description: description,
        price: price,
        duration: duration,
        maxUsers: maxUsers,
        status: status,
      );
      await refreshAll();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      setBusy(false);
      notifyListeners();
      return false;
    }
  }

  Future<void> togglePlanStatus(PlanModel plan) async {
    try {
      await _planService.toggleStatus(plan.id);
      await refreshAll();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> deletePlan(PlanModel plan) async {
    try {
      await _planService.deletePlan(plan.id);
      await refreshAll();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void copyCredentials(CredentialsModel creds) {
    Clipboard.setData(ClipboardData(text: creds.toFormattedString()));
  }

  void copyText(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  List<CompanyUserModel> _selectedCompanyUsers = [];
  Map<String, dynamic> _selectedCompanyPlanUsage = {};
  bool _loadingCompanyUsers = false;

  List<CompanyUserModel> get selectedCompanyUsers => _selectedCompanyUsers;
  Map<String, dynamic> get selectedCompanyPlanUsage => _selectedCompanyPlanUsage;
  bool get loadingCompanyUsers => _loadingCompanyUsers;

  Future<void> loadCompanyUsers(int companyId) async {
    _loadingCompanyUsers = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _companyService.getCompanyUsers(companyId);
      _selectedCompanyUsers = res['users'] as List<CompanyUserModel>;
      _selectedCompanyPlanUsage = res['company'] as Map<String, dynamic>;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _loadingCompanyUsers = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> createCompanyUser({
    required int companyId,
    required String name,
    required String email,
    required String password,
    String role = 'sales_rep',
    String? phone,
  }) async {
    setBusy(true);
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _companyService.createCompanyUser(
        companyId: companyId,
        name: name,
        email: email,
        password: password,
        role: role,
        phone: phone,
      );
      await loadCompanyUsers(companyId);
      await fetchCompanies(silent: true);
      setBusy(false);
      return result;
    } catch (e) {
      _errorMessage = e.toString();
      setBusy(false);
      notifyListeners();
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateCompanyUser({
    required int companyId,
    required int userId,
    String? name,
    required String email,
    String? password,
    String? role,
    String? phone,
  }) async {
    setBusy(true);
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _companyService.updateCompanyUser(
        companyId: companyId,
        userId: userId,
        name: name,
        email: email,
        password: password,
        role: role,
        phone: phone,
      );
      await loadCompanyUsers(companyId);
      await fetchCompanies(silent: true);
      setBusy(false);
      return result;
    } catch (e) {
      _errorMessage = e.toString();
      setBusy(false);
      notifyListeners();
      return null;
    }
  }

  Future<void> toggleCompanyUserStatus(int companyId, int userId) async {
    try {
      await _companyService.toggleCompanyUserStatus(companyId, userId);
      await loadCompanyUsers(companyId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> deleteCompanyUser(int companyId, int userId) async {
    try {
      await _companyService.deleteCompanyUser(companyId, userId);
      await loadCompanyUsers(companyId);
      await fetchCompanies(silent: true);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _navigationService.clearStackAndShow(Routes.loginView);
  }
}
