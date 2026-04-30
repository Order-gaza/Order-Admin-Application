import 'dart:async';
import 'package:get/get.dart';
import '../../app/constants/api_endpoints.dart';
import '../../data/providers/api_provider.dart';

/// Shared notifications controller — works for SA, Admin, Vendor.
class NotificationsController extends GetxController {
  final notifications = <Map<String, dynamic>>[].obs;
  final unreadCount = 0.obs;
  final isLoading = false.obs;
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  Timer? _pollTimer;

  @override
  void onInit() {
    super.onInit();
    fetchUnreadCount();
    fetchNotifications();
    // Poll every 30 seconds for unread count
    _pollTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => fetchUnreadCount(),
    );
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    super.onClose();
  }

  Future<void> fetchUnreadCount() async {
    try {
      final res = await ApiProvider.get(ApiEndpoints.notificationsUnreadCount);
      if (res.success && res.data != null) {
        unreadCount.value = res.data['unread_count'] ?? 0;
      }
    } catch (_) {}
  }

  Future<void> fetchNotifications({bool refresh = false}) async {
    if (refresh) currentPage.value = 1;
    isLoading.value = true;
    try {
      final res = await ApiProvider.get(
        '${ApiEndpoints.notificationsGetAll}?page=${currentPage.value}&limit=25',
      );
      if (res.success && res.data != null) {
        final list = (res.data['notifications'] as List?)
                ?.map((e) => Map<String, dynamic>.from(e))
                .toList() ??
            [];
        if (refresh || currentPage.value == 1) {
          notifications.value = list;
        } else {
          notifications.addAll(list);
        }
        final pagination = res.data['pagination'];
        if (pagination != null) {
          totalPages.value = pagination['total_pages'] ?? 1;
        }
      }
    } catch (_) {}
    isLoading.value = false;
  }

  Future<void> loadMore() async {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      await fetchNotifications();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await ApiProvider.post(
        ApiEndpoints.notificationsMarkRead,
        body: {'notification_id': notificationId},
      );
      final idx = notifications.indexWhere((n) => n['id'] == notificationId);
      if (idx != -1) {
        notifications[idx] = {...notifications[idx], 'is_read': '1'};
        notifications.refresh();
      }
      if (unreadCount.value > 0) unreadCount.value--;
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      await ApiProvider.post(ApiEndpoints.notificationsMarkAllRead, body: {});
      for (var i = 0; i < notifications.length; i++) {
        notifications[i] = {...notifications[i], 'is_read': '1'};
      }
      notifications.refresh();
      unreadCount.value = 0;
    } catch (_) {}
  }

  Future<void> refreshAll() async {
    await fetchNotifications(refresh: true);
    await fetchUnreadCount();
  }
}
