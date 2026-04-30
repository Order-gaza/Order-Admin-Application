import 'package:get/get.dart';

/// Application-wide constants matching the PHP backend
class AppConstants {
  AppConstants._();

  // ── User Roles ──
  static const String roleSuperAdmin = 'super_admin';
  static const String roleAdmin = 'admin';
  static const String roleVendor = 'vendor';
  static const String roleCustomer = 'customer';

  // ── Order Statuses ──
  static const String orderPending = 'pending';
  static const String orderAdminConfirmed = 'admin_confirmed';
  static const String orderSentToVendor = 'sent_to_vendor';
  static const String orderVendorAccepted = 'vendor_accepted';
  static const String orderPreparing = 'preparing';
  static const String orderReadyForPickup = 'ready_for_pickup';
  static const String orderOutForDelivery = 'out_for_delivery';
  static const String orderDelivered = 'delivered';
  static const String orderCancelled = 'cancelled';

  // ── Vendor Statuses ──
  static const String vendorPending = 'pending';
  static const String vendorApproved = 'approved';
  static const String vendorSuspended = 'suspended';
  static const String vendorRejected = 'rejected';

  // ── Payment ──
  static const String payCash = 'cash_on_delivery';
  static const String payBank = 'bank_transfer';
  static const String paymentPending = 'pending';
  static const String paymentCollected = 'collected';
  static const String paymentFailed = 'failed';

  // ── Fee Models ──
  static const String feeFlat = 'flat_per_order';
  static const String feePercentage = 'percentage';

  // ── Storage Keys ──
  static const String storageToken = 'auth_token';
  static const String storageRole = 'user_role';
  static const String storageUserId = 'user_id';
  static const String storageUserName = 'user_name';
  static const String storageUserEmail = 'user_email';
  static const String storageVendorId = 'vendor_id';
  static const String storageVendorName = 'vendor_name';

  // ── Human-readable status labels ──
  static String orderStatusLabel(String status) {
    switch (status) {
      case orderPending:
        return 'Pending'.tr;
      case orderAdminConfirmed:
        return 'Confirmed'.tr;
      case orderSentToVendor:
        return 'Sent to Vendor'.tr;
      case orderVendorAccepted:
        return 'Accepted'.tr;
      case orderPreparing:
        return 'Preparing'.tr;
      case orderReadyForPickup:
        return 'Ready'.tr;
      case orderOutForDelivery:
        return 'Out for Delivery'.tr;
      case orderDelivered:
        return 'Delivered'.tr;
      case orderCancelled:
        return 'Cancelled'.tr;
      default:
        return status.tr;
    }
  }

  static String vendorStatusLabel(String status) {
    switch (status) {
      case vendorPending:
        return 'Pending Approval'.tr;
      case vendorApproved:
        return 'Approved'.tr;
      case vendorSuspended:
        return 'Suspended'.tr;
      case vendorRejected:
        return 'Rejected'.tr;
      default:
        return status.tr;
    }
  }

  static String roleLabel(String role) {
    switch (role) {
      case roleSuperAdmin:
        return 'Super Admin'.tr;
      case roleAdmin:
        return 'Admin'.tr;
      case roleVendor:
        return 'Vendor'.tr;
      case roleCustomer:
        return 'Customer'.tr;
      default:
        return role.tr;
    }
  }
}
