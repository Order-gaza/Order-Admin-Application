import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/constants/api_endpoints.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/providers/api_provider.dart';

/// Step 3: Enter new password + confirm → reset
class ResetPasswordView extends StatelessWidget {
  const ResetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final email = args['email'] as String? ?? '';
    final otp = args['otp'] as String? ?? '';

    final passCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final isLoading = false.obs;
    final error = ''.obs;
    final obscure1 = true.obs;
    final obscure2 = true.obs;

    Future<void> resetPassword() async {
      final pass = passCtrl.text;
      final confirm = confirmCtrl.text;

      if (pass.isEmpty || confirm.isEmpty) {
        error.value = 'Both fields are required'.tr;
        return;
      }
      if (pass.length < 6) {
        error.value = 'Password must be at least 6 characters'.tr;
        return;
      }
      if (pass != confirm) {
        error.value = 'Passwords do not match'.tr;
        return;
      }

      isLoading.value = true;
      error.value = '';

      final res = await ApiProvider.post(
        ApiEndpoints.resetPassword,
        body: {
          'email': email,
          'reset_token': otp,
          'new_password': pass,
          'confirm_password': confirm,
        },
      );

      isLoading.value = false;

      if (res.success) {
        Get.snackbar('Success'.tr, 'Password reset successfully'.tr,
            backgroundColor: const Color(0xFF4CAF50),
            colorText: const Color(0xFFFFFFFF));
        Get.offAllNamed(AppRoutes.login);
      } else {
        error.value = res.message?.tr ?? 'Reset failed'.tr;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        title: Text('New Password'.tr),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Icon ──
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_open_outlined,
                    size: 40, color: AppColors.primaryOrange),
              ),
            ),
            const SizedBox(height: 24),

            Center(
              child: Text('Create new password'.tr,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Your new password must be at least 6 characters'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.6)),
              ),
            ),
            const SizedBox(height: 32),

            // ── New password ──
            Obx(() => TextField(
                  controller: passCtrl,
                  obscureText: obscure1.value,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'New Password'.tr,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscure1.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => obscure1.value = !obscure1.value,
                    ),
                  ),
                )),
            const SizedBox(height: 16),

            // ── Confirm password ──
            Obx(() => TextField(
                  controller: confirmCtrl,
                  obscureText: obscure2.value,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Confirm New Password'.tr,
                    prefixIcon: const Icon(Icons.lock_reset),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscure2.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => obscure2.value = !obscure2.value,
                    ),
                  ),
                )),
            const SizedBox(height: 16),

            // ── Error ──
            Obx(() {
              if (error.value.isEmpty) return const SizedBox.shrink();
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Text(error.value,
                    style:
                        const TextStyle(color: AppColors.error, fontSize: 13)),
              );
            }),

            // ── Reset button ──
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading.value ? null : resetPassword,
                    child: isLoading.value
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5))
                        : Text('Reset Password'.tr,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
