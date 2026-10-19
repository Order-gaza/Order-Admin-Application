/// API Endpoints for the Order Delivery backend
class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://appforyou.store/backendOrder',
  );

  // ── Auth ──
  static const String login = '$baseUrl/auth/login.php';
  static const String logout = '$baseUrl/auth/logout.php';
  static const String validateSession = '$baseUrl/auth/validate_session.php';
  static const String forgotPassword = '$baseUrl/auth/forgot_password.php';
  static const String resetPassword = '$baseUrl/auth/reset_password.php';
  static const String verifyOtp = '$baseUrl/auth/verify_otp.php';
  static const String resendOtp = '$baseUrl/auth/resend_otp.php';
  static const String changePassword = '$baseUrl/auth/change_password.php';
  static const String refreshToken = '$baseUrl/auth/refresh_token.php';
  static const String registerVendor = '$baseUrl/auth/register_vendor.php';
  static const String registerFcmToken =
      '$baseUrl/auth/register_fcm_token.php';

  // ── Notifications (shared — works for any authenticated role) ──
  static const String notificationsGetAll =
      '$baseUrl/auth/notifications_get_all.php';
  static const String notificationsUnreadCount =
      '$baseUrl/auth/notifications_unread_count.php';
  static const String notificationsMarkRead =
      '$baseUrl/auth/notifications_mark_read.php';
  static const String notificationsMarkAllRead =
      '$baseUrl/auth/notifications_mark_all_read.php';

  // ── Super Admin: Dashboard ──
  static const String saDashboardStats =
      '$baseUrl/super_admin/dashboard/get_stats.php';
  static const String saDashboardRecentOrders =
      '$baseUrl/super_admin/dashboard/get_recent_orders.php';
  static const String saDashboardRevenueChart =
      '$baseUrl/super_admin/dashboard/get_revenue_chart.php';

  // ── Super Admin: Admins ──
  static const String saAdminsGetAll =
      '$baseUrl/super_admin/admins/get_all.php';
  static const String saAdminsGetById =
      '$baseUrl/super_admin/admins/get_by_id.php';
  static const String saAdminsAdd = '$baseUrl/super_admin/admins/add.php';
  static const String saAdminsUpdate =
      '$baseUrl/super_admin/admins/update.php';
  static const String saAdminsDelete =
      '$baseUrl/super_admin/admins/delete.php';

  static const String saAdminsToggle =
      '$baseUrl/super_admin/admins/toggle_status.php';
  static const String saAdminsResetPassword =
      '$baseUrl/super_admin/admins/reset_password.php';

  // ── Super Admin: Customers ──
  static const String saCustomersGetAll =
      '$baseUrl/super_admin/customers/get_all.php';
  static const String saCustomersGetById =
      '$baseUrl/super_admin/customers/get_by_id.php';
  static const String saCustomersToggle =
      '$baseUrl/super_admin/customers/toggle_status.php';
  static const String saCustomersDelete =
      '$baseUrl/super_admin/customers/delete.php';

  // ── Super Admin: Vendors ──
  static const String saVendorsGetAll =
      '$baseUrl/super_admin/vendors/get_all.php';
  static const String saVendorsGetById =
      '$baseUrl/super_admin/vendors/get_by_id.php';
  static const String saVendorsGetPending =
      '$baseUrl/super_admin/vendors/get_pending.php';
  static const String saVendorsApprove =
      '$baseUrl/super_admin/vendors/approve.php';
  static const String saVendorsSuspend =
      '$baseUrl/super_admin/vendors/suspend.php';
  static const String saVendorsReactivate =
      '$baseUrl/super_admin/vendors/reactivate.php';
  static const String saVendorsReject =
      '$baseUrl/super_admin/vendors/reject.php';
  static const String saVendorsSearch =
      '$baseUrl/super_admin/vendors/search.php';
  static const String saVendorsCreate =
      '$baseUrl/super_admin/vendors/create.php';

  // ── Super Admin: Orders ──
  static const String saOrdersGetAll =
      '$baseUrl/super_admin/orders/get_all.php';
  static const String saOrdersGetById =
      '$baseUrl/super_admin/orders/get_by_id.php';
  static const String saOrdersGetByStatus =
      '$baseUrl/super_admin/orders/get_by_status.php';
  static const String saOrdersSearch =
      '$baseUrl/super_admin/orders/search.php';
  static const String saOrdersCancel =
      '$baseUrl/super_admin/orders/cancel.php';

  // ── Super Admin: Advertisements ──
  static const String saAdsGetAll =
      '$baseUrl/super_admin/advertisements/get_all.php';
  static const String saAdsGetById =
      '$baseUrl/super_admin/advertisements/get_by_id.php';
  static const String saAdsAdd =
      '$baseUrl/super_admin/advertisements/add.php';
  static const String saAdsUpdate =
      '$baseUrl/super_admin/advertisements/update.php';
  static const String saAdsDelete =
      '$baseUrl/super_admin/advertisements/delete.php';
  static const String saAdsToggle =
      '$baseUrl/super_admin/advertisements/toggle_status.php';
  static const String saAdsReorder =
      '$baseUrl/super_admin/advertisements/reorder.php';
  static const String saAdsUploadImage =
      '$baseUrl/super_admin/advertisements/upload_image.php';

  // ── Super Admin: Global Categories ──
  static const String saCategoriesGetAll =
      '$baseUrl/super_admin/categories/get_all.php';
  static const String saCategoriesAdd =
      '$baseUrl/super_admin/categories/add.php';
  static const String saCategoriesUpdate =
      '$baseUrl/super_admin/categories/update.php';
  static const String saCategoriesDelete =
      '$baseUrl/super_admin/categories/delete.php';
  static const String saCategoriesToggle =
      '$baseUrl/super_admin/categories/toggle_status.php';

  // ── Super Admin: Earnings ──
  static const String saEarningsGetAll =
      '$baseUrl/super_admin/earnings/get_all.php';
  static const String saEarningsGetSummary =
      '$baseUrl/super_admin/earnings/get_summary.php';
  static const String saEarningsGetByDateRange =
      '$baseUrl/super_admin/earnings/get_by_date_range.php';
  static const String saEarningsMarkCollected =
      '$baseUrl/super_admin/earnings/mark_collected.php';
  static const String saEarningsMarkBulkCollected =
      '$baseUrl/super_admin/earnings/mark_bulk_collected.php';
  static const String saEarningsExportPdf =
      '$baseUrl/super_admin/earnings/export_pdf.php';

  // ── Super Admin: Fee Config ──
  static const String saFeeConfigGet =
      '$baseUrl/super_admin/fee_config/get.php';
  static const String saFeeConfigUpdate =
      '$baseUrl/super_admin/fee_config/update.php';

  // ── Super Admin: Points Config ──
  static const String saPointsConfigGet =
      '$baseUrl/super_admin/points_config/get.php';
  static const String saPointsConfigUpdate =
      '$baseUrl/super_admin/points_config/update.php';

  // ── Super Admin: Promo Codes ──
  static const String saPromoCodesGetAll =
      '$baseUrl/super_admin/promo_codes/get_all.php';
  static const String saPromoCodesGetById =
      '$baseUrl/super_admin/promo_codes/get_by_id.php';
  static const String saPromoCodesCreate =
      '$baseUrl/super_admin/promo_codes/create.php';
  static const String saPromoCodesUpdate =
      '$baseUrl/super_admin/promo_codes/update.php';
  static const String saPromoCodesToggle =
      '$baseUrl/super_admin/promo_codes/toggle_status.php';
  static const String saPromoCodesDelete =
      '$baseUrl/super_admin/promo_codes/delete.php';
  // ── Super Admin: Broadcast Notifications ──
  static const String saNotificationsSend =
      '$baseUrl/super_admin/notifications/send.php';

  // ── Super Admin: Scheduled Notifications ──
  static const String saScheduledNotifsGetConfig =
      '$baseUrl/super_admin/scheduled_notifs/get_config.php';
  static const String saScheduledNotifsUpdateConfig =
      '$baseUrl/super_admin/scheduled_notifs/update_config.php';
  static const String saScheduledNotifsAddMessage =
      '$baseUrl/super_admin/scheduled_notifs/add_message.php';
  static const String saScheduledNotifsUpdateMessage =
      '$baseUrl/super_admin/scheduled_notifs/update_message.php';
  static const String saScheduledNotifsDeleteMessage =
      '$baseUrl/super_admin/scheduled_notifs/delete_message.php';

  // ── Super Admin: Delivery Zones ──
  static const String saDeliveryZonesGetAll =
      '$baseUrl/super_admin/delivery_zones/get_all.php';
  static const String saDeliveryZonesAdd =
      '$baseUrl/super_admin/delivery_zones/add.php';
  static const String saDeliveryZonesUpdate =
      '$baseUrl/super_admin/delivery_zones/update.php';
  static const String saDeliveryZonesDelete =
      '$baseUrl/super_admin/delivery_zones/delete.php';
  static const String saDeliveryZonesToggle =
      '$baseUrl/super_admin/delivery_zones/toggle_status.php';

  // ── Super Admin: Profile ──
  static const String saProfileGet =
      '$baseUrl/super_admin/profile/get.php';
  static const String saProfileUpdate =
      '$baseUrl/super_admin/profile/update.php';

  // ── Profile (shared — works for any authenticated role) ──
  static const String profileGet = '$baseUrl/profile/get.php';
  static const String profileUpdate = '$baseUrl/profile/update.php';
  static const String profileChangePassword =
      '$baseUrl/profile/change_password.php';

  // ── Admin: Dashboard ──
  static const String adminDashboardStats =
      '$baseUrl/admin/dashboard/get_stats.php';
  static const String adminDashboardRecentOrders =
      '$baseUrl/admin/dashboard/get_recent_orders.php';

  // ── Admin: Orders ──
  static const String adminOrdersGetAll =
      '$baseUrl/admin/orders/get_all.php';
  static const String adminOrdersGetById =
      '$baseUrl/admin/orders/get_by_id.php';
  static const String adminOrdersGetByStatus =
      '$baseUrl/admin/orders/get_by_status.php';
  static const String adminOrdersGetPending =
      '$baseUrl/admin/orders/get_pending.php';
  static const String adminOrdersSearch =
      '$baseUrl/admin/orders/search.php';
  static const String adminOrdersGetStatusHistory =
      '$baseUrl/admin/orders/get_status_history.php';
  static const String adminOrdersConfirm =
      '$baseUrl/admin/orders/confirm.php';
  static const String adminOrdersDispatch =
      '$baseUrl/admin/orders/dispatch.php';
  static const String adminOrdersDeliver =
      '$baseUrl/admin/orders/deliver.php';
  static const String adminOrdersCancel =
      '$baseUrl/admin/orders/cancel.php';

  // ── Admin: Delivery Zones ──
  static const String adminDeliveryZonesGetAll =
      '$baseUrl/admin/delivery_zones/get_all.php';
  static const String adminDeliveryZonesGetById =
      '$baseUrl/admin/delivery_zones/get_by_id.php';
  static const String adminDeliveryZonesAdd =
      '$baseUrl/admin/delivery_zones/add.php';
  static const String adminDeliveryZonesUpdate =
      '$baseUrl/admin/delivery_zones/update.php';
  static const String adminDeliveryZonesDelete =
      '$baseUrl/admin/delivery_zones/delete.php';
  static const String adminDeliveryZonesToggle =
      '$baseUrl/admin/delivery_zones/toggle_status.php';

  // ── Admin: Delivery Fee Settings ──
  static const String adminDeliverySettingsGet =
      '$baseUrl/admin/delivery_settings/get.php';
  static const String adminDeliverySettingsUpdate =
      '$baseUrl/admin/delivery_settings/update.php';
  static const String adminZonePricingGet =
      '$baseUrl/admin/delivery_settings/get_zone_pricing.php';
  static const String adminZonePricingUpdate =
      '$baseUrl/admin/delivery_settings/update_zone_pricing.php';

  // ── Admin: Profile ──
  static const String adminProfileGet = '$baseUrl/admin/profile/get.php';
  static const String adminProfileUpdate =
      '$baseUrl/admin/profile/update.php';

  // ── Vendor: Dashboard ──
  static const String vendorDashboardStats =
      '$baseUrl/vendor/dashboard/get_stats.php';
  static const String vendorDashboardRecentOrders =
      '$baseUrl/vendor/dashboard/get_recent_orders.php';

  // ── Vendor: Orders ──
  static const String vendorOrdersGetAll =
      '$baseUrl/vendor/orders/get_all.php';
  static const String vendorOrdersGetById =
      '$baseUrl/vendor/orders/get_by_id.php';
  static const String vendorOrdersGetPending =
      '$baseUrl/vendor/orders/get_pending.php';
  static const String vendorOrdersGetHistory =
      '$baseUrl/vendor/orders/get_history.php';
  static const String vendorOrdersAccept =
      '$baseUrl/vendor/orders/accept.php';
  static const String vendorOrdersPreparing =
      '$baseUrl/vendor/orders/mark_preparing.php';
  static const String vendorOrdersReady =
      '$baseUrl/vendor/orders/mark_ready.php';

  // ── Vendor: Categories ──
  static const String vendorCategoriesGetAll =
      '$baseUrl/vendor/categories/get_all.php';
  static const String vendorCategoriesAdd =
      '$baseUrl/vendor/categories/add.php';
  static const String vendorCategoriesUpdate =
      '$baseUrl/vendor/categories/update.php';
  static const String vendorCategoriesDelete =
      '$baseUrl/vendor/categories/delete.php';
  static const String vendorCategoriesToggle =
      '$baseUrl/vendor/categories/toggle_status.php';
  static const String vendorCategoriesReorder =
      '$baseUrl/vendor/categories/reorder.php';
  static const String vendorCategoriesGetGlobal =
      '$baseUrl/vendor/categories/get_global.php';

  // ── Vendor: Menu Items ──
  static const String vendorItemsGetAll =
      '$baseUrl/vendor/items/get_all.php';
  static const String vendorItemsGetById =
      '$baseUrl/vendor/items/get_by_id.php';
  static const String vendorItemsGetByCategory =
      '$baseUrl/vendor/items/get_by_category.php';
  static const String vendorItemsAdd = '$baseUrl/vendor/items/add.php';
  static const String vendorItemsUpdate =
      '$baseUrl/vendor/items/update.php';
  static const String vendorItemsDelete =
      '$baseUrl/vendor/items/delete.php';
  static const String vendorItemsToggle =
      '$baseUrl/vendor/items/toggle_availability.php';
  static const String vendorItemsUploadImage =
      '$baseUrl/vendor/items/upload_image.php';
  static const String vendorItemsDeleteImage =
      '$baseUrl/vendor/items/delete_image.php';

  // ── Vendor: Profile ──
  static const String vendorProfileGet = '$baseUrl/vendor/profile/get.php';
  static const String vendorProfileUpdate =
      '$baseUrl/vendor/profile/update.php';
  static const String vendorToggleOpen =
      '$baseUrl/vendor/profile/toggle_open.php';
  static const String vendorProfileUploadLogo =
      '$baseUrl/vendor/profile/upload_logo.php';
  static const String vendorProfileUploadCover =
      '$baseUrl/vendor/profile/upload_cover.php';
  static const String vendorProfileDeleteLogo =
      '$baseUrl/vendor/profile/delete_logo.php';
  static const String vendorProfileDeleteCover =
      '$baseUrl/vendor/profile/delete_cover.php';
}
