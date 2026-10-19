import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../app/theme/app_colors.dart';
import '../../shared/localization/app_translations.dart';
import '../controllers/notifications_controller.dart';

class NotificationsView extends ConsumerStatefulWidget {
  const NotificationsView({super.key});

  @override
  ConsumerState<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends ConsumerState<NotificationsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationsProvider).refreshAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        title: Text('Notifications'.tr),
        actions: [
          if (ctrl.unreadCount > 0)
            TextButton.icon(
              onPressed: ctrl.markAllAsRead,
              icon: const Icon(Icons.done_all, size: 18),
              label: Text('Read All'.tr),
            ),
        ],
      ),
      body: Builder(builder: (context) {
        if (ctrl.isLoading && ctrl.notifications.isEmpty) {
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
                      color: Colors.white.withValues(alpha: 0.4), fontSize: 16),
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
                if (ctrl.currentPage < ctrl.totalPages) {
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
    final id = n['id']?.toString();
    if (!isRead && id != null) ctrl.markAsRead(id);

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
      ctrl.navigateToOrderFromData(data);
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
                  if (createdAt.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      _formatDate(createdAt),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!isRead)
              Container(
                width: 8,
                height: 8,
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
      case 'vendor_approved':
        return Icons.verified_outlined;
      case 'vendor_suspended':
        return Icons.block_outlined;
      case 'broadcast':
        return Icons.campaign_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _iconColor(String type) {
    switch (type) {
      case 'new_order':
        return AppColors.goldenYellow;
      case 'order_status':
        return AppColors.primaryOrange;
      case 'vendor_approved':
        return AppColors.success;
      case 'vendor_suspended':
        return AppColors.error;
      case 'broadcast':
        return Colors.purpleAccent;
      default:
        return Colors.blueAccent;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inMinutes < 1) return 'Just now'.tr;
      if (diff.inHours < 1) return '${diff.inMinutes}m ago'.tr;
      if (diff.inDays < 1) return '${diff.inHours}h ago'.tr;
      if (diff.inDays < 7) return '${diff.inDays}d ago'.tr;

      return DateFormat('MMM d, h:mm a').format(dt);
    } catch (_) {
      return dateStr;
    }
  }
}
