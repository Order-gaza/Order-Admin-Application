import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../app/constants/api_endpoints.dart';
import '../../../../data/providers/api_provider.dart';

class VendorDashboardController extends GetxController {
  final isLoading = false.obs;
  final error = ''.obs;

  // Order stats
  final totalOrders = 0.obs;
  final pendingOrders = 0.obs;
  final preparingOrders = 0.obs;
  final readyOrders = 0.obs;
  final deliveredOrders = 0.obs;

  // Revenue breakdown (from delivered/completed orders only)
  final grossRevenue = 0.0.obs;
  final netRevenue = 0.0.obs;
  final totalCommissionPaid = 0.0.obs;
  final commissionRate = 0.0.obs;

  // Today
  final todayOrders = 0.obs;
  final todayGrossRevenue = 0.0.obs;
  final todayNetRevenue = 0.0.obs;

  // Menu
  final activeMenuItems = 0.obs;

  final recentOrders = <Map<String, dynamic>>[].obs;

  final fmt = NumberFormat.currency(symbol: '₪', decimalDigits: 2);

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchAll() async {
    isLoading.value = true;
    error.value = '';
    try {
      final statsRes =
          await ApiProvider.get(ApiEndpoints.vendorDashboardStats);
      if (kDebugMode) debugPrint(
          '[VendorDashboard] stats response: success=${statsRes.success}, message=${statsRes.message}, data=${statsRes.data}');

      if (statsRes.success && statsRes.data != null) {
        final d = statsRes.data is Map<String, dynamic>
            ? statsRes.data as Map<String, dynamic>
            : <String, dynamic>{};

        // Orders
        final orders = d['orders'] is Map<String, dynamic>
            ? d['orders'] as Map<String, dynamic>
            : <String, dynamic>{};
        totalOrders.value = _toInt(orders['total']);
        pendingOrders.value = _toInt(orders['pending']);
        preparingOrders.value = _toInt(orders['preparing']);
        readyOrders.value = _toInt(orders['ready']);
        deliveredOrders.value = _toInt(orders['delivered']);

        // Revenue (from delivered orders only)
        final revenue = d['revenue'] is Map<String, dynamic>
            ? d['revenue'] as Map<String, dynamic>
            : <String, dynamic>{};
        grossRevenue.value =
            double.tryParse(revenue['gross_revenue']?.toString() ?? '0') ?? 0;
        netRevenue.value =
            double.tryParse(revenue['net_revenue']?.toString() ?? '0') ?? 0;
        totalCommissionPaid.value =
            double.tryParse(
                    revenue['total_commission_paid']?.toString() ?? '0') ??
                0;
        commissionRate.value =
            double.tryParse(revenue['commission_rate']?.toString() ?? '0') ?? 0;

        // Today
        final today = d['today'] is Map<String, dynamic>
            ? d['today'] as Map<String, dynamic>
            : <String, dynamic>{};
        todayOrders.value = _toInt(today['orders']);
        todayGrossRevenue.value =
            double.tryParse(today['gross_revenue']?.toString() ?? '0') ?? 0;
        todayNetRevenue.value =
            double.tryParse(today['net_revenue']?.toString() ?? '0') ?? 0;

        activeMenuItems.value = _toInt(d['active_menu_items']);
      } else {
        error.value = statsRes.message ?? 'Failed to load dashboard';
      }

      final recentRes =
          await ApiProvider.get(ApiEndpoints.vendorDashboardRecentOrders);
      if (recentRes.success && recentRes.data != null) {
        final od = recentRes.data is Map<String, dynamic>
            ? recentRes.data as Map<String, dynamic>
            : <String, dynamic>{};
        recentOrders.value =
            List<Map<String, dynamic>>.from(od['orders'] as List? ?? []);
      }
    } catch (e, st) {
      if (kDebugMode) debugPrint('[VendorDashboard] Error: $e\n$st');
      error.value = 'Error loading dashboard: $e';
    } finally {
      isLoading.value = false;
    }
  }

  int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }
}
