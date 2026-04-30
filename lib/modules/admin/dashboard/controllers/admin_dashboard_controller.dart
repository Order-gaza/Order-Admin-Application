import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../app/constants/api_endpoints.dart';
import '../../../../app/constants/app_constants.dart';
import '../../../../data/providers/api_provider.dart';

class AdminDashboardController extends GetxController {
  final isLoading = false.obs;

  // Stats
  final pendingOrders = 0.obs;
  final activeVendors = 0.obs;
  final todayOrders = 0.obs;
  final todayRevenue = 0.0.obs;
  final todayDelivered = 0.obs;
  final todayCancelled = 0.obs;
  final ordersByStatus = <String, int>{}.obs;
  final recentOrders = <Map<String, dynamic>>[].obs;

  // Delivery profit (Admin's earnings) — from delivered orders only
  final totalDeliveryEarnings = 0.0.obs;
  final todayDeliveryEarnings = 0.0.obs;
  final totalCollectedFromUsers = 0.0.obs;
  final totalPaidToVendors = 0.0.obs;
  final saOwed = 0.0.obs;

  final fmt = NumberFormat.currency(symbol: '₪', decimalDigits: 2);

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchAll() async {
    isLoading.value = true;
    try {
      final statsRes = await ApiProvider.get(ApiEndpoints.adminDashboardStats);
      if (statsRes.success && statsRes.data != null) {
        final d = statsRes.data as Map<String, dynamic>;
        pendingOrders.value = (d['pending_orders'] ?? 0) as int;
        activeVendors.value = (d['active_vendors'] ?? 0) as int;
        final today = d['today'] as Map<String, dynamic>? ?? {};
        todayOrders.value = (today['orders'] ?? 0) as int;
        todayRevenue.value =
            double.tryParse(today['revenue']?.toString() ?? '0') ?? 0;
        todayDelivered.value = (today['delivered'] ?? 0) as int;
        todayCancelled.value = (today['cancelled'] ?? 0) as int;
        ordersByStatus.value =
            Map<String, int>.from(d['orders_by_status'] ?? {});

        // Delivery profit
        final dp = d['delivery_profit'] as Map<String, dynamic>? ?? {};
        totalDeliveryEarnings.value = double.tryParse(
                dp['total_delivery_earnings']?.toString() ?? '0') ??
            0;
        todayDeliveryEarnings.value = double.tryParse(
                dp['today_delivery_earnings']?.toString() ?? '0') ??
            0;
        totalCollectedFromUsers.value = double.tryParse(
                dp['total_collected_from_users']?.toString() ?? '0') ??
            0;
        totalPaidToVendors.value = double.tryParse(
                dp['total_paid_to_vendors']?.toString() ?? '0') ??
            0;
        saOwed.value =
            double.tryParse(dp['sa_owed']?.toString() ?? '0') ?? 0;
      }

      final recentRes =
          await ApiProvider.get(ApiEndpoints.adminDashboardRecentOrders);
      if (recentRes.success && recentRes.data != null) {
        final od = recentRes.data as Map<String, dynamic>;
        recentOrders.value =
            List<Map<String, dynamic>>.from(od['orders'] as List? ?? []);
      }
    } finally {
      isLoading.value = false;
    }
  }

  String statusLabel(String s) => AppConstants.orderStatusLabel(s);
}
