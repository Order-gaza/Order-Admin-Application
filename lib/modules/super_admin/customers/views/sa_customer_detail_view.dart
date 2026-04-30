import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/constants/api_endpoints.dart';
import '../../../../data/providers/api_provider.dart';

class SaCustomerDetailView extends StatefulWidget {
  final String customerId;
  final String customerName;

  const SaCustomerDetailView({
    super.key,
    required this.customerId,
    required this.customerName,
  });

  @override
  State<SaCustomerDetailView> createState() => _SaCustomerDetailViewState();
}

class _SaCustomerDetailViewState extends State<SaCustomerDetailView> {
  bool _loading = true;
  Map<String, dynamic> _customer = {};
  Map<String, dynamic> _stats = {};
  List<dynamic> _recentOrders = [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final res = await ApiProvider.post(ApiEndpoints.saCustomersGetById,
          body: {'customer_id': widget.customerId});
      if (res.success && res.data != null) {
        final d = res.data as Map<String, dynamic>;
        setState(() {
          _customer = d['customer'] ?? {};
          _stats = d['stats'] ?? {};
          _recentOrders = d['recent_orders'] ?? [];
        });
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      body: _loading
          ? const Center(
              child:
                  CircularProgressIndicator(color: AppColors.primaryOrange))
          : CustomScrollView(
              slivers: [
                _buildAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Stats Cards ──
                        _statsRow(),
                        const SizedBox(height: 20),

                        // ── Contact Info ──
                        _sectionTitle('Contact Information'.tr),
                        const SizedBox(height: 10),
                        _infoCard([
                          _infoRow(Icons.person, 'Name'.tr,
                              _customer['name'] ?? '—'),
                          _infoRow(Icons.email, 'Email'.tr,
                              _customer['email'] ?? '—',
                              copyable: true),
                          _infoRow(Icons.phone, 'Phone'.tr,
                              _customer['phone'] ?? '—',
                              copyable: true),
                        ]),
                        const SizedBox(height: 20),

                        // ── Order Statistics ──
                        _sectionTitle('Order Statistics'.tr),
                        const SizedBox(height: 10),
                        _infoCard([
                          _infoRow(
                              Icons.shopping_bag,
                              'Total Orders'.tr,
                              '${_stats['total_orders'] ?? 0}'),
                          _infoRow(
                              Icons.attach_money,
                              'Total Spent'.tr,
                              '₪${(_stats['total_spent'] ?? 0).toStringAsFixed(2)}'),
                          _infoRow(
                              Icons.calendar_today,
                              'Last Order'.tr,
                              _stats['last_order_date'] ?? 'Never'.tr),
                          _infoRow(
                              Icons.location_on,
                              'Saved Addresses'.tr,
                              '${_stats['address_count'] ?? 0}'),
                        ]),
                        const SizedBox(height: 20),

                        // ── Status Breakdown ──
                        if (_stats['status_breakdown'] != null &&
                            _stats['status_breakdown'] is Map &&
                            (_stats['status_breakdown'] as Map).isNotEmpty) ...[
                          _sectionTitle('Order Status Breakdown'.tr),
                          const SizedBox(height: 10),
                          _statusBreakdownCard(),
                          const SizedBox(height: 20),
                        ],

                        // ── Recent Orders ──
                        _sectionTitle(
                            'Recent Orders'.tr + ' (${_recentOrders.length})'),
                        const SizedBox(height: 10),
                        if (_recentOrders.isEmpty)
                          _card(
                            child: Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: Column(
                                  children: [
                                    Icon(Icons.receipt_long,
                                        size: 36,
                                        color: Colors.white
                                            .withValues(alpha: 0.2)),
                                    const SizedBox(height: 8),
                                    Text('No orders yet'.tr,
                                        style: TextStyle(
                                            color: Colors.white
                                                .withValues(alpha: 0.4),
                                            fontSize: 13)),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else
                          ..._recentOrders
                              .map((o) => _orderCard(o))
                              ,
                        const SizedBox(height: 20),

                        // ── System Info ──
                        _sectionTitle('System Info'.tr),
                        const SizedBox(height: 10),
                        _infoCard([
                          _infoRow(Icons.fingerprint, 'User ID'.tr,
                              _customer['id']?.toString() ?? '—',
                              copyable: true),
                          _infoRow(Icons.calendar_today, 'Registered'.tr,
                              _customer['created_at'] ?? '—'),
                          _infoRow(Icons.update, 'Updated'.tr,
                              _customer['updated_at'] ?? '—'),
                        ]),
                        const SizedBox(height: 24),

                        // ── Actions ──
                        _actionsSection(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  SliverAppBar _buildAppBar() {
    final isActive =
        _customer['is_active'] == true || _customer['is_active'] == 1;
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.charcoalBlack,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.charcoalBlack, Color(0xFF2C2C2C)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isActive
                        ? [AppColors.primaryOrange, AppColors.darkOrange]
                        : [
                            AppColors.textSecondary,
                            const Color(0xFF555555)
                          ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    (_customer['name'] ?? 'C')[0].toUpperCase(),
                    style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _customer['name'] ?? widget.customerName,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: (isActive ? AppColors.success : AppColors.error)
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isActive ? 'Active'.tr : 'Inactive'.tr,
                  style: TextStyle(
                      color:
                          isActive ? AppColors.success : AppColors.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _fetch,
        ),
      ],
    );
  }

  Widget _statsRow() {
    return Row(
      children: [
        _statCard('${_stats['total_orders'] ?? 0}',
          'Orders'.tr,
          AppColors.primaryOrange,
        ),
        const SizedBox(width: 10),
        _statCard('₪${(_stats['total_spent'] ?? 0).toStringAsFixed(0)}',
          'Total Spent'.tr,
          AppColors.success,
        ),
        const SizedBox(width: 10),
        _statCard('${_stats['address_count'] ?? 0}',
          'Addresses'.tr,
          AppColors.info,
        ),
      ],
    );
  }

  Widget _statCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            Text(label,
                style: TextStyle(
                    color: color.withValues(alpha: 0.7), fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _statusBreakdownCard() {
    final breakdown = _stats['status_breakdown'] is Map
        ? Map<String, dynamic>.from(_stats['status_breakdown'])
        : <String, dynamic>{};
    return _card(
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: breakdown.entries.map((e) {
          final color = _statusColor(e.key);
          return Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${e.value}',
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(width: 4),
                Text(_formatStatus(e.key),
                    style: TextStyle(color: color, fontSize: 12)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _orderCard(dynamic order) {
    final status = order['status'] ?? '';
    final color = _statusColor(status);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.receipt, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('#${order['order_number'] ?? ''}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
                const SizedBox(height: 2),
                Text(order['vendor_name'] ?? 'Unknown vendor'.tr,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                Text(order['created_at'] ?? '',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₪${order['total_amount'] ?? 0}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14)),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _formatStatus(status),
                  style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionsSection() {
    final isActive =
        _customer['is_active'] == true || _customer['is_active'] == 1;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              final res = await ApiProvider.post(
                ApiEndpoints.saCustomersToggle,
                body: {'customer_id': widget.customerId},
              );
              if (res.success) {
                Get.snackbar('Success'.tr, res.message?.tr ?? 'Status updated'.tr,
                    backgroundColor: const Color(0xFF4CAF50),
                    colorText: const Color(0xFFFFFFFF));
                _fetch();
              }
            },
            icon: Icon(
              isActive ? Icons.block : Icons.check_circle_outline,
              color: isActive ? AppColors.warning : AppColors.success,
            ),
            label: Text(
              isActive ? 'Deactivate Customer'.tr : 'Activate Customer'.tr,
              style: TextStyle(
                  color: isActive ? AppColors.warning : AppColors.success),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                  color: isActive ? AppColors.warning : AppColors.success),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _confirmDeleteFromDetail(),
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            label: Text('Delete Customer'.tr,
                style: TextStyle(color: AppColors.error)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  void _confirmDeleteFromDetail() {
    final totalOrders = _stats['total_orders'] ?? 0;
    Get.dialog(AlertDialog(
      backgroundColor: AppColors.darkSurface,
      title: Text('Delete Customer'.tr,
          style: const TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Are you sure you want to delete "%s"?'.tr.replaceFirst('%s', _customer['name'] ?? ''),
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          if (totalOrders > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: AppColors.warning, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This customer has '.tr + '$totalOrders ' + 'order(s). The account will be deactivated instead.'.tr,
                      style: const TextStyle(
                          color: AppColors.warning, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Get.back(), child: Text('Cancel'.tr)),
        ElevatedButton(
          style:
              ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          onPressed: () async {
            Get.back();
            final res = await ApiProvider.post(
              ApiEndpoints.saCustomersDelete,
              body: {'customer_id': widget.customerId},
            );
            if (res.success) {
              Get.snackbar('Done'.tr, res.message?.tr ?? 'Customer removed'.tr,
                  backgroundColor: const Color(0xFF4CAF50),
                  colorText: const Color(0xFFFFFFFF));
              Get.back(result: true);
            }
          },
          child: Text(totalOrders > 0 ? 'Deactivate'.tr : 'Delete'.tr),
        ),
      ],
    ));
  }

  // ── Helpers ──

  Color _statusColor(String status) {
    switch (status) {
      case 'delivered':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      case 'pending':
        return AppColors.warning;
      case 'preparing':
      case 'admin_confirmed':
      case 'sent_to_vendor':
      case 'vendor_accepted':
        return AppColors.info;
      case 'ready_for_pickup':
      case 'out_for_delivery':
        return AppColors.primaryOrange;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatStatus(String status) {
    return status
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty
            ? '${w[0].toUpperCase()}${w.substring(1)}'
            : '')
        .join(' ');
  }

  Widget _sectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600));
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: AppColors.divider.withValues(alpha: 0.3)),
      ),
      child: child,
    );
  }

  Widget _infoCard(List<Widget> rows) {
    return _card(
      child: Column(
        children: rows
            .expand((r) => [
                  r,
                  if (r != rows.last)
                    Divider(
                        height: 20,
                        color:
                            AppColors.divider.withValues(alpha: 0.2))
                ])
            .toList(),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value,
      {bool copyable = false}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        SizedBox(
          width: 110,
          child: Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              overflow: TextOverflow.ellipsis),
        ),
        if (copyable)
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              Get.snackbar('Copied'.tr, '$label ' + 'copied'.tr,
                  backgroundColor: AppColors.cardDark,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 1));
            },
            icon: const Icon(Icons.copy, size: 14, color: AppColors.textSecondary),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            visualDensity: VisualDensity.compact,
            splashRadius: 14,
          ),
      ],
    );
  }
}
