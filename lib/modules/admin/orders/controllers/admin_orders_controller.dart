import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/providers/api_provider.dart';
import '../../../../app/constants/api_endpoints.dart';

class AdminOrdersController extends GetxController {
  final isLoading = false.obs;
  final orders = <Map<String, dynamic>>[].obs;
  final selectedStatus = 'pending'.obs;
  final searchQuery = ''.obs;

  final statusFilters = [
    'pending', 'admin_confirmed', 'sent_to_vendor', 'vendor_accepted',
    'preparing', 'ready_for_pickup', 'out_for_delivery', 'delivered', 'cancelled'
  ];

  @override
  void onInit() {
    super.onInit();
    ever(selectedStatus, (_) => fetchOrders());
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    isLoading.value = true;
    try {
      final res = await ApiProvider.get(
        ApiEndpoints.adminOrdersGetByStatus,
        queryParams: {'status': selectedStatus.value},
      );
      if (res.success && res.data != null) {
        final d = res.data as Map<String, dynamic>;
        orders.value =
            List<Map<String, dynamic>>.from(d['orders'] as List? ?? []);
      }
    } finally {
      isLoading.value = false;
    }
  }

  List<Map<String, dynamic>> get filtered {
    if (searchQuery.value.isEmpty) return orders;
    final q = searchQuery.value.toLowerCase();
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

  void _handleActionResult(
      dynamic res, String successMsg) {
    if (res.success) {
      fetchOrders();
      Get.snackbar('Success', successMsg,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF));
    } else {
      Get.snackbar('Error'.tr, res.message?.tr ?? 'Action failed'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
    }
  }
}
