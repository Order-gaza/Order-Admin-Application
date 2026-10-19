import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/api_provider.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../shared/localization/app_translations.dart';
import '../../../../shared/utils/app_navigator.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';
import '../../../../shared/widgets/responsive_content.dart';
import '../../../../shared/widgets/stat_card.dart';
import '../../../../shared/widgets/order_status_badge.dart';
import '../../../../shared/widgets/notification_bell.dart';
import '../controllers/sa_dashboard_controller.dart';

class SaDashboardView extends ConsumerWidget {
  const SaDashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(saDashboardProvider);
    final currFmt = NumberFormat.currency(symbol: '₪', decimalDigits: 2);
    final userName = ApiProvider.storedUserName ?? 'Super Admin';

    return ResponsiveScaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        title: Text('Super Admin'.tr),
        actions: [
          const NotificationBell(),
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: controller.fetchDashboard,
          ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: AppRoutes.saDashboard),
      body: Builder(builder: (context) {
        if (controller.isLoading && controller.recentOrders.isEmpty) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange));
        }
        return RefreshIndicator(
          color: AppColors.primaryOrange,
          onRefresh: controller.fetchDashboard,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ResponsiveContent(
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
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color:
                                AppColors.primaryOrange.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        DateFormat('dd MMM yyyy').format(DateTime.now()),
                        style: const TextStyle(
                            color: AppColors.primaryOrange, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Stats Grid ──
                LayoutBuilder(
                  builder: (ctx, _) {
                    final w = MediaQuery.of(ctx).size.width;
                    final cols = w > 1400 ? 4 : (w > 900 ? 3 : 2);
                    final ratio = w > 1400 ? 1.6 : (w > 900 ? 1.4 : 1.25);
                    return GridView.count(
                      crossAxisCount: cols,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: ratio,
                      children: [
                        StatCard(title: 'Total Orders'.tr, value: '${controller.totalOrders}', onTap: () => AppNavigator.toNamed(AppRoutes.saOrders)),
                        StatCard(title: 'Pending Orders'.tr, value: '${controller.pendingOrders}', onTap: () => AppNavigator.toNamed(AppRoutes.saOrders)),
                        StatCard(title: 'All Vendors'.tr, value: '${controller.totalVendors}', onTap: () => AppNavigator.toNamed(AppRoutes.saVendors)),
                        StatCard(title: 'Pending Approval'.tr, value: '${controller.pendingVendors}', onTap: () => AppNavigator.toNamed(AppRoutes.saVendors)),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),

                // ── SA Revenue Banner (from delivered orders only) ──
                GestureDetector(
                  onTap: () => AppNavigator.toNamed(AppRoutes.saEarnings),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.primaryOrange,
                          AppColors.darkOrange
                        ],
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
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'My Total Earnings'.tr,
                                    style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13),
                                  ),
                                  Text(
                                    currFmt.format(
                                        controller.saTotalEarnings),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${'Today'.tr}: ${currFmt.format(controller.saTodayEarnings)}',
                                    style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.account_balance_wallet,
                                color: Colors.white38, size: 56),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 1,
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _earningChip(
                                Icons.receipt_long,
                                'Service Fees'.tr,
                                currFmt.format(
                                    controller.totalServiceFees),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _earningChip(
                                Icons.percent,
                                'Commissions'.tr,
                                currFmt.format(
                                    controller.totalCommissions),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _earningChip(
                                Icons.check_circle_outline,
                                'Collected'.tr,
                                currFmt
                                    .format(controller.saCollected),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _earningChip(
                                Icons.hourglass_bottom,
                                'Uncollected'.tr,
                                currFmt
                                    .format(controller.saUncollected),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Quick Actions ──
                Text(
                  'Quick Actions'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _quickAction(Icons.admin_panel_settings, 'Admins'.tr,
                          AppColors.info, () => AppNavigator.toNamed(AppRoutes.saAdmins)),
                      _quickAction(Icons.store, 'Vendors'.tr, AppColors.success,
                          () => AppNavigator.toNamed(AppRoutes.saVendors)),
                      _quickAction(Icons.campaign, 'Ads'.tr,
                          AppColors.goldenYellow,
                          () => AppNavigator.toNamed(AppRoutes.saAds)),
                      _quickAction(Icons.tune, 'Fees'.tr, AppColors.warning,
                          () => AppNavigator.toNamed(AppRoutes.saFeeConfig)),
                      _quickAction(
                          Icons.map,
                          'Zones'.tr,
                          AppColors.statusPreparing,
                          () => AppNavigator.toNamed(AppRoutes.saDeliveryZones)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Recent Orders ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Orders'.tr,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    TextButton(
                      onPressed: () => AppNavigator.toNamed(AppRoutes.saOrders),
                      child: Text('View All'.tr),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (controller.recentOrders.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.divider.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long,
                            size: 48,
                            color: Colors.white.withValues(alpha: 0.2)),
                        const SizedBox(height: 12),
                        Text(
                          'No recent orders'.tr,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4)),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.recentOrders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final o = controller.recentOrders[i];
                      return _orderCard(o, currFmt);
                    },
                  ),
                const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _earningChip(IconData icon, String label, String value) {
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
                    style: const TextStyle(
                        color: Colors.white60, fontSize: 10)),
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

  Widget _quickAction(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _orderCard(Map<String, dynamic> order, NumberFormat fmt) {
    return GestureDetector(
      onTap: () => AppNavigator.toNamed(AppRoutes.saOrderDetail, arguments: {
        'order_id': order['id']?.toString() ?? order['order_id']?.toString() ?? '',
        'order_number': order['order_number'] ?? '',
      }),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.receipt_outlined,
                color: AppColors.primaryOrange, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order['order_number'] ?? '',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14),
                  ),
                  Text(
                    order['customer_name'] ?? '',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                OrderStatusBadge(status: order['status'] ?? ''),
                const SizedBox(height: 4),
                Text(
                  fmt.format(
                      double.tryParse(
                              order['total_amount']?.toString() ?? '0') ??
                          0),
                  style: const TextStyle(
                      color: AppColors.primaryOrange,
                      fontWeight: FontWeight.w600,
                      fontSize: 13),
                ),
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
