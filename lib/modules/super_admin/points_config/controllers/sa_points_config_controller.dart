import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/api_provider.dart';
import '../../../../app/constants/api_endpoints.dart';
import '../../../../shared/localization/app_translations.dart';
import '../../../../shared/utils/app_navigator.dart';

final saPointsConfigProvider =
    ChangeNotifierProvider<SaPointsConfigController>((ref) {
  return SaPointsConfigController.to;
});

class SaPointsConfigController extends ChangeNotifier {
  static SaPointsConfigController? _instance;
  static SaPointsConfigController get to =>
      _instance ??= SaPointsConfigController();

  bool isLoading = false;
  bool isSaving = false;

  bool isActive = true;
  final spendAmountCtrl = TextEditingController();
  final pointsPerShekelCtrl = TextEditingController();

  SaPointsConfigController() {
    fetchConfig();
  }

  void setIsActive(bool val) {
    isActive = val;
    notifyListeners();
  }

  @override
  void dispose() {
    spendAmountCtrl.dispose();
    pointsPerShekelCtrl.dispose();
    super.dispose();
  }

  Future<void> fetchConfig() async {
    isLoading = true;
    notifyListeners();
    try {
      final res = await ApiProvider.get(ApiEndpoints.saPointsConfigGet);
      if (res.success && res.data != null) {
        final d = res.data['points_config'] as Map<String, dynamic>? ?? res.data;
        spendAmountCtrl.text = d['spend_amount_for_point']?.toString() ?? '10';
        pointsPerShekelCtrl.text = d['points_per_shekel']?.toString() ?? '10';
        isActive = d['is_active'] == true || d['is_active'] == 1;
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveConfig() async {
    isSaving = true;
    notifyListeners();
    try {
      final res = await ApiProvider.post(ApiEndpoints.saPointsConfigUpdate, body: {
        'spend_amount_for_point': spendAmountCtrl.text,
        'points_per_shekel': pointsPerShekelCtrl.text,
        'is_active': isActive ? '1' : '0',
      });
      if (res.success) {
        AppNavigator.snackbar('Saved'.tr, 'Points configuration updated'.tr,
            backgroundColor: const Color(0xFF4CAF50),
            colorText: const Color(0xFFFFFFFF));
      } else {
        AppNavigator.snackbar('Error'.tr, res.message?.tr ?? 'Failed to save'.tr,
            backgroundColor: const Color(0xFFF44336),
            colorText: const Color(0xFFFFFFFF));
      }
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
