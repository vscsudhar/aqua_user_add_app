import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../models/super_admin_user.dart';
import '../../../services/admin_auth_service.dart';
import '../../../services/api_service.dart';

class ProfileViewModel extends ReactiveViewModel {
  final AdminAuthService _authService;
  final NavigationService _navigationService;

  ProfileViewModel({
    AdminAuthService? authService,
    NavigationService? navigationService,
  })  : _authService = authService ?? locator<AdminAuthService>(),
        _navigationService = navigationService ?? locator<NavigationService>();

  @override
  List<ListenableServiceMixin> get listenableServices => [_authService];

  SuperAdminUser? get currentUser => _authService.currentUser;

  bool _isEditing = false;
  bool get isEditing => _isEditing;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  // Form Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController profileImageController = TextEditingController();

  // Password controllers
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> passwordFormKey = GlobalKey<FormState>();

  bool _isChangingPassword = false;
  bool get isChangingPassword => _isChangingPassword;

  bool _obscureCurrentPass = true;
  bool get obscureCurrentPass => _obscureCurrentPass;
  void toggleObscureCurrentPass() {
    _obscureCurrentPass = !_obscureCurrentPass;
    notifyListeners();
  }

  bool _obscureNewPass = true;
  bool get obscureNewPass => _obscureNewPass;
  void toggleObscureNewPass() {
    _obscureNewPass = !_obscureNewPass;
    notifyListeners();
  }

  bool _obscureConfirmPass = true;
  bool get obscureConfirmPass => _obscureConfirmPass;
  void toggleObscureConfirmPass() {
    _obscureConfirmPass = !_obscureConfirmPass;
    notifyListeners();
  }

  void init() {
    _populateControllers();
    _refreshProfileSilently();
  }

  void _populateControllers() {
    final user = currentUser;
    if (user != null) {
      nameController.text = user.name;
      emailController.text = user.email;
      phoneController.text = user.phone ?? '';
      usernameController.text = user.username ?? '';
      profileImageController.text = user.profileImage ?? '';
    }
  }

  Future<void> _refreshProfileSilently() async {
    try {
      await _authService.fetchProfile();
      if (!_isEditing) {
        _populateControllers();
        notifyListeners();
      }
    } catch (_) {
      // Silently fall back to cached session user
    }
  }

  void startEditing() {
    _errorMessage = null;
    _successMessage = null;
    _populateControllers();
    _isEditing = true;
    notifyListeners();
  }

  void cancelEditing() {
    _errorMessage = null;
    _successMessage = null;
    _populateControllers();
    _isEditing = false;
    notifyListeners();
  }

  Future<bool> saveProfile() async {
    _errorMessage = null;
    _successMessage = null;

    if (formKey.currentState != null && !formKey.currentState!.validate()) {
      return false;
    }

    if (nameController.text.trim().isEmpty) {
      _errorMessage = 'Name is required';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    notifyListeners();

    try {
      await _authService.updateProfile(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
        username: usernameController.text.trim().isEmpty ? null : usernameController.text.trim(),
        profileImage: profileImageController.text.trim().isEmpty ? null : profileImageController.text.trim(),
      );

      _isEditing = false;
      _successMessage = 'Profile updated successfully!';
      _populateControllers();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      notifyListeners();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> changePassword() async {
    _errorMessage = null;
    _successMessage = null;

    if (passwordFormKey.currentState != null && !passwordFormKey.currentState!.validate()) {
      return false;
    }

    final currentPass = currentPasswordController.text;
    final newPass = newPasswordController.text;
    final confirmPass = confirmPasswordController.text;

    if (currentPass.isEmpty) {
      _errorMessage = 'Current password is required.';
      notifyListeners();
      return false;
    }

    if (newPass.length < 6) {
      _errorMessage = 'New password must be at least 6 characters.';
      notifyListeners();
      return false;
    }

    if (newPass != confirmPass) {
      _errorMessage = 'New password and confirmation do not match.';
      notifyListeners();
      return false;
    }

    _isChangingPassword = true;
    notifyListeners();

    try {
      final msg = await _authService.changePassword(
        currentPassword: currentPass,
        newPassword: newPass,
        confirmPassword: confirmPass,
      );

      _successMessage = msg;
      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Password update failed: ${e.toString()}';
      notifyListeners();
      return false;
    } finally {
      _isChangingPassword = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfileImage(String imageUrlOrData) async {
    _errorMessage = null;
    _successMessage = null;
    _isSaving = true;
    notifyListeners();

    try {
      await _authService.updateProfileImage(imageUrlOrData);
      _successMessage = 'Profile photo updated successfully!';
      profileImageController.text = imageUrlOrData;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to update photo: ${e.toString()}';
      notifyListeners();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> removeProfileImage() async {
    _errorMessage = null;
    _successMessage = null;
    _isSaving = true;
    notifyListeners();

    try {
      await _authService.deleteProfileImage();
      _successMessage = 'Profile photo removed.';
      profileImageController.clear();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to remove photo: ${e.toString()}';
      notifyListeners();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void goBack() {
    _navigationService.back();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    usernameController.dispose();
    profileImageController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
