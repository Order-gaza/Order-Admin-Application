import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/constants/app_constants.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/order_status_badge.dart';
import '../controllers/admin_orders_controller.dart';

class AdminOrdersView extends GetView<AdminOrdersController> {
  const AdminOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AdminOrdersController());
    final fmt = NumberFormat.currency(symbol: '₪', decimalDigits: 2);

    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        title: Text('Orders'.tr),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: controller.fetchOrders),
        ],
      ),
      drawer: const AppDrawer(currentRoute: AppRoutes.adminOrders),
      body: Column(
        children: [
          // ── Search ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              onChanged: (v) => controller.searchQuery.value = v,
              decoration: InputDecoration(
                hintText: 'Search orders...'.tr,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          // ── Filter chips ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Obx(() => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: controller.statusFilters.map((f) {
                      final sel = controller.selectedStatus.value == f;
                      return GestureDetector(
                        onTap: () => controller.selectedStatus.value = f,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: sel
                                ? AppColors.primaryOrange
                                : AppColors.darkSurface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: sel
                                    ? AppColors.primaryOrange
                                    : AppColors.divider),
                          ),
                          child: Text(
                            AppConstants.orderStatusLabel(f),
                            style: TextStyle(
                              color: sel
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: sel
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                )),
          ),
          // ── List ──
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryOrange));
              }
              final list = controller.filtered;
              if (list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inbox,
                          size: 64,
                          color: Colors.white.withValues(alpha: 0.2)),
                      const SizedBox(height: 12),
                      Text('No orders'.tr,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4))),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                color: AppColors.primaryOrange,
                onRefresh: controller.fetchOrders,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _orderCard(list[i], fmt),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _orderCard(Map<String, dynamic> order, NumberFormat fmt) {
    final status = order['status'] ?? '';
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.adminOrderDetail, arguments: {
        'order_id': order['id']?.toString() ?? '',
        'order_number': order['order_number'] ?? '',
      }),
      child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.divider.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order['order_number'] ?? '',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15)),
                    Text(order['customer_name'] ?? '',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13)),
                    if (order['delivery_city'] != null && order['delivery_city'].toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          '${order['delivery_neighborhood'] ?? ''}, ${order['delivery_city']}',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 11),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  OrderStatusBadge(status: status),
                  if (order['delivery_zone_from'] != null && order['delivery_zone_to'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${_zoneAr(order['delivery_zone_from'])} → ${_zoneAr(order['delivery_zone_to'])}',
                          style: const TextStyle(
                            color: AppColors.info,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                fmt.format(double.tryParse(
                        order['total_amount']?.toString() ?? '0') ??
                    0),
                style: const TextStyle(
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.w600,
                    fontSize: 14),
              ),
              const Spacer(),
              ..._actionButtons(order),
            ],
          ),
        ],
      ),
      ),
    );
  }

  List<Widget> _actionButtons(Map<String, dynamic> order) {
    final status = order['status'] ?? '';
    final id = order['id'] ?? '';

    if (status == AppConstants.orderPending) {
      return [
        _actionBtn('Confirm'.tr, AppColors.success,
            () => controller.confirmOrder(id)),
        const SizedBox(width: 8),
        _actionBtn('Cancel'.tr, AppColors.error, () => _cancel(id)),
      ];
    }
    if (status == AppConstants.orderReadyForPickup) {
      return [
        _actionBtn('Dispatch'.tr, AppColors.info,
            () => controller.dispatchOrder(id)),
      ];
    }
    if (status == AppConstants.orderOutForDelivery) {
      return [
        _actionBtn('Delivered'.tr, AppColors.success,
            () => controller.deliverOrder(id)),
      ];
    }
    return [];
  }

  Widget _actionBtn(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Text(label,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _cancel(String id) {
    final ctrl = TextEditingController();
    Get.dialog(AlertDialog(
      backgroundColor: AppColors.darkSurface,
      title:
          Text('Cancel Order'.tr, style: const TextStyle(color: Colors.white)),
      content: TextField(
        controller: ctrl,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(hintText: 'Cancellation reason...'.tr),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: Text('Back'.tr)),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          onPressed: () {
            Get.back();
            controller.cancelOrder(id, ctrl.text);
          },
          child: Text('Cancel Order'.tr),
        ),
      ],
    ));
  }

  String _zoneAr(String? zone) {
    switch (zone) {
      case 'north': return 'الشمال';
      case 'central': return 'الوسطى';
      case 'south': return 'الجنوب';
      default: return zone ?? '';
    }
  }
}
