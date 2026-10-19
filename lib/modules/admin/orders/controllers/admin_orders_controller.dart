import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/api_provider.dart';
import '../../../../app/constants/api_endpoints.dart';
import '../../../../shared/localization/app_translations.dart';
import '../../../../shared/utils/app_navigator.dart';

final adminOrdersProvider = ChangeNotifierProvider<AdminOrdersController>((ref) {
  return AdminOrdersController.to;
});

class AdminOrdersController extends ChangeNotifier {
  static AdminOrdersController? _instance;
  static AdminOrdersController get to => _instance ??= AdminOrdersController();

  bool isLoading = false;
  List<Map<String, dynamic>> orders = [];
  String selectedStatus = 'pending';
  String searchQuery = '';

  final statusFilters = [
    'pending', 'admin_confirmed', 'sent_to_vendor', 'vendor_accepted',
    'preparing', 'ready_for_pickup', 'out_for_delivery', 'delivered', 'cancelled'
  ];

  AdminOrdersController() {
    fetchOrders();
  }

  void selectStatus(String s) {
    if (selectedStatus == s) return;
    selectedStatus = s;
    notifyListeners();
    fetchOrders();
  }

  void setSearchQuery(String q) {
    searchQuery = q;
    notifyListeners();
  }

  Future<void> fetchOrders() async {
    isLoading = true;
    notifyListeners();
    try {
      final res = await ApiProvider.get(
        ApiEndpoints.adminOrdersGetByStatus,
        queryParams: {'status': selectedStatus},
      );
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

  Future<void> confirmOrder(String orderId) async {
    final res = await ApiProvider.post(ApiEndpoints.adminOrdersConfirm,
        body: {'order_id': orderId});
    _handleActionResult(res, 'Order confirmed and sent to vendor');
  }

  Future<void> dispatchOrder(String orderId) async {
    final res = await ApiProvider.post(ApiEndpoints.adminOrdersDispatch,
        body: {'order_id': orderId});
    _handleActionResult(res, 'Order dispatched for delivery');
  }

  Future<void> deliverOrder(String orderId) async {
    final res = await ApiProvider.post(ApiEndpoints.adminOrdersDeliver,
        body: {'order_id': orderId});
    _handleActionResult(res, 'Order marked as delivered');
  }

  Future<void> cancelOrder(String orderId, String reason) async {
    final res = await ApiProvider.post(ApiEndpoints.adminOrdersCancel,
        body: {'order_id': orderId, 'reason': reason});
    _handleActionResult(res, 'Order cancelled');
  }

  void _handleActionResult(dynamic res, String successMsg) {
    if (res.success) {
      fetchOrders();
      AppNavigator.snackbar('Success', successMsg,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF));
    } else {
      AppNavigator.snackbar('Error'.tr, res.message?.tr ?? 'Action failed'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
    }
  }
}
