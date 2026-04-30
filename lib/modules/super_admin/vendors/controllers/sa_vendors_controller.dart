import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/providers/api_provider.dart';
import '../../../../app/constants/api_endpoints.dart';

class SaVendorsController extends GetxController {
  final isLoading = false.obs;
  final vendors = <Map<String, dynamic>>[].obs;
  final selectedFilter = 'all'.obs; // all, pending, approved, suspended
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Accept initial filter from route arguments
    final args = Get.arguments;
    if (args is Map && args['filter'] != null) {
      selectedFilter.value = args['filter'] as String;
    }
    fetchVendors();
  }

  Future<void> fetchVendors() async {
    isLoading.value = true;
    try {
      final res = await ApiProvider.get(ApiEndpoints.saVendorsGetAll);
      if (res.success && res.data != null) {
        final d = res.data as Map<String, dynamic>;
        vendors.value =
            List<Map<String, dynamic>>.from(d['vendors'] as List? ?? []);
      }
    } finally {
      isLoading.value = false;
    }
  }

  List<Map<String, dynamic>> get filtered {
    var list = vendors.toList();
    if (selectedFilter.value != 'all') {
      list = list.where((v) => v['status'] == selectedFilter.value).toList();
    }
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      list = list.where((v) {
        return (v['vendor_name'] ?? '').toLowerCase().contains(q) ||
            (v['owner_name'] ?? '').toLowerCase().contains(q) ||
            (v['type'] ?? '').toLowerCase().contains(q);
      }).toList();
    }
    return list;
  }

  Future<void> approve(String vendorId) async {
    final res = await ApiProvider.post(ApiEndpoints.saVendorsApprove,
        body: {'vendor_id': vendorId});
    if (res.success) {
      _updateLocalStatus(vendorId, 'approved');
      Get.snackbar('Approved'.tr, 'Vendor approved successfully'.tr,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF));
    } else {
      Get.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
    }
  }

  Future<void> suspend(String vendorId) async {
    final res = await ApiProvider.post(ApiEndpoints.saVendorsSuspend,
        body: {'vendor_id': vendorId});
    if (res.success) {
      _updateLocalStatus(vendorId, 'suspended');
      Get.snackbar('Suspended'.tr, 'Vendor suspended'.tr,
          backgroundColor: const Color(0xFFFF9800),
          colorText: const Color(0xFFFFFFFF));
    } else {
      Get.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
    }
  }

  Future<void> reactivate(String vendorId) async {
    final res = await ApiProvider.post(ApiEndpoints.saVendorsReactivate,
        body: {'vendor_id': vendorId});
    if (res.success) {
      _updateLocalStatus(vendorId, 'approved');
      Get.snackbar('Reactivated'.tr, 'Vendor reactivated'.tr,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF));
    } else {
      Get.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
    }
  }

  Future<void> reject(String vendorId) async {
    final res = await ApiProvider.post(ApiEndpoints.saVendorsReject,
        body: {'vendor_id': vendorId});
    if (res.success) {
      _updateLocalStatus(vendorId, 'rejected');
      Get.snackbar('Rejected'.tr, 'Vendor application rejected'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
    } else {
      Get.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
    }
  }

  void _updateLocalStatus(String vendorId, String status) {
    final idx = vendors.indexWhere((v) => v['id'] == vendorId);
    if (idx != -1) {
      vendors[idx] = {...vendors[idx], 'status': status};
      vendors.refresh();
    }
  }
}
