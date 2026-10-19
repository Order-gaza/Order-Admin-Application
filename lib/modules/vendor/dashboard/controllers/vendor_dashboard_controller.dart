import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../app/constants/api_endpoints.dart';
import '../../../../data/providers/api_provider.dart';

final vendorDashboardProvider = ChangeNotifierProvider<VendorDashboardController>((ref) {
  return VendorDashboardController.to;
});

class VendorDashboardController extends ChangeNotifier {
  static VendorDashboardController? _instance;
  static VendorDashboardController get to => _instance ??= VendorDashboardController();

  bool isLoading = false;
  String error = '';

  // Order stats
  int totalOrders = 0;
  int pendingOrders = 0;
  int preparingOrders = 0;
  int readyOrders = 0;
  int deliveredOrders = 0;

  // Revenue breakdown (from delivered/completed orders only)
  double grossRevenue = 0.0;
  double netRevenue = 0.0;
  double totalCommissionPaid = 0.0;
  double commissionRate = 0.0;

  // Today
  int todayOrders = 0;
  double todayGrossRevenue = 0.0;
  double todayNetRevenue = 0.0;

  // Menu
  int activeMenuItems = 0;

  List<Map<String, dynamic>> recentOrders = [];

  final fmt = NumberFormat.currency(symbol: '₪', decimalDigits: 2);

  VendorDashboardController() {
    fetchAll();
  }

  Future<void> fetchAll() async {
    isLoading = true;
    error = '';
    notifyListeners();

    try {
      final statsRes =
          await ApiProvider.get(ApiEndpoints.vendorDashboardStats);
      if (kDebugMode) {
        debugPrint(
            '[VendorDashboard] stats response: success=${statsRes.success}, message=${statsRes.message}, data=${statsRes.data}');
      }

      if (statsRes.success && statsRes.data != null) {
        final d = statsRes.data is Map<String, dynamic>
            ? statsRes.data as Map<String, dynamic>
            : <String, dynamic>{};

        // Orders
        final orders = d['orders'] is Map<String, dynamic>
            ? d['orders'] as Map<String, dynamic>
            : <String, dynamic>{};
        totalOrders = _toInt(orders['total']);
        pendingOrders = _toInt(orders['pending']);
        preparingOrders = _toInt(orders['preparing']);
        readyOrders = _toInt(orders['ready']);
        deliveredOrders = _toInt(orders['delivered']);

        // Revenue (from delivered orders only)
        final revenue = d['revenue'] is Map<String, dynamic>
            ? d['revenue'] as Map<String, dynamic>
            : <String, dynamic>{};
        grossRevenue =
            double.tryParse(revenue['gross_revenue']?.toString() ?? '0') ?? 0;
        netRevenue =
            double.tryParse(revenue['net_revenue']?.toString() ?? '0') ?? 0;
        totalCommissionPaid =
            double.tryParse(
                    revenue['total_commission_paid']?.toString() ?? '0') ??
                0;
        commissionRate =
            double.tryParse(revenue['commission_rate']?.toString() ?? '0') ?? 0;

        // Today
        final today = d['today'] is Map<String, dynamic>
            ? d['today'] as Map<String, dynamic>
            : <String, dynamic>{};
        todayOrders = _toInt(today['orders']);
        todayGrossRevenue =
            double.tryParse(today['gross_revenue']?.toString() ?? '0') ?? 0;
        todayNetRevenue =
            double.tryParse(today['net_revenue']?.toString() ?? '0') ?? 0;

        activeMenuItems = _toInt(d['active_menu_items']);
      } else {
        error = statsRes.message ?? 'Failed to load dashboard';
      }

      final recentRes =
          await ApiProvider.get(ApiEndpoints.vendorDashboardRecentOrders);
      if (recentRes.success && recentRes.data != null) {
        final od = recentRes.data is Map<String, dynamic>
            ? recentRes.data as Map<String, dynamic>
            : <String, dynamic>{};
        recentOrders =
            List<Map<String, dynamic>>.from(od['orders'] as List? ?? []);
      }
    } catch (e, st) {
      if (kDebugMode) debugPrint('[VendorDashboard] Error: $e\n$st');
      error = 'Error loading dashboard: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }
}
