import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/providers/api_provider.dart';
import '../../../../app/constants/api_endpoints.dart';

class VendorOrdersController extends GetxController {
  final isLoading = false.obs;
  final pendingOrders = <Map<String, dynamic>>[].obs;
  final allOrders = <Map<String, dynamic>>[].obs;
  final error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchAll() async {
    isLoading.value = true;
    error.value = '';
    try {
      final pendRes =
          await ApiProvider.get(ApiEndpoints.vendorOrdersGetPending);
      if (pendRes.success && pendRes.data != null) {
        final data = pendRes.data;
        if (data is List) {
          pendingOrders.value =
              List<Map<String, dynamic>>.from(data);
        } else if (data is Map<String, dynamic>) {
          pendingOrders.value =
              List<Map<String, dynamic>>.from(data['orders'] as List? ?? []);
        }
      }
      final allRes = await ApiProvider.get(ApiEndpoints.vendorOrdersGetAll);
      if (allRes.success && allRes.data != null) {
        final data = allRes.data;
        if (data is List) {
          allOrders.value =
              List<Map<String, dynamic>>.from(data);
        } else if (data is Map<String, dynamic>) {
          allOrders.value =
              List<Map<String, dynamic>>.from(data['orders'] as List? ?? []);
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[VendorOrders] Error: $e');
      error.value = 'Error loading orders: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> acceptOrder(String orderId) async {
    final res = await ApiProvider.post(ApiEndpoints.vendorOrdersAccept,
        body: {'order_id': orderId});
    _handle(res, 'Order accepted!');
  }

  Future<void> markPreparing(String orderId) async {
    final res = await ApiProvider.post(ApiEndpoints.vendorOrdersPreparing,
        body: {'order_id': orderId});
    _handle(res, 'Order is now being prepared');
  }

  Future<void> markReady(String orderId) async {
    final res = await ApiProvider.post(ApiEndpoints.vendorOrdersReady,
        body: {'order_id': orderId});
    _handle(res, 'Order is ready for pickup!');
  }

  void _handle(dynamic res, String msg) {
    if (res.success) {
      fetchAll();
      Get.snackbar('Success'.tr, msg,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF));
    } else {
      Get.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
    }
  }
}
