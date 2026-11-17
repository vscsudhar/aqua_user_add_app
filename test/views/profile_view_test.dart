import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aqua_user/app/app.locator.dart';
import 'package:aqua_user/models/super_admin_user.dart';
import 'package:aqua_user/services/admin_auth_service.dart';
import 'package:aqua_user/services/api_service.dart';
import 'package:aqua_user/services/storage_service.dart';
import 'package:aqua_user/ui/views/profile/profile_view.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('ProfileView Widget Tests -', () {
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

      final authService = locator<AdminAuthService>();
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

    testWidgets('ProfileView renders profile header, details, and Edit button', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileView(),
        ),
      );
      await tester.pumpAndSettle();

      // Check header and name
      expect(find.text('Administrator Profile'), findsOneWidget);
      expect(find.text('Super Administrator'), findsWidgets);
      expect(find.text('admin@aquaflow.com'), findsWidgets);
      expect(find.text('+91 98765 43210'), findsOneWidget);
      expect(find.text('super_admin'), findsWidgets);
      expect(find.text('SS AquaFlow System Administration'), findsWidgets);

      // Check Change Password section exists
      expect(find.text('Change Password'), findsOneWidget);
      expect(find.text('Update Password'), findsOneWidget);

      // Check Edit button exists
      expect(find.text('Edit Profile'), findsOneWidget);

      // Tap Edit button to enter edit mode
      await tester.tap(find.text('Edit Profile'));
      await tester.pumpAndSettle();

      // Verify edit form elements
      expect(find.text('Edit Profile Details'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // Scroll to Cancel and tap
      await tester.ensureVisible(find.text('Cancel'));
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Profile Details'), findsNothing);
      expect(find.text('Edit Profile'), findsOneWidget);
    });
  });
}
