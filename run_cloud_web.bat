@echo off
echo =========================================================================
echo   MARINA AQUA SUPER ADMIN PORTAL (CHROME WEB)
echo   Base URL: https://aqua-api.ethiodeploy.app/api/v1
echo =========================================================================
flutter run -d chrome --dart-define=API_BASE_URL=https://aqua-api.ethiodeploy.app/api/v1 %*
