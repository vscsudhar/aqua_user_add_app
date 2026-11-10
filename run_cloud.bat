@echo off
echo =========================================================================
echo   MARINA AQUA SUPER ADMIN PORTAL
echo   Base URL: https://aqua-api.ethiodeploy.app/api/v1
echo =========================================================================
flutter run --dart-define=API_BASE_URL=https://aqua-api.ethiodeploy.app/api/v1 %*
