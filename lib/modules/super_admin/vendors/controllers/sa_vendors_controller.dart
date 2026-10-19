import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/api_provider.dart';
import '../../../../app/constants/api_endpoints.dart';
import '../../../../shared/localization/app_translations.dart';
import '../../../../shared/utils/app_navigator.dart';

final saVendorsProvider = ChangeNotifierProvider<SaVendorsController>((ref) {
  return SaVendorsController.to;
});

class SaVendorsController extends ChangeNotifier {
  static SaVendorsController? _instance;
  static SaVendorsController get to => _instance ??= SaVendorsController();

  bool isLoading = false;
  List<Map<String, dynamic>> vendors = [];
  String selectedFilter = 'all'; // all, pending, approved, suspended
  String searchQuery = '';

  SaVendorsController() {
    final args = AppNavigator.arguments;
    if (args is Map && args['filter'] != null) {
      selectedFilter = args['filter'] as String;
    }
    fetchVendors();
  }

  void setFilter(String filter) {
    selectedFilter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  Future<void> fetchVendors() async {
    isLoading = true;
    notifyListeners();
    try {
      final res = await ApiProvider.get(ApiEndpoints.saVendorsGetAll);
      if (res.success && res.data != null) {
        final d = res.data as Map<String, dynamic>;
        vendors =
            List<Map<String, dynamic>>.from(d['vendors'] as List? ?? []);
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> get filtered {
    var list = vendors.toList();
    if (selectedFilter != 'all') {
      list = list.where((v) => v['status'] == selectedFilter).toList();
    }
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
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
      AppNavigator.snackbar('Approved'.tr, 'Vendor approved successfully'.tr,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF));
    } else {
      AppNavigator.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
    }
  }

  Future<void> suspend(String vendorId) async {
    final res = await ApiProvider.post(ApiEndpoints.saVendorsSuspend,
        body: {'vendor_id': vendorId});
    if (res.success) {
      _updateLocalStatus(vendorId, 'suspended');
      AppNavigator.snackbar('Suspended'.tr, 'Vendor suspended'.tr,
          backgroundColor: const Color(0xFFFF9800),
          colorText: const Color(0xFFFFFFFF));
    } else {
      AppNavigator.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
    }
  }

  Future<void> reactivate(String vendorId) async {
    final res = await ApiProvider.post(ApiEndpoints.saVendorsReactivate,
        body: {'vendor_id': vendorId});
    if (res.success) {
      _updateLocalStatus(vendorId, 'approved');
      AppNavigator.snackbar('Reactivated'.tr, 'Vendor reactivated'.tr,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF));
    } else {
      AppNavigator.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
    }
  }

  Future<void> reject(String vendorId) async {
    final res = await ApiProvider.post(ApiEndpoints.saVendorsReject,
        body: {'vendor_id': vendorId});
    if (res.success) {
      _updateLocalStatus(vendorId, 'rejected');
      AppNavigator.snackbar('Rejected'.tr, 'Vendor application rejected'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
    } else {
      AppNavigator.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
    }
  }

  void _updateLocalStatus(String vendorId, String status) {
    final idx = vendors.indexWhere((v) => v['id'] == vendorId);
    if (idx != -1) {
      vendors[idx] = {...vendors[idx], 'status': status};
      notifyListeners();
    }
  }
}
