import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../controllers/sa_admins_controller.dart';

class SaAdminsView extends GetView<SaAdminsController> {
  const SaAdminsView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SaAdminsController());
    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        title: Text('Manage Admins'.tr),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: controller.fetchAdmins),
        ],
      ),
      drawer: const AppDrawer(currentRoute: AppRoutes.saAdmins),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        icon: const Icon(Icons.add),
        label: Text('Add Admin'.tr),
      ),
      body: Column(
        children: [
          // ── Search ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => controller.searchQuery.value = v,
              decoration: InputDecoration(
                hintText: 'Search admins...'.tr,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          // ── List ──
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
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
                      Icon(Icons.admin_panel_settings,
                          size: 64,
                          color: Colors.white.withValues(alpha: 0.2)),
                      const SizedBox(height: 12),
                      Text('No admins found'.tr,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4))),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                color: AppColors.primaryOrange,
                onRefresh: controller.fetchAdmins,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _adminCard(context, list[i]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _adminCard(BuildContext context, Map<String, dynamic> admin) {
    // Backend may send is_active as bool (true/false) or int (1/0)
    final isActive = admin['is_active'] == true || admin['is_active'] == 1;
    return Material(
      color: AppColors.cardDark,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Get.toNamed(AppRoutes.saAdminDetail, arguments: {
          'id': admin['id'],
          'name': admin['name']
        }),
        child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryOrange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                (admin['name'] ?? 'A')[0].toUpperCase(),
                style: const TextStyle(
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(admin['name'] ?? '',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15)),
                Text(admin['email'] ?? '',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                if (admin['phone'] != null)
                  Text(admin['phone'],
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                if (admin['zone_coverage'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _zoneColor(admin['zone_coverage']).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        admin['zone_coverage'] == 'north' ? 'فرع الشمال' : 'فرع الجنوب',
                        style: TextStyle(
                            color: _zoneColor(admin['zone_coverage']),
                            fontSize: 10,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
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
                      color: isActive ? AppColors.success : AppColors.error,
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    onPressed: () => controller.toggleStatus(admin['id']),
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
                    onPressed: () => _confirmDelete(context, admin['id']),
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

  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final selectedZone = Rxn<String>();

    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: Text('Add New Admin'.tr,
            style: const TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField(nameCtrl, 'Full Name'.tr, Icons.person),
              const SizedBox(height: 12),
              _dialogField(emailCtrl, 'Email'.tr, Icons.email,
                  type: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _dialogField(phoneCtrl, 'Phone'.tr, Icons.phone,
                  type: TextInputType.phone),
              const SizedBox(height: 12),
              _dialogField(passCtrl, 'Password'.tr, Icons.lock,
                  obscure: true),
              const SizedBox(height: 16),
              // ── Branch Zone Picker ──
              Align(
                alignment: Alignment.centerRight,
                child: Text('منطقة الفرع *'.tr,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
              ),
              const SizedBox(height: 8),
              Obx(() => Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => selectedZone.value = 'north',
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: selectedZone.value == 'north'
                                  ? const Color(0xFF2196F3).withValues(alpha: 0.15)
                                  : AppColors.cardDark,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selectedZone.value == 'north'
                                    ? const Color(0xFF2196F3)
                                    : AppColors.divider,
                                width: selectedZone.value == 'north' ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.north,
                                    color: selectedZone.value == 'north'
                                        ? const Color(0xFF2196F3)
                                        : AppColors.textSecondary,
                                    size: 22),
                                const SizedBox(height: 4),
                                Text('الشمال',
                                    style: TextStyle(
                                        color: selectedZone.value == 'north'
                                            ? const Color(0xFF2196F3)
                                            : AppColors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13)),
                                Text('غزة',
                                    style: TextStyle(
                                        color: selectedZone.value == 'north'
                                            ? const Color(0xFF2196F3).withValues(alpha: 0.7)
                                            : AppColors.textSecondary.withValues(alpha: 0.6),
                                        fontSize: 10)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => selectedZone.value = 'south',
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: selectedZone.value == 'south'
                                  ? const Color(0xFFFF9800).withValues(alpha: 0.15)
                                  : AppColors.cardDark,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selectedZone.value == 'south'
                                    ? const Color(0xFFFF9800)
                                    : AppColors.divider,
                                width: selectedZone.value == 'south' ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.south,
                                    color: selectedZone.value == 'south'
                                        ? const Color(0xFFFF9800)
                                        : AppColors.textSecondary,
                                    size: 22),
                                const SizedBox(height: 4),
                                Text('الجنوب',
                                    style: TextStyle(
                                        color: selectedZone.value == 'south'
                                            ? const Color(0xFFFF9800)
                                            : AppColors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13)),
                                Text('الوسطى + خان',
                                    style: TextStyle(
                                        color: selectedZone.value == 'south'
                                            ? const Color(0xFFFF9800).withValues(alpha: 0.7)
                                            : AppColors.textSecondary.withValues(alpha: 0.6),
                                        fontSize: 10)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Get.back(),
              child: Text('Cancel'.tr)),
          ElevatedButton(
            onPressed: () {
              if (selectedZone.value == null) {
                Get.snackbar('Error'.tr, 'يجب اختيار منطقة الفرع'.tr,
                    backgroundColor: const Color(0xFFF44336),
                    colorText: const Color(0xFFFFFFFF));
                return;
              }
              Get.back();
              controller.addAdmin(
                name: nameCtrl.text,
                email: emailCtrl.text,
                phone: phoneCtrl.text,
                password: passCtrl.text,
                zoneCoverage: selectedZone.value!,
              );
            },
            child: Text('Add Admin'.tr),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(TextEditingController ctrl, String hint, IconData icon,
      {TextInputType type = TextInputType.text, bool obscure = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    Get.dialog(AlertDialog(
      backgroundColor: AppColors.darkSurface,
      title: Text('Delete Admin'.tr, style: const TextStyle(color: Colors.white)),
      content: Text('Are you sure? This action cannot be undone.'.tr,
          style: const TextStyle(color: AppColors.textSecondary)),
      actions: [
        TextButton(onPressed: () => Get.back(), child: Text('Cancel'.tr)),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          onPressed: () {
            Get.back();
            controller.deleteAdmin(id);
          },
          child: Text('Delete'.tr),
        ),
      ],
    ));
  }

  static Color _zoneColor(String? zone) {
    switch (zone) {
      case 'north':
        return const Color(0xFF2196F3);
      case 'south':
        return const Color(0xFFFF9800);
      default:
        return AppColors.primaryOrange;
    }
  }
}
