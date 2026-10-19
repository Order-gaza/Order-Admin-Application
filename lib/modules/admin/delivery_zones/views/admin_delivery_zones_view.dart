import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/constants/api_endpoints.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../shared/localization/app_translations.dart';
import '../../../../shared/utils/app_navigator.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../data/providers/api_provider.dart';

class AdminDeliveryZonesView extends StatefulWidget {
  const AdminDeliveryZonesView({super.key});

  @override
  State<AdminDeliveryZonesView> createState() =>
      _AdminDeliveryZonesViewState();
}

class _AdminDeliveryZonesViewState extends State<AdminDeliveryZonesView> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _zones = [];

  @override
  void initState() {
    super.initState();
    _fetchZones();
  }

  Future<void> _fetchZones() async {
    setState(() => _isLoading = true);
    try {
      final res =
          await ApiProvider.get(ApiEndpoints.adminDeliveryZonesGetAll);
      if (res.success && res.data != null) {
        final d = res.data as Map<String, dynamic>;
        setState(() {
          _zones =
              List<Map<String, dynamic>>.from(d['delivery_zones'] as List? ?? []);
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleZone(String id) async {
    final res = await ApiProvider.post(
        ApiEndpoints.adminDeliveryZonesToggle,
        body: {'zone_id': id});
    if (res.success && mounted) {
      final idx = _zones.indexWhere((z) => z['id']?.toString() == id);
      if (idx != -1) {
        setState(() {
          final cur = (_zones[idx]['is_active'] ?? 1) as int;
          _zones[idx] = {..._zones[idx], 'is_active': cur == 1 ? 0 : 1};
        });
      }
    }
  }

  Future<void> _deleteZone(String id) async {
    final res = await ApiProvider.post(
        ApiEndpoints.adminDeliveryZonesDelete,
        body: {'zone_id': id});
    if (res.success) {
      if (mounted) {
        setState(() {
          _zones.removeWhere((z) => z['id']?.toString() == id);
        });
      }
      AppNavigator.snackbar('Deleted'.tr, 'Zone removed'.tr,
          backgroundColor: AppColors.success, colorText: Colors.white);
    } else {
      AppNavigator.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
          backgroundColor: AppColors.error, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        title: Text('Delivery Zones'.tr),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh), onPressed: _fetchZones),
        ],
      ),
      drawer: const AppDrawer(currentRoute: AppRoutes.adminDeliveryZones),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await AppNavigator.toNamed(AppRoutes.adminAddZone);
          if (result == true) _fetchZones();
        },
        icon: const Icon(Icons.add_location_alt),
        label: Text('Add Zone'.tr),
      ),
      body: Builder(builder: (context) {
        if (_isLoading) {
          return const Center(
              child: CircularProgressIndicator(
                  color: AppColors.primaryOrange));
        }
        if (_zones.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.map,
                    size: 64,
                    color: Colors.white.withValues(alpha: 0.2)),
                const SizedBox(height: 12),
                Text('No delivery zones'.tr,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4))),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await AppNavigator.toNamed(AppRoutes.adminAddZone);
                    if (result == true) _fetchZones();
                  },
                  icon: const Icon(Icons.add),
                  label: Text('Add First Zone'.tr),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          color: AppColors.primaryOrange,
          onRefresh: _fetchZones,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _zones.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _zoneCard(_zones[i]),
          ),
        );
      }),
    );
  }

  Widget _zoneCard(Map<String, dynamic> zone) {
    final isActive = (zone['is_active'] ?? 1) == 1;
    final id = zone['id']?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive
              ? AppColors.primaryOrange.withValues(alpha: 0.3)
              : AppColors.divider.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.map,
                    color: AppColors.primaryOrange, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(zone['name'] ?? '',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15)),
                    const SizedBox(height: 3),
                    Text(
                      '${zone['min_distance_km'] ?? 0} km  →  ${zone['max_distance_km'] ?? 0} km',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _toggleZone(id),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: (isActive ? AppColors.success : AppColors.error)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: (isActive
                              ? AppColors.success
                              : AppColors.error)
                          .withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    isActive ? 'Active'.tr : 'Inactive'.tr,
                    style: TextStyle(
                        color: isActive
                            ? AppColors.success
                            : AppColors.error,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),
          // Fee info row — matches DB fields
          Row(
            children: [
              _infoItem(Icons.attach_money, 'Base Fee'.tr,
                  '₪${zone['base_fee'] ?? 0}', AppColors.primaryOrange),
              const SizedBox(width: 12),
              _infoItem(Icons.near_me, 'Nearby Extra'.tr,
                  '₪${zone['nearby_extra_fee'] ?? 0}', AppColors.info),
              const SizedBox(width: 12),
              _infoItem(Icons.travel_explore, 'Far Extra'.tr,
                  '₪${zone['far_extra_fee'] ?? 0}', AppColors.goldenYellow),
            ],
          ),
          // Estimated delivery time
          if (zone['estimated_delivery_time'] != null &&
              zone['estimated_delivery_time'].toString().isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.delivery_dining,
                    size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  '${'Est. delivery: '.tr}${zone['estimated_delivery_time']}',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () async {
                  final result = await AppNavigator.toNamed(
                    AppRoutes.adminAddZone,
                    arguments: zone,
                  );
                  if (result == true) _fetchZones();
                },
                icon: const Icon(Icons.edit_outlined,
                    size: 16, color: AppColors.info),
                label: Text('Edit'.tr,
                    style: const TextStyle(color: AppColors.info, fontSize: 12)),
                style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _confirmDelete(id),
                icon: const Icon(Icons.delete_outline,
                    size: 16, color: AppColors.error),
                label: Text('Delete'.tr,
                    style: const TextStyle(color: AppColors.error, fontSize: 12)),
                style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _confirmDelete(String id) {
    AppNavigator.dialog(AlertDialog(
      backgroundColor: AppColors.darkSurface,
      title: Text('Delete Zone'.tr,
          style: const TextStyle(color: Colors.white)),
      content: Text('Remove this delivery zone?'.tr,
          style: const TextStyle(color: AppColors.textSecondary)),
      actions: [
        TextButton(
            onPressed: () => AppNavigator.back(), child: Text('Cancel'.tr)),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error),
          onPressed: () {
            AppNavigator.back();
            _deleteZone(id);
          },
          child: Text('Delete'.tr),
        ),
      ],
    ));
  }
}
