import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../controllers/vendor_categories_controller.dart';

class VendorCategoriesView extends GetView<VendorCategoriesController> {
  const VendorCategoriesView({super.key});

  static const _iconMap = <String, IconData>{
    'restaurant': Icons.restaurant_rounded,
    'local_pharmacy': Icons.local_pharmacy_rounded,
    'local_grocery_store': Icons.local_grocery_store_rounded,
    'local_drink': Icons.local_drink_rounded,
    'cake': Icons.cake_rounded,
    'devices': Icons.devices_rounded,
    'checkroom': Icons.checkroom_rounded,
    'health_and_safety': Icons.health_and_safety_rounded,
    'category': Icons.category_rounded,
    'shopping_bag': Icons.shopping_bag_rounded,
    'sports_esports': Icons.sports_esports_rounded,
    'auto_awesome': Icons.auto_awesome_rounded,
    'pets': Icons.pets_rounded,
    'home_repair_service': Icons.home_repair_service_rounded,
    'menu_book': Icons.menu_book_rounded,
    'local_florist': Icons.local_florist_rounded,
    'build': Icons.build_rounded,
    'directions_car': Icons.directions_car_rounded,
    'child_care': Icons.child_care_rounded,
    'cleaning_services': Icons.cleaning_services_rounded,
  };

  static IconData _resolveIcon(String? name) =>
      _iconMap[name] ?? Icons.category_rounded;

  @override
  Widget build(BuildContext context) {
    Get.put(VendorCategoriesController());
    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        title: Text('My Categories'.tr),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: controller.fetchCategories),
        ],
      ),
      drawer: const AppDrawer(currentRoute: AppRoutes.vendorCategories),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context),
        icon: const Icon(Icons.add),
        label: Text('Add Category'.tr),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange));
        }
        if (controller.categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.category,
                    size: 64,
                    color: Colors.white.withValues(alpha: 0.2)),
                const SizedBox(height: 12),
                Text('No categories yet'.tr,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4))),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showAddSheet(context),
                  icon: const Icon(Icons.add),
                  label: Text('Add First Category'.tr),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          color: AppColors.primaryOrange,
          onRefresh: controller.fetchCategories,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.categories.length,
            itemBuilder: (_, i) {
              final cat = controller.categories[i];
              final id = cat['id']?.toString() ?? '';
              final isActive = (cat['is_active'] ?? 1) == 1;
              return _categoryCard(context, cat, id, isActive);
            },
          ),
        );
      }),
    );
  }

  Widget _categoryCard(BuildContext context, Map<String, dynamic> cat,
      String id, bool isActive) {
    final iconName = cat['icon_name']?.toString() ?? 'category';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive
              ? AppColors.primaryOrange.withValues(alpha: 0.3)
              : AppColors.divider.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primaryOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_resolveIcon(iconName),
                color: AppColors.primaryOrange, size: 20),
          ),
          const SizedBox(width: 12),
          // Name + Arabic + item count
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cat['name'] ?? '',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15)),
                if (cat['name_ar'] != null &&
                    cat['name_ar'].toString().isNotEmpty)
                  Text(cat['name_ar'],
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                if (cat['items_count'] != null)
                  Text('${cat['items_count']} ' + 'items'.tr,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          // Toggle
          GestureDetector(
            onTap: () => controller.toggleCategory(id),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: (isActive ? AppColors.success : AppColors.error)
                    .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: (isActive ? AppColors.success : AppColors.error)
                      .withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                isActive ? 'On'.tr : 'Off'.tr,
                style: TextStyle(
                    color: isActive ? AppColors.success : AppColors.error,
                    fontSize: 11,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Delete
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: AppColors.error, size: 20),
            onPressed: () => _confirmDelete(id),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  /// Show bottom sheet with available global categories to pick from
  void _showAddSheet(BuildContext context) {
    // Refresh global categories first
    controller.fetchGlobalCategories().then((_) {
      Get.bottomSheet(
        Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          decoration: const BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Choose Category'.tr,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ),
              const Divider(height: 1, color: AppColors.divider),
              Expanded(
                child: Obx(() {
                  final available = controller.availableGlobalCategories;
                  if (available.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          'You have subscribed to all available categories'.tr,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 14),
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: available.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final gc = available[i];
                      final iconName =
                          gc['icon_name']?.toString() ?? 'category';
                      return ListTile(
                        onTap: () {
                          Get.back();
                          controller.subscribeToCategory(
                              gc['id']?.toString() ?? '');
                        },
                        leading: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.primaryOrange
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(_resolveIcon(iconName),
                              color: AppColors.primaryOrange, size: 20),
                        ),
                        title: Text(gc['name'] ?? '',
                            style:
                                const TextStyle(color: Colors.white)),
                        subtitle: gc['name_ar'] != null &&
                                gc['name_ar'].toString().isNotEmpty
                            ? Text(gc['name_ar'],
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12))
                            : null,
                        trailing: const Icon(Icons.add_circle_outline,
                            color: AppColors.primaryOrange),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        tileColor: AppColors.cardDark,
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
        isScrollControlled: true,
      );
    });
  }

  void _confirmDelete(String id) {
    Get.dialog(AlertDialog(
      backgroundColor: AppColors.darkSurface,
      title: Text('Remove Category'.tr,
          style: const TextStyle(color: Colors.white)),
      content: Text(
          'Remove this category from your menu? Items in it will not be deleted.'.tr,
          style: const TextStyle(color: AppColors.textSecondary)),
      actions: [
        TextButton(
            onPressed: () => Get.back(), child: Text('Cancel'.tr)),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error),
          onPressed: () {
            Get.back();
            controller.deleteCategory(id);
          },
          child: Text('Delete'.tr),
        ),
      ],
    ));
  }
}
