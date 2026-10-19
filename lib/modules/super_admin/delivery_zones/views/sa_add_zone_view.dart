import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/constants/api_endpoints.dart';
import '../../../../data/providers/api_provider.dart';
import '../../../../shared/localization/app_translations.dart';
import '../../../../shared/utils/app_navigator.dart';

final saAddZoneProvider =
    ChangeNotifierProvider.autoDispose<SaAddZoneController>((ref) {
  final ctrl = SaAddZoneController();
  ctrl.init(AppNavigator.arguments);
  return ctrl;
});

class SaAddZoneController extends ChangeNotifier {
  bool isSaving = false;

  // Form fields matching DB columns exactly
  final nameCtrl = TextEditingController();
  final minDistanceCtrl = TextEditingController();
  final maxDistanceCtrl = TextEditingController();
  final baseFeeCtrl = TextEditingController();
  final nearbyExtraFeeCtrl = TextEditingController(text: '0');
  final farExtraFeeCtrl = TextEditingController(text: '0');
  final estDeliveryTimeCtrl = TextEditingController();

  // Edit mode
  bool get isEditMode => _editZoneId != null;
  String? _editZoneId;

  void init(dynamic args) {
    if (args is Map<String, dynamic> && args['id'] != null) {
      _editZoneId = args['id'].toString();
      nameCtrl.text = args['name'] ?? '';
      minDistanceCtrl.text = args['min_distance_km']?.toString() ?? '';
      maxDistanceCtrl.text = args['max_distance_km']?.toString() ?? '';
      baseFeeCtrl.text = args['base_fee']?.toString() ?? '';
      nearbyExtraFeeCtrl.text = args['nearby_extra_fee']?.toString() ?? '0';
      farExtraFeeCtrl.text = args['far_extra_fee']?.toString() ?? '0';
      estDeliveryTimeCtrl.text = args['estimated_delivery_time']?.toString() ?? '';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    minDistanceCtrl.dispose();
    maxDistanceCtrl.dispose();
    baseFeeCtrl.dispose();
    nearbyExtraFeeCtrl.dispose();
    farExtraFeeCtrl.dispose();
    estDeliveryTimeCtrl.dispose();
    super.dispose();
  }

  Future<void> save() async {
    // Validate
    if (nameCtrl.text.trim().isEmpty) {
      _error('Zone name is required'.tr);
      return;
    }
    if (minDistanceCtrl.text.trim().isEmpty) {
      _error('Min distance is required'.tr);
      return;
    }
    if (maxDistanceCtrl.text.trim().isEmpty) {
      _error('Max distance is required'.tr);
      return;
    }
    if (baseFeeCtrl.text.trim().isEmpty) {
      _error('Base fee is required'.tr);
      return;
    }

    final minDist = double.tryParse(minDistanceCtrl.text.trim()) ?? 0;
    final maxDist = double.tryParse(maxDistanceCtrl.text.trim()) ?? 0;
    if (maxDist <= minDist) {
      _error('Max distance must be greater than min distance'.tr);
      return;
    }

    isSaving = true;
    notifyListeners();
    try {
      final body = <String, String>{
        'name': nameCtrl.text.trim(),
        'min_distance_km': minDistanceCtrl.text.trim(),
        'max_distance_km': maxDistanceCtrl.text.trim(),
        'base_fee': baseFeeCtrl.text.trim(),
        'nearby_extra_fee': nearbyExtraFeeCtrl.text.trim().isEmpty
            ? '0'
            : nearbyExtraFeeCtrl.text.trim(),
        'far_extra_fee': farExtraFeeCtrl.text.trim().isEmpty
            ? '0'
            : farExtraFeeCtrl.text.trim(),
        if (estDeliveryTimeCtrl.text.trim().isNotEmpty)
          'estimated_delivery_time': estDeliveryTimeCtrl.text.trim(),
      };

      ApiResponse res;

      if (isEditMode) {
        body['zone_id'] = _editZoneId!;
        res = await ApiProvider.post(ApiEndpoints.saDeliveryZonesUpdate,
            body: body);
      } else {
        res = await ApiProvider.post(ApiEndpoints.saDeliveryZonesAdd,
            body: body);
      }

      if (res.success) {
        AppNavigator.back(result: true);
        AppNavigator.snackbar(
          isEditMode ? 'Updated'.tr : 'Created'.tr,
          isEditMode
              ? 'Delivery zone updated'.tr
              : 'Delivery zone created'.tr,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF),
        );
      } else {
        _error(res.message?.tr ?? 'Failed'.tr);
      }
    } catch (e) {
      _error('Something went wrong'.tr);
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  void _error(String msg) {
    AppNavigator.snackbar('Error'.tr, msg,
        backgroundColor: const Color(0xFFF44336),
        colorText: const Color(0xFFFFFFFF));
  }
}

class SaAddZoneView extends ConsumerWidget {
  const SaAddZoneView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.watch(saAddZoneProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        title: Text(ctrl.isEditMode
            ? 'Edit Delivery Zone'.tr
            : 'New Delivery Zone'.tr),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => AppNavigator.back(),
        ),
        actions: [
          ctrl.isSaving
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: AppColors.primaryOrange, strokeWidth: 2)),
                )
              : TextButton(
                  onPressed: ctrl.save,
                  child: Text('Save'.tr,
                      style: const TextStyle(
                          color: AppColors.primaryOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Zone Name ──
            _sectionTitle(Icons.map, 'Zone Details'.tr),
            const SizedBox(height: 12),
            _label('Zone Name *'.tr),
            TextField(
              controller: ctrl.nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'e.g. Zone 1 - Very Close (0 to 2 km)'.tr,
                prefixIcon: const Icon(Icons.label_outline),
              ),
            ),
            const SizedBox(height: 24),

            // ── Distance Range ──
            _sectionTitle(Icons.straighten, 'Distance Range'.tr),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Min Distance (km) *'.tr),
                      TextField(
                        controller: ctrl.minDistanceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: '0.00',
                          prefixIcon: Icon(Icons.arrow_downward),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Max Distance (km) *'.tr),
                      TextField(
                        controller: ctrl.maxDistanceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: '2.00',
                          prefixIcon: Icon(Icons.arrow_upward),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Visual hint
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: AppColors.info.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: AppColors.info, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Max distance must be greater than min distance. Use consecutive ranges (e.g. 0–2, 2.01–5, 5.01–10).'
                          .tr,
                      style: const TextStyle(
                          color: AppColors.info, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Fees ──
            _sectionTitle(Icons.attach_money, 'Delivery Fees'.tr),
            const SizedBox(height: 12),
            _label('Base Fee (₪) *'.tr),
            TextField(
              controller: ctrl.baseFeeCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: '10.00',
                prefixIcon: Icon(Icons.monetization_on_outlined),
              ),
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Nearby Extra Fee (₪)'.tr),
                      TextField(
                        controller: ctrl.nearbyExtraFeeCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: '5.00',
                          prefixIcon: Icon(Icons.near_me),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Far Extra Fee (₪)'.tr),
                      TextField(
                        controller: ctrl.farExtraFeeCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: '10.00',
                          prefixIcon: Icon(Icons.travel_explore),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.goldenYellow.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.goldenYellow.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: AppColors.goldenYellow, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Nearby extra fee is added for short-distance surcharges. Far extra fee is added for long-distance orders within this zone.'
                          .tr,
                      style: const TextStyle(
                          color: AppColors.goldenYellow, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Estimated Delivery Time ──
            _sectionTitle(Icons.delivery_dining, 'Estimated Delivery Time'.tr),
            const SizedBox(height: 12),
            _label('Estimated Time (optional)'.tr),
            TextField(
              controller: ctrl.estDeliveryTimeCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'e.g. 30-45 min'.tr,
                prefixIcon: const Icon(Icons.timer_outlined),
              ),
            ),
            const SizedBox(height: 32),

            // ── Submit ──
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: ctrl.isSaving ? null : ctrl.save,
                icon: Icon(ctrl.isEditMode
                    ? Icons.save_outlined
                    : Icons.add_location_alt),
                label: Text(ctrl.isSaving
                    ? 'Saving...'.tr
                    : ctrl.isEditMode
                        ? 'Save Changes'.tr
                        : 'Create Zone'.tr),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryOrange.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primaryOrange, size: 18),
        ),
        const SizedBox(width: 10),
        Text(text,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style:
              const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
    );
  }
}
