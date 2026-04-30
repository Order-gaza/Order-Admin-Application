import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/theme/app_colors.dart';
import '../../app/constants/app_constants.dart';
import '../../app/routes/app_routes.dart';
import '../../data/providers/api_provider.dart';
import '../../modules/auth/controllers/auth_controller.dart';

/// A role-aware navigation drawer used across all dashboards.
class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final role = ApiProvider.storedRole ?? '';
    final name = ApiProvider.storedUserName ?? 'User';
    final email = ApiProvider.storedUserEmail ?? '';

    return Drawer(
      backgroundColor: AppColors.charcoalBlack,
      child: Column(
        children: [
          // ── Header ──
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 24,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryOrange, AppColors.darkOrange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    AppConstants.roleLabel(role),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Menu Items ──
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: _buildMenuItems(role),
            ),
          ),

          // ── Logout ──
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title:
                Text('Logout'.tr, style: const TextStyle(color: AppColors.error)),
            onTap: () {
              Get.dialog(
                AlertDialog(
                  backgroundColor: AppColors.darkSurface,
                  title: Text('Logout'.tr,
                      style: const TextStyle(color: Colors.white)),
                  content: Text('Are you sure you want to logout?'.tr,
                      style: const TextStyle(color: AppColors.textSecondary)),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('Cancel'.tr),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error),
                      onPressed: () {
                        Get.back();
                        Get.put(AuthController()).logout();
                      },
                      child: Text('Logout'.tr),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  List<Widget> _buildMenuItems(String role) {
    switch (role) {
      case AppConstants.roleSuperAdmin:
        return [
          _tile(Icons.dashboard, 'Dashboard'.tr, AppRoutes.saDashboard),
          _tile(Icons.admin_panel_settings, 'Admins'.tr, AppRoutes.saAdmins),
          _tile(Icons.store, 'Vendors'.tr, AppRoutes.saVendors),
          _tile(Icons.people, 'Customers'.tr, AppRoutes.saCustomers),
          _tile(Icons.receipt_long, 'Orders'.tr, AppRoutes.saOrders),
          _tile(Icons.campaign, 'Advertisements'.tr, AppRoutes.saAds),
          _tile(Icons.category, 'Categories'.tr, AppRoutes.saCategories),
          _tile(Icons.attach_money, 'Earnings'.tr, AppRoutes.saEarnings),
          _tile(Icons.tune, 'Fee Config'.tr, AppRoutes.saFeeConfig),
          // _tile(Icons.map, 'Delivery Zones'.tr, AppRoutes.saDeliveryZones),
          _tile(Icons.person, 'Profile'.tr, AppRoutes.saProfile),
        ];
      case AppConstants.roleAdmin:
        return [
          _tile(Icons.dashboard, 'Dashboard'.tr, AppRoutes.adminDashboard),
          _tile(Icons.receipt_long, 'Orders'.tr, AppRoutes.adminOrders),
          // _tile(Icons.map, 'Delivery Zones'.tr, AppRoutes.adminDeliveryZones),
          _tile(Icons.delivery_dining, 'Delivery Fee'.tr, AppRoutes.adminDeliverySettings),
          _tile(Icons.person, 'Profile'.tr, AppRoutes.adminProfile),
        ];
      case AppConstants.roleVendor:
        return [
          _tile(Icons.dashboard, 'Dashboard'.tr, AppRoutes.vendorDashboard),
          _tile(Icons.receipt_long, 'Orders'.tr, AppRoutes.vendorOrders),
          _tile(Icons.restaurant_menu, 'Menu'.tr, AppRoutes.vendorMenu),
          _tile(Icons.category, 'Categories'.tr, AppRoutes.vendorCategories),
          _tile(Icons.person, 'Profile'.tr, AppRoutes.vendorProfile),
        ];
      default:
        return [];
    }
  }


  /// Check if this route is a dashboard route
  bool _isDashboard(String route) {
    return route == AppRoutes.saDashboard ||
        route == AppRoutes.adminDashboard ||
        route == AppRoutes.vendorDashboard;
  }

  Widget _tile(IconData icon, String title, String route) {
    final isActive = currentRoute == route;
    return ListTile(
      leading: Icon(icon,
          color: isActive ? AppColors.primaryOrange : AppColors.textSecondary),
      title: Text(
        title,
        style: TextStyle(
          color: isActive ? AppColors.primaryOrange : Colors.white,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      tileColor:
          isActive ? AppColors.primaryOrange.withValues(alpha: 0.1) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: () {
        Get.back(); // close drawer
        if (route == currentRoute) return;

        if (_isDashboard(route)) {
          // Going to dashboard → clear entire stack
          Get.offAllNamed(route);
        } else {
          // Going to a sub-page → push on top of dashboard
          // First check if we're already on a sub-page (not dashboard)
          // If so, replace current sub-page with new one
          if (_isDashboard(currentRoute)) {
            // We're on dashboard → just push sub-page
            Get.toNamed(route, arguments: Get.arguments);
          } else {
            // We're on another sub-page → go back to dashboard first, then push
            Get.until((r) => _isDashboard(r.settings.name ?? ''));
            Get.toNamed(route, arguments: Get.arguments);
          }
        }
      },
    );
  }
}
