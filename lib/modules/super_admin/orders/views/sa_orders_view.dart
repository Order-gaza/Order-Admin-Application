import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/constants/app_constants.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/order_status_badge.dart';
import '../controllers/sa_orders_controller.dart';

class SaOrdersView extends GetView<SaOrdersController> {
  const SaOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SaOrdersController());
    final currFmt = NumberFormat.currency(symbol: '₪', decimalDigits: 2);

    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        title: Text('All Orders'.tr),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: controller.fetchOrders),
        ],
      ),
      drawer: const AppDrawer(currentRoute: AppRoutes.saOrders),
      body: Column(
        children: [
          // ── Search ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              onChanged: (v) => controller.searchQuery.value = v,
              decoration: InputDecoration(
                hintText: 'Search order # or customer...'.tr,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          // ── Status filter chips ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Obx(() => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: controller.statusFilters.map((f) {
                      final selected = controller.selectedStatus.value == f;
                      final label = f == 'all'
                          ? 'All'.tr
                          : AppConstants.orderStatusLabel(f);
                      return GestureDetector(
                        onTap: () => controller.selectedStatus.value = f,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primaryOrange
                                : AppColors.darkSurface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primaryOrange
                                  : AppColors.divider,
                            ),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: selected
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
                      Icon(Icons.receipt_long,
                          size: 64,
                          color: Colors.white.withValues(alpha: 0.2)),
                      const SizedBox(height: 12),
                      Text('No orders found'.tr,
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
                  itemBuilder: (_, i) => _orderCard(list[i], currFmt),
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
    final canCancel = status != AppConstants.orderDelivered &&
        status != AppConstants.orderCancelled;

    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.saOrderDetail, arguments: {
        'order_id': order['id']?.toString() ?? '',
        'order_number': order['order_number'] ?? '',
      }),
      child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.3)),
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
                    Text(
                      order['order_number'] ?? '',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15),
                    ),
                    Text(
                      order['customer_name'] ?? '',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              OrderStatusBadge(status: status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _infoChip(Icons.payments_outlined,
                  fmt.format(double.tryParse(
                          order['total_amount']?.toString() ?? '0') ??
                      0),
                  AppColors.primaryOrange),
              const SizedBox(width: 8),
              _infoChip(
                  Icons.payment,
                  order['payment_method'] == 'cash_on_delivery'
                      ? 'Cash'.tr
                      : 'Bank'.tr,
                  AppColors.info),
              const Spacer(),
              if (canCancel)
                TextButton.icon(
                  onPressed: () => _showCancelDialog(order['id']),
                  icon: const Icon(Icons.cancel_outlined,
                      size: 16, color: AppColors.error),
                  label: Text('Cancel'.tr,
                      style: const TextStyle(color: AppColors.error, fontSize: 12)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
          if (order['created_at'] != null) ...[
            const SizedBox(height: 8),
            Text(
              order['created_at'],
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11),
            ),
          ],
        ],
      ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showCancelDialog(String orderId) {
    final reasonCtrl = TextEditingController();
    Get.dialog(AlertDialog(
      backgroundColor: AppColors.darkSurface,
      title:
          Text('Cancel Order'.tr, style: const TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Please provide a cancellation reason:'.tr,
              style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          TextField(
            controller: reasonCtrl,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(hintText: 'Reason...'.tr),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: Text('Cancel'.tr)),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          onPressed: () {
            Get.back();
            controller.cancelOrder(orderId, reasonCtrl.text);
          },
          child: Text('Confirm Cancel'.tr),
        ),
      ],
    ));
  }
}
