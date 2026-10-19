import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../shared/localization/app_translations.dart';
import '../../../../shared/utils/app_navigator.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../controllers/sa_categories_controller.dart';

class SaCategoriesView extends ConsumerWidget {
  const SaCategoriesView({super.key});

  // Icon map matching the backend icon_name values
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
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(saCategoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        title: Text('Global Categories'.tr),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: controller.fetchCategories),
        ],
      ),
      drawer: const AppDrawer(currentRoute: AppRoutes.saCategories),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategoryDialog(context, controller: controller),
        icon: const Icon(Icons.add),
        label: Text('Add Category'.tr),
      ),
      body: Builder(builder: (context) {
        if (controller.isLoading) {
          return const Center(
              child:
                  CircularProgressIndicator(color: AppColors.primaryOrange));
        }
        if (controller.categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.category,
                    size: 64, color: Colors.white.withValues(alpha: 0.2)),
                const SizedBox(height: 12),
                Text('No categories'.tr,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4))),
              ],
            ),
          );
        }
        return RefreshIndicator(
          color: AppColors.primaryOrange,
          onRefresh: controller.fetchCategories,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.categories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) =>
                _categoryCard(context, controller, controller.categories[i]),
          ),
        );
      }),
    );
  }

  Widget _categoryCard(BuildContext context, SaCategoriesController controller,
      Map<String, dynamic> cat) {
    final isActive = (cat['is_active'] ?? 1) == 1;
    final id = cat['id']?.toString() ?? '';
    final iconName = cat['icon_name']?.toString() ?? 'category';
    final vendorsCount = cat['vendors_count'] ?? 0;

    return Container(
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
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primaryOrange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_resolveIcon(iconName),
                color: AppColors.primaryOrange, size: 24),
          ),
          const SizedBox(width: 14),
          // Name + Arabic + vendors count
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
                          color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.store,
                        size: 12, color: AppColors.goldenYellow),
                    const SizedBox(width: 4),
                    Text(
                      '$vendorsCount ${'vendors'.tr}',
                      style: const TextStyle(
                          color: AppColors.goldenYellow,
                          fontSize: 11,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 12),
                    // Sort order badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#${cat['sort_order'] ?? 0}',
                        style: const TextStyle(
                            color: AppColors.info,
                            fontSize: 10,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
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
                isActive ? 'Active'.tr : 'Off'.tr,
                style: TextStyle(
                    color: isActive ? AppColors.success : AppColors.error,
                    fontSize: 11,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert,
                color: AppColors.textSecondary, size: 20),
            color: AppColors.darkSurface,
            onSelected: (v) {
              if (v == 'edit') {
                _showCategoryDialog(context, controller: controller, cat: cat);
              }
              if (v == 'delete') {
                _confirmDelete(controller, id, cat['name'] ?? '');
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                  value: 'edit',
                  child: Row(children: [
                    const Icon(Icons.edit_outlined,
                        color: AppColors.info, size: 16),
                    const SizedBox(width: 8),
                    Text('Edit'.tr,
                        style: const TextStyle(color: Colors.white)),
                  ])),
              PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [
                    const Icon(Icons.delete_outline,
                        color: AppColors.error, size: 16),
                    const SizedBox(width: 8),
                    Text('Delete'.tr,
                        style: const TextStyle(color: Colors.white)),
                  ])),
            ],
          ),
        ],
      ),
    );
  }

  void _showCategoryDialog(BuildContext context,
      {required SaCategoriesController controller,
      Map<String, dynamic>? cat}) {
    final isEdit = cat != null;
    final nameCtrl = TextEditingController(text: cat?['name'] ?? '');
    final nameArCtrl = TextEditingController(text: cat?['name_ar'] ?? '');
    final sortCtrl = TextEditingController(
        text: (cat?['sort_order'] ?? 0).toString());
    String selectedIcon = cat?['icon_name']?.toString() ?? 'category';

    AppNavigator.dialog(
      StatefulBuilder(
        builder: (dialogContext, setState) {
          return AlertDialog(
            backgroundColor: AppColors.darkSurface,
            title: Text(
              isEdit ? 'Edit Category'.tr : 'New Category'.tr,
              style: const TextStyle(color: Colors.white),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name (English)
                  TextField(
                    controller: nameCtrl,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Category name (English)'.tr,
                      prefixIcon: const Icon(Icons.label),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Name (Arabic)
                  TextField(
                    controller: nameArCtrl,
                    style: const TextStyle(color: Colors.white),
                    textDirection: TextDirection.rtl,
                    decoration: const InputDecoration(
                      hintText: 'اسم الفئة (عربي)',
                      prefixIcon: Icon(Icons.translate),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Sort order
                  TextField(
                    controller: sortCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Sort order'.tr,
                      prefixIcon: const Icon(Icons.sort),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Icon picker
                  Text('Icon'.tr,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _iconMap.entries.map((e) {
                      final isSelected = selectedIcon == e.key;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIcon = e.key;
                          });
                        },
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryOrange
                                    .withValues(alpha: 0.2)
                                : AppColors.cardDark,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryOrange
                                  : AppColors.divider
                                      .withValues(alpha: 0.3),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Icon(e.value,
                              color: isSelected
                                  ? AppColors.primaryOrange
                                  : AppColors.textSecondary,
                              size: 20),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => AppNavigator.back(),
                  child: Text('Cancel'.tr)),
              ElevatedButton(
                onPressed: () {
                  if (nameCtrl.text.trim().isEmpty) return;
                  AppNavigator.back();
                  if (isEdit) {
                    controller.updateCategory(
                      id: cat['id']?.toString() ?? '',
                      name: nameCtrl.text.trim(),
                      nameAr: nameArCtrl.text.trim(),
                      iconName: selectedIcon,
                      sortOrder: int.tryParse(sortCtrl.text) ?? 0,
                    );
                  } else {
                    controller.addCategory(
                      name: nameCtrl.text.trim(),
                      nameAr: nameArCtrl.text.trim(),
                      iconName: selectedIcon,
                      sortOrder: int.tryParse(sortCtrl.text) ?? 0,
                    );
                  }
                },
                child: Text(isEdit ? 'Update'.tr : 'Add'.tr),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDelete(
      SaCategoriesController controller, String id, String name) {
    AppNavigator.dialog(AlertDialog(
      backgroundColor: AppColors.darkSurface,
      title: Text('Delete Category'.tr,
          style: const TextStyle(color: Colors.white)),
      content: Text(
          '${'Remove'.tr} "$name"? ${'This will only work if no vendors are using it.'.tr}',
          style: const TextStyle(color: AppColors.textSecondary)),
      actions: [
        TextButton(
            onPressed: () => AppNavigator.back(), child: Text('Cancel'.tr)),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          onPressed: () {
            AppNavigator.back();
            controller.deleteCategory(id);
          },
          child: Text('Delete'.tr),
        ),
      ],
    ));
  }
}
