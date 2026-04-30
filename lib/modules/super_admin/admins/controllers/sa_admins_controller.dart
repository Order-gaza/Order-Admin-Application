import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/providers/api_provider.dart';
import '../../../../app/constants/api_endpoints.dart';

class SaAdminsController extends GetxController {
  final isLoading = false.obs;
  final admins = <Map<String, dynamic>>[].obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAdmins();
  }

  Future<void> fetchAdmins() async {
    isLoading.value = true;
    try {
      final res = await ApiProvider.get(ApiEndpoints.saAdminsGetAll);
      if (res.success && res.data != null) {
        final d = res.data as Map<String, dynamic>;
        admins.value =
            List<Map<String, dynamic>>.from(d['admins'] as List? ?? []);
      }
    } finally {
      isLoading.value = false;
    }
  }

  List<Map<String, dynamic>> get filtered {
    if (searchQuery.value.isEmpty) return admins;
    final q = searchQuery.value.toLowerCase();
    return admins.where((a) {
      return (a['name'] ?? '').toLowerCase().contains(q) ||
          (a['email'] ?? '').toLowerCase().contains(q);
    }).toList();
  }

  Future<void> toggleStatus(String adminId) async {
    final res = await ApiProvider.post(
      ApiEndpoints.saAdminsToggle,
      body: {'admin_id': adminId},
    );
    if (res.success) {
      // Refetch to get accurate server state
      await fetchAdmins();
      Get.snackbar(
        'Success',
        res.message?.tr ?? 'Status updated',
        backgroundColor: const Color(0xFF4CAF50),
        colorText: const Color(0xFFFFFFFF),
      );
    } else {
      Get.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
    }
  }

  Future<void> addAdmin({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String zoneCoverage,
  }) async {
    final res = await ApiProvider.post(
      ApiEndpoints.saAdminsAdd,
      body: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'zone_coverage': zoneCoverage,
      },
    );
    if (res.success) {
      fetchAdmins();
      Get.snackbar('Success'.tr, 'Admin added successfully'.tr,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF));
    } else {
      Get.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
    }
  }

  Future<void> deleteAdmin(String adminId) async {
    final res = await ApiProvider.post(
      ApiEndpoints.saAdminsDelete,
      body: {'admin_id': adminId},
    );
    if (res.success) {
      admins.removeWhere((a) => a['id'] == adminId);
      Get.snackbar('Deleted'.tr, 'Admin removed'.tr,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF));
    } else {
      Get.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
    }
  }
}
