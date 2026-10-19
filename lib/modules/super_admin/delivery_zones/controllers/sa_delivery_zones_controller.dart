import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/api_provider.dart';
import '../../../../app/constants/api_endpoints.dart';
import '../../../../shared/localization/app_translations.dart';
import '../../../../shared/utils/app_navigator.dart';

final saDeliveryZonesProvider =
    ChangeNotifierProvider<SaDeliveryZonesController>((ref) {
  return SaDeliveryZonesController.to;
});

class SaDeliveryZonesController extends ChangeNotifier {
  static SaDeliveryZonesController? _instance;
  static SaDeliveryZonesController get to =>
      _instance ??= SaDeliveryZonesController();

  bool isLoading = false;
  List<Map<String, dynamic>> zones = [];

  SaDeliveryZonesController() {
    fetchZones();
  }

  Future<void> fetchZones() async {
    isLoading = true;
    notifyListeners();
    try {
      final res = await ApiProvider.get(ApiEndpoints.saDeliveryZonesGetAll);
      if (res.success && res.data != null) {
        final d = res.data as Map<String, dynamic>;
        zones =
            List<Map<String, dynamic>>.from(d['delivery_zones'] as List? ?? []);
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleZone(String zoneId) async {
    final res = await ApiProvider.post(ApiEndpoints.saDeliveryZonesToggle,
        body: {'zone_id': zoneId});
    if (res.success) {
      final idx = zones.indexWhere((z) => z['id']?.toString() == zoneId);
      if (idx != -1) {
        final cur = (zones[idx]['is_active'] ?? 1) as int;
        zones[idx] = {...zones[idx], 'is_active': cur == 1 ? 0 : 1};
        notifyListeners();
      }
    } else {
      AppNavigator.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
    }
  }

  Future<void> deleteZone(String zoneId) async {
    final res = await ApiProvider.post(ApiEndpoints.saDeliveryZonesDelete,
        body: {'zone_id': zoneId});
    if (res.success) {
      zones.removeWhere((z) => z['id']?.toString() == zoneId);
      notifyListeners();
      AppNavigator.snackbar('Deleted'.tr, 'Zone removed'.tr,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF));
    } else {
      AppNavigator.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
    }
  }
}
