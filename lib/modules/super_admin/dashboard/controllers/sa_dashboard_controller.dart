import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/api_provider.dart';
import '../../../../app/constants/api_endpoints.dart';

final saDashboardProvider = ChangeNotifierProvider<SaDashboardController>((ref) {
  return SaDashboardController.to;
});

class SaDashboardController extends ChangeNotifier {
  static SaDashboardController? _instance;
  static SaDashboardController get to => _instance ??= SaDashboardController();

  bool isLoading = false;

  // Stats
  int totalOrders = 0;
  int pendingOrders = 0;
  int deliveredOrders = 0;
  int totalVendors = 0;
  int pendingVendors = 0;

  // SA Earnings (only from completed/delivered orders)
  double saTotalEarnings = 0.0;
  double totalServiceFees = 0.0;
  double totalCommissions = 0.0;
  double saUncollected = 0.0;
  double saCollected = 0.0;
  double saTodayEarnings = 0.0;
  double todayServiceFees = 0.0;
  double todayCommissions = 0.0;

  // Recent orders
  List<Map<String, dynamic>> recentOrders = [];

  SaDashboardController() {
    fetchDashboard();
  }

  Future<void> fetchDashboard() async {
    isLoading = true;
    notifyListeners();
    try {
      final statsRes = await ApiProvider.get(ApiEndpoints.saDashboardStats);
      if (statsRes.success && statsRes.data != null) {
        final d = statsRes.data as Map<String, dynamic>;

        // Orders
        final ordersRaw = d['orders'];
        if (ordersRaw is Map<String, dynamic>) {
          totalOrders =
              int.tryParse(ordersRaw['total_orders']?.toString() ?? '0') ?? 0;
          pendingOrders =
              int.tryParse(ordersRaw['pending_orders']?.toString() ?? '0') ?? 0;
          deliveredOrders =
              int.tryParse(ordersRaw['delivered_orders']?.toString() ?? '0') ??
                  0;
        }

        // Vendors
        final vendorsRaw = d['vendors'];
        if (vendorsRaw is Map<String, dynamic>) {
          totalVendors =
              int.tryParse(vendorsRaw['total_vendors']?.toString() ?? '0') ?? 0;
          pendingVendors =
              int.tryParse(vendorsRaw['pending_vendors']?.toString() ?? '0') ??
                  0;
        }

        // SA Earnings breakdown (only from delivered orders)
        final earningsRaw = d['earnings'];
        if (earningsRaw is Map<String, dynamic>) {
          saTotalEarnings = double.tryParse(
                  earningsRaw['sa_total_earnings']?.toString() ?? '0') ??
              0;
          totalServiceFees = double.tryParse(
                  earningsRaw['total_service_fees']?.toString() ?? '0') ??
              0;
          totalCommissions = double.tryParse(
                  earningsRaw['total_commissions']?.toString() ?? '0') ??
              0;
          saUncollected = double.tryParse(
                  earningsRaw['sa_uncollected']?.toString() ?? '0') ??
              0;
          saCollected =
              double.tryParse(earningsRaw['sa_collected']?.toString() ?? '0') ??
                  0;
          saTodayEarnings = double.tryParse(
                  earningsRaw['sa_today_earnings']?.toString() ?? '0') ??
              0;
          todayServiceFees = double.tryParse(
                  earningsRaw['today_service_fees']?.toString() ?? '0') ??
              0;
          todayCommissions = double.tryParse(
                  earningsRaw['today_commissions']?.toString() ?? '0') ??
              0;
        }
      }

      final ordersRes =
          await ApiProvider.get(ApiEndpoints.saDashboardRecentOrders);
      if (ordersRes.success && ordersRes.data != null) {
        final od = ordersRes.data as Map<String, dynamic>;
        recentOrders =
            List<Map<String, dynamic>>.from(od['orders'] as List? ?? []);
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
