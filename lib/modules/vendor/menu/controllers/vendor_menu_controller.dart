import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/providers/api_provider.dart';
import '../../../../app/constants/api_endpoints.dart';

class VendorMenuController extends GetxController {
  final isLoading = false.obs;
  final categories = <Map<String, dynamic>>[].obs;
  final items = <Map<String, dynamic>>[].obs;
  final selectedCategoryId = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchItems();
  }

  Future<void> fetchCategories() async {
    final res = await ApiProvider.get(ApiEndpoints.vendorCategoriesGetAll);
    if (res.success && res.data != null) {
      final d = res.data as Map<String, dynamic>;
      categories.value =
          List<Map<String, dynamic>>.from(d['categories'] as List? ?? []);
    }
  }

  Future<void> fetchItems() async {
    isLoading.value = true;
    try {
      // Fetch all items — default server limit is 20 (ITEMS_PER_PAGE),
      // but the vendor needs to see their full menu for management.
      final res = await ApiProvider.get(ApiEndpoints.vendorItemsGetAll,
          queryParams: {'limit': '200'});
      if (res.success && res.data != null) {
        final d = res.data as Map<String, dynamic>;
        items.value =
            List<Map<String, dynamic>>.from(d['items'] as List? ?? []);
      }
    } finally {
      isLoading.value = false;
    }
  }

  List<Map<String, dynamic>> get filteredItems {
    if (selectedCategoryId.value == null) return items;
    return items
        .where((i) =>
            i['category_id']?.toString() == selectedCategoryId.value)
        .toList();
  }

  Future<void> toggleItemStatus(String itemId) async {
    final res = await ApiProvider.post(ApiEndpoints.vendorItemsToggle,
        body: {'item_id': itemId});
    if (res.success) {
      fetchItems();
    } else {
      Get.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
    }
  }

  Future<void> deleteItem(String itemId) async {
    final res = await ApiProvider.post(ApiEndpoints.vendorItemsDelete,
        body: {'item_id': itemId});
    if (res.success) {
      items.removeWhere((i) => i['id'] == itemId);
      Get.snackbar('Deleted'.tr, 'Item removed'.tr,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF));
    } else {
      Get.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
    }
  }

  Future<void> addCategory(String name) async {
    final res = await ApiProvider.post(ApiEndpoints.vendorCategoriesAdd,
        body: {'name': name});
    if (res.success) {
      fetchCategories();
      Get.snackbar('Added'.tr, 'Category created'.tr,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF));
    }
  }
}
