import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../app/constants/api_endpoints.dart';
import '../../../../app/constants/app_constants.dart';
import '../../../../data/providers/api_provider.dart';

final adminDashboardProvider = ChangeNotifierProvider<AdminDashboardController>((ref) {
  return AdminDashboardController.to;
});

class AdminDashboardController extends ChangeNotifier {
  static AdminDashboardController? _instance;
  static AdminDashboardController get to => _instance ??= AdminDashboardController();

  bool isLoading = false;

  // Stats
  int pendingOrders = 0;
  int activeVendors = 0;
  int todayOrders = 0;
  double todayRevenue = 0.0;
  int todayDelivered = 0;
  int todayCancelled = 0;
  Map<String, int> ordersByStatus = {};
  List<Map<String, dynamic>> recentOrders = [];

  // Delivery profit (Admin's earnings) — from delivered orders only
  double totalDeliveryEarnings = 0.0;
  double todayDeliveryEarnings = 0.0;
  double totalCollectedFromUsers = 0.0;
  double totalPaidToVendors = 0.0;
  double saOwed = 0.0;

  final fmt = NumberFormat.currency(symbol: '₪', decimalDigits: 2);

  AdminDashboardController() {
    fetchAll();
  }

  Future<void> fetchAll() async {
    isLoading = true;
    notifyListeners();
    try {
      final statsRes = await ApiProvider.get(ApiEndpoints.adminDashboardStats);
      if (statsRes.success && statsRes.data != null) {
        final d = statsRes.data as Map<String, dynamic>;
        pendingOrders = (d['pending_orders'] ?? 0) as int;
        activeVendors = (d['active_vendors'] ?? 0) as int;
        final today = d['today'] as Map<String, dynamic>? ?? {};
        todayOrders = (today['orders'] ?? 0) as int;
        todayRevenue =
            double.tryParse(today['revenue']?.toString() ?? '0') ?? 0;
        todayDelivered = (today['delivered'] ?? 0) as int;
        todayCancelled = (today['cancelled'] ?? 0) as int;
        ordersByStatus =
            Map<String, int>.from(d['orders_by_status'] ?? {});

        // Delivery profit
        final dp = d['delivery_profit'] as Map<String, dynamic>? ?? {};
        totalDeliveryEarnings = double.tryParse(
                dp['total_delivery_earnings']?.toString() ?? '0') ??
            0;
        todayDeliveryEarnings = double.tryParse(
                dp['today_delivery_earnings']?.toString() ?? '0') ??
            0;
        totalCollectedFromUsers = double.tryParse(
                dp['total_collected_from_users']?.toString() ?? '0') ??
            0;
        totalPaidToVendors = double.tryParse(
                dp['total_paid_to_vendors']?.toString() ?? '0') ??
            0;
        saOwed =
            double.tryParse(dp['sa_owed']?.toString() ?? '0') ?? 0;
      }

      final recentRes =
          await ApiProvider.get(ApiEndpoints.adminDashboardRecentOrders);
      if (recentRes.success && recentRes.data != null) {
        final od = recentRes.data as Map<String, dynamic>;
        recentOrders =
            List<Map<String, dynamic>>.from(od['orders'] as List? ?? []);
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String statusLabel(String s) => AppConstants.orderStatusLabel(s);
}
