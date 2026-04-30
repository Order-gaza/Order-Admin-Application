import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/constants/api_endpoints.dart';
import '../../../../data/providers/api_provider.dart';

class SaCategoriesController extends GetxController {
  final isLoading = false.obs;
  final categories = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    isLoading.value = true;
    try {
      final res = await ApiProvider.get(ApiEndpoints.saCategoriesGetAll);
      if (res.success && res.data != null) {
        final d = res.data as Map<String, dynamic>;
        categories.value =
            List<Map<String, dynamic>>.from(d['categories'] as List? ?? []);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addCategory({
    required String name,
    String? nameAr,
    required String iconName,
    int sortOrder = 0,
  }) async {
    final body = <String, String>{
      'name': name,
      'icon_name': iconName,
      'sort_order': sortOrder.toString(),
    };
    if (nameAr != null && nameAr.isNotEmpty) body['name_ar'] = nameAr;

    final res = await ApiProvider.post(ApiEndpoints.saCategoriesAdd, body: body);
    if (res.success) {
      await fetchCategories();
      Get.snackbar('Added'.tr, 'Category created'.tr,
          backgroundColor: const Color(0xFF4CAF50), colorText: Colors.white);
    } else {
      Get.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
          backgroundColor: const Color(0xFFF44336), colorText: Colors.white);
    }
  }

  Future<void> updateCategory({
    required String id,
    required String name,
    String? nameAr,
    required String iconName,
    int sortOrder = 0,
  }) async {
    final body = <String, String>{
      'category_id': id,
      'name': name,
      'icon_name': iconName,
      'sort_order': sortOrder.toString(),
    };
    if (nameAr != null) body['name_ar'] = nameAr;

    final res =
        await ApiProvider.post(ApiEndpoints.saCategoriesUpdate, body: body);
    if (res.success) {
      await fetchCategories();
      Get.snackbar('Updated'.tr, 'Category updated'.tr,
          backgroundColor: const Color(0xFF4CAF50), colorText: Colors.white);
    } else {
      Get.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
          backgroundColor: const Color(0xFFF44336), colorText: Colors.white);
    }
  }

  Future<void> deleteCategory(String id) async {
    final res = await ApiProvider.post(ApiEndpoints.saCategoriesDelete,
        body: {'category_id': id});
    if (res.success) {
      categories.removeWhere((c) => c['id']?.toString() == id);
      Get.snackbar('Deleted'.tr, 'Category removed'.tr,
          backgroundColor: const Color(0xFF4CAF50), colorText: Colors.white);
    } else {
      Get.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
          backgroundColor: const Color(0xFFF44336), colorText: Colors.white);
    }
  }

  Future<void> toggleCategory(String id) async {
    final res = await ApiProvider.post(ApiEndpoints.saCategoriesToggle,
        body: {'category_id': id});
    if (res.success) {
      await fetchCategories();
    } else {
      Get.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
          backgroundColor: const Color(0xFFF44336), colorText: Colors.white);
    }
  }
}
