import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../shared/localization/app_translations.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';
import '../../../../shared/widgets/responsive_content.dart';
import '../controllers/sa_points_config_controller.dart';

class SaPointsConfigView extends ConsumerWidget {
  const SaPointsConfigView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(saPointsConfigProvider);

    return ResponsiveScaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        title: Text('Points Settings'.tr),
        actions: [
          controller.isSaving
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: AppColors.primaryOrange, strokeWidth: 2),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: controller.saveConfig,
                  tooltip: 'Save'.tr,
                ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: AppRoutes.saPointsConfig),
      body: ResponsiveContent(
        child: controller.isLoading
            ? const Center(
                child:
                    CircularProgressIndicator(color: AppColors.primaryOrange))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.info.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              color: AppColors.info, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Customers earn points on each delivered order. They can redeem points for discounts at checkout.'
                                  .tr,
                              style: const TextStyle(
                                  color: AppColors.info, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Active toggle
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardDark,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Points System'.tr,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(
                                controller.isActive
                                    ? 'Active'.tr
                                    : 'Disabled'.tr,
                                style: TextStyle(
                                  color: controller.isActive
                                      ? AppColors.success
                                      : AppColors.error,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: controller.isActive,
                            onChanged: (v) => controller.setIsActive(v),
                            activeThumbColor: AppColors.primaryOrange,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Earning config
                    _label('Earning: Every X₪ spent = 1 point'.tr),
                    _field(controller.spendAmountCtrl, '10',
                        Icons.shopping_cart),
                    const SizedBox(height: 8),
                    _hint(
                        'Example: If set to 10, a 75₪ order earns 7 points'.tr),
                    const SizedBox(height: 24),

                    // Redemption config
                    _label('Redemption: Y points = 1₪ discount'.tr),
                    _field(
                        controller.pointsPerShekelCtrl, '10', Icons.redeem),
                    const SizedBox(height: 8),
                    _hint(
                        'Example: If set to 10, a customer with 50 points gets 5₪ off'
                            .tr),
                    const SizedBox(height: 32),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            controller.isSaving ? null : controller.saveConfig,
                        icon: controller.isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.save),
                        label: Text(controller.isSaving
                            ? 'Saving...'.tr
                            : 'Save Configuration'.tr),
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16)),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 13)),
      );

  Widget _hint(String text) => Row(
        children: [
          const Icon(Icons.lightbulb_outline,
              color: AppColors.warning, size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text,
                style:
                    const TextStyle(color: AppColors.warning, fontSize: 11)),
          ),
        ],
      );

  Widget _field(TextEditingController ctrl, String hint, IconData icon) =>
      TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon)),
      );
}
