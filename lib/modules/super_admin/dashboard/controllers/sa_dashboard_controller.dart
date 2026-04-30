import 'package:get/get.dart';
import '../../../../data/providers/api_provider.dart';
import '../../../../app/constants/api_endpoints.dart';

class SaDashboardController extends GetxController {
  final isLoading = false.obs;

  // Stats
  final totalOrders = 0.obs;
  final pendingOrders = 0.obs;
  final deliveredOrders = 0.obs;
  final totalVendors = 0.obs;
  final pendingVendors = 0.obs;

  // SA Earnings (only from completed/delivered orders)
  final saTotalEarnings = 0.0.obs;
  final totalServiceFees = 0.0.obs;
  final totalCommissions = 0.0.obs;
  final saUncollected = 0.0.obs;
  final saCollected = 0.0.obs;
  final saTodayEarnings = 0.0.obs;
  final todayServiceFees = 0.0.obs;
  final todayCommissions = 0.0.obs;

  // Recent orders
  final recentOrders = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboard();
  }

  Future<void> fetchDashboard() async {
    isLoading.value = true;
    try {
      final statsRes = await ApiProvider.get(ApiEndpoints.saDashboardStats);
      if (statsRes.success && statsRes.data != null) {
        final d = statsRes.data as Map<String, dynamic>;

        // Orders
        final ordersRaw = d['orders'];
        if (ordersRaw is Map<String, dynamic>) {
          totalOrders.value =
              int.tryParse(ordersRaw['total_orders']?.toString() ?? '0') ?? 0;
          pendingOrders.value =
              int.tryParse(ordersRaw['pending_orders']?.toString() ?? '0') ?? 0;
          deliveredOrders.value =
              int.tryParse(ordersRaw['delivered_orders']?.toString() ?? '0') ??
                  0;
        }

        // Vendors
        final vendorsRaw = d['vendors'];
        if (vendorsRaw is Map<String, dynamic>) {
          totalVendors.value =
              int.tryParse(vendorsRaw['total_vendors']?.toString() ?? '0') ?? 0;
          pendingVendors.value =
              int.tryParse(vendorsRaw['pending_vendors']?.toString() ?? '0') ??
                  0;
        }

        // SA Earnings breakdown (only from delivered orders)
        final earningsRaw = d['earnings'];
        if (earningsRaw is Map<String, dynamic>) {
          saTotalEarnings.value = double.tryParse(
                  earningsRaw['sa_total_earnings']?.toString() ?? '0') ??
              0;
          totalServiceFees.value = double.tryParse(
                  earningsRaw['total_service_fees']?.toString() ?? '0') ??
              0;
          totalCommissions.value = double.tryParse(
                  earningsRaw['total_commissions']?.toString() ?? '0') ??
              0;
          saUncollected.value = double.tryParse(
                  earningsRaw['sa_uncollected']?.toString() ?? '0') ??
              0;
          saCollected.value =
              double.tryParse(earningsRaw['sa_collected']?.toString() ?? '0') ??
                  0;
          saTodayEarnings.value = double.tryParse(
                  earningsRaw['sa_today_earnings']?.toString() ?? '0') ??
              0;
          todayServiceFees.value = double.tryParse(
                  earningsRaw['today_service_fees']?.toString() ?? '0') ??
              0;
          todayCommissions.value = double.tryParse(
                  earningsRaw['today_commissions']?.toString() ?? '0') ??
              0;
        }
      }

      final ordersRes =
          await ApiProvider.get(ApiEndpoints.saDashboardRecentOrders);
      if (ordersRes.success && ordersRes.data != null) {
        final od = ordersRes.data as Map<String, dynamic>;
        recentOrders.value =
            List<Map<String, dynamic>>.from(od['orders'] as List? ?? []);
      }
    } finally {
      isLoading.value = false;
    }
  }
}
