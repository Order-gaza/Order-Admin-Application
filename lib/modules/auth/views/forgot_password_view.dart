import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/constants/api_endpoints.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/providers/api_provider.dart';

/// Step 1: Enter email → send OTP code
class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final emailCtrl = TextEditingController();
    final isLoading = false.obs;
    final error = ''.obs;

    Future<void> sendCode() async {
      final email = emailCtrl.text.trim();
      if (email.isEmpty) {
        error.value = 'Please enter your email'.tr;
        return;
      }

      isLoading.value = true;
      error.value = '';

      final res = await ApiProvider.post(
        ApiEndpoints.forgotPassword,
        body: {'email': email},
      );

      isLoading.value = false;

      if (res.success) {
        Get.toNamed(
          AppRoutes.verifyOtp,
          arguments: {'email': email},
        );
      } else {
        error.value = res.message?.tr ?? 'Failed to send code'.tr;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        title: Text('Forgot Password'.tr),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
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
                child: const Icon(Icons.lock_reset,
                    size: 40, color: AppColors.primaryOrange),
              ),
            ),
            const SizedBox(height: 24),

            // ── Title ──
            Center(
              child: Text('Reset your password'.tr,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Enter your email and we\'ll send you a 6-digit code'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.6)),
              ),
            ),
            const SizedBox(height: 32),

            // ── Email field ──
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Email address'.tr,
                prefixIcon: const Icon(Icons.email_outlined),
              ),
            ),
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

            // ── Send button ──
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading.value ? null : sendCode,
                    child: isLoading.value
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5))
                        : Text('Send Reset Code'.tr,
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
