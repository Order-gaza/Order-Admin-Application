import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../shared/localization/app_translations.dart';
import '../../../../shared/utils/app_navigator.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../controllers/sa_customers_controller.dart';

class SaCustomersView extends ConsumerWidget {
  const SaCustomersView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(saCustomersProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        title: Text('Manage Customers'.tr),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: controller.fetchCustomers),
        ],
      ),
      drawer: const AppDrawer(currentRoute: AppRoutes.saCustomers),
      body: Column(
        children: [
          // ── Search + Stats Bar ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  onChanged: (v) => controller.setSearchQuery(v),
                  decoration: InputDecoration(
                    hintText: 'Search customers...'.tr,
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 12),
                // Stats row
                Row(
                  children: [
                    _statChip(
                      'Total'.tr,
                      controller.customers.length.toString(),
                      AppColors.primaryOrange,
                    ),
                    const SizedBox(width: 8),
                    _statChip(
                      'Active'.tr,
                      controller.customers
                          .where((c) =>
                              c['is_active'] == true ||
                              c['is_active'] == 1)
                          .length
                          .toString(),
                      AppColors.success,
                    ),
                    const SizedBox(width: 8),
                    _statChip(
                      'Inactive'.tr,
                      controller.customers
                          .where((c) =>
                              c['is_active'] == false ||
                              c['is_active'] == 0)
                          .length
                          .toString(),
                      AppColors.error,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ── List ──
          Expanded(
            child: Builder(builder: (_) {
              if (controller.isLoading) {
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
                      Icon(Icons.people_outline,
                          size: 64,
                          color: Colors.white.withValues(alpha: 0.2)),
                      const SizedBox(height: 12),
                      Text('No customers found'.tr,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4))),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                color: AppColors.primaryOrange,
                onRefresh: controller.fetchCustomers,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _customerCard(context, controller, list[i]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _statChip(String label, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(count,
                style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    color: color.withValues(alpha: 0.8), fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _customerCard(BuildContext context, SaCustomersController controller, Map<String, dynamic> customer) {
    final isActive =
        customer['is_active'] == true || customer['is_active'] == 1;
    final orderCount = customer['order_count'] ?? 0;

    return Material(
      color: AppColors.cardDark,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => AppNavigator.toNamed(AppRoutes.saCustomerDetail, arguments: {
          'customer_id': customer['id'],
          'customer_name': customer['name'] ?? 'Customer',
        }),
        child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: AppColors.divider.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isActive
                      ? [AppColors.primaryOrange, AppColors.darkOrange]
                      : [AppColors.textSecondary, const Color(0xFF555555)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  (customer['name'] ?? 'C')[0].toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(customer['name'] ?? '',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15)),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.email_outlined,
                          size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(customer['email'] ?? '',
                            style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.shopping_bag_outlined,
                          size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text('$orderCount ' + 'orders'.tr,
                          style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12)),
                      if (customer['phone'] != null &&
                          customer['phone'].toString().isNotEmpty) ...[
                        const SizedBox(width: 12),
                        const Icon(Icons.phone_outlined,
                            size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(customer['phone'],
                            style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Status + Actions
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isActive ? AppColors.success : AppColors.error)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isActive ? 'Active'.tr : 'Inactive'.tr,
                    style: TextStyle(
                        color:
                            isActive ? AppColors.success : AppColors.error,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => controller.toggleStatus(customer['id']),
                      icon: Icon(
                        isActive ? Icons.pause_circle : Icons.play_circle,
                        color: isActive ? AppColors.warning : AppColors.success,
                        size: 22,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      visualDensity: VisualDensity.compact,
                      splashRadius: 18,
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      onPressed: () => _confirmDelete(context, controller, customer),
                      icon: const Icon(Icons.delete_outline,
                          color: AppColors.error, size: 22),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      visualDensity: VisualDensity.compact,
                      splashRadius: 18,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, SaCustomersController controller, Map<String, dynamic> customer) {
    final orderCount = customer['order_count'] ?? 0;
    AppNavigator.dialog(AlertDialog(
      backgroundColor: AppColors.darkSurface,
      title:
          Text('Delete Customer'.tr, style: const TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Are you sure you want to delete "%s"?'.tr.replaceFirst('%s', customer['name'] ?? ''),
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          if (orderCount > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: AppColors.warning, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This customer has '.tr + '$orderCount ' + 'order(s). The account will be deactivated instead of deleted to preserve order history.'.tr,
                      style: const TextStyle(
                          color: AppColors.warning, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => AppNavigator.back(), child: Text('Cancel'.tr)),
        ElevatedButton(
          style:
              ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          onPressed: () {
            AppNavigator.back();
            controller.deleteCustomer(customer['id']);
          },
          child: Text(orderCount > 0 ? 'Deactivate'.tr : 'Delete'.tr),
        ),
      ],
    ));
  }
}
