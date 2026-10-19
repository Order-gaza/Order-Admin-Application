import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/api_provider.dart';
import '../../../../app/constants/api_endpoints.dart';
import '../../../../shared/localization/app_translations.dart';
import '../../../../shared/utils/app_navigator.dart';

final saOrdersProvider = ChangeNotifierProvider<SaOrdersController>((ref) {
  return SaOrdersController.to;
});

class SaOrdersController extends ChangeNotifier {
  static SaOrdersController? _instance;
  static SaOrdersController get to => _instance ??= SaOrdersController();

  bool isLoading = false;
  List<Map<String, dynamic>> orders = [];
  String selectedStatus = 'all';
  String searchQuery = '';

  final statusFilters = [
    'all', 'pending', 'admin_confirmed', 'sent_to_vendor',
    'vendor_accepted', 'preparing', 'ready_for_pickup',
    'out_for_delivery', 'delivered', 'cancelled'
  ];

  SaOrdersController() {
    final args = AppNavigator.arguments;
    if (args is Map && args['filter'] != null) {
      selectedStatus = args['filter'] as String;
    }
    fetchOrders();
  }

  void setStatus(String status) {
    selectedStatus = status;
    notifyListeners();
    fetchOrders();
  }

  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  Future<void> fetchOrders() async {
    isLoading = true;
    notifyListeners();
    try {
      String url;
      Map<String, String>? params;
      if (selectedStatus == 'all') {
        url = ApiEndpoints.saOrdersGetAll;
      } else {
        url = ApiEndpoints.saOrdersGetByStatus;
        params = {'status': selectedStatus};
      }
      final res = await ApiProvider.get(url, queryParams: params);
      if (res.success && res.data != null) {
        final d = res.data as Map<String, dynamic>;
        orders =
            List<Map<String, dynamic>>.from(d['orders'] as List? ?? []);
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> get filtered {
    if (searchQuery.isEmpty) return orders;
    final q = searchQuery.toLowerCase();
    return orders.where((o) {
      return (o['order_number'] ?? '').toLowerCase().contains(q) ||
          (o['customer_name'] ?? '').toLowerCase().contains(q);
    }).toList();
  }

  Future<void> cancelOrder(String orderId, String reason) async {
    final res = await ApiProvider.post(ApiEndpoints.saOrdersCancel,
        body: {'order_id': orderId, 'reason': reason});
    if (res.success) {
      fetchOrders();
      AppNavigator.snackbar('Cancelled'.tr, 'Order cancelled'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
    } else {
      AppNavigator.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
    }
  }
}
