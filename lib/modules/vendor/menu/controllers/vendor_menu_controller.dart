import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/api_provider.dart';
import '../../../../app/constants/api_endpoints.dart';
import '../../../../shared/localization/app_translations.dart';
import '../../../../shared/utils/app_navigator.dart';

final vendorMenuProvider = ChangeNotifierProvider<VendorMenuController>((ref) {
  return VendorMenuController.to;
});

class VendorMenuController extends ChangeNotifier {
  static VendorMenuController? _instance;
  static VendorMenuController get to => _instance ??= VendorMenuController();

  bool isLoading = false;
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> items = [];
  String? selectedCategoryId;

  VendorMenuController() {
    fetchCategories();
    fetchItems();
  }

  void selectCategory(String? categoryId) {
    selectedCategoryId = categoryId;
    notifyListeners();
  }

  Future<void> fetchCategories() async {
    final res = await ApiProvider.get(ApiEndpoints.vendorCategoriesGetAll);
    if (res.success && res.data != null) {
      final d = res.data as Map<String, dynamic>;
      categories =
          List<Map<String, dynamic>>.from(d['categories'] as List? ?? []);
      notifyListeners();
    }
  }

  Future<void> fetchItems() async {
    isLoading = true;
    notifyListeners();
    try {
      final res = await ApiProvider.get(ApiEndpoints.vendorItemsGetAll,
          queryParams: {'limit': '200'});
      if (res.success && res.data != null) {
        final d = res.data as Map<String, dynamic>;
        items =
            List<Map<String, dynamic>>.from(d['items'] as List? ?? []);
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> get filteredItems {
    if (selectedCategoryId == null) return items;
    return items
        .where((i) =>
            i['category_id']?.toString() == selectedCategoryId)
        .toList();
  }

  Future<void> toggleItemStatus(String itemId) async {
    final res = await ApiProvider.post(ApiEndpoints.vendorItemsToggle,
        body: {'item_id': itemId});
    if (res.success) {
      fetchItems();
    } else {
      AppNavigator.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
    }
  }

  Future<void> deleteItem(String itemId) async {
    final res = await ApiProvider.post(ApiEndpoints.vendorItemsDelete,
        body: {'item_id': itemId});
    if (res.success) {
      items.removeWhere((i) => i['id'] == itemId);
      notifyListeners();
      AppNavigator.snackbar('Deleted'.tr, 'Item removed'.tr,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF));
    } else {
      AppNavigator.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
    }
  }

  Future<void> addCategory(String name) async {
    final res = await ApiProvider.post(ApiEndpoints.vendorCategoriesAdd,
        body: {'name': name});
    if (res.success) {
      fetchCategories();
      AppNavigator.snackbar('Added'.tr, 'Category created'.tr,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF));
    }
  }
}
