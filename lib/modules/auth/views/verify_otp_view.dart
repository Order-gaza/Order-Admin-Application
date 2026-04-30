import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/constants/api_endpoints.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/providers/api_provider.dart';

/// Step 2: Enter 6-digit OTP code → verify
class VerifyOtpView extends StatelessWidget {
  const VerifyOtpView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final email = args['email'] as String? ?? '';

    final otpCtrl = TextEditingController();
    final isLoading = false.obs;
    final isResending = false.obs;
    final error = ''.obs;
    final successMsg = ''.obs;

    Future<void> verifyCode() async {
      final otp = otpCtrl.text.trim();
      if (otp.isEmpty || otp.length != 6) {
        error.value = 'Please enter the 6-digit code'.tr;
        return;
      }

      isLoading.value = true;
      error.value = '';

      final res = await ApiProvider.post(
        ApiEndpoints.verifyOtp,
        body: {
          'email': email,
          'otp': otp,
          'type': 'reset_password',
        },
      );

      isLoading.value = false;

      if (res.success) {
        Get.offNamed(
          AppRoutes.resetPassword,
          arguments: {'email': email, 'otp': otp},
        );
      } else {
        error.value = res.message?.tr ?? 'Invalid code'.tr;
      }
    }

    Future<void> resendCode() async {
      isResending.value = true;
      error.value = '';
      successMsg.value = '';

      final res = await ApiProvider.post(
        ApiEndpoints.resendOtp,
        body: {
          'email': email,
          'type': 'reset_password',
        },
      );

      isResending.value = false;

      if (res.success) {
        successMsg.value = 'New code sent to your email'.tr;
      } else {
        error.value = res.message?.tr ?? 'Failed to resend code'.tr;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        title: Text('Verify Code'.tr),
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
                child: const Icon(Icons.verified_user_outlined,
                    size: 40, color: AppColors.primaryOrange),
              ),
            ),
            const SizedBox(height: 24),

            Center(
              child: Text('Enter verification code'.tr,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'We sent a 6-digit code to\n'.tr + email,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.6)),
              ),
            ),
            const SizedBox(height: 32),

            // ── OTP field ──
            TextField(
              controller: otpCtrl,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 12),
              decoration: const InputDecoration(
                hintText: '------',
                counterText: '',
                prefixIcon: Icon(Icons.pin),
              ),
            ),
            const SizedBox(height: 16),

            // ── Error / Success ──
            Obx(() {
              if (error.value.isNotEmpty) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Text(error.value,
                      style: const TextStyle(
                          color: AppColors.error, fontSize: 13)),
                );
              }
              if (successMsg.value.isNotEmpty) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.3)),
                  ),
                  child: Text(successMsg.value,
                      style: const TextStyle(
                          color: AppColors.success, fontSize: 13)),
                );
              }
              return const SizedBox.shrink();
            }),

            // ── Verify button ──
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading.value ? null : verifyCode,
                    child: isLoading.value
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5))
                        : Text('Verify Code'.tr,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                )),

            const SizedBox(height: 16),

            // ── Resend ──
            Center(
              child: Obx(() => TextButton(
                    onPressed: isResending.value ? null : resendCode,
                    child: isResending.value
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primaryOrange))
                        : Text('Didn\'t receive code? Resend'.tr,
                            style: TextStyle(
                                color: AppColors.primaryOrange, fontSize: 14)),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
