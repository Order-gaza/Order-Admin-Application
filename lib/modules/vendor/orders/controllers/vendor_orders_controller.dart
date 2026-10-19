import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/api_provider.dart';
import '../../../../app/constants/api_endpoints.dart';
import '../../../../shared/localization/app_translations.dart';
import '../../../../shared/utils/app_navigator.dart';

final vendorOrdersProvider = ChangeNotifierProvider<VendorOrdersController>((ref) {
  return VendorOrdersController.to;
});

class VendorOrdersController extends ChangeNotifier {
  static VendorOrdersController? _instance;
  static VendorOrdersController get to => _instance ??= VendorOrdersController();

  bool isLoading = false;
  List<Map<String, dynamic>> pendingOrders = [];
  List<Map<String, dynamic>> allOrders = [];
  String error = '';

  VendorOrdersController() {
    fetchAll();
  }

  Future<void> fetchAll() async {
    isLoading = true;
    error = '';
    notifyListeners();

    try {
      final pendRes =
          await ApiProvider.get(ApiEndpoints.vendorOrdersGetPending);
      if (pendRes.success && pendRes.data != null) {
        final data = pendRes.data;
        if (data is List) {
          pendingOrders = List<Map<String, dynamic>>.from(data);
        } else if (data is Map<String, dynamic>) {
          pendingOrders =
              List<Map<String, dynamic>>.from(data['orders'] as List? ?? []);
        }
      }
      final allRes = await ApiProvider.get(ApiEndpoints.vendorOrdersGetAll);
      if (allRes.success && allRes.data != null) {
        final data = allRes.data;
        if (data is List) {
          allOrders = List<Map<String, dynamic>>.from(data);
        } else if (data is Map<String, dynamic>) {
          allOrders =
              List<Map<String, dynamic>>.from(data['orders'] as List? ?? []);
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[VendorOrders] Error: $e');
      error = 'Error loading orders: $e';
    } finally {
      isLoading = false;
      notifyListeners();
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
      AppNavigator.snackbar('Success'.tr, msg,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF));
    } else {
      AppNavigator.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
    }
  }
}
