import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/localization/app_translations.dart';
import '../../shared/utils/app_navigator.dart';
import '../../shared/utils/sound_player_stub.dart'
    if (dart.library.html) '../../shared/utils/sound_player_web.dart'
    if (dart.library.io) '../../shared/utils/sound_player_io.dart';
import '../../app/constants/api_endpoints.dart';
import '../../app/routes/app_routes.dart';
import '../../data/providers/api_provider.dart';

/// Shared notifications controller — works for SA, Admin, Vendor.
class NotificationsController extends ChangeNotifier {
  static NotificationsController? _instance;
  static NotificationsController get to =>
      _instance ??= NotificationsController();

  List<Map<String, dynamic>> notifications = [];
  int unreadCount = 0;
  bool isLoading = false;
  int currentPage = 1;
  int totalPages = 1;
  Timer? _pollTimer;

  final Set<String> _seenNotificationIds = {};
  bool _isInitialFetch = true;

  NotificationsController() {
    _instance = this;
    fetchUnreadCount();
    fetchNotifications();

    final isDesktop = defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS;
    final pollInterval = isDesktop ? 10 : 30;

    _pollTimer = Timer.periodic(
      Duration(seconds: pollInterval),
      (_) => _pollCheck(),
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _pollCheck() async {
    final prevCount = unreadCount;
    await fetchUnreadCount();
    final isDesktop = defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS;

    if (isDesktop || unreadCount > prevCount) {
      await fetchNotifications(refresh: true, isPolling: true);
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      final res = await ApiProvider.get(ApiEndpoints.notificationsUnreadCount);
      if (res.success && res.data != null) {
        unreadCount = res.data['unread_count'] ?? 0;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> fetchNotifications(
      {bool refresh = false, bool isPolling = false}) async {
    if (refresh) currentPage = 1;
    if (!isPolling) {
      isLoading = true;
      notifyListeners();
    }
    try {
      final res = await ApiProvider.get(
        '${ApiEndpoints.notificationsGetAll}?page=$currentPage&limit=25',
      );
      if (res.success && res.data != null) {
        final list = (res.data['notifications'] as List?)
                ?.map((e) => Map<String, dynamic>.from(e))
                .toList() ??
            [];
        if (refresh || currentPage == 1) {
          notifications = list;
        } else {
          notifications.addAll(list);
        }
        final pagination = res.data['pagination'];
        if (pagination != null) {
          totalPages = pagination['total_pages'] ?? 1;
        }

        _checkForNewNotifications(list);
      }
    } catch (_) {}
    if (!isPolling) {
      isLoading = false;
    }
    notifyListeners();
  }

  void _checkForNewNotifications(List<Map<String, dynamic>> list) {
    if (list.isEmpty) return;

    if (_isInitialFetch) {
      for (final n in list) {
        final id = n['id']?.toString();
        if (id != null && id.isNotEmpty) {
          _seenNotificationIds.add(id);
        }
      }
      _isInitialFetch = false;
      return;
    }

    final newUnreadNotifications = <Map<String, dynamic>>[];
    for (final n in list) {
      final id = n['id']?.toString();
      final isRead = n['is_read']?.toString() == '1';
      if (id != null &&
          id.isNotEmpty &&
          !isRead &&
          !_seenNotificationIds.contains(id)) {
        _seenNotificationIds.add(id);
        newUnreadNotifications.add(n);
      }
    }

    for (final n in newUnreadNotifications) {
      triggerNotificationAlertAndSound(n);
    }
  }

  void triggerNotificationAlertAndSound(Map<String, dynamic> n) {
    final title = n['title']?.toString() ?? 'Notification'.tr;
    final body = n['body']?.toString() ?? '';

    _playAlertSound();

    if (AppNavigator.isSnackbarOpen == false) {
      AppNavigator.snackbar(
        title,
        body,
        backgroundColor: const Color(0xFF1E1E2E),
        colorText: Colors.white,
        icon: const Icon(
          Icons.notifications_active,
          color: Color(0xFFFF6B35),
          size: 28,
        ),
        duration: const Duration(seconds: 6),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  void _playAlertSound() {
    try {
      if (kIsWeb) {
        playWebSound();
      } else {
        SystemSound.play(SystemSoundType.alert);
        Future.delayed(const Duration(milliseconds: 250), () {
          SystemSound.play(SystemSoundType.alert);
        });
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[NotificationSound] Error playing sound: $e');
    }
  }

  void navigateToOrderFromData(Map<String, dynamic> data) {
    final orderId = data['order_id'];
    final orderNumber = data['order_number'];
    if (orderId != null && orderId.toString().isNotEmpty) {
      String role = 'admin';
      try {
        role = ApiProvider.storedRole ?? 'admin';
      } catch (_) {}

      String route;
      if (role == 'vendor') {
        route = AppRoutes.vendorOrderDetail;
      } else if (role == 'super_admin') {
        route = AppRoutes.saOrderDetail;
      } else {
        route = AppRoutes.adminOrderDetail;
      }

      try {
        AppNavigator.toNamed(route, arguments: {
          'order_id': orderId.toString(),
          'order_number': orderNumber?.toString() ?? '',
        });
      } catch (_) {}
    }
  }

  Future<void> loadMore() async {
    if (currentPage < totalPages) {
      currentPage++;
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
      }
      if (unreadCount > 0) unreadCount--;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      await ApiProvider.post(ApiEndpoints.notificationsMarkAllRead, body: {});
      for (var i = 0; i < notifications.length; i++) {
        notifications[i] = {...notifications[i], 'is_read': '1'};
      }
      unreadCount = 0;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> refreshAll() async {
    await fetchNotifications(refresh: true);
    await fetchUnreadCount();
  }
}

final notificationsProvider = ChangeNotifierProvider<NotificationsController>(
    (ref) => NotificationsController.to);
