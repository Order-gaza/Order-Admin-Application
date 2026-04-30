import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/constants/api_endpoints.dart';
import '../../../../data/providers/api_provider.dart';

class VendorCategoriesController extends GetxController {
  final isLoading = false.obs;
  final categories = <Map<String, dynamic>>[].obs;
  final globalCategories = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchGlobalCategories();
  }

  Future<void> fetchCategories() async {
    isLoading.value = true;
    try {
      final res = await ApiProvider.get(ApiEndpoints.vendorCategoriesGetAll);
      if (res.success && res.data != null) {
        final d = res.data as Map<String, dynamic>;
        categories.value =
            List<Map<String, dynamic>>.from(d['categories'] as List? ?? []);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchGlobalCategories() async {
    final res = await ApiProvider.get(ApiEndpoints.vendorCategoriesGetGlobal);
    if (res.success && res.data != null) {
      final d = res.data as Map<String, dynamic>;
      globalCategories.value =
          List<Map<String, dynamic>>.from(d['categories'] as List? ?? []);
    }
  }

  /// Get unsubscribed global categories (ones vendor hasn't added yet)
  List<Map<String, dynamic>> get availableGlobalCategories {
    return globalCategories
        .where((gc) => (gc['is_subscribed'] ?? 0) == 0)
        .toList();
  }

  Future<void> subscribeToCategory(String globalCategoryId) async {
    final res = await ApiProvider.post(ApiEndpoints.vendorCategoriesAdd,
        body: {'global_category_id': globalCategoryId});
    if (res.success) {
      await fetchCategories();
      await fetchGlobalCategories();
      Get.snackbar('Added'.tr, 'Category added'.tr,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white);
    } else {
      Get.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: Colors.white);
    }
  }

  Future<void> toggleCategory(String id) async {
    final res = await ApiProvider.post(ApiEndpoints.vendorCategoriesToggle,
        body: {'category_id': id});
    if (res.success) {
      await fetchCategories();
    } else {
      Get.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: Colors.white);
    }
  }

  Future<void> deleteCategory(String id) async {
    final res = await ApiProvider.post(ApiEndpoints.vendorCategoriesDelete,
        body: {'category_id': id});
    if (res.success) {
      categories.removeWhere((c) => c['id']?.toString() == id);
      await fetchGlobalCategories();
      Get.snackbar('Deleted'.tr, 'Category removed'.tr,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white);
    } else {
      Get.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: Colors.white);
    }
  }
}
