import 'package:get/get.dart';
import '../../../data/providers/api_provider.dart';
import '../../../app/constants/api_endpoints.dart';
import '../../../app/constants/app_constants.dart';
import '../../../app/routes/app_routes.dart';
import '../../../shared/controllers/language_controller.dart';
import '../../../shared/services/fcm_service.dart';

class AuthController extends GetxController {
  // ── Observable state ──
  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final errorMessage = ''.obs;

  // ── Text field values ──
  String email = '';
  String password = '';

  /// Toggle password visibility
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  /// Perform login
  Future<void> login() async {
    // Validate
    if (email.trim().isEmpty || password.trim().isEmpty) {
      errorMessage.value = 'Email and password are required'.tr;
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

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
        if (Get.isRegistered<LanguageController>()) {
          Get.find<LanguageController>().reloadLanguage();
        }

        // Register FCM token after successful login
        if (Get.isRegistered<FcmService>()) {
          Get.find<FcmService>().refreshToken();
        }

        // Navigate to correct dashboard
        _navigateByRole(role);
      } else {
        errorMessage.value = response.message?.tr ?? 'Login failed'.tr;
      }
    } catch (e) {
      errorMessage.value = 'Connection error. Please try again.'.tr;
    } finally {
      isLoading.value = false;
    }
  }

  /// Logout — clear storage and go to login
  Future<void> logout() async {
    try {
      // Call backend logout (best-effort)
      await ApiProvider.post(ApiEndpoints.logout);
    } catch (_) {}

    ApiProvider.clearAuth();
    if (Get.isRegistered<LanguageController>()) {
      Get.find<LanguageController>().reloadLanguage();
    }
    Get.offAllNamed(AppRoutes.login);
  }

  /// Navigate to the correct dashboard based on role
  static void _navigateByRole(String role) {
    switch (role) {
      case AppConstants.roleSuperAdmin:
        Get.offAllNamed(AppRoutes.saDashboard);
        break;
      case AppConstants.roleAdmin:
        Get.offAllNamed(AppRoutes.adminDashboard);
        break;
      case AppConstants.roleVendor:
        Get.offAllNamed(AppRoutes.vendorDashboard);
        break;
      default:
        Get.offAllNamed(AppRoutes.login);
    }
  }

  /// Try auto-login from stored token/role
  static Future<void> tryAutoLogin() async {
    if (ApiProvider.isLoggedIn) {
      final role = ApiProvider.storedRole;

      // Validate session with backend
      final response = await ApiProvider.post(ApiEndpoints.validateSession);

      if (response.success) {
        if (role != null) {
          if (Get.isRegistered<LanguageController>()) {
            Get.find<LanguageController>().reloadLanguage();
          }
          // Re-register FCM token on auto-login
          if (Get.isRegistered<FcmService>()) {
            Get.find<FcmService>().refreshToken();
          }
          _navigateByRole(role);
          return;
        }
      } else {
        // Token expired or invalid
        ApiProvider.clearAuth();
      }
    }
    Get.offAllNamed(AppRoutes.login);
  }
}
