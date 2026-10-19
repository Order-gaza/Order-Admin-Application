import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/services/secure_storage_service.dart';
import '../../shared/utils/app_navigator.dart';
import '../../app/constants/api_endpoints.dart';
import '../../app/routes/app_routes.dart';
import '../../data/providers/api_provider.dart';
import '../controllers/notifications_controller.dart';

/// Top-level background message handler (must be a top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) debugPrint('[FCM] Background message: ${message.messageId}');
}

class FcmService extends ChangeNotifier {
  static FcmService? _instance;
  static FcmService get to => _instance ??= FcmService();

  // Nullable so desktop doesn't crash resolving native plugins
  FirebaseMessaging? _messaging;
  FlutterLocalNotificationsPlugin? _localNotifications;

  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'order_notifications',
    'Order Notifications',
    description: 'Notifications for order status updates and new orders',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
    showBadge: true,
  );

  FcmService() {
    _instance = this;
  }

  /// Initialize FCM (no-op on Windows/Linux/macOS; partial on web — no local notifications)
  Future<FcmService> init() async {
    _instance = this;
    final isDesktop = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS);

    if (isDesktop) {
      if (kDebugMode) debugPrint('[FCM] Desktop platform — skipping FCM init');
      return this;
    }

    _messaging = FirebaseMessaging.instance;

    // flutter_local_notifications is not supported on web — skip on web
    if (!kIsWeb) {
      _localNotifications = FlutterLocalNotificationsPlugin();

      // Create notification channel on Android
      await _localNotifications!
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);

      // Initialize local notifications
      const androidSettings =
          AndroidInitializationSettings('@drawable/ic_notification');
      const initSettings = InitializationSettings(android: androidSettings);
      await _localNotifications!.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
    }

    // Request permission
    final settings = await _messaging!.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    if (kDebugMode) {
      debugPrint('[FCM] Permission: ${settings.authorizationStatus}');
    }

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      final token = await _messaging!.getToken();
      if (token != null) _registerTokenWithBackend(token);
      _messaging!.onTokenRefresh.listen(_registerTokenWithBackend);
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
      final initialMessage = await _messaging!.getInitialMessage();
      if (initialMessage != null) _handleNotificationTap(initialMessage);
    }

    return this;
  }

  Future<void> _registerTokenWithBackend(String token) async {
    try {
      final authToken = SecureStorageService.instance.read('auth_token');
      if (authToken == null) return;
      // Send correct device type so backend can distinguish channels
      final deviceType = kIsWeb ? 'web' : 'android';
      await ApiProvider.post(
        ApiEndpoints.registerFcmToken,
        body: {'fcm_token': token, 'device_type': deviceType},
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[FCM] Failed to register token: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification != null && _localNotifications != null) {
      _localNotifications!.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@drawable/ic_notification',
            playSound: true,
            enableVibration: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
      _unreadCount++;
      notifyListeners();
      try {
        NotificationsController.to.fetchUnreadCount();
        NotificationsController.to.fetchNotifications(refresh: true);
      } catch (_) {}

      if (AppNavigator.isSnackbarOpen == false) {
        AppNavigator.snackbar(
          notification.title ?? 'Notification',
          notification.body ?? '',
          backgroundColor: const Color(0xFF1E1E2E),
          colorText: Colors.white,
          icon: const Icon(Icons.notifications_active,
              color: Color(0xFFFF6B35)),
          duration: const Duration(seconds: 4),
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(12),
          borderRadius: 12,
        );
      }
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    _navigateToOrder(message.data);
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final data =
            jsonDecode(response.payload!) as Map<String, dynamic>;
        _navigateToOrder(data);
      } catch (_) {}
    }
  }

  void _navigateToOrder(Map<String, dynamic> data) {
    final orderId = data['order_id'];
    final orderNumber = data['order_number'];
    if (orderId != null && orderId.toString().isNotEmpty) {
      final role = SecureStorageService.instance.read('user_role') ?? '';
      String route;
      if (role == 'vendor') {
        route = AppRoutes.vendorOrderDetail;
      } else if (role == 'admin') {
        route = AppRoutes.adminOrderDetail;
      } else {
        route = AppRoutes.saOrderDetail;
      }
      try {
        AppNavigator.toNamed(route, arguments: {
          'order_id': orderId.toString(),
          'order_number': orderNumber?.toString() ?? '',
        });
      } catch (_) {}
    }
  }

  Future<void> refreshToken() async {
    final token = await _messaging?.getToken();
    if (token != null) await _registerTokenWithBackend(token);
  }
}

final fcmServiceProvider =
    ChangeNotifierProvider<FcmService>((ref) => FcmService.to);
