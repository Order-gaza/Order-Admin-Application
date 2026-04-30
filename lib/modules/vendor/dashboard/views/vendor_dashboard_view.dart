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
import '../controllers/vendor_dashboard_controller.dart';

class VendorDashboardView extends GetView<VendorDashboardController> {
  const VendorDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '₪', decimalDigits: 2);
    final userName = ApiProvider.storedUserName ?? 'Vendor';

    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        title: Text('Vendor Dashboard'.tr),
        actions: [
          const NotificationBell(),
          IconButton(icon: const Icon(Icons.refresh), onPressed: controller.fetchAll),
        ],
      ),
      drawer: const AppDrawer(currentRoute: AppRoutes.vendorDashboard),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryOrange));
        }
        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                  const SizedBox(height: 16),
                  Text(controller.error.value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.error, fontSize: 14)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: controller.fetchAll,
                    icon: const Icon(Icons.refresh),
                    label: Text('Retry'.tr),
                  ),
                ],
              ),
            ),
          );
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

                // ── Incoming orders alert ──
                Obx(() => controller.pendingOrders.value > 0
                    ? GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.vendorOrders),
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
                              const Icon(Icons.delivery_dining, color: AppColors.primaryOrange),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text('${controller.pendingOrders.value} ${'new incoming orders!'.tr}',
                                    style: const TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.w600)),
                              ),
                              Text('View →'.tr, style: const TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink()),

                // ── Revenue Banner (from delivered orders only) ──
                Obx(() => Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
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
                                      'Net Revenue'.tr,
                                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                                    ),
                                    Text(
                                      fmt.format(controller.netRevenue.value),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${'Today'.tr}: ${fmt.format(controller.todayNetRevenue.value)}',
                                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.account_balance_wallet, color: Colors.white38, size: 56),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(height: 1, color: Colors.white.withValues(alpha: 0.2)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _revenueChip(
                                  Icons.monetization_on,
                                  'Gross Revenue'.tr,
                                  fmt.format(controller.grossRevenue.value),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _revenueChip(
                                  Icons.percent,
                                  'Commission (${controller.commissionRate.value.toStringAsFixed(0)}%)',
                                  fmt.format(controller.totalCommissionPaid.value),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )),

                // ── Today ──
                Text('Today'.tr, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: StatCard(
                      title: 'Orders'.tr,
                      value: '${controller.todayOrders.value}',
                      onTap: () => Get.toNamed(AppRoutes.vendorOrders),
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: StatCard(
                      title: 'Gross'.tr,
                      value: fmt.format(controller.todayGrossRevenue.value),
                      onTap: () => Get.toNamed(AppRoutes.vendorOrders),
                    )),
                  ],
                ),
                const SizedBox(height: 24),

                // ── All-time ──
                Text('All Time'.tr, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
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
                      title: 'Total Orders'.tr,
                      value: '${controller.totalOrders.value}',
                      onTap: () => Get.toNamed(AppRoutes.vendorOrders),
                    ),
                    StatCard(
                      title: 'Net Revenue'.tr,
                      value: fmt.format(controller.netRevenue.value),
                      ),
                    StatCard(
                      title: 'Delivered'.tr,
                      value: '${controller.deliveredOrders.value}',
                      onTap: () => Get.toNamed(AppRoutes.vendorOrders),
                    ),
                    StatCard(
                      title: 'Active Items'.tr,
                      value: '${controller.activeMenuItems.value}',
                      onTap: () => Get.toNamed(AppRoutes.vendorMenu),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Live order pipeline ──
                GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.vendorOrders),
                  child: Text('Live Pipeline'.tr, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 12),
                _pipeline(),
                const SizedBox(height: 24),

                // ── Recent orders ──
                if (controller.recentOrders.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Recent Orders'.tr, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                      TextButton(
                        onPressed: () => Get.toNamed(AppRoutes.vendorOrders),
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

  Widget _revenueChip(IconData icon, String label, String value) {
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

  Widget _pipeline() {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.vendorOrders),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(14)),
        child: Obx(() {
          final stages = [
            {'label': 'Incoming'.tr, 'value': controller.pendingOrders.value, 'color': AppColors.primaryOrange},
            {'label': 'Preparing'.tr, 'value': controller.preparingOrders.value, 'color': AppColors.statusPreparing},
            {'label': 'Ready'.tr, 'value': controller.readyOrders.value, 'color': AppColors.statusReady},
            {'label': 'Delivered'.tr, 'value': controller.deliveredOrders.value, 'color': AppColors.success},
          ];
          return Row(
            children: stages.asMap().entries.map((e) {
              final s = e.value;
              final isLast = e.key == stages.length - 1;
              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text('${s['value']}', style: TextStyle(color: s['color'] as Color, fontSize: 20, fontWeight: FontWeight.bold)),
                          Text(s['label'] as String, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                        ],
                      ),
                    ),
                    if (!isLast) const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.textSecondary),
                  ],
                ),
              );
            }).toList(),
          );
        }),
      ),
    );
  }

  Widget _orderTile(Map<String, dynamic> o, NumberFormat fmt) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.vendorOrderDetail, arguments: {
        'order_id': o['order_id']?.toString() ?? o['id']?.toString() ?? '',
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
            Expanded(child: Text(o['order_number'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
            OrderStatusBadge(status: o['status'] ?? AppConstants.orderSentToVendor),
            const SizedBox(width: 8),
            Text(fmt.format(double.tryParse(o['total_amount']?.toString() ?? '0') ?? 0),
                style: const TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.w600, fontSize: 13)),
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
