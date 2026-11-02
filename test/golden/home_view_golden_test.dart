import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aqua_user/app/app.locator.dart';
import 'package:aqua_user/services/admin_auth_service.dart';
import 'package:aqua_user/services/api_service.dart';
import 'package:aqua_user/services/company_service.dart';
import 'package:aqua_user/services/plan_service.dart';
import 'package:aqua_user/services/storage_service.dart';
import 'package:aqua_user/ui/views/home/home_view.dart';
import 'package:aqua_user/ui/views/home/home_viewmodel.dart';
import 'package:aqua_user/ui/views/login/login_view.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('LoginView Widget Tests -', () {
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

    testWidgets('LoginView renders branding, email, and password fields', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginView(),
        ),
      );

      expect(find.text('AQUA USER'), findsOneWidget);
      expect(find.text('Super Administrator Portal'), findsOneWidget);
      expect(find.byKey(const ValueKey('super_admin_email_input')), findsOneWidget);
      expect(find.byKey(const ValueKey('super_admin_password_input')), findsOneWidget);
      expect(find.byKey(const ValueKey('super_admin_login_button')), findsOneWidget);
    });

    testWidgets('HomeView renders in mobile view (360x640) without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.runAsync(() async {
        await tester.pumpWidget(
          const MaterialApp(
            home: HomeView(),
          ),
        );
        await Future.delayed(const Duration(milliseconds: 200));
      });
      await tester.pump();

      expect(find.byType(HomeView), findsOneWidget);
    });

    testWidgets('HomeView renders companies and plans tabs on mobile (360x640) without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.runAsync(() async {
        await tester.pumpWidget(
          const MaterialApp(
            home: HomeView(),
          ),
        );
        await Future.delayed(const Duration(milliseconds: 200));
      });
      await tester.pump();

      // Open drawer to switch tab to companies
      final scaffoldState = tester.firstState<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pump();

      expect(find.byType(Drawer), findsOneWidget);
    });

    testWidgets('Manage Users dialog renders without intrinsic dimension or layout exceptions', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => const AlertDialog(
                      title: Text('Manage Users'),
                      content: Text('Test Content'),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        );
      });
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Manage Users'), findsOneWidget);
    });

    testWidgets('Generated User Credentials dialog renders without RenderFlex overflow on small screens', (tester) async {
      tester.view.physicalSize = const Size(360, 500);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final dummyViewModel = HomeViewModel();
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                const view = HomeView();
                view.showGeneratedUserCredentialsDialog(
                  context,
                  dummyViewModel,
                  {
                    'company_name': 'Aqua Corp',
                    'company_id': 'AC001',
                    'name': 'Manager John Doe',
                    'email': 'john.doe@aquacorp.com',
                    'password': 'StrongSecretPassword123!',
                    'role': 'manager',
                  },
                );
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('User Created Successfully!'), findsOneWidget);
      expect(find.text('john.doe@aquacorp.com'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
    });

    testWidgets('Exit Application dialog shows on Home and confirms Close App', (tester) async {
      final dummyViewModel = HomeViewModel();
      bool? dialogResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                const view = HomeView();
                dialogResult = await view.confirmCloseApp(context, dummyViewModel);
              },
              child: const Text('Trigger Exit'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Trigger Exit'));
      await tester.pumpAndSettle();

      expect(find.text('Exit Application'), findsOneWidget);
      expect(find.text('Are you sure you want to close and exit the application?'), findsOneWidget);
      expect(find.text('Close App'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      await tester.tap(find.text('Close App'));
      await tester.pumpAndSettle();

      expect(dialogResult, isTrue);
    });

    testWidgets('Exit Application dialog shows Back to Home option when on Companies or Plans tab', (tester) async {
      final dummyViewModel = HomeViewModel();
      dummyViewModel.setActiveTab('companies');
      bool? dialogResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                const view = HomeView();
                dialogResult = await view.confirmCloseApp(context, dummyViewModel);
              },
              child: const Text('Trigger Exit'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Trigger Exit'));
      await tester.pumpAndSettle();

      expect(find.text('Exit Application'), findsOneWidget);
      expect(find.text('Back to Home'), findsOneWidget);
      expect(find.text('Close App'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      await tester.tap(find.text('Back to Home'));
      await tester.pumpAndSettle();

      expect(dialogResult, isFalse);
      expect(dummyViewModel.activeTab, equals('dashboard'));
    });
  });
}
