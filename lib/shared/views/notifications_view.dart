import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/providers/api_provider.dart';
import 'package:intl/intl.dart';
import '../../app/theme/app_colors.dart';
import '../../app/routes/app_routes.dart';
import '../controllers/notifications_controller.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<NotificationsController>();
    ctrl.refreshAll();

    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        title: Text('Notifications'.tr),
        actions: [
          Obx(() => ctrl.unreadCount.value > 0
              ? TextButton.icon(
                  onPressed: ctrl.markAllAsRead,
                  icon: const Icon(Icons.done_all, size: 18),
                  label: Text('Read All'.tr),
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoading.value && ctrl.notifications.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryOrange),
          );
        }
        if (ctrl.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.notifications_off_outlined,
                    size: 64, color: Colors.white.withValues(alpha: 0.2)),
                const SizedBox(height: 16),
                Text(
                  'No notifications yet'.tr,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 16),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          color: AppColors.primaryOrange,
          onRefresh: ctrl.refreshAll,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: ctrl.notifications.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              if (i == ctrl.notifications.length) {
                if (ctrl.currentPage.value < ctrl.totalPages.value) {
                  return Center(
                    child: TextButton(
                      onPressed: ctrl.loadMore,
                      child: Text('Load More'.tr),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }
              final n = ctrl.notifications[i];
              return _NotificationCard(
                notification: n,
                onTap: () => _handleTap(n, ctrl),
              );
            },
          ),
        );
      }),
    );
  }

  void _handleTap(Map<String, dynamic> n, NotificationsController ctrl) {
    final isRead = n['is_read']?.toString() == '1';
    if (!isRead) ctrl.markAsRead(n['id']);

    final type = n['type'] ?? '';
    Map<String, dynamic>? data;
    final dataStr = n['data'];
    if (dataStr is String && dataStr.isNotEmpty) {
      try {
        data = Map<String, dynamic>.from(jsonDecode(dataStr));
      } catch (_) {}
    } else if (dataStr is Map) {
      data = Map<String, dynamic>.from(dataStr);
    }

    if (data != null &&
        (type == 'new_order' || type == 'order_status') &&
        data['order_id'] != null) {
      final role = _getCurrentRole();
      String route;
      switch (role) {
        case 'super_admin':
          route = AppRoutes.saOrderDetail;
          break;
        case 'vendor':
          route = AppRoutes.vendorOrderDetail;
          break;
        default:
          route = AppRoutes.adminOrderDetail;
      }
      Get.toNamed(route, arguments: {
        'order_id': data['order_id'],
        'order_number': data['order_number'] ?? '',
      });
    }
  }

  String _getCurrentRole() {
    try {
      return ApiProvider.storedRole ?? 'admin';
    } catch (_) {
      return 'admin';
    }
  }
}

class _NotificationCard extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isRead = notification['is_read']?.toString() == '1';
    final type = notification['type'] ?? '';
    final title = notification['title'] ?? '';
    final body = notification['body'] ?? '';
    final createdAt = notification['created_at'] ?? '';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isRead
              ? AppColors.cardDark
              : AppColors.primaryOrange.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isRead
                ? AppColors.divider.withValues(alpha: 0.2)
                : AppColors.primaryOrange.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _iconColor(type).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_icon(type), color: _iconColor(type), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: isRead ? FontWeight.w400 : FontWeight.w700,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatTime(createdAt),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (!isRead)
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 6),
                decoration: const BoxDecoration(
                  color: AppColors.primaryOrange,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _icon(String type) {
    switch (type) {
      case 'new_order':
        return Icons.shopping_bag_outlined;
      case 'order_status':
        return Icons.local_shipping_outlined;
      case 'promo':
        return Icons.campaign_outlined;
      case 'system':
        return Icons.info_outline;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _iconColor(String type) {
    switch (type) {
      case 'new_order':
        return AppColors.primaryOrange;
      case 'order_status':
        return AppColors.info;
      case 'promo':
        return AppColors.goldenYellow;
      case 'system':
        return AppColors.statusPreparing;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatTime(String ts) {
    if (ts.isEmpty) return '';
    try {
      // DB stores timestamps in UTC — append 'Z' so Dart parses as UTC,
      // then convert to local for correct time-ago calculation.
      final utcStr = ts.endsWith('Z') ? ts : '${ts.replaceAll(' ', 'T')}Z';
      final dt = DateTime.parse(utcStr).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return DateFormat('MMM d, yyyy').format(dt);
    } catch (_) {
      return ts;
    }
  }
}
