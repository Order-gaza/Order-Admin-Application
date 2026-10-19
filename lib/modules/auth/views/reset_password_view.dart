import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/constants/api_endpoints.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/providers/api_provider.dart';
import '../../../shared/localization/app_translations.dart';
import '../../../shared/utils/app_navigator.dart';

/// Step 3: Enter new password + confirm → reset
class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  late final TextEditingController _passCtrl;
  late final TextEditingController _confirmCtrl;
  bool _isLoading = false;
  String _error = '';
  bool _obscure1 = true;
  bool _obscure2 = true;

  String get _email {
    final args = AppNavigator.arguments as Map<String, dynamic>? ?? {};
    return args['email'] as String? ?? '';
  }

  String get _otp {
    final args = AppNavigator.arguments as Map<String, dynamic>? ?? {};
    return args['otp'] as String? ?? '';
  }

  @override
  void initState() {
    super.initState();
    _passCtrl = TextEditingController();
    _confirmCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final pass = _passCtrl.text;
    final confirm = _confirmCtrl.text;

    if (pass.isEmpty || confirm.isEmpty) {
      setState(() => _error = 'Both fields are required'.tr);
      return;
    }
    if (pass.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters'.tr);
      return;
    }
    if (pass != confirm) {
      setState(() => _error = 'Passwords do not match'.tr);
      return;
    }

    setState(() {
      _isLoading = true;
      _error = '';
    });

    final res = await ApiProvider.post(
      ApiEndpoints.resetPassword,
      body: {
        'email': _email,
        'reset_token': _otp,
        'new_password': pass,
        'confirm_password': confirm,
      },
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (res.success) {
      AppNavigator.snackbar(
        'Success'.tr,
        'Password reset successfully'.tr,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: const Color(0xFFFFFFFF),
      );
      AppNavigator.offAllNamed(AppRoutes.login);
    } else {
      setState(() => _error = res.message?.tr ?? 'Reset failed'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            TextField(
              controller: _passCtrl,
              obscureText: _obscure1,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'New Password'.tr,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure1
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () => setState(() => _obscure1 = !_obscure1),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Confirm password ──
            TextField(
              controller: _confirmCtrl,
              obscureText: _obscure2,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Confirm New Password'.tr,
                prefixIcon: const Icon(Icons.lock_reset),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure2
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () => setState(() => _obscure2 = !_obscure2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Error ──
            if (_error.isNotEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Text(_error,
                    style:
                        const TextStyle(color: AppColors.error, fontSize: 13)),
              ),

            // ── Reset button ──
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _resetPassword,
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : Text('Reset Password'.tr,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
