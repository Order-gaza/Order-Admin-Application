import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/constants/api_endpoints.dart';
import '../../../../data/providers/api_provider.dart';
import '../../../../shared/localization/app_translations.dart';
import '../../../../shared/utils/app_navigator.dart';

class AdminAddZoneView extends StatefulWidget {
  const AdminAddZoneView({super.key});

  @override
  State<AdminAddZoneView> createState() => _AdminAddZoneViewState();
}

class _AdminAddZoneViewState extends State<AdminAddZoneView> {
  bool _isSaving = false;

  late final TextEditingController _nameCtrl;
  late final TextEditingController _minDistanceCtrl;
  late final TextEditingController _maxDistanceCtrl;
  late final TextEditingController _baseFeeCtrl;
  late final TextEditingController _nearbyExtraFeeCtrl;
  late final TextEditingController _farExtraFeeCtrl;
  late final TextEditingController _estDeliveryTimeCtrl;

  bool get _isEditMode => _editZoneId != null;
  String? _editZoneId;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _minDistanceCtrl = TextEditingController();
    _maxDistanceCtrl = TextEditingController();
    _baseFeeCtrl = TextEditingController();
    _nearbyExtraFeeCtrl = TextEditingController(text: '0');
    _farExtraFeeCtrl = TextEditingController(text: '0');
    _estDeliveryTimeCtrl = TextEditingController();

    final args = AppNavigator.arguments;
    if (args is Map<String, dynamic> && args['id'] != null) {
      _editZoneId = args['id'].toString();
      _nameCtrl.text = args['name'] ?? '';
      _minDistanceCtrl.text = args['min_distance_km']?.toString() ?? '';
      _maxDistanceCtrl.text = args['max_distance_km']?.toString() ?? '';
      _baseFeeCtrl.text = args['base_fee']?.toString() ?? '';
      _nearbyExtraFeeCtrl.text = args['nearby_extra_fee']?.toString() ?? '0';
      _farExtraFeeCtrl.text = args['far_extra_fee']?.toString() ?? '0';
      _estDeliveryTimeCtrl.text = args['estimated_delivery_time']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _minDistanceCtrl.dispose();
    _maxDistanceCtrl.dispose();
    _baseFeeCtrl.dispose();
    _nearbyExtraFeeCtrl.dispose();
    _farExtraFeeCtrl.dispose();
    _estDeliveryTimeCtrl.dispose();
    super.dispose();
  }

  void _error(String msg) {
    AppNavigator.snackbar('Error'.tr, msg,
        backgroundColor: const Color(0xFFF44336),
        colorText: const Color(0xFFFFFFFF));
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      _error('Zone name is required'.tr);
      return;
    }
    if (_minDistanceCtrl.text.trim().isEmpty) {
      _error('Min distance is required'.tr);
      return;
    }
    if (_maxDistanceCtrl.text.trim().isEmpty) {
      _error('Max distance is required'.tr);
      return;
    }
    if (_baseFeeCtrl.text.trim().isEmpty) {
      _error('Base fee is required'.tr);
      return;
    }

    final minDist = double.tryParse(_minDistanceCtrl.text.trim()) ?? 0;
    final maxDist = double.tryParse(_maxDistanceCtrl.text.trim()) ?? 0;
    if (maxDist <= minDist) {
      _error('Max distance must be greater than min distance'.tr);
      return;
    }

    setState(() => _isSaving = true);
    try {
      final body = <String, String>{
        'name': _nameCtrl.text.trim(),
        'min_distance_km': _minDistanceCtrl.text.trim(),
        'max_distance_km': _maxDistanceCtrl.text.trim(),
        'base_fee': _baseFeeCtrl.text.trim(),
        'nearby_extra_fee': _nearbyExtraFeeCtrl.text.trim().isEmpty
            ? '0'
            : _nearbyExtraFeeCtrl.text.trim(),
        'far_extra_fee': _farExtraFeeCtrl.text.trim().isEmpty
            ? '0'
            : _farExtraFeeCtrl.text.trim(),
        if (_estDeliveryTimeCtrl.text.trim().isNotEmpty)
          'estimated_delivery_time': _estDeliveryTimeCtrl.text.trim(),
      };

      ApiResponse res;

      if (_isEditMode) {
        body['zone_id'] = _editZoneId!;
        res = await ApiProvider.post(ApiEndpoints.adminDeliveryZonesUpdate,
            body: body);
      } else {
        res = await ApiProvider.post(ApiEndpoints.adminDeliveryZonesAdd,
            body: body);
      }

      if (res.success) {
        AppNavigator.back(result: true);
        AppNavigator.snackbar(
          _isEditMode ? 'Updated'.tr : 'Created'.tr,
          _isEditMode ? 'Delivery zone updated'.tr : 'Delivery zone created'.tr,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF),
        );
      } else {
        _error(res.message?.tr ?? 'Failed'.tr);
      }
    } catch (e) {
      _error('Something went wrong'.tr);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        title:
            Text(_isEditMode ? 'Edit Delivery Zone'.tr : 'New Delivery Zone'.tr),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => AppNavigator.back(),
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: AppColors.primaryOrange, strokeWidth: 2)),
            )
          else
            TextButton(
              onPressed: _save,
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
              controller: _nameCtrl,
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
                        controller: _minDistanceCtrl,
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
                        controller: _maxDistanceCtrl,
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
                      'Max distance must be greater than min distance. Use consecutive ranges (e.g. 0–2, 2.01–5, 5.01–10).'.tr,
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
              controller: _baseFeeCtrl,
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
                        controller: _nearbyExtraFeeCtrl,
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
                        controller: _farExtraFeeCtrl,
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
                      'Nearby extra fee is added for short-distance surcharges. Far extra fee is added for long-distance orders within this zone.'.tr,
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
              controller: _estDeliveryTimeCtrl,
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
                onPressed: _isSaving ? null : _save,
                icon: Icon(_isEditMode
                    ? Icons.save_outlined
                    : Icons.add_location_alt),
                label: Text(_isSaving
                    ? 'Saving...'.tr
                    : _isEditMode
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
