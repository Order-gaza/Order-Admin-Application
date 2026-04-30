import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/providers/api_provider.dart';
import '../../../../app/constants/api_endpoints.dart';

class SaOrdersController extends GetxController {
  final isLoading = false.obs;
  final orders = <Map<String, dynamic>>[].obs;
  final selectedStatus = 'all'.obs;
  final searchQuery = ''.obs;

  final statusFilters = [
    'all', 'pending', 'admin_confirmed', 'sent_to_vendor',
    'vendor_accepted', 'preparing', 'ready_for_pickup',
    'out_for_delivery', 'delivered', 'cancelled'
  ];

  @override
  void onInit() {
    super.onInit();
    // Accept initial filter from route arguments
    final args = Get.arguments;
    if (args is Map && args['filter'] != null) {
      selectedStatus.value = args['filter'] as String;
    }
    ever(selectedStatus, (_) => fetchOrders());
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    isLoading.value = true;
    try {
      String url;
      Map<String, String>? params;
      if (selectedStatus.value == 'all') {
        url = ApiEndpoints.saOrdersGetAll;
      } else {
        url = ApiEndpoints.saOrdersGetByStatus;
        params = {'status': selectedStatus.value};
      }
      final res = await ApiProvider.get(url, queryParams: params);
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

  Future<void> cancelOrder(String orderId, String reason) async {
    final res = await ApiProvider.post(ApiEndpoints.saOrdersCancel,
        body: {'order_id': orderId, 'reason': reason});
    if (res.success) {
      fetchOrders();
      Get.snackbar('Cancelled'.tr, 'Order cancelled'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
    } else {
      Get.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
    }
  }
}
