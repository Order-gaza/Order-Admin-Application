import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/constants/api_endpoints.dart';
import '../../../../app/constants/app_constants.dart';
import '../../../../data/providers/api_provider.dart';

class SaVendorDetailController extends GetxController {
  final isLoading = false.obs;
  final vendor = Rxn<Map<String, dynamic>>();
  final String vendorId;

  SaVendorDetailController({required this.vendorId});

  @override
  void onInit() {
    super.onInit();
    fetchVendor();
  }

  Future<void> fetchVendor() async {
    isLoading.value = true;
    try {
      final res = await ApiProvider.get(
        ApiEndpoints.saVendorsGetById,
        queryParams: {'id': vendorId},
      );
      if (res.success && res.data != null) {
        final d = res.data as Map<String, dynamic>;
        vendor.value = d['vendor'] as Map<String, dynamic>?;
      }
    } finally {
      isLoading.value = false;
    }
  }
}

class SaVendorDetailView extends StatelessWidget {
  final String vendorId;
  final String vendorName;

  const SaVendorDetailView({
    super.key,
    required this.vendorId,
    required this.vendorName,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(SaVendorDetailController(vendorId: vendorId));

    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return CustomScrollView(
            slivers: [
              _buildAppBar(null),
              const SliverFillRemaining(
                child: Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryOrange)),
              ),
            ],
          );
        }

        final v = ctrl.vendor.value;
        if (v == null) {
          return CustomScrollView(
            slivers: [
              _buildAppBar(null),
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline,
                          size: 48,
                          color: Colors.white.withValues(alpha: 0.3)),
                      const SizedBox(height: 12),
                      Text('Vendor not found'.tr,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5))),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        return RefreshIndicator(
          color: AppColors.primaryOrange,
          onRefresh: ctrl.fetchVendor,
          child: CustomScrollView(
            slivers: [
              _buildAppBar(v),
              SliverToBoxAdapter(child: _buildBody(context, v)),
            ],
          ),
        );
      }),
    );
  }

  SliverAppBar _buildAppBar(Map<String, dynamic>? v) {
    final coverUrl = v?['cover_url']?.toString();
    final hasCover = coverUrl != null && coverUrl.isNotEmpty;

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.charcoalBlack,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          v?['name'] ?? vendorName,
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              shadows: [Shadow(color: Colors.black54, blurRadius: 8)]),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (hasCover)
              Image.network(
                coverUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _defaultCoverGradient(),
              )
            else
              _defaultCoverGradient(),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => Get.find<SaVendorDetailController>().fetchVendor(),
        ),
      ],
    );
  }

  Widget _defaultCoverGradient() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2C2C2C),
            Color(0xFF1A1A1A),
            AppColors.primaryOrange,
          ],
          stops: [0.0, 0.6, 1.0],
        ),
      ),
      child: const Center(
        child: Icon(Icons.store, color: Colors.white24, size: 64),
      ),
    );
  }

  Widget _buildBody(BuildContext context, Map<String, dynamic> v) {
    final status = v['status'] ?? 'pending';
    final statusColor = _statusColor(status);
    final logoUrl = v['logo_url']?.toString();
    final hasLogo = logoUrl != null && logoUrl.isNotEmpty;
    final isOpen = (v['is_currently_open'] ?? v['is_open'] ?? 0) == 1;
    final menuItems =
        List<Map<String, dynamic>>.from(v['menu_items'] as List? ?? []);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header with logo + status ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.primaryOrange.withValues(alpha: 0.3)),
                ),
                child: hasLogo
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(logoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                                Icons.store,
                                color: AppColors.primaryOrange,
                                size: 28)),
                      )
                    : const Icon(Icons.store,
                        color: AppColors.primaryOrange, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      v['name'] ?? '',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    if (v['description'] != null &&
                        v['description'].toString().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        v['description'],
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _typeBadge(v['type'] ?? ''),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: statusColor.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            AppConstants.vendorStatusLabel(status),
                            style: TextStyle(
                                color: statusColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: (isOpen
                                    ? AppColors.success
                                    : AppColors.error)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: (isOpen
                                      ? AppColors.success
                                      : AppColors.error)
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            isOpen ? 'Open'.tr : 'Closed'.tr,
                            style: TextStyle(
                                color: isOpen
                                    ? AppColors.success
                                    : AppColors.error,
                                fontSize: 11,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        if (v['delivery_zone'] != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _zoneColor(v['delivery_zone']).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: _zoneColor(v['delivery_zone']).withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.delivery_dining, size: 12,
                                    color: _zoneColor(v['delivery_zone'])),
                                const SizedBox(width: 4),
                                Text(
                                  _zoneAr(v['delivery_zone']),
                                  style: TextStyle(
                                      color: _zoneColor(v['delivery_zone']),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Stats row ──
          _statsRow(v),
          const SizedBox(height: 16),

          // ── Quick Call Buttons ──
          Row(
            children: [
              if ((v['phone'] ?? '').toString().isNotEmpty)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => launchUrl(Uri.parse('tel:${v['phone']}')),
                    icon: const Icon(Icons.phone, color: Colors.white, size: 18),
                    label: Text('Call Vendor'.tr,
                        style: const TextStyle(color: Colors.white, fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              if ((v['phone'] ?? '').toString().isNotEmpty &&
                  (v['owner_phone'] ?? '').toString().isNotEmpty)
                const SizedBox(width: 10),
              if ((v['owner_phone'] ?? '').toString().isNotEmpty)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => launchUrl(Uri.parse('tel:${v['owner_phone']}')),
                    icon: const Icon(Icons.person, color: Colors.white, size: 18),
                    label: Text('Call Owner'.tr,
                        style: const TextStyle(color: Colors.white, fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.info,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Contact & Location ──
          _sectionTitle('Contact & Location'.tr),
          const SizedBox(height: 10),
          _infoCard([
            _infoRow(
                Icons.phone, 'Phone'.tr, v['phone'] ?? '—'),
            _infoRow(Icons.location_city, 'City'.tr, v['city'] ?? '—'),
            _infoRow(Icons.map, 'Neighborhood'.tr, v['neighborhood'] ?? '—'),
            _infoRow(Icons.location_on, 'Address'.tr, v['address'] ?? '—'),
            _infoRow(Icons.my_location, 'Coordinates'.tr,
                '${v['latitude'] ?? '—'}, ${v['longitude'] ?? '—'}'),
          ]),
          const SizedBox(height: 20),

          // ── Owner Info ──
          _sectionTitle('Owner Information'.tr),
          const SizedBox(height: 10),
          _infoCard([
            _infoRow(Icons.person, 'Name'.tr, v['owner_name'] ?? '—'),
            _infoRow(Icons.email, 'Email'.tr, v['owner_email'] ?? '—'),
            _infoRow(
                Icons.phone_android, 'Phone'.tr, v['owner_phone'] ?? '—'),
            _infoRow(Icons.verified_user, 'Account Active'.tr,
                (v['account_active'] ?? 0) == 1 ? 'Yes'.tr : 'No'.tr),
          ]),
          const SizedBox(height: 20),

          // ── Business Details ──
          _sectionTitle('Business Details'.tr),
          const SizedBox(height: 10),
          _infoCard([
            _infoRow(Icons.monetization_on, 'Commission'.tr,
                '${v['commission_rate'] ?? '—'}%'),
            _infoRow(Icons.shopping_cart_checkout, 'Min Order'.tr,
                '₪${v['min_order_amount'] ?? '0.00'}'),
            _infoRow(Icons.delivery_dining, 'Delivery Zone'.tr,
                _zoneAr(v['delivery_zone'])),
            _infoRow(Icons.delivery_dining, 'Est. Delivery'.tr,
                v['estimated_delivery_time'] ?? '—'),
            _infoRow(Icons.access_time, 'Opening'.tr,
                v['opening_time']?.toString() ?? '—'),
            _infoRow(Icons.access_time_filled, 'Closing'.tr,
                v['closing_time']?.toString() ?? '—'),
            _infoRow(Icons.schedule, 'Operating Hours'.tr,
                v['operating_hours']?.toString() ?? '—'),
          ]),
          const SizedBox(height: 20),

          // ── Menu Items with Prices ──
          _sectionTitle('Menu Items'.tr + ' (${menuItems.length})'),
          const SizedBox(height: 10),
          if (menuItems.isEmpty)
            _card(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      Icon(Icons.restaurant_menu,
                          size: 36,
                          color: Colors.white.withValues(alpha: 0.2)),
                      const SizedBox(height: 8),
                      Text('No menu items yet'.tr,
                          style: TextStyle(
                              color:
                                  Colors.white.withValues(alpha: 0.4),
                              fontSize: 13)),
                    ],
                  ),
                ),
              ),
            )
          else
            ...menuItems.map((item) => _menuItemCard(item)),
          const SizedBox(height: 20),

          // ── ID & Dates ──
          _sectionTitle('System Info'.tr),
          const SizedBox(height: 10),
          _infoCard([
            _infoRow(
                Icons.fingerprint, 'Vendor ID'.tr, v['id']?.toString() ?? '—',
                copyable: true),
            _infoRow(Icons.person_pin, 'User ID'.tr,
                v['user_id']?.toString() ?? '—',
                copyable: true),
            _infoRow(Icons.calendar_today, 'Registered'.tr,
                _formatDate(v['registered_at'] ?? v['created_at'])),
            _infoRow(Icons.update, 'Updated'.tr, _formatDate(v['updated_at'])),
          ]),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _menuItemCard(Map<String, dynamic> item) {
    final price = double.tryParse(item['base_price']?.toString() ?? '0') ?? 0;
    final discountPrice =
        double.tryParse(item['discount_price']?.toString() ?? '0') ?? 0;
    final hasDiscount = discountPrice > 0 && discountPrice < price;
    final isAvailable = (item['is_available'] ?? 1) == 1;
    final imageUrl = item['image_url']?.toString();
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAvailable
              ? AppColors.divider.withValues(alpha: 0.2)
              : AppColors.error.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          // Item image
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryOrange.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: hasImage
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                            Icons.fastfood,
                            color: AppColors.primaryOrange,
                            size: 22)),
                  )
                : const Icon(Icons.fastfood,
                    color: AppColors.primaryOrange, size: 22),
          ),
          const SizedBox(width: 12),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name'] ?? '',
                    style: TextStyle(
                      color: isAvailable
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.4),
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    )),
                const SizedBox(height: 2),
                Text(item['category_name'] ?? 'Uncategorized'.tr,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          // Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (hasDiscount) ...[
                Text('₪${price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 11,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: Colors.white.withValues(alpha: 0.3),
                    )),
                Text('₪${discountPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
              ] else
                Text('₪${price.toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: AppColors.primaryOrange,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
              if (!isAvailable)
                Text('Unavailable'.tr,
                    style: TextStyle(color: AppColors.error, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statsRow(Map<String, dynamic> v) {
    return Row(
      children: [
        Expanded(
          child: _statCard('Rating'.tr,
            '${v['rating'] ?? '0.00'}',
            accent: AppColors.goldenYellow,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard('Reviews'.tr,
            '${v['total_ratings'] ?? 0}',
            accent: AppColors.info,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard('Completed'.tr,
            '${v['completed_orders'] ?? 0}',
            accent: AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _statCard(String label, String value,
      {Color accent = AppColors.primaryOrange}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.primaryOrange,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(text,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.2)),
      ),
      child: child,
    );
  }

  Widget _infoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.2)),
      ),
      child: Column(children: children),
    );
  }

  Widget _infoRow(IconData icon, String label, String value,
      {bool copyable = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.primaryOrange),
          const SizedBox(width: 10),
          SizedBox(
            width: 90,
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
          ),
          Expanded(
            child: GestureDetector(
              onTap: copyable
                  ? () {
                      Clipboard.setData(ClipboardData(text: value));
                      Get.snackbar('Copied'.tr, '$label ' + 'copied to clipboard'.tr,
                          backgroundColor:
                              AppColors.primaryOrange.withValues(alpha: 0.9),
                          colorText: Colors.white,
                          duration: const Duration(seconds: 1),
                          snackPosition: SnackPosition.BOTTOM);
                    }
                  : null,
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      value,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        decoration: copyable
                            ? TextDecoration.underline
                            : TextDecoration.none,
                        decorationColor:
                            Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  if (copyable) ...[
                    const SizedBox(width: 4),
                    Icon(Icons.copy,
                        size: 12,
                        color: Colors.white.withValues(alpha: 0.3)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeBadge(String type) {
    IconData icon;
    switch (type) {
      case 'restaurant':
        icon = Icons.restaurant;
        break;
      case 'cafe':
        icon = Icons.coffee;
        break;
      default:
        icon = Icons.shopping_bag;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.info),
          const SizedBox(width: 4),
          Text(
            type.isNotEmpty
                ? type.tr
                : '',
            style: const TextStyle(
                color: AppColors.info,
                fontSize: 11,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic d) {
    if (d == null) return '—';
    try {
      final dt = DateTime.parse(d.toString());
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return d.toString();
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return AppColors.success;
      case 'suspended':
        return AppColors.error;
      case 'pending':
        return AppColors.warning;
      case 'rejected':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }

  String _zoneAr(String? zone) {
    switch (zone) {
      case 'north': return 'الشمال';
      case 'central': return 'الوسطى';
      case 'south': return 'الجنوب';
      default: return zone ?? '—';
    }
  }

  Color _zoneColor(String? zone) {
    switch (zone) {
      case 'north': return const Color(0xFF2196F3);
      case 'central': return const Color(0xFF4CAF50);
      case 'south': return const Color(0xFFFF9800);
      default: return AppColors.primaryOrange;
    }
  }
}
