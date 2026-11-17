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

  Future<void> updateCurrentUser(SuperAdminUser updatedUser) async {
    await _storageService.saveUser(updatedUser);
    _currentUser = updatedUser;
    notifyListeners();
  }

  Future<SuperAdminUser> fetchProfile() async {
    final response = await _apiService.get<Map<String, dynamic>>(
      '/profile',
      fromData: (data) => data as Map<String, dynamic>,
    );

    if (response.isSuccess && response.data != null) {
      final user = SuperAdminUser.fromJson(response.data!);
      await updateCurrentUser(user);
      return user;
    } else {
      throw ApiException(
        message: response.message.isNotEmpty ? response.message : 'Failed to fetch profile',
      );
    }
  }

  Future<SuperAdminUser> updateProfile({
    required String name,
    required String email,
    String? phone,
    String? username,
    String? profileImage,
  }) async {
    final payload = <String, dynamic>{
      'name': name.trim(),
      'email': email.trim(),
      'phone': phone?.trim(),
      'username': username?.trim(),
    };
    if (profileImage != null) {
      payload['profile_image'] = profileImage;
    }

    final response = await _apiService.put<Map<String, dynamic>>(
      '/profile',
      data: payload,
      fromData: (data) => data as Map<String, dynamic>,
    );

    if (response.isSuccess && response.data != null) {
      final updatedUser = SuperAdminUser.fromJson(response.data!);
      await updateCurrentUser(updatedUser);
      return updatedUser;
    } else {
      throw ApiException(
        message: response.message.isNotEmpty ? response.message : 'Failed to update profile',
        errors: response.errors,
      );
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String emailOrUsername) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      '/super-admin/forgot-password',
      data: {
        'email': emailOrUsername.trim(),
      },
      fromData: (data) => data as Map<String, dynamic>,
    );

    if (response.isSuccess && response.data != null) {
      return response.data!;
    } else {
      throw ApiException(
        message: response.message.isNotEmpty ? response.message : 'Failed to send password reset request',
        errors: response.errors,
      );
    }
  }

  Future<String> resetPassword({
    required String email,
    required String code,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      '/super-admin/reset-password',
      data: {
        'email': email.trim(),
        'code': code.trim(),
        'password': newPassword,
        'password_confirmation': confirmPassword,
      },
      fromData: (data) => data as Map<String, dynamic>,
    );

    if (response.isSuccess) {
      return response.message.isNotEmpty ? response.message : 'Password reset successfully.';
    } else {
      throw ApiException(
        message: response.message.isNotEmpty ? response.message : 'Failed to reset password',
        errors: response.errors,
      );
    }
  }

  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      '/profile/change-password',
      data: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': confirmPassword,
      },
    );

    if (response.isSuccess) {
      return response.message.isNotEmpty ? response.message : 'Password changed successfully.';
    } else {
      throw ApiException(
        message: response.message.isNotEmpty ? response.message : 'Failed to change password',
        errors: response.errors,
      );
    }
  }

  Future<SuperAdminUser> updateProfileImage(String imageUrlOrBase64) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      '/profile/image',
      data: {
        'image_data': imageUrlOrBase64.trim(),
      },
      fromData: (data) => data as Map<String, dynamic>,
    );

    if (response.isSuccess && response.data != null) {
      final updatedUser = SuperAdminUser.fromJson(response.data!);
      await updateCurrentUser(updatedUser);
      return updatedUser;
    } else {
      throw ApiException(
        message: response.message.isNotEmpty ? response.message : 'Failed to update profile image',
        errors: response.errors,
      );
    }
  }

  Future<SuperAdminUser> deleteProfileImage() async {
    final response = await _apiService.delete<Map<String, dynamic>>(
      '/profile/image',
      fromData: (data) => data as Map<String, dynamic>,
    );

    if (response.isSuccess && response.data != null) {
      final updatedUser = SuperAdminUser.fromJson(response.data!);
      await updateCurrentUser(updatedUser);
      return updatedUser;
    } else {
      throw ApiException(
        message: response.message.isNotEmpty ? response.message : 'Failed to remove profile image',
        errors: response.errors,
      );
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
