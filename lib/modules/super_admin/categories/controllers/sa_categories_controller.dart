import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/constants/api_endpoints.dart';
import '../../../../data/providers/api_provider.dart';
import '../../../../shared/localization/app_translations.dart';
import '../../../../shared/utils/app_navigator.dart';

final saCategoriesProvider =
    ChangeNotifierProvider<SaCategoriesController>((ref) {
  return SaCategoriesController.to;
});

class SaCategoriesController extends ChangeNotifier {
  static SaCategoriesController? _instance;
  static SaCategoriesController get to =>
      _instance ??= SaCategoriesController();

  bool isLoading = false;
  List<Map<String, dynamic>> categories = [];

  SaCategoriesController() {
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    isLoading = true;
    notifyListeners();
    try {
      final res = await ApiProvider.get(ApiEndpoints.saCategoriesGetAll);
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
      AppNavigator.snackbar('Added'.tr, 'Category created'.tr,
          backgroundColor: const Color(0xFF4CAF50), colorText: Colors.white);
    } else {
      AppNavigator.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
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
      AppNavigator.snackbar('Updated'.tr, 'Category updated'.tr,
          backgroundColor: const Color(0xFF4CAF50), colorText: Colors.white);
    } else {
      AppNavigator.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
          backgroundColor: const Color(0xFFF44336), colorText: Colors.white);
    }
  }

  Future<void> deleteCategory(String id) async {
    final res = await ApiProvider.post(ApiEndpoints.saCategoriesDelete,
        body: {'category_id': id});
    if (res.success) {
      categories.removeWhere((c) => c['id']?.toString() == id);
      notifyListeners();
      AppNavigator.snackbar('Deleted'.tr, 'Category removed'.tr,
          backgroundColor: const Color(0xFF4CAF50), colorText: Colors.white);
    } else {
      AppNavigator.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
          backgroundColor: const Color(0xFFF44336), colorText: Colors.white);
    }
  }

  Future<void> toggleCategory(String id) async {
    final res = await ApiProvider.post(ApiEndpoints.saCategoriesToggle,
        body: {'category_id': id});
    if (res.success) {
      await fetchCategories();
    } else {
      AppNavigator.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
          backgroundColor: const Color(0xFFF44336), colorText: Colors.white);
    }
  }
}
