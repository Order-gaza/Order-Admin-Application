import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/api_provider.dart';
import '../../../../app/constants/api_endpoints.dart';
import '../../../../shared/localization/app_translations.dart';
import '../../../../shared/utils/app_navigator.dart';

final saCustomersProvider =
    ChangeNotifierProvider<SaCustomersController>((ref) {
  return SaCustomersController.to;
});

class SaCustomersController extends ChangeNotifier {
  static SaCustomersController? _instance;
  static SaCustomersController get to =>
      _instance ??= SaCustomersController();

  bool isLoading = false;
  List<Map<String, dynamic>> customers = [];
  String searchQuery = '';

  SaCustomersController() {
    fetchCustomers();
  }

  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  Future<void> fetchCustomers() async {
    isLoading = true;
    notifyListeners();
    try {
      final res = await ApiProvider.get(ApiEndpoints.saCustomersGetAll);
      if (res.success && res.data != null) {
        final d = res.data as Map<String, dynamic>;
        customers =
            List<Map<String, dynamic>>.from(d['customers'] as List? ?? []);
      } else {
        AppNavigator.snackbar(
          'Debug Error'.tr,
          res.message?.tr ?? 'Unknown API error'.tr,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> get filtered {
    if (searchQuery.isEmpty) return customers;
    final q = searchQuery.toLowerCase();
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
      AppNavigator.snackbar(
        'Success',
        res.message?.tr ?? 'Status updated',
        backgroundColor: const Color(0xFF4CAF50),
        colorText: const Color(0xFFFFFFFF),
      );
    } else {
      AppNavigator.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
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
      notifyListeners();
      AppNavigator.snackbar('Done'.tr, res.message?.tr ?? 'Customer removed'.tr,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF));
    } else {
      AppNavigator.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
    }
  }
}
