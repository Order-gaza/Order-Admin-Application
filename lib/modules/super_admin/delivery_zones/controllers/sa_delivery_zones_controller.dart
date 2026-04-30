import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/providers/api_provider.dart';
import '../../../../app/constants/api_endpoints.dart';

class SaDeliveryZonesController extends GetxController {
  final isLoading = false.obs;
  final zones = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchZones();
  }

  Future<void> fetchZones() async {
    isLoading.value = true;
    try {
      final res = await ApiProvider.get(ApiEndpoints.saDeliveryZonesGetAll);
      if (res.success && res.data != null) {
        final d = res.data as Map<String, dynamic>;
        zones.value =
            List<Map<String, dynamic>>.from(d['delivery_zones'] as List? ?? []);
      }
    } finally {
      isLoading.value = false;
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
        zones.refresh();
      }
    } else {
      Get.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
    }
  }

  Future<void> deleteZone(String zoneId) async {
    final res = await ApiProvider.post(ApiEndpoints.saDeliveryZonesDelete,
        body: {'zone_id': zoneId});
    if (res.success) {
      zones.removeWhere((z) => z['id']?.toString() == zoneId);
      Get.snackbar('Deleted'.tr, 'Zone removed'.tr,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF));
    } else {
      Get.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
    }
  }
}
