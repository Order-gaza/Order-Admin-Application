import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/constants/app_constants.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../shared/localization/app_translations.dart';
import '../../../../shared/utils/app_navigator.dart';
import '../../../../shared/widgets/order_status_badge.dart';
import '../controllers/vendor_orders_controller.dart';

class VendorOrdersView extends ConsumerWidget {
  const VendorOrdersView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(vendorOrdersProvider);
    final fmt = NumberFormat.currency(symbol: '₪', decimalDigits: 2);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldDark,
        appBar: AppBar(
          title: Text('Orders'.tr),
          bottom: TabBar(
            labelColor: AppColors.primaryOrange,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primaryOrange,
            tabs: [
              Tab(text: 'Incoming'.tr),
              Tab(text: 'All Orders'.tr),
            ],
          ),
          actions: [
            IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: controller.fetchAll),
          ],
        ),
        body: TabBarView(
          children: [
            // ── Tab 1: Incoming (pending) orders ──
            Builder(builder: (context) {
              if (controller.isLoading) {
                return const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryOrange));
              }
              final list = controller.pendingOrders;
              if (list.isEmpty) {
                return _emptyState('No incoming orders'.tr,
                    Icons.delivery_dining);
              }
              return RefreshIndicator(
                color: AppColors.primaryOrange,
                onRefresh: controller.fetchAll,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) =>
                      _incomingCard(list[i], fmt, controller),
                ),
              );
            }),
            // ── Tab 2: All orders history ──
            Builder(builder: (context) {
              final list = controller.allOrders;
              if (list.isEmpty) {
                return _emptyState('No orders yet'.tr, Icons.receipt_long);
              }
              return RefreshIndicator(
                color: AppColors.primaryOrange,
                onRefresh: controller.fetchAll,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _historyCard(list[i], fmt),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _incomingCard(Map<String, dynamic> order, NumberFormat fmt, VendorOrdersController controller) {
    final status = order['status'] ?? '';
    final id = order['id'] ?? '';
    return GestureDetector(
      onTap: () => AppNavigator.toNamed(AppRoutes.vendorOrderDetail, arguments: {
        'order_id': id.toString(),
        'order_number': order['order_number'] ?? '',
      }),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppColors.primaryOrange.withValues(alpha: 0.3)),
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
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                      Text(
                        fmt.format(double.tryParse(
                                order['total_amount']?.toString() ?? '0') ??
                            0),
                        style: const TextStyle(
                            color: AppColors.primaryOrange,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                OrderStatusBadge(status: status),
              ],
            ),
            if (order['customer_notes'] != null &&
                (order['customer_notes'] as String).isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.goldenYellow.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.note,
                        size: 14, color: AppColors.goldenYellow),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(order['customer_notes'],
                          style: const TextStyle(
                              color: AppColors.goldenYellow, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            // Action buttons row
            Row(
              children: [
                if (status == AppConstants.orderSentToVendor)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => controller.acceptOrder(id),
                      child: Text('Accept'.tr),
                    ),
                  ),
                if (status == AppConstants.orderVendorAccepted)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => controller.markPreparing(id),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.statusPreparing),
                      child: Text('Start Preparing'.tr),
                    ),
                  ),
                if (status == AppConstants.orderPreparing)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => controller.markReady(id),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.statusReady),
                      child: Text('Mark Ready'.tr),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _historyCard(Map<String, dynamic> order, NumberFormat fmt) {
    return GestureDetector(
      onTap: () => AppNavigator.toNamed(AppRoutes.vendorOrderDetail, arguments: {
        'order_id': order['id']?.toString() ?? '',
        'order_number': order['order_number'] ?? '',
      }),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: AppColors.divider.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order['order_number'] ?? '',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600)),
                  Text(
                    fmt.format(double.tryParse(
                            order['total_amount']?.toString() ?? '0') ??
                        0),
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
            OrderStatusBadge(status: order['status'] ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(String msg, IconData icon) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: Colors.white.withValues(alpha: 0.2)),
          const SizedBox(height: 12),
          Text(msg,
              style:
                  TextStyle(color: Colors.white.withValues(alpha: 0.4))),
        ],
      ),
    );
  }
}
