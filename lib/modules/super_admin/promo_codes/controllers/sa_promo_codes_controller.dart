import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/api_provider.dart';
import '../../../../app/constants/api_endpoints.dart';
import '../../../../shared/localization/app_translations.dart';
import '../../../../shared/utils/app_navigator.dart';

final saPromoCodesProvider =
    ChangeNotifierProvider<SaPromoCodesController>((ref) {
  return SaPromoCodesController.to;
});

class SaPromoCodesController extends ChangeNotifier {
  static SaPromoCodesController? _instance;
  static SaPromoCodesController get to =>
      _instance ??= SaPromoCodesController();

  bool isLoading = false;
  List<dynamic> promoCodes = [];

  SaPromoCodesController() {
    fetchAll();
  }

  Future<void> fetchAll() async {
    isLoading = true;
    notifyListeners();
    try {
      final res = await ApiProvider.get(ApiEndpoints.saPromoCodesGetAll);
      if (res.success && res.data != null) {
        promoCodes = res.data['promo_codes'] ?? [];
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleStatus(String id) async {
    final res = await ApiProvider.post(ApiEndpoints.saPromoCodesToggle, body: {'id': id});
    if (res.success) {
      await fetchAll();
      AppNavigator.snackbar('Done'.tr, res.message ?? 'Status updated'.tr,
          backgroundColor: const Color(0xFF4CAF50), colorText: const Color(0xFFFFFFFF));
    } else {
      AppNavigator.snackbar('Error'.tr, res.message ?? 'Failed'.tr,
          backgroundColor: const Color(0xFFF44336), colorText: const Color(0xFFFFFFFF));
    }
  }

  Future<void> deletePromo(String id) async {
    final res = await ApiProvider.post(ApiEndpoints.saPromoCodesDelete, body: {'id': id});
    if (res.success) {
      await fetchAll();
      AppNavigator.snackbar('Deleted'.tr, 'Promo code deleted'.tr,
          backgroundColor: const Color(0xFF4CAF50), colorText: const Color(0xFFFFFFFF));
    } else {
      AppNavigator.snackbar('Error'.tr, res.message ?? 'Cannot delete'.tr,
          backgroundColor: const Color(0xFFF44336), colorText: const Color(0xFFFFFFFF));
    }
  }

  Future<bool> createPromo(Map<String, String> body) async {
    final res = await ApiProvider.post(ApiEndpoints.saPromoCodesCreate, body: body);
    if (res.success) {
      await fetchAll();
      return true;
    }
    AppNavigator.snackbar('Error'.tr, res.message ?? 'Failed to create'.tr,
        backgroundColor: const Color(0xFFF44336), colorText: const Color(0xFFFFFFFF));
    return false;
  }

  Future<bool> updatePromo(Map<String, String> body) async {
    final res = await ApiProvider.post(ApiEndpoints.saPromoCodesUpdate, body: body);
    if (res.success) {
      await fetchAll();
      return true;
    }
    AppNavigator.snackbar('Error'.tr, res.message ?? 'Failed to update'.tr,
        backgroundColor: const Color(0xFFF44336), colorText: const Color(0xFFFFFFFF));
    return false;
  }
}
