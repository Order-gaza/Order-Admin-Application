import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../controllers/sa_earnings_controller.dart';

class SaEarningsView extends GetView<SaEarningsController> {
  const SaEarningsView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SaEarningsController());
    final fmt = NumberFormat.currency(symbol: '₪', decimalDigits: 2);
    final dateFmt = DateFormat('dd MMM yyyy');

    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        title: Text('Earnings'.tr),
        actions: [
          Obx(() => controller.fromDate.value != null
              ? IconButton(
                  icon: const Icon(Icons.close, color: AppColors.error),
                  tooltip: 'Clear Filter'.tr,
                  onPressed: controller.clearDateFilter,
                )
              : const SizedBox.shrink()),
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () => controller.pickDateRange(context),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Download PDF Report'.tr,
            onPressed: () => controller.downloadReport(),
          ),
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: controller.fetchAll),
          IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Collect All'.tr,
              onPressed: () {
                Get.dialog(AlertDialog(
                  backgroundColor: AppColors.darkSurface,
                  title: Text('Collect All'.tr,
                      style: const TextStyle(color: Colors.white)),
                  content: Text(
                      'Mark all uncollected earnings as collected?'.tr,
                      style:
                          const TextStyle(color: AppColors.textSecondary)),
                  actions: [
                    TextButton(
                        onPressed: () => Get.back(),
                        child: Text('Cancel'.tr)),
                    ElevatedButton(
                      onPressed: () {
                        Get.back();
                        controller.markBulkCollected();
                      },
                      child: Text('Collect All'.tr),
                    ),
                  ],
                ));
              }),
        ],
      ),
      drawer: const AppDrawer(currentRoute: AppRoutes.saEarnings),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(
                  color: AppColors.primaryOrange));
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
                // Date filter indicator
                Obx(() {
                  if (controller.fromDate.value == null) {
                    return const SizedBox.shrink();
                  }
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.info.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.filter_alt,
                            size: 16, color: AppColors.info),
                        const SizedBox(width: 8),
                        Text(
                          '${dateFmt.format(controller.fromDate.value!)}  →  ${dateFmt.format(controller.toDate.value!)}',
                          style: const TextStyle(
                              color: AppColors.info, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }),

                // ── Summary Cards ──
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                  children: [
                    _summaryCard(
                        'My Total Earnings'.tr,
                        fmt.format(controller.totalSaEarnings.value),
                        Icons.account_balance_wallet,
                        AppColors.primaryOrange),
                    _summaryCard(
                        'This Month'.tr,
                        fmt.format(controller.thisMonthEarnings.value),
                        Icons.calendar_today,
                        AppColors.success),
                    _summaryCard(
                        'Service Fees'.tr,
                        fmt.format(controller.totalServiceFees.value),
                        Icons.receipt_long,
                        AppColors.info),
                    _summaryCard(
                        'Commissions'.tr,
                        fmt.format(controller.totalCommissions.value),
                        Icons.percent,
                        AppColors.goldenYellow),
                  ],
                ),
                const SizedBox(height: 12),

                // ── Collection status row ──
                Row(
                  children: [
                    Expanded(
                      child: _miniStat(
                        'Collected'.tr,
                        fmt.format(controller.totalCollected.value),
                        AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _miniStat(
                        'Uncollected'.tr,
                        fmt.format(controller.totalUncollected.value),
                        AppColors.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _miniStat(
                        'Orders'.tr,
                        '${controller.totalOrders.value}',
                        AppColors.info,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _miniStat(
                        'Avg / Order'.tr,
                        fmt.format(controller.avgPerOrder.value),
                        AppColors.primaryOrange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Per-Vendor Summary ──
                if (controller.vendorSummary.isNotEmpty) ...[
                  Text(
                    'Earnings by Vendor'.tr,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  ...controller.vendorSummary
                      .map((v) => _vendorSummaryCard(v, fmt)),
                  const SizedBox(height: 24),
                ],

                // ── Earnings List ──
                Text(
                  'Earnings Details'.tr,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),

                if (controller.earnings.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.bar_chart,
                            size: 48,
                            color: Colors.white.withValues(alpha: 0.2)),
                        const SizedBox(height: 12),
                        Text('No earnings data'.tr,
                            style: TextStyle(
                                color: Colors.white
                                    .withValues(alpha: 0.4))),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.earnings.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 8),
                    itemBuilder: (_, i) =>
                        _earningRow(controller.earnings[i], fmt, dateFmt),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _summaryCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: AppColors.divider.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              Text(label,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.divider.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _vendorSummaryCard(Map<String, dynamic> v, NumberFormat fmt) {
    final commRate =
        double.tryParse(v['commission_rate']?.toString() ?? '0') ?? 0;
    final totalEarned =
        double.tryParse(v['total_sa_earned']?.toString() ?? '0') ?? 0;
    final uncollected =
        double.tryParse(v['uncollected']?.toString() ?? '0') ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.divider.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.storefront,
                color: AppColors.primaryOrange, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(v['vendor_name'] ?? 'Vendor',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600)),
                Text(
                    'Rate'.tr + ': ${commRate.toStringAsFixed(1)}%',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(fmt.format(totalEarned),
                  style: const TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                      fontSize: 14)),
              if (uncollected > 0)
                Text(
                    '${'Uncollected'.tr}: ${fmt.format(uncollected)}',
                    style: const TextStyle(
                        color: AppColors.warning, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _earningRow(
      Map<String, dynamic> e, NumberFormat fmt, DateFormat dateFmt) {
    final serviceFee =
        double.tryParse(e['service_fee_earned']?.toString() ?? '0') ?? 0;
    final commission =
        double.tryParse(e['commission_earned']?.toString() ?? '0') ?? 0;
    final saEarning = serviceFee + commission;
    final vendorName = e['vendor_name'] ?? '';
    final date = e['earned_at'] ?? e['date'] ?? e['created_at'] ?? '';
    final isCollected = (e['is_collected'] ?? 0) == 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: AppColors.divider.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.attach_money,
                    color: AppColors.success, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e['order_number'] ?? '',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                    if (vendorName.isNotEmpty)
                      Text(vendorName,
                          style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11)),
                    Text(date,
                        style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(fmt.format(saEarning),
                      style: const TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  if (!isCollected)
                    GestureDetector(
                      onTap: () => controller
                          .markCollected(e['id']?.toString() ?? ''),
                      child: Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryOrange
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppColors.primaryOrange
                                  .withValues(alpha: 0.4)),
                        ),
                        child: Text('Collect'.tr,
                            style: const TextStyle(
                                color: AppColors.primaryOrange,
                                fontSize: 10,
                                fontWeight: FontWeight.w600)),
                      ),
                    )
                  else
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color:
                            AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Collected'.tr,
                          style: const TextStyle(
                              color: AppColors.success,
                              fontSize: 10,
                              fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
            ],
          ),
          // Breakdown row
          if (serviceFee > 0 || commission > 0) ...[
            const SizedBox(height: 8),
            Container(
              height: 1,
              color: AppColors.divider.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _breakdownChip(
                    'Service'.tr, fmt.format(serviceFee), AppColors.info),
                _breakdownChip(
                    'Commission'.tr, fmt.format(commission), AppColors.goldenYellow),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _breakdownChip(String label, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text('$label: ',
            style:
                TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
        Text(value,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
