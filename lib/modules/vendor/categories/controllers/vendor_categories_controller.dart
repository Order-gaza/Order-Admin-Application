import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/constants/api_endpoints.dart';
import '../../../../data/providers/api_provider.dart';
import '../../../../shared/localization/app_translations.dart';
import '../../../../shared/utils/app_navigator.dart';

final vendorCategoriesProvider = ChangeNotifierProvider<VendorCategoriesController>((ref) {
  return VendorCategoriesController.to;
});

class VendorCategoriesController extends ChangeNotifier {
  static VendorCategoriesController? _instance;
  static VendorCategoriesController get to => _instance ??= VendorCategoriesController();

  bool isLoading = false;
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> globalCategories = [];

  VendorCategoriesController() {
    fetchCategories();
    fetchGlobalCategories();
  }

  Future<void> fetchCategories() async {
    isLoading = true;
    notifyListeners();
    try {
      final res = await ApiProvider.get(ApiEndpoints.vendorCategoriesGetAll);
      if (res.success && res.data != null) {
        final d = res.data as Map<String, dynamic>;
        categories =
            List<Map<String, dynamic>>.from(d['categories'] as List? ?? []);
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchGlobalCategories() async {
    final res = await ApiProvider.get(ApiEndpoints.vendorCategoriesGetGlobal);
    if (res.success && res.data != null) {
      final d = res.data as Map<String, dynamic>;
      globalCategories =
          List<Map<String, dynamic>>.from(d['categories'] as List? ?? []);
      notifyListeners();
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
      AppNavigator.snackbar('Added'.tr, 'Category added'.tr,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white);
    } else {
      AppNavigator.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
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
      AppNavigator.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
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
      notifyListeners();
      AppNavigator.snackbar('Deleted'.tr, 'Category removed'.tr,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white);
    } else {
      AppNavigator.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: Colors.white);
    }
  }
}
