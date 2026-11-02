import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../app/app.locator.dart';
import '../app/app.router.dart';
import '../models/super_admin_user.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AdminAuthService with ListenableServiceMixin {
  final StorageService _storageService;
  final ApiService _apiService;

  SuperAdminUser? _currentUser;
  bool _initialized = false;

  AdminAuthService([StorageService? storageService, ApiService? apiService])
      : _storageService = storageService ?? locator<StorageService>(),
        _apiService = apiService ?? locator<ApiService>() {
    listenToReactiveValues([_currentUser, _initialized]);
    _apiService.onUnauthorized = _handleUnauthorized;
  }

  SuperAdminUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isInitialized => _initialized;

  Future<void> _handleUnauthorized() async {
    await logout();
  }

  Future<bool> initializeSession() async {
    try {
      await _storageService.init();
      await _apiService.init();
      final token = await _storageService.getToken();

      if (token == null || token.isEmpty) {
        _currentUser = null;
        _initialized = true;
        notifyListeners();
        return false;
      }

      final cachedUser = await _storageService.getUser();
      if (cachedUser != null) {
        _currentUser = cachedUser;
      }

      // Check dashboard access to verify super admin token
      final response = await _apiService.get<dynamic>('/super-admin/dashboard');

      if (response.isSuccess) {
        _initialized = true;
        notifyListeners();
        return true;
      } else {
        await _storageService.clearAuthSession();
        _currentUser = null;
        _initialized = true;
        notifyListeners();
        return false;
      }
    } catch (_) {
      _initialized = true;
      notifyListeners();
      return _currentUser != null;
    }
  }

  Future<SuperAdminUser> login({
    required String login,
    required String password,
  }) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      '/super-admin/login',
      data: {
        'login': login.trim(),
        'password': password,
      },
      fromData: (data) => data as Map<String, dynamic>,
    );

    if (response.isSuccess && response.data != null) {
      final token = response.data!['token'] as String;
      final rawUser = response.data!['user'] as Map<String, dynamic>;
      final user = SuperAdminUser.fromJson(rawUser);

      await _storageService.saveToken(token);
      await _storageService.saveUser(user);

      _currentUser = user;
      notifyListeners();
      return user;
    } else {
      throw ApiException(message: response.message.isNotEmpty ? response.message : 'Login failed');
    }
  }

  Future<void> logout() async {
    try {
      await _storageService.clearAuthSession();
    } finally {
      _currentUser = null;
      notifyListeners();

      final navigationService = locator<NavigationService>();
      navigationService.clearStackAndShow(Routes.loginView);
    }
  }
}
