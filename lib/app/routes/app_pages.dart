import 'package:flutter/material.dart';
import 'app_routes.dart';

// Auth
import '../../modules/auth/views/login_view.dart';
import '../../modules/auth/views/forgot_password_view.dart';
import '../../modules/auth/views/verify_otp_view.dart';
import '../../modules/auth/views/reset_password_view.dart';
import '../../modules/auth/views/vendor_register_view.dart';

// Splash
import '../../modules/splash/splash_view.dart';

// Super Admin
import '../../modules/super_admin/dashboard/views/sa_dashboard_view.dart';
import '../../modules/super_admin/admins/views/sa_admins_view.dart';
import '../../modules/super_admin/admins/views/sa_admin_detail_view.dart';
import '../../modules/super_admin/vendors/views/sa_vendors_view.dart';
import '../../modules/super_admin/vendors/views/sa_vendor_detail_view.dart';
import '../../modules/super_admin/vendors/views/sa_create_vendor_view.dart';
import '../../modules/super_admin/customers/views/sa_customers_view.dart';
import '../../modules/super_admin/customers/views/sa_customer_detail_view.dart';
import '../../modules/super_admin/orders/views/sa_orders_view.dart';
import '../../modules/super_admin/advertisements/views/sa_ads_view.dart';
import '../../modules/super_admin/advertisements/views/sa_add_ad_view.dart';
import '../../modules/super_admin/earnings/views/sa_earnings_view.dart';
import '../../modules/super_admin/fee_config/views/sa_fee_config_view.dart';
import '../../modules/super_admin/categories/views/sa_categories_view.dart';
import '../../modules/super_admin/points_config/views/sa_points_config_view.dart';
import '../../modules/super_admin/promo_codes/views/sa_promo_codes_list_view.dart';
import '../../modules/super_admin/promo_codes/views/sa_promo_code_form_view.dart';
import '../../modules/super_admin/promo_codes/views/sa_promo_code_detail_view.dart';
import '../../modules/super_admin/notifications/views/sa_notifications_view.dart';
import '../../modules/super_admin/scheduled_notifs/views/sa_scheduled_notifs_view.dart';

// Admin
import '../../modules/admin/dashboard/views/admin_dashboard_view.dart';
import '../../modules/admin/orders/views/admin_orders_view.dart';
import '../../modules/admin/delivery_settings/views/admin_delivery_settings_view.dart';

// Vendor
import '../../modules/vendor/dashboard/views/vendor_dashboard_view.dart';
import '../../modules/vendor/orders/views/vendor_orders_view.dart';
import '../../modules/vendor/menu/views/vendor_menu_view.dart';
import '../../modules/vendor/menu/views/add_item_view.dart';
import '../../modules/vendor/categories/views/vendor_categories_view.dart';

// Shared
import '../../shared/views/profile_view.dart';
import '../../shared/views/order_detail_view.dart';
import '../../shared/views/notifications_view.dart';

class AppPages {
  static final Map<String, WidgetBuilder> routes = {
    // ── Splash ──
    AppRoutes.splash: (context) => const SplashView(),

    // ── Auth ──
    AppRoutes.login: (context) => const LoginView(),
    AppRoutes.forgotPassword: (context) => const ForgotPasswordView(),
    AppRoutes.verifyOtp: (context) => const VerifyOtpView(),
    AppRoutes.resetPassword: (context) => const ResetPasswordView(),
    AppRoutes.vendorRegister: (context) => const VendorRegisterView(),

    // ── Super Admin ──
    AppRoutes.saDashboard: (context) => const SaDashboardView(),
    AppRoutes.saAdmins: (context) => const SaAdminsView(),
    AppRoutes.saVendors: (context) => const SaVendorsView(),
    AppRoutes.saCreateVendor: (context) => const SaCreateVendorView(),
    AppRoutes.saCustomers: (context) => const SaCustomersView(),
    AppRoutes.saOrders: (context) => const SaOrdersView(),
    AppRoutes.saAds: (context) => const SaAdsView(),
    AppRoutes.saAddAd: (context) => const SaAddAdView(),
    AppRoutes.saEarnings: (context) => const SaEarningsView(),
    AppRoutes.saFeeConfig: (context) => const SaFeeConfigView(),
    AppRoutes.saCategories: (context) => const SaCategoriesView(),
    AppRoutes.saProfile: (context) => const SaProfileView(),
    AppRoutes.saPointsConfig: (context) => const SaPointsConfigView(),
    AppRoutes.saPromoCodes: (context) => const SaPromoCodesListView(),
    AppRoutes.saPromoCodeForm: (context) => const SaPromoCodeFormView(),
    AppRoutes.saPromoCodeDetail: (context) => const SaPromoCodeDetailView(),
    AppRoutes.saNotifications: (context) => const SaNotificationsView(),
    AppRoutes.saScheduledNotifs: (context) => const SaScheduledNotifsView(),

    // ── Admin ──
    AppRoutes.adminDashboard: (context) => const AdminDashboardView(),
    AppRoutes.adminOrders: (context) => const AdminOrdersView(),
    AppRoutes.adminDeliverySettings: (context) =>
        const AdminDeliverySettingsView(),
    AppRoutes.adminProfile: (context) => const AdminProfileView(),

    // ── Vendor ──
    AppRoutes.vendorDashboard: (context) => const VendorDashboardView(),
    AppRoutes.vendorOrders: (context) => const VendorOrdersView(),
    AppRoutes.vendorMenu: (context) => const VendorMenuView(),
    AppRoutes.vendorAddItem: (context) => const AddItemView(),
    AppRoutes.vendorCategories: (context) => const VendorCategoriesView(),
    AppRoutes.vendorProfile: (context) => const VendorProfileView(),

    // ── Shared: Notifications ──
    AppRoutes.notifications: (context) => const NotificationsView(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final name = settings.name;
    final args = (settings.arguments as Map<String, dynamic>?) ?? {};

    Widget? page;
    switch (name) {
      case AppRoutes.saAdminDetail:
        page = SaAdminDetailView(
          adminId: args['id'] ?? '',
          adminName: args['name'] ?? '',
        );
        break;
      case AppRoutes.saVendorDetail:
        page = SaVendorDetailView(
          vendorId: args['vendor_id'] ?? '',
          vendorName: args['vendor_name'] ?? '',
        );
        break;
      case AppRoutes.saCustomerDetail:
        page = SaCustomerDetailView(
          customerId: args['customer_id'] ?? '',
          customerName: args['customer_name'] ?? '',
        );
        break;
      case AppRoutes.saOrderDetail:
        page = SaOrderDetailView(
          orderId: args['order_id'] ?? '',
          orderNumber: args['order_number'] ?? '',
        );
        break;
      case AppRoutes.adminOrderDetail:
        page = AdminOrderDetailView(
          orderId: args['order_id'] ?? '',
          orderNumber: args['order_number'] ?? '',
        );
        break;
      case AppRoutes.vendorOrderDetail:
        page = VendorOrderDetailView(
          orderId: args['order_id'] ?? '',
          orderNumber: args['order_number'] ?? '',
        );
        break;
      default:
        final builder = routes[name];
        if (builder != null) {
          return MaterialPageRoute(builder: builder, settings: settings);
        }
        return null;
    }
    return MaterialPageRoute(builder: (_) => page!, settings: settings);
  }
}
