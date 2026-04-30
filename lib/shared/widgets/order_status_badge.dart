import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/constants/app_constants.dart';

/// Badge widget that shows order status with appropriate color.
/// Returns [SizedBox.shrink] for empty / unknown statuses to avoid
/// rendering a featureless gray oval.
class OrderStatusBadge extends StatelessWidget {
  final String status;

  const OrderStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    // Don't render anything for empty / unset statuses
    if (status.isEmpty) return const SizedBox.shrink();

    final label = AppConstants.orderStatusLabel(status);
    if (label.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: _color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color get _color {
    switch (status) {
      case AppConstants.orderPending:
        return AppColors.statusPending;
      case AppConstants.orderAdminConfirmed:
        return AppColors.statusConfirmed;
      case AppConstants.orderSentToVendor:
        return AppColors.statusSentToVendor;
      case AppConstants.orderVendorAccepted:
        return AppColors.statusAccepted;
      case AppConstants.orderPreparing:
        return AppColors.statusPreparing;
      case AppConstants.orderReadyForPickup:
        return AppColors.statusReady;
      case AppConstants.orderOutForDelivery:
        return AppColors.statusDispatched;
      case AppConstants.orderDelivered:
        return AppColors.statusDelivered;
      case AppConstants.orderCancelled:
        return AppColors.statusCancelled;
      default:
        return AppColors.textSecondary;
    }
  }
}
