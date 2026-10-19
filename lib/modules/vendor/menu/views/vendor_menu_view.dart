import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/app_network_image.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../shared/localization/app_translations.dart';
import '../../../../shared/utils/app_navigator.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/controllers/language_controller.dart';
import '../controllers/vendor_menu_controller.dart';

class VendorMenuView extends ConsumerWidget {
  const VendorMenuView({super.key});

  String _displayName(dynamic data) {
    if (LanguageController.to.currentLanguage == 'ar') {
      final ar = data['name_ar']?.toString();
      if (ar != null && ar.isNotEmpty) return ar;
    }
    return data['name']?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(vendorMenuProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        title: Text('Menu'.tr),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                controller.fetchCategories();
                controller.fetchItems();
              }),
        ],
      ),
      drawer: const AppDrawer(currentRoute: AppRoutes.vendorMenu),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await AppNavigator.toNamed(AppRoutes.vendorAddItem);
          if (result == true) {
            controller.fetchItems();
          }
        },
        icon: const Icon(Icons.add),
        label: Text('Add Item'.tr),
      ),
      body: Column(
        children: [
          // ── Category Filter ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _categoryChip('All'.tr, null, controller),
                  ...controller.categories.map((c) => _categoryChip(
                        _displayName(c),
                        c['id']?.toString(),
                        controller,
                      )),
                ],
              ),
            ),
          ),
          // ── Items ──
          Expanded(
            child: Builder(builder: (context) {
              if (controller.isLoading) {
                return const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryOrange));
              }
              final items = controller.filteredItems;
              if (items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.restaurant_menu,
                          size: 64, color: Colors.white.withValues(alpha: 0.2)),
                      const SizedBox(height: 12),
                      Text('No items in this category'.tr,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4))),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                color: AppColors.primaryOrange,
                onRefresh: controller.fetchItems,
                child: LayoutBuilder(
                  builder: (ctx, _) {
                    final w = MediaQuery.of(ctx).size.width;
                    final cols = w > 1200 ? 4 : (w > 800 ? 3 : 2);
                    final ratio = w > 1200 ? 0.8 : (w > 800 ? 0.72 : 0.62);
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        childAspectRatio: ratio,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: items.length,
                      itemBuilder: (_, i) => _itemCard(items[i], controller),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _categoryChip(String label, String? categoryId, VendorMenuController controller) {
    final selected = controller.selectedCategoryId == categoryId;
    return GestureDetector(
      onTap: () => controller.selectCategory(categoryId),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryOrange : AppColors.darkSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? AppColors.primaryOrange : AppColors.divider),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _itemCard(Map<String, dynamic> item, VendorMenuController controller) {
    final isAvailable = (item['is_available'] ?? 1) == 1;
    final imageUrl = item['image_url'] as String?;
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return GestureDetector(
      onTap: () async {
        final result = await AppNavigator.toNamed(
          AppRoutes.vendorAddItem,
          arguments: item,
        );
        if (result == true) {
          controller.fetchItems();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isAvailable
                  ? AppColors.divider.withValues(alpha: 0.3)
                  : AppColors.error.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ──
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: SizedBox(
                height: 100,
                width: double.infinity,
                child: hasImage
                    ? AppNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: () => Container(
                          color: AppColors.primaryOrange.withValues(alpha: 0.1),
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: AppColors.primaryOrange,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        ),
                        errorWidget: () => Container(
                          color: AppColors.primaryOrange.withValues(alpha: 0.1),
                          child: const Center(
                            child: Icon(Icons.broken_image,
                                color: AppColors.textSecondary, size: 32),
                          ),
                        ),
                      )
                    : Container(
                        color: AppColors.primaryOrange.withValues(alpha: 0.1),
                        child: const Center(
                          child: Icon(Icons.fastfood,
                              color: AppColors.primaryOrange, size: 36),
                        ),
                      ),
              ),
            ),

            // ── Info ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _displayName(item),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '₪${item['base_price'] ?? '0'}',
                      style: const TextStyle(
                          color: AppColors.primaryOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                    const Spacer(),

                    // ── Toggle + Actions ──
                    Row(
                      children: [
                        // Toggle switch
                        Expanded(
                          child: GestureDetector(
                            onTap: () => controller
                                .toggleItemStatus(item['id']?.toString() ?? ''),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 5),
                              decoration: BoxDecoration(
                                color: (isAvailable
                                        ? AppColors.success
                                        : AppColors.error)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: (isAvailable
                                          ? AppColors.success
                                          : AppColors.error)
                                      .withValues(alpha: 0.4),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isAvailable
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    color: isAvailable
                                        ? AppColors.success
                                        : AppColors.error,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      isAvailable ? 'On'.tr : 'Off'.tr,
                                      style: TextStyle(
                                        color: isAvailable
                                            ? AppColors.success
                                            : AppColors.error,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Edit
                        _actionIcon(
                          Icons.edit_outlined,
                          AppColors.primaryOrange,
                          () async {
                            final result = await AppNavigator.toNamed(
                              AppRoutes.vendorAddItem,
                              arguments: item,
                            );
                            if (result == true) controller.fetchItems();
                          },
                        ),
                        const SizedBox(width: 4),
                        // Delete
                        _actionIcon(
                          Icons.delete_outline,
                          AppColors.error,
                          () => _confirmDelete(item, controller),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionIcon(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> item, VendorMenuController controller) {
    AppNavigator.dialog(AlertDialog(
      backgroundColor: AppColors.darkSurface,
      title:
          Text('Delete Item'.tr, style: const TextStyle(color: Colors.white)),
      content: Text(
        'Are you sure you want to delete '.tr + '"${_displayName(item)}"?',
        style: const TextStyle(color: AppColors.textSecondary),
      ),
      actions: [
        TextButton(onPressed: () => AppNavigator.back(), child: Text('Cancel'.tr)),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          onPressed: () {
            AppNavigator.back();
            controller.deleteItem(item['id']?.toString() ?? '');
          },
          child: Text('Delete'.tr),
        ),
      ],
    ));
  }
}
