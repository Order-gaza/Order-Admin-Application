import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/providers/api_provider.dart';
import '../../../../app/constants/api_endpoints.dart';
import '../../../../app/constants/app_constants.dart';

class SaFeeConfigController extends GetxController {
  final isLoading = false.obs;
  final isSaving = false.obs;

  // Config values
  final activeModel = AppConstants.feeFlat.obs;
  final flatFee = ''.obs;
  final percentage = ''.obs;
  final minFee = ''.obs;
  final maxFee = ''.obs;

  // Text controllers
  final flatFeeCtrl = TextEditingController();
  final percentageCtrl = TextEditingController();
  final minFeeCtrl = TextEditingController();
  final maxFeeCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchConfig();
  }

  @override
  void onClose() {
    flatFeeCtrl.dispose();
    percentageCtrl.dispose();
    minFeeCtrl.dispose();
    maxFeeCtrl.dispose();
    super.onClose();
  }

  Future<void> fetchConfig() async {
    isLoading.value = true;
    try {
      final res = await ApiProvider.get(ApiEndpoints.saFeeConfigGet);
      if (res.success && res.data != null) {
        final outer = res.data as Map<String, dynamic>;
        final d = outer['fee_config'] as Map<String, dynamic>? ?? outer;
        // DB columns: active_model, flat_fee_amount, percentage_value
        activeModel.value =
            d['active_model'] ?? AppConstants.feeFlat;
        flatFeeCtrl.text =
            d['flat_fee_amount']?.toString() ?? '0';
        percentageCtrl.text =
            d['percentage_value']?.toString() ?? '0';
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveConfig() async {
    isSaving.value = true;
    try {
      final res = await ApiProvider.post(ApiEndpoints.saFeeConfigUpdate, body: {
        'active_model': activeModel.value,
        'flat_fee_amount': flatFeeCtrl.text,
        'percentage_value': percentageCtrl.text,
      });
      if (res.success) {
        Get.snackbar('Saved'.tr, 'Fee configuration updated'.tr,
            backgroundColor: const Color(0xFF4CAF50),
            colorText: const Color(0xFFFFFFFF));
      } else {
        Get.snackbar('Error'.tr, res.message?.tr ?? 'Failed to save'.tr,
            backgroundColor: const Color(0xFFF44336),
            colorText: const Color(0xFFFFFFFF));
      }
    } finally {
      isSaving.value = false;
    }
  }
}
