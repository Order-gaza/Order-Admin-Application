import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/constants/app_constants.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../shared/localization/app_translations.dart';
import '../../../../shared/utils/app_navigator.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../controllers/sa_vendors_controller.dart';

class SaVendorsView extends ConsumerWidget {
  const SaVendorsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(saVendorsProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        title: Text('Manage Vendors'.tr),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: controller.fetchVendors),
        ],
      ),
      drawer: const AppDrawer(currentRoute: AppRoutes.saVendors),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await AppNavigator.toNamed(AppRoutes.saCreateVendor);
          if (result == true) controller.fetchVendors();
        },
        icon: const Icon(Icons.add_business),
        label: Text('Add Vendor'.tr),
      ),
      body: Column(
        children: [
          // ── Search ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              onChanged: (v) => controller.setSearchQuery(v),
              decoration: InputDecoration(
                hintText: 'Search vendors...'.tr,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          // ── Filter chips ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  'all', 'pending', 'approved', 'suspended', 'rejected'
                ].map((f) {
                  final selected = controller.selectedFilter == f;
                  return GestureDetector(
                    onTap: () => controller.setFilter(f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primaryOrange
                            : AppColors.darkSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? AppColors.primaryOrange
                              : AppColors.divider,
                        ),
                      ),
                      child: Text(
                        f.tr,
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // ── List ──
          Expanded(
            child: Builder(builder: (_) {
              if (controller.isLoading) {
                return const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryOrange));
              }
              final list = controller.filtered;
              if (list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.store,
                          size: 64,
                          color: Colors.white.withValues(alpha: 0.2)),
                      const SizedBox(height: 12),
                      Text('No vendors found'.tr,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4))),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                color: AppColors.primaryOrange,
                onRefresh: controller.fetchVendors,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _vendorCard(context, controller, list[i]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _vendorCard(BuildContext context, SaVendorsController controller, Map<String, dynamic> vendor) {
    final status = vendor['status'] ?? 'pending';
    final statusColor = _statusColor(status);
    final vendorId = vendor['id']?.toString() ?? '';
    final vendorName = vendor['vendor_name'] ?? vendor['name'] ?? '';
    final logoUrl = vendor['logo_url']?.toString() ?? '';
    final coverUrl = vendor['cover_url']?.toString() ?? '';
    final isOpen = (vendor['is_currently_open'] ?? vendor['is_open'] ?? 0) == 1;
    final typeStr = (vendor['type'] ?? '').toString();

    return GestureDetector(
      onTap: () => AppNavigator.toNamed(
        AppRoutes.saVendorDetail,
        arguments: {'vendor_id': vendorId, 'vendor_name': vendorName},
      ),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image header
            SizedBox(
              height: 85,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (coverUrl.isNotEmpty)
                    Image.network(coverUrl, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                            decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                    colors: [Color(0xFF2C2C2C), Color(0xFF3D2C1E)]))))
                  else
                    Container(
                        decoration: const BoxDecoration(
                            gradient: LinearGradient(
                                colors: [Color(0xFF2C2C2C), Color(0xFF3D2C1E)]))),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8, right: 8,
                    child: Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: (isOpen ? AppColors.success : AppColors.error).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(isOpen ? 'Open'.tr : 'Closed'.tr,
                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(AppConstants.vendorStatusLabel(status),
                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600)),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
            // Logo + info area
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Transform.translate(
                    offset: const Offset(0, -20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.cardDark, width: 3),
                            color: AppColors.darkSurface,
                          ),
                          child: ClipOval(
                            child: logoUrl.isNotEmpty
                                ? Image.network(logoUrl, fit: BoxFit.cover, width: 44, height: 44,
                                    errorBuilder: (_, __, ___) => _logoPlaceholder(vendorName))
                                : _logoPlaceholder(vendorName),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(vendorName,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -12),
                    child: Column(
                      children: [
                        Row(children: [
                          Icon(
                            typeStr == 'restaurant' ? Icons.restaurant
                                : typeStr == 'cafe' ? Icons.coffee : Icons.shopping_bag,
                            color: AppColors.textSecondary, size: 13),
                          const SizedBox(width: 4),
                          Text(typeStr.isNotEmpty ? typeStr.tr : '',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          if (vendor['delivery_zone'] != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _zoneColor(vendor['delivery_zone']).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _zoneAr(vendor['delivery_zone']),
                                style: TextStyle(
                                  color: _zoneColor(vendor['delivery_zone']),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                          const Spacer(),
                          if (vendor['vendor_phone'] != null || vendor['phone'] != null) ...[
                            const Icon(Icons.phone, size: 12, color: AppColors.textSecondary),
                            const SizedBox(width: 3),
                            Text(vendor['vendor_phone'] ?? vendor['phone'] ?? '',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                          ],
                          if (vendor['rating'] != null) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.star, size: 13, color: AppColors.goldenYellow),
                            const SizedBox(width: 2),
                            Text('${vendor['rating']}',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                          ],
                        ]),
                        const SizedBox(height: 10),
                        // Action buttons
                        Row(children: [
                          if (status == 'pending') ...[
                            Expanded(child: ElevatedButton.icon(
                              onPressed: () => controller.approve(vendor['id']),
                              icon: const Icon(Icons.check, size: 16),
                              label: Text('Approve'.tr),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                  padding: const EdgeInsets.symmetric(vertical: 8)),
                            )),
                            const SizedBox(width: 8),
                            Expanded(child: OutlinedButton.icon(
                              onPressed: () => controller.reject(vendor['id']),
                              icon: const Icon(Icons.close, size: 16),
                              label: Text('Reject'.tr),
                              style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                  side: const BorderSide(color: AppColors.error),
                                  padding: const EdgeInsets.symmetric(vertical: 8)),
                            )),
                          ],
                          if (status == 'approved')
                            Expanded(child: OutlinedButton.icon(
                              onPressed: () => controller.suspend(vendor['id']),
                              icon: const Icon(Icons.pause, size: 16),
                              label: Text('Suspend'.tr),
                              style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                  side: const BorderSide(color: AppColors.error),
                                  padding: const EdgeInsets.symmetric(vertical: 8)),
                            )),
                          if (status == 'suspended')
                            Expanded(child: ElevatedButton.icon(
                              onPressed: () => controller.reactivate(vendor['id']),
                              icon: const Icon(Icons.play_arrow, size: 16),
                              label: Text('Reactivate'.tr),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                  padding: const EdgeInsets.symmetric(vertical: 8)),
                            )),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _logoPlaceholder(String name) {
    return Container(
      color: AppColors.primaryOrange.withValues(alpha: 0.15),
      child: Center(
        child: name.isNotEmpty
            ? Text(name[0].toUpperCase(),
                style: const TextStyle(color: AppColors.primaryOrange,
                    fontWeight: FontWeight.bold, fontSize: 18))
            : const Icon(Icons.store, color: AppColors.primaryOrange, size: 20),
      ),
    );
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
      default: return zone ?? '';
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
