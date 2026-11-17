import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../services/admin_auth_service.dart';
import '../../../services/api_service.dart';

class LoginViewModel extends BaseViewModel {
  final _authService = locator<AdminAuthService>();
  final _navigationService = locator<NavigationService>();
  final _apiService = locator<ApiService>();

  String _login = '';
  String _password = '';
  bool _isPasswordVisible = false;
  String? _errorMessage;

  String get login => _login;
  String get password => _password;
  bool get isPasswordVisible => _isPasswordVisible;
  String? get errorMessage => _errorMessage;
  String get currentBaseUrl => _apiService.baseUrl;

  Future<void> updateBaseUrl(String newUrl) async {
    await _apiService.updateAndSaveBaseUrl(newUrl);
    notifyListeners();
  }

  void setLogin(String val) {
    _login = val;
    _errorMessage = null;
    notifyListeners();
  }

  void setPassword(String val) {
    _password = val;
    _errorMessage = null;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  Future<void> submitLogin() async {
    if (_login.trim().isEmpty || _password.isEmpty) {
      _errorMessage = 'Please enter both login and password.';
      notifyListeners();
      return;
    }

    setBusy(true);
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.login(
        login: _login.trim(),
        password: _password,
      );
      _navigationService.clearStackAndShow(Routes.homeView);
    } catch (e) {
      if (e is ApiException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = 'Authentication failed. Please check your credentials.';
      }
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> sendForgotPasswordCode(String emailOrUsername) async {
    return await _authService.forgotPassword(emailOrUsername);
  }

  Future<String> submitPasswordReset({
    required String email,
    required String code,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final msg = await _authService.resetPassword(
      email: email,
      code: code,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
    _login = email;
    _password = newPassword;
    _errorMessage = null;
    notifyListeners();
    return msg;
  }

  void fillDemoCredentials() {
    _login = 'superadmin@aquasystem.com';
    _password = 'Admin@1234';
    _errorMessage = null;
    notifyListeners();
  }
}
