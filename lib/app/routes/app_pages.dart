import 'package:get/get.dart';
import 'app_routes.dart';

// Auth
import '../../modules/auth/views/login_view.dart';
import '../../modules/auth/views/forgot_password_view.dart';
import '../../modules/auth/views/verify_otp_view.dart';
import '../../modules/auth/views/reset_password_view.dart';
import '../../modules/auth/views/vendor_register_view.dart';
import '../../modules/auth/controllers/auth_controller.dart';

// Splash
import '../../modules/splash/splash_view.dart';

// Super Admin
import '../../modules/super_admin/dashboard/views/sa_dashboard_view.dart';
import '../../modules/super_admin/admins/views/sa_admins_view.dart';
import '../../modules/super_admin/admins/views/sa_admin_detail_view.dart';
import '../../modules/super_admin/admins/controllers/sa_admins_controller.dart';
import '../../modules/super_admin/vendors/views/sa_vendors_view.dart';
import '../../modules/super_admin/vendors/views/sa_vendor_detail_view.dart';
import '../../modules/super_admin/vendors/views/sa_create_vendor_view.dart';
import '../../modules/super_admin/vendors/controllers/sa_vendors_controller.dart';
import '../../modules/super_admin/customers/views/sa_customers_view.dart';
import '../../modules/super_admin/customers/views/sa_customer_detail_view.dart';
import '../../modules/super_admin/customers/controllers/sa_customers_controller.dart';
import '../../modules/super_admin/orders/views/sa_orders_view.dart';
import '../../modules/super_admin/orders/controllers/sa_orders_controller.dart';
import '../../modules/super_admin/delivery_zones/views/sa_delivery_zones_view.dart';
import '../../modules/super_admin/delivery_zones/views/sa_add_zone_view.dart';
import '../../modules/super_admin/delivery_zones/controllers/sa_delivery_zones_controller.dart';
import '../../modules/super_admin/advertisements/views/sa_ads_view.dart';
import '../../modules/super_admin/advertisements/views/sa_add_ad_view.dart';
import '../../modules/super_admin/advertisements/controllers/sa_ads_controller.dart';
import '../../modules/super_admin/earnings/views/sa_earnings_view.dart';
import '../../modules/super_admin/earnings/controllers/sa_earnings_controller.dart';
import '../../modules/super_admin/fee_config/views/sa_fee_config_view.dart';
import '../../modules/super_admin/fee_config/controllers/sa_fee_config_controller.dart';
import '../../modules/super_admin/categories/views/sa_categories_view.dart';
import '../../modules/super_admin/categories/controllers/sa_categories_controller.dart';

// Admin
import '../../modules/admin/dashboard/views/admin_dashboard_view.dart';
import '../../modules/admin/dashboard/controllers/admin_dashboard_controller.dart';
import '../../modules/admin/orders/views/admin_orders_view.dart';
import '../../modules/admin/orders/controllers/admin_orders_controller.dart';
import '../../modules/admin/delivery_zones/views/admin_delivery_zones_view.dart';
import '../../modules/admin/delivery_zones/views/admin_add_zone_view.dart';
import '../../modules/admin/delivery_settings/views/admin_delivery_settings_view.dart';

// Vendor
import '../../modules/vendor/dashboard/views/vendor_dashboard_view.dart';
import '../../modules/vendor/dashboard/controllers/vendor_dashboard_controller.dart';
import '../../modules/vendor/orders/views/vendor_orders_view.dart';
import '../../modules/vendor/orders/controllers/vendor_orders_controller.dart';
import '../../modules/vendor/menu/views/vendor_menu_view.dart';
import '../../modules/vendor/menu/controllers/vendor_menu_controller.dart';
import '../../modules/vendor/menu/views/add_item_view.dart';
import '../../modules/vendor/categories/views/vendor_categories_view.dart';
import '../../modules/vendor/categories/controllers/vendor_categories_controller.dart';

// Shared
import '../../shared/views/profile_view.dart';
import '../../shared/controllers/profile_controller.dart';
import '../../shared/views/order_detail_view.dart';
import '../../shared/views/notifications_view.dart';
import '../../shared/controllers/notifications_controller.dart';

class AppPages {
  static final pages = [
    // ── Splash ──
    GetPage(name: AppRoutes.splash, page: () => const SplashView()),

    // ── Auth ──
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => AuthController())),
    ),
    GetPage(name: AppRoutes.forgotPassword, page: () => const ForgotPasswordView()),
    GetPage(name: AppRoutes.verifyOtp, page: () => const VerifyOtpView()),
    GetPage(name: AppRoutes.resetPassword, page: () => const ResetPasswordView()),
    GetPage(name: AppRoutes.vendorRegister, page: () => const VendorRegisterView()),

    // ── Super Admin ──
    GetPage(name: AppRoutes.saDashboard, page: () => const SaDashboardView()),
    GetPage(
      name: AppRoutes.saAdmins,
      page: () => const SaAdminsView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => SaAdminsController())),
    ),
    GetPage(
      name: AppRoutes.saAdminDetail,
      page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        return SaAdminDetailView(
          adminId: args['id'] ?? '',
          adminName: args['name'] ?? '',
        );
      },
    ),
    GetPage(
      name: AppRoutes.saVendors,
      page: () => const SaVendorsView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => SaVendorsController())),
    ),
    GetPage(
      name: AppRoutes.saVendorDetail,
      page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        return SaVendorDetailView(
          vendorId: args['vendor_id'] ?? '',
          vendorName: args['vendor_name'] ?? '',
        );
      },
    ),
    GetPage(
      name: AppRoutes.saCreateVendor,
      page: () => const SaCreateVendorView(),
    ),
    GetPage(
      name: AppRoutes.saCustomers,
      page: () => const SaCustomersView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => SaCustomersController())),
    ),
    GetPage(
      name: AppRoutes.saCustomerDetail,
      page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        return SaCustomerDetailView(
          customerId: args['customer_id'] ?? '',
          customerName: args['customer_name'] ?? '',
        );
      },
    ),
    GetPage(
      name: AppRoutes.saOrders,
      page: () => const SaOrdersView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => SaOrdersController())),
    ),
    GetPage(
      name: AppRoutes.saOrderDetail,
      page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        return SaOrderDetailView(
          orderId: args['order_id'] ?? '',
          orderNumber: args['order_number'] ?? '',
        );
      },
    ),
    // GetPage(
    //   name: AppRoutes.saDeliveryZones,
    //   page: () => const SaDeliveryZonesView(),
    //   binding: BindingsBuilder(() => Get.lazyPut(() => SaDeliveryZonesController())),
    // ),
    // GetPage(
    //   name: AppRoutes.saAddZone,
    //   page: () => const SaAddZoneView(),
    // ),
    GetPage(
      name: AppRoutes.saAds,
      page: () => const SaAdsView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => SaAdsController())),
    ),
    GetPage(
      name: AppRoutes.saAddAd,
      page: () => const SaAddAdView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => SaAddAdController())),
    ),
    GetPage(
      name: AppRoutes.saEarnings,
      page: () => const SaEarningsView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => SaEarningsController())),
    ),
    GetPage(
      name: AppRoutes.saFeeConfig,
      page: () => const SaFeeConfigView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => SaFeeConfigController())),
    ),
    GetPage(
      name: AppRoutes.saCategories,
      page: () => const SaCategoriesView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => SaCategoriesController())),
    ),
    GetPage(
      name: AppRoutes.saProfile,
      page: () => const SaProfileView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => ProfileController())),
    ),

    // ── Admin ──
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const AdminDashboardView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => AdminDashboardController())),
    ),
    GetPage(
      name: AppRoutes.adminOrders,
      page: () => const AdminOrdersView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => AdminOrdersController())),
    ),
    GetPage(
      name: AppRoutes.adminOrderDetail,
      page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        return AdminOrderDetailView(
          orderId: args['order_id'] ?? '',
          orderNumber: args['order_number'] ?? '',
        );
      },
    ),
    // GetPage(name: AppRoutes.adminDeliveryZones, page: () => const AdminDeliveryZonesView()),
    // GetPage(name: AppRoutes.adminAddZone, page: () => const AdminAddZoneView()),
    GetPage(name: AppRoutes.adminDeliverySettings, page: () => const AdminDeliverySettingsView()),
    GetPage(
      name: AppRoutes.adminProfile,
      page: () => const AdminProfileView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => ProfileController())),
    ),

    // ── Vendor ──
    GetPage(
      name: AppRoutes.vendorDashboard,
      page: () => const VendorDashboardView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => VendorDashboardController())),
    ),
    GetPage(
      name: AppRoutes.vendorOrders,
      page: () => const VendorOrdersView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => VendorOrdersController())),
    ),
    GetPage(
      name: AppRoutes.vendorOrderDetail,
      page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        return VendorOrderDetailView(
          orderId: args['order_id'] ?? '',
          orderNumber: args['order_number'] ?? '',
        );
      },
    ),
    GetPage(
      name: AppRoutes.vendorMenu,
      page: () => const VendorMenuView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => VendorMenuController())),
    ),
    GetPage(
      name: AppRoutes.vendorAddItem,
      page: () => const AddItemView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => AddItemController())),
    ),
    GetPage(
      name: AppRoutes.vendorCategories,
      page: () => const VendorCategoriesView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => VendorCategoriesController())),
    ),
    GetPage(
      name: AppRoutes.vendorProfile,
      page: () => const VendorProfileView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => ProfileController())),
    ),

    // ── Shared: Notifications ──
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<NotificationsController>()) {
          Get.put(NotificationsController(), permanent: true);
        }
      }),
    ),
  ];
}
