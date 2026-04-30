import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/providers/api_provider.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/constants/app_constants.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/stat_card.dart';
import '../../../../shared/widgets/order_status_badge.dart';
import '../../../../shared/widgets/notification_bell.dart';
import '../controllers/admin_dashboard_controller.dart';

class AdminDashboardView extends GetView<AdminDashboardController> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AdminDashboardController());
    final fmt = NumberFormat.currency(symbol: '₪', decimalDigits: 2);
    final userName = ApiProvider.storedUserName ?? 'Admin';

    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        title: Text('Admin Dashboard'.tr),
        actions: [
          const NotificationBell(),
          IconButton(icon: const Icon(Icons.refresh), onPressed: controller.fetchAll),
        ],
      ),
      drawer: const AppDrawer(currentRoute: AppRoutes.adminDashboard),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryOrange));
        }
        return RefreshIndicator(
          color: AppColors.primaryOrange,
          onRefresh: controller.fetchAll,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Greeting ──
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good '.tr + _greeting() + ',',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                          Text(
                            userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Pending orders alert ──
                Obx(() => controller.pendingOrders.value > 0
                    ? GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.adminOrders),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppColors.primaryOrange.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primaryOrange.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.notification_important, color: AppColors.primaryOrange),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '${controller.pendingOrders.value} ${'orders waiting for confirmation!'.tr}',
                                  style: const TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.w600),
                                ),
                              ),
                              Text('View →'.tr, style: const TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink()),

                // ── Delivery Profit Banner (from delivered orders only) ──
                Obx(() => Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
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
                                      'Delivery Profit'.tr,
                                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                                    ),
                                    Text(
                                      fmt.format(controller.totalDeliveryEarnings.value),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${'Today'.tr}: ${fmt.format(controller.todayDeliveryEarnings.value)}',
                                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.delivery_dining, color: Colors.white38, size: 56),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(height: 1, color: Colors.white.withValues(alpha: 0.2)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _profitChip(
                                  Icons.account_balance,
                                  'SA Owed'.tr,
                                  fmt.format(controller.saOwed.value),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _profitChip(
                                  Icons.payments,
                                  'Paid to Vendors'.tr,
                                  fmt.format(controller.totalPaidToVendors.value),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )),

                // ── Today stats ──
                Text('Today'.tr, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                  children: [
                    StatCard(
                      title: 'Orders Today'.tr,
                      value: '${controller.todayOrders.value}',
                      onTap: () => Get.toNamed(AppRoutes.adminOrders),
                    ),
                    StatCard(
                      title: 'Revenue Today'.tr,
                      value: fmt.format(controller.todayRevenue.value),
                      onTap: () => Get.toNamed(AppRoutes.adminOrders),
                    ),
                    StatCard(
                      title: 'Delivered'.tr,
                      value: '${controller.todayDelivered.value}',
                      onTap: () => Get.toNamed(AppRoutes.adminOrders),
                    ),
                    StatCard(
                      title: 'Cancelled'.tr,
                      value: '${controller.todayCancelled.value}',
                      onTap: () => Get.toNamed(AppRoutes.adminOrders),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Orders by status ──
                Text('Orders by Status'.tr, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Obx(() {
                  final map = controller.ordersByStatus;
                  if (map.isEmpty) return const SizedBox.shrink();
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(14)),
                    child: Column(
                      children: map.entries.map((e) => GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.adminOrders),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(AppConstants.orderStatusLabel(e.key),
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                              ),
                              OrderStatusBadge(status: e.key),
                              const SizedBox(width: 12),
                              Text('${e.value}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                            ],
                          ),
                        ),
                      )).toList(),
                    ),
                  );
                }),
                const SizedBox(height: 24),

                // ── Recent orders ──
                if (controller.recentOrders.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Recent Orders'.tr, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                      TextButton(
                        onPressed: () => Get.toNamed(AppRoutes.adminOrders),
                        child: Text('View All'.tr),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...controller.recentOrders.map((o) => _orderTile(o, fmt)),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _profitChip(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(color: Colors.white60, fontSize: 10)),
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderTile(Map<String, dynamic> o, NumberFormat fmt) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.adminOrderDetail, arguments: {
        'order_id': o['id']?.toString() ?? o['order_id']?.toString() ?? '',
        'order_number': o['order_number'] ?? '',
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.divider.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(o['order_number'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  Text(o['customer_name'] ?? '', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                OrderStatusBadge(status: o['status'] ?? ''),
                const SizedBox(height: 4),
                Text(fmt.format(double.tryParse(o['total_amount']?.toString() ?? '0') ?? 0),
                    style: const TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'morning'.tr;
    if (h < 17) return 'afternoon'.tr;
    return 'evening'.tr;
  }
}
