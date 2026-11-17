import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aqua_user/app/app.locator.dart';
import 'package:aqua_user/models/super_admin_user.dart';
import 'package:aqua_user/services/admin_auth_service.dart';
import 'package:aqua_user/services/storage_service.dart';
import 'package:aqua_user/services/api_service.dart';
import 'package:aqua_user/ui/views/profile/profile_viewmodel.dart';
import 'package:stacked_services/stacked_services.dart';
import '../helpers/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProfileViewModel Tests -', () {
    late AdminAuthService authService;
    late NavigationService navigationService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
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
      authService = locator<AdminAuthService>();
      navigationService = locator<NavigationService>();

      // Seed an initial user into authService
      const testUser = SuperAdminUser(
        id: 1,
        name: 'Super Administrator',
        email: 'admin@aquaflow.com',
        phone: '+91 98765 43210',
        username: 'super_admin',
        role: 'super_admin',
        isActive: true,
        createdAt: '2026-01-01T00:00:00Z',
        companyName: 'SS AquaFlow System Administration',
      );
      await authService.updateCurrentUser(testUser);
    });

    tearDown(() => locator.reset());

    test('Initializes with current user and pre-fills form fields', () {
      final model = ProfileViewModel(
        authService: authService,
        navigationService: navigationService,
      );
      model.init();

      expect(model.currentUser?.name, 'Super Administrator');
      expect(model.nameController.text, 'Super Administrator');
      expect(model.emailController.text, 'admin@aquaflow.com');
      expect(model.phoneController.text, '+91 98765 43210');
      expect(model.usernameController.text, 'super_admin');
      expect(model.isEditing, false);
      expect(model.isSaving, false);
    });

    test('startEditing toggles isEditing to true', () {
      final model = ProfileViewModel(
        authService: authService,
        navigationService: navigationService,
      );
      model.init();

      model.startEditing();
      expect(model.isEditing, true);

      model.cancelEditing();
      expect(model.isEditing, false);
    });

    test('Local update of user reflects in currentUser and controllers immediately', () async {
      final model = ProfileViewModel(
        authService: authService,
        navigationService: navigationService,
      );
      model.init();

      const updatedUser = SuperAdminUser(
        id: 1,
        name: 'John Aqua Admin',
        email: 'john@aquaflow.com',
        phone: '+91 12345 67890',
        username: 'john_admin',
        role: 'super_admin',
        isActive: true,
      );
      await authService.updateCurrentUser(updatedUser);

      expect(model.currentUser?.name, 'John Aqua Admin');
      expect(model.currentUser?.phone, '+91 12345 67890');
    });

    test('Validation: Form cannot save when name is empty', () async {
      final model = ProfileViewModel(
        authService: authService,
        navigationService: navigationService,
      );
      model.init();
      model.startEditing();

      model.nameController.text = '';
      final success = await model.saveProfile();
      expect(success, false);
      expect(model.isEditing, true); // Stays in editing mode
    });

    test('Change Password: password mismatch sets error message', () async {
      final model = ProfileViewModel(
        authService: authService,
        navigationService: navigationService,
      );
      model.init();

      model.currentPasswordController.text = 'oldpass123';
      model.newPasswordController.text = 'newpass123';
      model.confirmPasswordController.text = 'different123';

      final success = await model.changePassword();
      expect(success, false);
      expect(model.errorMessage, contains('do not match'));
    });

    test('Password visibility toggles update state', () {
      final model = ProfileViewModel(
        authService: authService,
        navigationService: navigationService,
      );
      expect(model.obscureCurrentPass, true);
      expect(model.obscureNewPass, true);
      expect(model.obscureConfirmPass, true);

      model.toggleObscureCurrentPass();
      expect(model.obscureCurrentPass, false);

      model.toggleObscureNewPass();
      expect(model.obscureNewPass, false);

      model.toggleObscureConfirmPass();
      expect(model.obscureConfirmPass, false);
    });

    test('Profile image is populated from user model', () async {
      const userWithImage = SuperAdminUser(
        id: 1,
        name: 'Super Admin',
        email: 'admin@aquaflow.com',
        role: 'super_admin',
        isActive: true,
        profileImage: 'https://example.com/avatar.jpg',
      );
      await authService.updateCurrentUser(userWithImage);

      final model = ProfileViewModel(
        authService: authService,
        navigationService: navigationService,
      );
      model.init();

      expect(model.currentUser?.profileImage, 'https://example.com/avatar.jpg');
      expect(model.profileImageController.text, 'https://example.com/avatar.jpg');
    });
  });
}
