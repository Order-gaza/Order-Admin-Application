/// Route name constants
abstract class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String verifyOtp = '/verify-otp';
  static const String resetPassword = '/reset-password';
  static const String vendorRegister = '/vendor-register';

  // Super Admin
  static const String saDashboard = '/sa/dashboard';
  static const String saAdmins = '/sa/admins';
  static const String saAdminDetail = '/sa/admin-detail';
  static const String saVendors = '/sa/vendors';
  static const String saVendorDetail = '/sa/vendor-detail';
  static const String saCustomers = '/sa/customers';
  static const String saCustomerDetail = '/sa/customer-detail';
  static const String saCreateVendor = '/sa/vendor-create';
  static const String saOrders = '/sa/orders';
  static const String saOrderDetail = '/sa/order-detail';
  static const String saAds = '/sa/advertisements';
  static const String saAddAd = '/sa/advertisements/add';
  static const String saEarnings = '/sa/earnings';
  static const String saFeeConfig = '/sa/fee-config';
  static const String saDeliveryZones = '/sa/delivery-zones';
  static const String saAddZone = '/sa/delivery-zones/add';
  static const String saCategories = '/sa/categories';
  static const String saProfile = '/sa/profile';
  static const String saPointsConfig = '/sa/points-config';
  static const String saPromoCodes = '/sa/promo-codes';
  static const String saPromoCodeDetail = '/sa/promo-code-detail';
  static const String saPromoCodeForm = '/sa/promo-code-form';
  static const String saNotifications = '/sa/notifications';
  static const String saScheduledNotifs = '/sa/scheduled-notifs';

  // Admin
  static const String adminDashboard = '/admin/dashboard';
  static const String adminOrders = '/admin/orders';
  static const String adminOrderDetail = '/admin/order-detail';
  static const String adminDeliveryZones = '/admin/delivery-zones';
  static const String adminAddZone = '/admin/delivery-zones/add';
  static const String adminDeliverySettings = '/admin/delivery-settings';
  static const String adminProfile = '/admin/profile';

  // Vendor
  static const String vendorDashboard = '/vendor/dashboard';
  static const String vendorOrders = '/vendor/orders';
  static const String vendorOrderDetail = '/vendor/order-detail';
  static const String vendorMenu = '/vendor/menu';
  static const String vendorAddItem = '/vendor/menu/add-item';
  static const String vendorCategories = '/vendor/categories';
  static const String vendorProfile = '/vendor/profile';

  // Shared
  static const String notifications = '/notifications';
}
