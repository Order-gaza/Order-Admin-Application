import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/api_provider.dart';
import '../../../../app/constants/api_endpoints.dart';
import '../../../../app/constants/app_constants.dart';
import '../../../../shared/localization/app_translations.dart';
import '../../../../shared/utils/app_navigator.dart';

final saFeeConfigProvider =
    ChangeNotifierProvider<SaFeeConfigController>((ref) {
  return SaFeeConfigController.to;
});

class SaFeeConfigController extends ChangeNotifier {
  static SaFeeConfigController? _instance;
  static SaFeeConfigController get to =>
      _instance ??= SaFeeConfigController();

  bool isLoading = false;
  bool isSaving = false;

  // Config values
  String activeModel = AppConstants.feeFlat;

  // Text controllers
  final flatFeeCtrl = TextEditingController();
  final percentageCtrl = TextEditingController();
  final minFeeCtrl = TextEditingController();
  final maxFeeCtrl = TextEditingController();

  SaFeeConfigController() {
    fetchConfig();
  }

  void setActiveModel(String model) {
    activeModel = model;
    notifyListeners();
  }

  @override
  void dispose() {
    flatFeeCtrl.dispose();
    percentageCtrl.dispose();
    minFeeCtrl.dispose();
    maxFeeCtrl.dispose();
    super.dispose();
  }

  Future<void> fetchConfig() async {
    isLoading = true;
    notifyListeners();
    try {
      final res = await ApiProvider.get(ApiEndpoints.saFeeConfigGet);
      if (res.success && res.data != null) {
        final outer = res.data as Map<String, dynamic>;
        final d = outer['fee_config'] as Map<String, dynamic>? ?? outer;
        // DB columns: active_model, flat_fee_amount, percentage_value
        activeModel = d['active_model'] ?? AppConstants.feeFlat;
        flatFeeCtrl.text = d['flat_fee_amount']?.toString() ?? '0';
        percentageCtrl.text = d['percentage_value']?.toString() ?? '0';
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
      final res = await ApiProvider.post(ApiEndpoints.saFeeConfigUpdate, body: {
        'active_model': activeModel,
        'flat_fee_amount': flatFeeCtrl.text,
        'percentage_value': percentageCtrl.text,
      });
      if (res.success) {
        AppNavigator.snackbar('Saved'.tr, 'Fee configuration updated'.tr,
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
