import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/constants/app_constants.dart';
import '../../app/routes/app_routes.dart';
import '../../data/providers/api_provider.dart';
import '../../shared/localization/app_translations.dart';
import '../../shared/utils/app_navigator.dart';
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
              children: _buildMenuItems(context, role),
            ),
          ),

          // ── Logout ──
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title:
                Text('Logout'.tr, style: const TextStyle(color: AppColors.error)),
            onTap: () {
              AppNavigator.dialog(
                AlertDialog(
                  backgroundColor: AppColors.darkSurface,
                  title: Text('Logout'.tr,
                      style: const TextStyle(color: Colors.white)),
                  content: Text('Are you sure you want to logout?'.tr,
                      style: const TextStyle(color: AppColors.textSecondary)),
                  actions: [
                    TextButton(
                      onPressed: () => AppNavigator.back(),
                      child: Text('Cancel'.tr),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error),
                      onPressed: () {
                        AppNavigator.back();
                        AuthController.to.logout();
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

  List<Widget> _buildMenuItems(BuildContext context, String role) {
    switch (role) {
      case AppConstants.roleSuperAdmin:
        return [
          _tile(context, Icons.dashboard, 'Dashboard'.tr, AppRoutes.saDashboard),
          _tile(context, Icons.admin_panel_settings, 'Admins'.tr, AppRoutes.saAdmins),
          _tile(context, Icons.store, 'Vendors'.tr, AppRoutes.saVendors),
          _tile(context, Icons.people, 'Customers'.tr, AppRoutes.saCustomers),
          _tile(context, Icons.receipt_long, 'Orders'.tr, AppRoutes.saOrders),
          _tile(context, Icons.campaign, 'Advertisements'.tr, AppRoutes.saAds),
          _tile(context, Icons.category, 'Categories'.tr, AppRoutes.saCategories),
          _tile(context, Icons.attach_money, 'Earnings'.tr, AppRoutes.saEarnings),
          _tile(context, Icons.tune, 'Fee Config'.tr, AppRoutes.saFeeConfig),
          _tile(context, Icons.stars, 'Points Settings'.tr, AppRoutes.saPointsConfig),
          _tile(context, Icons.discount, 'Promo Codes'.tr, AppRoutes.saPromoCodes),
          _tile(context, Icons.notifications_active, 'Notifications'.tr, AppRoutes.saNotifications),
          _tile(context, Icons.schedule_send, 'Scheduled Notifs'.tr, AppRoutes.saScheduledNotifs),
          _tile(context, Icons.person, 'Profile'.tr, AppRoutes.saProfile),
        ];
      case AppConstants.roleAdmin:
        return [
          _tile(context, Icons.dashboard, 'Dashboard'.tr, AppRoutes.adminDashboard),
          _tile(context, Icons.receipt_long, 'Orders'.tr, AppRoutes.adminOrders),
          _tile(context, Icons.delivery_dining, 'Delivery Fee'.tr, AppRoutes.adminDeliverySettings),
          _tile(context, Icons.person, 'Profile'.tr, AppRoutes.adminProfile),
        ];
      case AppConstants.roleVendor:
        return [
          _tile(context, Icons.dashboard, 'Dashboard'.tr, AppRoutes.vendorDashboard),
          _tile(context, Icons.receipt_long, 'Orders'.tr, AppRoutes.vendorOrders),
          _tile(context, Icons.restaurant_menu, 'Menu'.tr, AppRoutes.vendorMenu),
          _tile(context, Icons.category, 'Categories'.tr, AppRoutes.vendorCategories),
          _tile(context, Icons.person, 'Profile'.tr, AppRoutes.vendorProfile),
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

  Widget _tile(BuildContext context, IconData icon, String title, String route) {
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
        final scaffold = Scaffold.maybeOf(context);
        if (scaffold?.isDrawerOpen ?? false) {
          AppNavigator.back(); // close drawer
        }
        if (route == currentRoute) return;

        if (_isDashboard(route)) {
          AppNavigator.offAllNamed(route);
        } else {
          if (_isDashboard(currentRoute)) {
            AppNavigator.toNamed(route, arguments: AppNavigator.arguments);
          } else {
            AppNavigator.until((r) => _isDashboard(r.settings.name ?? ''));
            AppNavigator.toNamed(route, arguments: AppNavigator.arguments);
          }
        }
      },
    );
  }
}
