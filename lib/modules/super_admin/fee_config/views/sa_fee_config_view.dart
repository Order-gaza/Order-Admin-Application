import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/constants/app_constants.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../shared/localization/app_translations.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../controllers/sa_fee_config_controller.dart';

class SaFeeConfigView extends ConsumerWidget {
  const SaFeeConfigView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(saFeeConfigProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        title: Text('Service Fee Config'.tr),
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
                  tooltip: 'Save Config'.tr,
                ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: AppRoutes.saFeeConfig),
      body: Builder(builder: (_) {
        if (controller.isLoading) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Info banner ──
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
                        'This fee is automatically added to the customer\'s delivery cost. Changes apply to all new orders.'.tr,
                        style: const TextStyle(
                            color: AppColors.info, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Model selector ──
              Text('Fee Model'.tr,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _modelCard(
                    controller,
                    AppConstants.feeFlat,
                    'Flat Fee'.tr,
                    'Fixed amount per order'.tr,
                    Icons.attach_money,
                    controller.activeModel == AppConstants.feeFlat,
                  ),
                  const SizedBox(width: 12),
                  _modelCard(
                    controller,
                    AppConstants.feePercentage,
                    'Percentage'.tr,
                    'Percent of order total'.tr,
                    Icons.percent,
                    controller.activeModel == AppConstants.feePercentage,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Config fields ──
              Builder(builder: (_) {
                final isFlat = controller.activeModel == AppConstants.feeFlat;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isFlat) ...[
                      _label('Service Fee (₪)'.tr),
                      _field(controller.flatFeeCtrl, '0.00',
                          Icons.money, TextInputType.number),
                    ] else ...[
                      _label('Commission Percentage (%)'.tr),
                      _field(controller.percentageCtrl, '0.00',
                          Icons.percent, TextInputType.number),
                      const SizedBox(height: 16),
                      _label('Minimum Fee (₪)'.tr),
                      _field(controller.minFeeCtrl, '0.00',
                          Icons.arrow_downward, TextInputType.number),
                      const SizedBox(height: 16),
                      _label('Maximum Fee Cap (₪)'.tr),
                      _field(controller.maxFeeCtrl, '0.00',
                          Icons.arrow_upward, TextInputType.number),
                    ],
                  ],
                );
              }),
              const SizedBox(height: 32),

              // ── Save button ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: controller.isSaving
                      ? null
                      : controller.saveConfig,
                  icon: controller.isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white))
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
        );
      }),
    );
  }

  Widget _modelCard(SaFeeConfigController controller, String value, String title, String subtitle,
      IconData icon, bool selected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setActiveModel(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryOrange.withValues(alpha: 0.15)
                : AppColors.cardDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? AppColors.primaryOrange
                  : AppColors.divider.withValues(alpha: 0.4),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: selected
                      ? AppColors.primaryOrange
                      : AppColors.textSecondary,
                  size: 28),
              const SizedBox(height: 8),
              Text(title,
                  style: TextStyle(
                      color: selected
                          ? AppColors.primaryOrange
                          : Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15)),
              Text(subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 13)),
    );
  }

  Widget _field(TextEditingController ctrl, String hint, IconData icon,
      TextInputType type) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: TextField(
        controller: ctrl,
        keyboardType: type,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon),
        ),
      ),
    );
  }
}
