import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/api_provider.dart';
import '../../../../app/constants/api_endpoints.dart';
import '../../../../shared/localization/app_translations.dart';
import '../../../../shared/utils/app_navigator.dart';

final saAdminsProvider = ChangeNotifierProvider<SaAdminsController>((ref) {
  return SaAdminsController.to;
});

class SaAdminsController extends ChangeNotifier {
  static SaAdminsController? _instance;
  static SaAdminsController get to => _instance ??= SaAdminsController();

  bool isLoading = false;
  List<Map<String, dynamic>> admins = [];
  String searchQuery = '';

  SaAdminsController() {
    fetchAdmins();
  }

  void setSearchQuery(String q) {
    searchQuery = q;
    notifyListeners();
  }

  Future<void> fetchAdmins() async {
    isLoading = true;
    notifyListeners();
    try {
      final res = await ApiProvider.get(ApiEndpoints.saAdminsGetAll);
      if (res.success && res.data != null) {
        final d = res.data as Map<String, dynamic>;
        admins =
            List<Map<String, dynamic>>.from(d['admins'] as List? ?? []);
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> get filtered {
    if (searchQuery.isEmpty) return admins;
    final q = searchQuery.toLowerCase();
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
      await fetchAdmins();
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
      AppNavigator.snackbar('Success'.tr, 'Admin added successfully'.tr,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF));
    } else {
      AppNavigator.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
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
      notifyListeners();
      AppNavigator.snackbar('Deleted'.tr, 'Admin removed'.tr,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF));
    } else {
      AppNavigator.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
    }
  }
}
