import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../controllers/sa_ads_controller.dart';

class SaAdsView extends GetView<SaAdsController> {
  const SaAdsView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SaAdsController());
    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        title: Text('Advertisements'.tr),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: controller.fetchAds),
        ],
      ),
      drawer: const AppDrawer(currentRoute: AppRoutes.saAds),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Get.toNamed(AppRoutes.saAddAd);
          if (result == true) controller.fetchAds();
        },
        icon: const Icon(Icons.add),
        label: Text('New Ad'.tr),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child:
                  CircularProgressIndicator(color: AppColors.primaryOrange));
        }
        if (controller.ads.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.campaign,
                    size: 64, color: Colors.white.withValues(alpha: 0.2)),
                const SizedBox(height: 12),
                Text('No advertisements'.tr,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4))),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Get.toNamed(AppRoutes.saAddAd);
                    if (result == true) controller.fetchAds();
                  },
                  icon: const Icon(Icons.add),
                  label: Text('Create First Ad'.tr),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          color: AppColors.primaryOrange,
          onRefresh: controller.fetchAds,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.ads.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _adCard(controller.ads[i]),
          ),
        );
      }),
    );
  }

  Widget _adCard(Map<String, dynamic> ad) {
    final isActive = (ad['is_active'] ?? 1) == 1;
    final id = ad['id']?.toString() ?? '';
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive
              ? AppColors.goldenYellow.withValues(alpha: 0.3)
              : AppColors.divider.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image area / banner
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryOrange.withValues(alpha: 0.2),
                  AppColors.goldenYellow.withValues(alpha: 0.1),
                ],
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: _buildImageArea(ad),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(ad['title'] ?? '',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ),
                    // Status badge
                    GestureDetector(
                      onTap: () => controller.toggleAd(id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color:
                              (isActive ? AppColors.success : AppColors.error)
                                  .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: (isActive
                                    ? AppColors.success
                                    : AppColors.error)
                                .withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          isActive ? 'Active'.tr : 'Paused'.tr,
                          style: TextStyle(
                            color: isActive
                                ? AppColors.success
                                : AppColors.error,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (ad['description'] != null &&
                    ad['description'].toString().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(ad['description'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13)),
                ],
                // Vendor info
                if (ad['vendor_name'] != null &&
                    ad['vendor_name'].toString().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.store,
                          size: 13, color: AppColors.goldenYellow),
                      const SizedBox(width: 4),
                      Text(
                        ad['vendor_name'],
                        style: const TextStyle(
                            color: AppColors.goldenYellow,
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
                // Date range info
                if (ad['starts_at'] != null || ad['ends_at'] != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        _formatDateRange(ad['starts_at']?.toString(),
                            ad['ends_at']?.toString()),
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 11),
                      ),
                      const Spacer(),
                      // Click count badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.touch_app,
                                size: 12, color: AppColors.info),
                            const SizedBox(width: 4),
                            Text(
                              '${ad['click_count'] ?? 0} ${'clicks'.tr}',
                              style: const TextStyle(
                                  color: AppColors.info,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () async {
                        final result = await Get.toNamed(
                          AppRoutes.saAddAd,
                          arguments: ad,
                        );
                        if (result == true) controller.fetchAds();
                      },
                      icon: const Icon(Icons.edit_outlined,
                          size: 16, color: AppColors.info),
                      label: Text('Edit'.tr,
                          style:
                              TextStyle(color: AppColors.info, fontSize: 12)),
                      style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4)),
                    ),
                    const SizedBox(width: 4),
                    TextButton.icon(
                      onPressed: () => _confirmDelete(id),
                      icon: const Icon(Icons.delete_outline,
                          size: 16, color: AppColors.error),
                      label: Text('Remove'.tr,
                          style:
                              TextStyle(color: AppColors.error, fontSize: 12)),
                      style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageArea(Map<String, dynamic> ad) {
    final imageUrl = ad['image_url']?.toString();
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 120,
          errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.broken_image,
                  color: AppColors.primaryOrange, size: 40)),
        ),
      );
    }
    return const Center(
        child: Icon(Icons.campaign,
            color: AppColors.primaryOrange, size: 40));
  }

  String _formatDateRange(String? start, String? end) {
    String fmt(String? d) {
      if (d == null) return '—';
      try {
        final dt = DateTime.parse(d);
        return '${dt.day}/${dt.month}/${dt.year}';
      } catch (_) {
        return d.length > 10 ? d.substring(0, 10) : d;
      }
    }
    return '${fmt(start)}  →  ${fmt(end)}';
  }

  void _confirmDelete(String id) {
    Get.dialog(AlertDialog(
      backgroundColor: AppColors.darkSurface,
      title: Text('Delete Ad'.tr, style: const TextStyle(color: Colors.white)),
      content: Text('Remove this advertisement?'.tr,
          style: TextStyle(color: AppColors.textSecondary)),
      actions: [
        TextButton(
            onPressed: () => Get.back(), child: Text('Cancel'.tr)),
        ElevatedButton(
          style:
              ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          onPressed: () {
            Get.back();
            controller.deleteAd(id);
          },
          child: Text('Delete'.tr),
        ),
      ],
    ));
  }
}
