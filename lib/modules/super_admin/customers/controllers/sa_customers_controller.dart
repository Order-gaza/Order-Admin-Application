import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/providers/api_provider.dart';
import '../../../../app/constants/api_endpoints.dart';

class SaCustomersController extends GetxController {
  final isLoading = false.obs;
  final customers = <Map<String, dynamic>>[].obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCustomers();
  }

  Future<void> fetchCustomers() async {
    isLoading.value = true;
    try {
      final res = await ApiProvider.get(ApiEndpoints.saCustomersGetAll);
      if (res.success && res.data != null) {
        final d = res.data as Map<String, dynamic>;
        customers.value =
            List<Map<String, dynamic>>.from(d['customers'] as List? ?? []);
      } else {
        Get.snackbar('Debug Error'.tr, res.message?.tr ?? 'Unknown API error'.tr, 
          backgroundColor: Colors.red, colorText: Colors.white, duration: const Duration(seconds: 5));
      }
    } finally {
      isLoading.value = false;
    }
  }

  List<Map<String, dynamic>> get filtered {
    if (searchQuery.value.isEmpty) return customers;
    final q = searchQuery.value.toLowerCase();
    return customers.where((c) {
      return (c['name'] ?? '').toLowerCase().contains(q) ||
          (c['email'] ?? '').toLowerCase().contains(q) ||
          (c['phone'] ?? '').toLowerCase().contains(q);
    }).toList();
  }

  Future<void> toggleStatus(String customerId) async {
    final res = await ApiProvider.post(
      ApiEndpoints.saCustomersToggle,
      body: {'customer_id': customerId},
    );
    if (res.success) {
      await fetchCustomers();
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

  Future<void> deleteCustomer(String customerId) async {
    final res = await ApiProvider.post(
      ApiEndpoints.saCustomersDelete,
      body: {'customer_id': customerId},
    );
    if (res.success) {
      customers.removeWhere((c) => c['id'] == customerId);
      Get.snackbar('Done'.tr, res.message?.tr ?? 'Customer removed'.tr,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF));
    } else {
      Get.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
    }
  }
}
