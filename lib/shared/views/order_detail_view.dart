import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/constants/api_endpoints.dart';
import '../../../data/providers/api_provider.dart';
import '../widgets/order_status_badge.dart';

/// Shared Order Detail screen used by SA, Admin, and Vendor.
/// Pass [getByIdEndpoint] for the role-specific endpoint.
/// Pass [cancelEndpoint] if cancellation is allowed (SA / Admin).
/// Pass [confirmEndpoint], [dispatchEndpoint], [deliverEndpoint] for Admin role.
class OrderDetailView extends StatefulWidget {
  final String orderId;
  final String orderNumber;
  final String getByIdEndpoint;
  final String? cancelEndpoint;
  final String? confirmEndpoint;
  final String? dispatchEndpoint;
  final String? deliverEndpoint;
  // Vendor-specific action endpoints
  final String? acceptEndpoint;
  final String? preparingEndpoint;
  final String? readyEndpoint;
  // Role hint for showing appropriate financial sections
  final String role;

  const OrderDetailView({
    super.key,
    required this.orderId,
    required this.orderNumber,
    required this.getByIdEndpoint,
    this.cancelEndpoint,
    this.confirmEndpoint,
    this.dispatchEndpoint,
    this.deliverEndpoint,
    this.acceptEndpoint,
    this.preparingEndpoint,
    this.readyEndpoint,
    this.role = '',
  });

  @override
  State<OrderDetailView> createState() => _OrderDetailViewState();
}

class _OrderDetailViewState extends State<OrderDetailView> {
  Map<String, dynamic>? order;
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> history = [];
  List<Map<String, dynamic>> vendors = [];
  Map<String, dynamic>? financialReceipt; // Admin role
  Map<String, dynamic>? revenueBreakdown; // SA role
  bool isLoading = true;
  final fmt = NumberFormat.currency(symbol: '₪', decimalDigits: 2);
  final dateFmt = DateFormat('dd MMM yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => isLoading = true);
    try {
      final res = await ApiProvider.get(
          '${widget.getByIdEndpoint}?id=${widget.orderId}');
      if (res.success && res.data != null) {
        final d = res.data as Map<String, dynamic>;
        setState(() {
          order = _normalizeOrder(d['order'] as Map<String, dynamic>?);
          items = List<Map<String, dynamic>>.from(d['items'] ?? []);
          history =
              List<Map<String, dynamic>>.from(d['status_history'] ?? []);
          vendors = List<Map<String, dynamic>>.from(d['vendors'] ?? []);
          // Financial data (role-specific)
          if (d['financial_receipt'] != null) {
            financialReceipt =
                Map<String, dynamic>.from(d['financial_receipt']);
          }
          if (d['revenue_breakdown'] != null) {
            revenueBreakdown =
                Map<String, dynamic>.from(d['revenue_breakdown']);
          }
        });
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// Normalize field names — view_order_detail returns 'order_status'
  /// but we always read 'status' in the UI.
  Map<String, dynamic>? _normalizeOrder(Map<String, dynamic>? raw) {
    if (raw == null) return null;
    final m = Map<String, dynamic>.from(raw);
    // view_order_detail uses 'order_status', view_admin_orders uses 'status'
    if (m['status'] == null && m['order_status'] != null) {
      m['status'] = m['order_status'];
    }
    // view_order_detail uses 'order_id' for the id
    if (m['id'] == null && m['order_id'] != null) {
      m['id'] = m['order_id'];
    }
    return m;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        title: Text(widget.orderNumber),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange))
          : order == null
              ? Center(
                  child: Text('Order not found'.tr,
                      style: TextStyle(color: Colors.white)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Status + price header ──
                      _card(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        order!['order_number'] ??
                                            widget.orderNumber,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        order!['customer_name'] ?? '',
                                        style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                                OrderStatusBadge(
                                    status: order!['status'] ?? ''),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(height: 1, color: AppColors.divider),
                            const SizedBox(height: 12),
                            _row('Total'.tr,
                                fmt.format(double.tryParse(
                                        order!['total_amount']
                                                ?.toString() ??
                                            '0') ??
                                    0),
                                AppColors.primaryOrange),
                            _row('Delivery Fee'.tr,
                                fmt.format(double.tryParse(
                                        order!['delivery_fee']
                                                ?.toString() ??
                                            '0') ??
                                    0),
                                AppColors.info),
                            if (order!['multi_vendor_surcharge'] != null &&
                                (double.tryParse(order!['multi_vendor_surcharge']?.toString() ?? '0') ?? 0) > 0)
                              _row('رسوم تعدد المتاجر',
                                  fmt.format(double.tryParse(
                                          order!['multi_vendor_surcharge']
                                                  ?.toString() ??
                                              '0') ??
                                      0),
                                  AppColors.warning),
                            if (order!['service_fee'] != null)
                              _row('Service Fee'.tr,
                                  fmt.format(double.tryParse(
                                          order!['service_fee']
                                                  ?.toString() ??
                                              '0') ??
                                      0),
                                  AppColors.info),
                            if (order!['delivery_address'] != null)
                              _row('Address'.tr,
                                  order!['delivery_address'], Colors.white),
                            if (order!['customer_notes'] != null &&
                                order!['customer_notes']
                                    .toString()
                                    .isNotEmpty)
                              _row('Notes'.tr, order!['customer_notes'],
                                  AppColors.goldenYellow),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── Quick Call Buttons ──
                      _callButtonsRow(),
                      const SizedBox(height: 16),

                      // ── Financial Receipt (Admin) ──
                      if (financialReceipt != null &&
                          widget.role == 'admin')
                        _financialReceiptCard(),

                      // ── Revenue Breakdown (SA) ──
                      if (revenueBreakdown != null &&
                          widget.role == 'super_admin')
                        _revenueBreakdownCard(),

                      // ── Action buttons ──
                      if (_hasActions()) _actionsSection(),

                      // ── Order items ──
                      Text('Order Items'.tr,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      if (items.isEmpty)
                        _emptyHint('No items'.tr)
                      else
                        ...items.map((item) => _itemRow(item)),
                      const SizedBox(height: 16),

                      // ── Vendors ──
                      if (vendors.isNotEmpty) ...[
                        Text('Vendors Breakdown'.tr,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 10),
                        ...vendors.map((v) => _vendorRow(v)),
                        const SizedBox(height: 16),
                      ],

                      // ── Status history ──
                      if (history.isNotEmpty) ...[
                        Text('Status History'.tr,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 10),
                        _card(
                          child: Column(
                            children: history.asMap().entries.map((e) {
                              final idx = e.key;
                              final h = e.value;
                              final isLastLine = idx == history.length - 1;
                              final isLatest = idx == 0;
                              return Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isLatest
                                              ? AppColors.primaryOrange
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                      if (!isLastLine)
                                        Container(
                                          width: 2,
                                          height: 30,
                                          color: AppColors.divider,
                                        ),
                                    ],
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${h['old_status'] ?? 'start'} → ${h['new_status'] ?? ''}',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 13),
                                          ),
                                          Text(
                                            h['changed_at'] ?? '',
                                            style: const TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }

  /// Financial Receipt card for Admin
  Widget _financialReceiptCard() {
    final fr = financialReceipt!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('' + 'Financial Receipt'.tr,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1B5E20).withValues(alpha: 0.3),
                AppColors.cardDark
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.4)),
          ),
          child: Column(
            children: [
              _receiptRow('Collect from User'.tr,
                  _fmtVal(fr['collect_from_user']), AppColors.primaryOrange),
              const SizedBox(height: 4),
              Container(
                  height: 1,
                  color: AppColors.divider.withValues(alpha: 0.2)),
              const SizedBox(height: 4),
              _receiptRow('Pay to Vendors'.tr,
                  '- ${_fmtVal(fr['pay_to_vendors'])}', AppColors.error),
              _receiptRow('Admin Keeps (Delivery)'.tr,
                  _fmtVal(fr['admin_keeps']), AppColors.success),
              _receiptRow('Hold for SA'.tr,
                  _fmtVal(fr['hold_for_sa']), AppColors.warning),
              const SizedBox(height: 8),
              Container(
                  height: 1,
                  color: AppColors.divider.withValues(alpha: 0.2)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '  Service Fee'.tr,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ),
                  Text(_fmtVal(fr['service_fee']),
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 11)),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '  Commission'.tr,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ),
                  Text(_fmtVal(fr['total_commission']),
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 11)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  /// Revenue Breakdown card for SA
  Widget _revenueBreakdownCard() {
    final rb = revenueBreakdown!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('' + 'Revenue Breakdown'.tr,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryOrange.withValues(alpha: 0.15),
                AppColors.cardDark
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: AppColors.primaryOrange.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              _receiptRow('User Pays'.tr,
                  _fmtVal(rb['user_pays']), AppColors.primaryOrange),
              const SizedBox(height: 8),
              Container(
                  height: 1,
                  color: AppColors.divider.withValues(alpha: 0.2)),
              const SizedBox(height: 8),
              _receiptRow(
                  'My Earnings'.tr,
                  _fmtVal(rb['sa_earnings']),
                  AppColors.success),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '  Service Fee'.tr,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ),
                  Text(_fmtVal(rb['service_fee']),
                      style: const TextStyle(
                          color: AppColors.info, fontSize: 11)),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '  Vendor Commission'.tr,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ),
                  Text(_fmtVal(rb['total_commission']),
                      style: const TextStyle(
                          color: AppColors.goldenYellow, fontSize: 11)),
                ],
              ),
              const SizedBox(height: 4),
              _receiptRow('Admin Keeps'.tr,
                  _fmtVal(rb['admin_earnings']), AppColors.info),
              _receiptRow('Vendor Payout'.tr,
                  _fmtVal(rb['total_vendor_payout']), Colors.white70),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _receiptRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
          ),
          Text(value,
              style: TextStyle(
                  color: valueColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14)),
        ],
      ),
    );
  }

  String _fmtVal(dynamic val) {
    final v = double.tryParse(val?.toString() ?? '0') ?? 0;
    return fmt.format(v);
  }

  Widget _callButtonsRow() {
    final customerPhone = order?['customer_phone']?.toString() ?? '';
    // vendor_phone comes from either the order or the first vendor
    String vendorPhone = order?['vendor_phone']?.toString() ?? '';
    if (vendorPhone.isEmpty && vendors.isNotEmpty) {
      vendorPhone = vendors.first['vendor_phone']?.toString() ?? '';
    }

    final showCustomer = customerPhone.isNotEmpty &&
        (widget.role == 'admin' || widget.role == 'vendor' || widget.role == 'super_admin');
    final showVendor = vendorPhone.isNotEmpty &&
        (widget.role == 'admin' || widget.role == 'super_admin');

    if (!showCustomer && !showVendor) return const SizedBox.shrink();

    return Row(
      children: [
        if (showCustomer)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => launchUrl(Uri.parse('tel:$customerPhone')),
              icon: const Icon(Icons.phone, color: Colors.white, size: 18),
              label: Text('Call Customer'.tr,
                  style: const TextStyle(color: Colors.white, fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        if (showCustomer && showVendor) const SizedBox(width: 10),
        if (showVendor)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => launchUrl(Uri.parse('tel:$vendorPhone')),
              icon: const Icon(Icons.store, color: Colors.white, size: 18),
              label: Text('Call Vendor'.tr,
                  style: const TextStyle(color: Colors.white, fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.info,
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
      ],
    );
  }

  bool _hasActions() {
    final status = order!['status'] ?? '';
    if (widget.confirmEndpoint != null && status == 'pending') {
      return true;
    }
    if (widget.dispatchEndpoint != null && status == 'ready_for_pickup') {
      return true;
    }
    if (widget.deliverEndpoint != null && status == 'out_for_delivery') {
      return true;
    }
    // Vendor actions
    if (widget.acceptEndpoint != null && status == 'sent_to_vendor') {
      return true;
    }
    if (widget.preparingEndpoint != null && status == 'vendor_accepted') {
      return true;
    }
    if (widget.readyEndpoint != null && status == 'preparing') {
      return true;
    }
    if (widget.cancelEndpoint != null &&
        !['delivered', 'cancelled'].contains(status)) {
      return true;
    }
    return false;
  }

  Widget _actionsSection() {
    final status = order!['status'] ?? '';
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (widget.confirmEndpoint != null && status == 'pending')
            _actionBtn('Confirm'.tr, AppColors.success, Icons.check_circle, () {
              _doAction(widget.confirmEndpoint!, {});
            }),
          // Vendor actions
          if (widget.acceptEndpoint != null && status == 'sent_to_vendor')
            _actionBtn('Accept'.tr, AppColors.success, Icons.thumb_up, () {
              _doAction(widget.acceptEndpoint!, {});
            }),
          if (widget.preparingEndpoint != null && status == 'vendor_accepted')
            _actionBtn('Start Preparing'.tr, AppColors.statusPreparing,
                Icons.restaurant, () {
              _doAction(widget.preparingEndpoint!, {});
            }),
          if (widget.readyEndpoint != null && status == 'preparing')
            _actionBtn('Mark Ready'.tr, AppColors.statusReady,
                Icons.check_box, () {
              _doAction(widget.readyEndpoint!, {});
            }),
          // Admin actions
          if (widget.dispatchEndpoint != null && status == 'ready_for_pickup')
            _actionBtn(
                'Dispatch'.tr, AppColors.info, Icons.delivery_dining, () {
              _doAction(widget.dispatchEndpoint!, {});
            }),
          if (widget.deliverEndpoint != null && status == 'out_for_delivery')
            _actionBtn('Delivered'.tr, AppColors.success, Icons.check, () {
              _doAction(widget.deliverEndpoint!, {});
            }),
          if (widget.cancelEndpoint != null &&
              !['delivered', 'cancelled'].contains(status))
            _actionBtn('Cancel'.tr, AppColors.error, Icons.cancel,
                () => _showCancelDialog()),
        ],
      ),
    );
  }

  void _showCancelDialog() {
    final reasonCtrl = TextEditingController();
    Get.dialog(AlertDialog(
      backgroundColor: AppColors.darkSurface,
      title: Text('Cancel Order'.tr,
          style: const TextStyle(color: Colors.white)),
      content: TextField(
        controller: reasonCtrl,
        style: const TextStyle(color: Colors.white),
        maxLines: 3,
        decoration: InputDecoration(hintText: 'Reason for cancellation'.tr),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: Text('No'.tr)),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          onPressed: () {
            Get.back();
            _doAction(
                widget.cancelEndpoint!, {'reason': reasonCtrl.text});
          },
          child: Text('Cancel Order'.tr),
        ),
      ],
    ));
  }

  Future<void> _doAction(String endpoint, Map<String, String> body) async {
    body['order_id'] = widget.orderId;
    final res = await ApiProvider.post(endpoint, body: body);
    if (res.success) {
      await _load();
      Get.snackbar('Done'.tr, res.message?.tr ?? 'Action completed'.tr,
          backgroundColor: AppColors.success,
          colorText: Colors.white);
    } else {
      Get.snackbar('Error'.tr, res.message?.tr ?? 'Action failed'.tr,
          backgroundColor: AppColors.error,
          colorText: Colors.white);
    }
  }

  Widget _itemRow(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          // Image
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: item['image_url'] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(item['image_url'],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                            Icons.fastfood,
                            color: AppColors.primaryOrange)))
                : const Icon(Icons.fastfood,
                    color: AppColors.primaryOrange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['item_name'] ?? '',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
                if (item['vendor_name'] != null)
                  Text(item['vendor_name'],
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 11)),
                if (item['special_instructions'] != null &&
                    item['special_instructions'].toString().isNotEmpty)
                  Text('${item['special_instructions']}',
                      style: const TextStyle(
                          color: AppColors.goldenYellow, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('×${item['quantity']}',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
              Text(
                fmt.format(double.tryParse(
                        item['line_total']?.toString() ?? '0') ??
                    0),
                style: const TextStyle(
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _vendorRow(Map<String, dynamic> v) {
    final hasCommission = v['commission_rate'] != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.storefront,
                color: AppColors.primaryOrange, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(v['vendor_name'] ?? 'Vendor',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
                if (v['vendor_phone'] != null)
                  Text(v['vendor_phone'],
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 11)),
                if (hasCommission && widget.role != 'vendor')
                  Text(
                      'Commission'.tr +
                          ': ${double.tryParse(v['commission_rate']?.toString() ?? '0')?.toStringAsFixed(1) ?? '0'}%',
                      style: const TextStyle(
                          color: AppColors.goldenYellow, fontSize: 11)),
                const SizedBox(height: 4),
                OrderStatusBadge(status: v['status'] ?? ''),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Subtotal'.tr,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11)),
              Text(
                fmt.format(
                    double.tryParse(v['subtotal']?.toString() ?? '0') ?? 0),
                style: const TextStyle(
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.bold),
              ),
              if (v['vendor_net_amount'] != null &&
                  widget.role != 'vendor') ...[
                const SizedBox(height: 4),
                Text('Payout'.tr,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 10)),
                Text(
                  fmt.format(double.tryParse(
                          v['vendor_net_amount']?.toString() ?? '0') ??
                      0),
                  style: const TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                      fontSize: 12),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.3)),
      ),
      child: child,
    );
  }

  Widget _row(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
          const Spacer(),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.end,
                style:
                    TextStyle(color: valueColor, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _emptyHint(String msg) {
    return Center(
        child: Text(msg,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4))));
  }

  ElevatedButton _actionBtn(
      String label, Color color, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(backgroundColor: color),
    );
  }
}

// ── Role-specific entry points ──

class SaOrderDetailView extends StatelessWidget {
  final String orderId;
  final String orderNumber;
  const SaOrderDetailView(
      {super.key, required this.orderId, required this.orderNumber});

  @override
  Widget build(BuildContext context) {
    return OrderDetailView(
      orderId: orderId,
      orderNumber: orderNumber,
      getByIdEndpoint: ApiEndpoints.saOrdersGetById,
      cancelEndpoint: ApiEndpoints.saOrdersCancel,
      role: 'super_admin',
    );
  }
}

class AdminOrderDetailView extends StatelessWidget {
  final String orderId;
  final String orderNumber;
  const AdminOrderDetailView(
      {super.key, required this.orderId, required this.orderNumber});

  @override
  Widget build(BuildContext context) {
    return OrderDetailView(
      orderId: orderId,
      orderNumber: orderNumber,
      getByIdEndpoint: ApiEndpoints.adminOrdersGetById,
      cancelEndpoint: ApiEndpoints.adminOrdersCancel,
      confirmEndpoint: ApiEndpoints.adminOrdersConfirm,
      dispatchEndpoint: ApiEndpoints.adminOrdersDispatch,
      deliverEndpoint: ApiEndpoints.adminOrdersDeliver,
      role: 'admin',
    );
  }
}

class VendorOrderDetailView extends StatelessWidget {
  final String orderId;
  final String orderNumber;
  const VendorOrderDetailView(
      {super.key, required this.orderId, required this.orderNumber});

  @override
  Widget build(BuildContext context) {
    return OrderDetailView(
      orderId: orderId,
      orderNumber: orderNumber,
      getByIdEndpoint: ApiEndpoints.vendorOrdersGetById,
      acceptEndpoint: ApiEndpoints.vendorOrdersAccept,
      preparingEndpoint: ApiEndpoints.vendorOrdersPreparing,
      readyEndpoint: ApiEndpoints.vendorOrdersReady,
      role: 'vendor',
    );
  }
}
