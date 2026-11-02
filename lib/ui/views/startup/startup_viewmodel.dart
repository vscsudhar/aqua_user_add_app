import 'package:stacked/stacked.dart';
import 'package:aqua_user/app/app.locator.dart';
import 'package:aqua_user/app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../services/admin_auth_service.dart';

class StartupViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _authService = locator<AdminAuthService>();

  Future runStartupLogic() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final hasSession = await _authService.initializeSession();

    if (hasSession && _authService.isAuthenticated) {
      _navigationService.replaceWithHomeView();
    } else {
      _navigationService.replaceWithLoginView();
    }
  }
}
