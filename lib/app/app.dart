import 'package:aqua_user/ui/bottom_sheets/notice/notice_sheet.dart';
import 'package:aqua_user/ui/dialogs/info_alert/info_alert_dialog.dart';
import 'package:aqua_user/ui/views/home/home_view.dart';
import 'package:aqua_user/ui/views/login/login_view.dart';
import 'package:aqua_user/ui/views/startup/startup_view.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';

import '../services/admin_auth_service.dart';
import '../services/api_service.dart';
import '../services/company_service.dart';
import '../services/plan_service.dart';
import '../services/storage_service.dart';

@StackedApp(
  routes: [
    MaterialRoute(page: StartupView, initial: true),
    MaterialRoute(page: LoginView),
    MaterialRoute(page: HomeView),
  ],
  dependencies: [
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: StorageService),
    LazySingleton(classType: ApiService),
    LazySingleton(classType: AdminAuthService),
    LazySingleton(classType: CompanyService),
    LazySingleton(classType: PlanService),
  ],
  bottomsheets: [
    StackedBottomsheet(classType: NoticeSheet),
  ],
  dialogs: [
    StackedDialog(classType: InfoAlertDialog),
  ],
)
class App {}
