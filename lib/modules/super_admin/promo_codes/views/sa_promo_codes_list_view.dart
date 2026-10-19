import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../shared/localization/app_translations.dart';
import '../../../../shared/utils/app_navigator.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';
import '../../../../shared/widgets/responsive_content.dart';
import '../controllers/sa_promo_codes_controller.dart';

class SaPromoCodesListView extends ConsumerWidget {
  const SaPromoCodesListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(saPromoCodesProvider);

    return ResponsiveScaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        title: Text('Promo Codes'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchAll,
          ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: AppRoutes.saPromoCodes),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await AppNavigator.toNamed(AppRoutes.saPromoCodeForm);
          controller.fetchAll();
        },
        backgroundColor: AppColors.primaryOrange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: ResponsiveContent(
        child: Builder(builder: (context) {
          if (controller.isLoading) {
            return const Center(
                child:
                    CircularProgressIndicator(color: AppColors.primaryOrange));
          }
          if (controller.promoCodes.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.discount_outlined,
                      size: 60, color: AppColors.textSecondary),
                  const SizedBox(height: 16),
                  Text('No promo codes yet'.tr,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 16)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: controller.fetchAll,
            color: AppColors.primaryOrange,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.promoCodes.length,
              itemBuilder: (_, i) =>
                  _promoCard(controller, controller.promoCodes[i]),
            ),
          );
        }),
      ),
    );
  }

  Widget _promoCard(SaPromoCodesController controller, dynamic promo) {
    final code = promo['code']?.toString() ?? '';
    final percentage = (promo['discount_percentage'] ?? 0).toDouble();
    final maxCap = (promo['max_discount_amount'] ?? 0).toDouble();
    final isActive = promo['is_active'] == true || promo['is_active'] == 1;
    final limitMode = promo['limit_mode']?.toString() ?? 'unlimited';
    final currentUses = promo['current_uses'] ?? 0;
    final maxUses = promo['max_uses'];
    final expiresAt = promo['expires_at']?.toString();

    String limitText;
    if (limitMode == 'count') {
      limitText = '$currentUses / ${maxUses ?? '∞'} uses';
    } else if (limitMode == 'date') {
      limitText = expiresAt != null
          ? 'Expires: ${expiresAt.split(' ').first}'
          : 'Date-limited';
    } else {
      limitText = '$currentUses uses (unlimited)';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Code + Status
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(code,
                      style: const TextStyle(
                          color: AppColors.primaryOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1)),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (isActive ? AppColors.success : AppColors.error)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isActive ? 'Active'.tr : 'Inactive'.tr,
                    style: TextStyle(
                        color: isActive ? AppColors.success : AppColors.error,
                        fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Discount info
            Row(
              children: [
                const Icon(Icons.percent,
                    color: AppColors.textSecondary, size: 14),
                const SizedBox(width: 6),
                Text(
                    '${percentage.toStringAsFixed(0)}% off — max ₪${maxCap.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.people_outline,
                    color: AppColors.textSecondary, size: 14),
                const SizedBox(width: 6),
                Text(limitText,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => controller.toggleStatus(promo['id']),
                  icon:
                      Icon(isActive ? Icons.pause : Icons.play_arrow, size: 16),
                  label: Text(isActive ? 'Deactivate'.tr : 'Activate'.tr,
                      style: const TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor:
                        isActive ? AppColors.warning : AppColors.success,
                  ),
                ),
                if (currentUses == 0)
                  TextButton.icon(
                    onPressed: () =>
                        _confirmDelete(controller, promo['id'], code),
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label:
                        Text('Delete'.tr, style: const TextStyle(fontSize: 12)),
                    style:
                        TextButton.styleFrom(foregroundColor: AppColors.error),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
      SaPromoCodesController controller, String id, String code) {
    AppNavigator.dialog(AlertDialog(
      backgroundColor: AppColors.cardDark,
      title: Text('Delete "$code"?'.tr,
          style: const TextStyle(color: Colors.white)),
      content: Text('This cannot be undone.'.tr,
          style: const TextStyle(color: AppColors.textSecondary)),
      actions: [
        TextButton(
            onPressed: () => AppNavigator.back(), child: Text('Cancel'.tr)),
        TextButton(
          onPressed: () {
            AppNavigator.back();
            controller.deletePromo(id);
          },
          child: Text('Delete'.tr,
              style: const TextStyle(color: AppColors.error)),
        ),
      ],
    ));
  }
}
