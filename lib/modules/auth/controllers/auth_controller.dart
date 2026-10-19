import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/api_provider.dart';
import '../../../app/constants/api_endpoints.dart';
import '../../../app/constants/app_constants.dart';
import '../../../app/routes/app_routes.dart';
import '../../../shared/localization/app_translations.dart';
import '../../../shared/utils/app_navigator.dart';
import '../../../shared/controllers/language_controller.dart';
import '../../../shared/services/fcm_service.dart';

class AuthController extends ChangeNotifier {
  static AuthController? _instance;
  static AuthController get to => _instance ??= AuthController();

  // ── Observable state ──
  bool isLoading = false;
  bool obscurePassword = true;
  String errorMessage = '';

  // ── Text field values ──
  String email = '';
  String password = '';

  AuthController() {
    _instance = this;
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  /// Perform login
  Future<void> login() async {
    // Validate
    if (email.trim().isEmpty || password.trim().isEmpty) {
      errorMessage = 'Email and password are required'.tr;
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      final response = await ApiProvider.post(
        ApiEndpoints.login,
        body: {
          'email': email.trim(),
          'password': password,
        },
      );

      if (response.success && response.data != null) {
        final user = response.data['user'];
        final token = response.data['token'] as String;
        final role = user['role'] as String;

        // Save auth data
        ApiProvider.saveAuth(
          token: token,
          role: role,
          userId: user['id'],
          userName: user['name'],
          userEmail: user['email'],
          vendorId: response.data['vendor']?['vendor_id'],
          vendorName: response.data['vendor']?['vendor_name'],
        );

        // Reload the user-specific language
        LanguageController.to.reloadLanguage();

        // Register FCM token after successful login
        FcmService.to.refreshToken();

        // Navigate to correct dashboard
        _navigateByRole(role);
      } else {
        errorMessage = response.message?.tr ?? 'Login failed'.tr;
      }
    } catch (e) {
      errorMessage = 'Connection error. Please try again.'.tr;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Logout — clear storage and go to login
  Future<void> logout() async {
    try {
      // Call backend logout (best-effort)
      await ApiProvider.post(ApiEndpoints.logout);
    } catch (_) {}

    ApiProvider.clearAuth();
    LanguageController.to.reloadLanguage();
    AppNavigator.offAllNamed(AppRoutes.login);
  }

  /// Navigate to the correct dashboard based on role
  static void _navigateByRole(String role) {
    switch (role) {
      case AppConstants.roleSuperAdmin:
        AppNavigator.offAllNamed(AppRoutes.saDashboard);
        break;
      case AppConstants.roleAdmin:
        AppNavigator.offAllNamed(AppRoutes.adminDashboard);
        break;
      case AppConstants.roleVendor:
        AppNavigator.offAllNamed(AppRoutes.vendorDashboard);
        break;
      default:
        AppNavigator.offAllNamed(AppRoutes.login);
    }
  }

  /// Try auto-login from stored token/role
  static Future<void> tryAutoLogin() async {
    if (ApiProvider.isLoggedIn) {
      final role = ApiProvider.storedRole;
      if (role != null && role.isNotEmpty) {
        LanguageController.to.reloadLanguage();
        FcmService.to.refreshToken();
        _navigateByRole(role);

        // Background session validation
        ApiProvider.post(ApiEndpoints.validateSession).then((response) {
          if (!response.success &&
              response.rawBody?['status'] == 'unauthenticated') {
            ApiProvider.clearAuth();
            AppNavigator.offAllNamed(AppRoutes.login);
          }
        }).catchError((_) {});
        return;
      }
    }
    AppNavigator.offAllNamed(AppRoutes.login);
  }
}

final authProvider =
    ChangeNotifierProvider<AuthController>((ref) => AuthController.to);
