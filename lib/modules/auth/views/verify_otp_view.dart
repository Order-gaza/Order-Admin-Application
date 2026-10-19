import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/constants/api_endpoints.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/providers/api_provider.dart';
import '../../../shared/localization/app_translations.dart';
import '../../../shared/utils/app_navigator.dart';

/// Step 2: Enter 6-digit OTP code → verify
class VerifyOtpView extends StatefulWidget {
  const VerifyOtpView({super.key});

  @override
  State<VerifyOtpView> createState() => _VerifyOtpViewState();
}

class _VerifyOtpViewState extends State<VerifyOtpView> {
  late final TextEditingController _otpCtrl;
  bool _isLoading = false;
  bool _isResending = false;
  String _error = '';
  String _successMsg = '';

  String get _email {
    final args = AppNavigator.arguments as Map<String, dynamic>? ?? {};
    return args['email'] as String? ?? '';
  }

  @override
  void initState() {
    super.initState();
    _otpCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    final otp = _otpCtrl.text.trim();
    if (otp.isEmpty || otp.length != 6) {
      setState(() => _error = 'Please enter the 6-digit code'.tr);
      return;
    }

    setState(() {
      _isLoading = true;
      _error = '';
    });

    final res = await ApiProvider.post(
      ApiEndpoints.verifyOtp,
      body: {
        'email': _email,
        'otp': otp,
        'type': 'reset_password',
      },
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (res.success) {
      AppNavigator.offNamed(
        AppRoutes.resetPassword,
        arguments: {'email': _email, 'otp': otp},
      );
    } else {
      setState(() => _error = res.message?.tr ?? 'Invalid code'.tr);
    }
  }

  Future<void> _resendCode() async {
    setState(() {
      _isResending = true;
      _error = '';
      _successMsg = '';
    });

    final res = await ApiProvider.post(
      ApiEndpoints.resendOtp,
      body: {
        'email': _email,
        'type': 'reset_password',
      },
    );

    if (!mounted) return;

    setState(() => _isResending = false);

    if (res.success) {
      setState(() => _successMsg = 'New code sent to your email'.tr);
    } else {
      setState(() => _error = res.message?.tr ?? 'Failed to resend code'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                'We sent a 6-digit code to\n'.tr + _email,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.6)),
              ),
            ),
            const SizedBox(height: 32),

            // ── OTP field ──
            TextField(
              controller: _otpCtrl,
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
            if (_error.isNotEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Text(_error,
                    style: const TextStyle(
                        color: AppColors.error, fontSize: 13)),
              ),
            if (_successMsg.isNotEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.3)),
                ),
                child: Text(_successMsg,
                    style: const TextStyle(
                        color: AppColors.success, fontSize: 13)),
              ),

            // ── Verify button ──
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyCode,
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : Text('Verify Code'.tr,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),

            const SizedBox(height: 16),

            // ── Resend ──
            Center(
              child: TextButton(
                onPressed: _isResending ? null : _resendCode,
                child: _isResending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryOrange))
                    : Text('Didn\'t receive code? Resend'.tr,
                        style: const TextStyle(
                            color: AppColors.primaryOrange, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
