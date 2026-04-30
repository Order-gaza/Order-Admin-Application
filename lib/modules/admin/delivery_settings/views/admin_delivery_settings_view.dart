import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/constants/api_endpoints.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../data/providers/api_provider.dart';

class AdminDeliverySettingsView extends StatefulWidget {
  const AdminDeliverySettingsView({super.key});

  @override
  State<AdminDeliverySettingsView> createState() =>
      _AdminDeliverySettingsViewState();
}

class _AdminDeliverySettingsViewState
    extends State<AdminDeliverySettingsView> {
  bool _isLoading = true;
  bool _isSaving = false;

  // 4 route controllers
  final _sameZoneCtrl = TextEditingController(text: '10');
  final _northCentralCtrl = TextEditingController(text: '20');
  final _centralSouthCtrl = TextEditingController(text: '20');
  final _northSouthCtrl = TextEditingController(text: '25');

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _sameZoneCtrl.dispose();
    _northCentralCtrl.dispose();
    _centralSouthCtrl.dispose();
    _northSouthCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiProvider.get(ApiEndpoints.adminZonePricingGet);
      if (res.success && res.data != null) {
        final routes = res.data['routes'] as List<dynamic>? ?? [];
        for (final r in routes) {
          final key = r['key'];
          final fee = r['fee']?.toString() ?? '0';
          switch (key) {
            case 'same_zone':
              _sameZoneCtrl.text = _formatFee(fee);
              break;
            case 'north_central':
              _northCentralCtrl.text = _formatFee(fee);
              break;
            case 'central_south':
              _centralSouthCtrl.text = _formatFee(fee);
              break;
            case 'north_south':
              _northSouthCtrl.text = _formatFee(fee);
              break;
          }
        }
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatFee(String fee) {
    final d = double.tryParse(fee) ?? 0;
    return d == d.roundToDouble() ? d.toInt().toString() : d.toStringAsFixed(2);
  }

  Future<void> _saveRoute(String routeKey, TextEditingController ctrl) async {
    final fee = double.tryParse(ctrl.text.trim());
    if (fee == null || fee < 0) {
      Get.snackbar('خطأ'.tr, 'أدخل سعر صحيح'.tr,
          backgroundColor: AppColors.error, colorText: Colors.white);
      return;
    }

    setState(() => _isSaving = true);
    try {
      final res = await ApiProvider.post(
        ApiEndpoints.adminZonePricingUpdate,
        body: {
          'route_key': routeKey,
          'fee': fee.toString(),
        },
      );
      if (res.success) {
        Get.snackbar('نجاح'.tr, 'تم تحديث سعر التوصيل'.tr,
            backgroundColor: AppColors.success, colorText: Colors.white);
      } else {
        Get.snackbar('خطأ'.tr, res.message?.tr ?? 'فشلت العملية'.tr,
            backgroundColor: AppColors.error, colorText: Colors.white);
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _saveAll() async {
    setState(() => _isSaving = true);
    final routes = [
      {'key': 'same_zone', 'ctrl': _sameZoneCtrl},
      {'key': 'north_central', 'ctrl': _northCentralCtrl},
      {'key': 'central_south', 'ctrl': _centralSouthCtrl},
      {'key': 'north_south', 'ctrl': _northSouthCtrl},
    ];

    bool allSuccess = true;
    for (final r in routes) {
      final ctrl = r['ctrl'] as TextEditingController;
      final fee = double.tryParse(ctrl.text.trim());
      if (fee == null || fee < 0) {
        allSuccess = false;
        continue;
      }
      final res = await ApiProvider.post(
        ApiEndpoints.adminZonePricingUpdate,
        body: {
          'route_key': r['key'] as String,
          'fee': fee.toString(),
        },
      );
      if (!res.success) allSuccess = false;
    }

    setState(() => _isSaving = false);

    if (allSuccess) {
      Get.snackbar('نجاح'.tr, 'تم تحديث جميع أسعار التوصيل'.tr,
          backgroundColor: AppColors.success, colorText: Colors.white);
    } else {
      Get.snackbar('تنبيه'.tr, 'بعض التحديثات لم تنجح'.tr,
          backgroundColor: AppColors.warning, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        title: Text('إعدادات التوصيل'.tr),
        actions: [
          _isSaving
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: AppColors.primaryOrange, strokeWidth: 2),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _saveAll,
                  tooltip: 'حفظ الكل'.tr,
                ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: AppRoutes.adminDeliverySettings),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: AppColors.primaryOrange))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.info.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: AppColors.info, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'التغييرات تطبق على الطلبات الجديدة فقط. الطلبات الحالية تحتفظ بسعر التوصيل الأصلي.'
                                .tr,
                            style: const TextStyle(
                                color: AppColors.info, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Zone map header
                  Row(
                    children: [
                      const Icon(Icons.map_outlined,
                          color: AppColors.primaryOrange, size: 20),
                      const SizedBox(width: 8),
                      Text('أسعار التوصيل حسب المنطقة'.tr,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'الشمال = غزة | الوسطى = دير البلح/النصيرات/البريج/المغازي | الجنوب = خانيونس',
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11),
                  ),
                  const SizedBox(height: 20),

                  // Route pricing cards
                  _routeCard(
                    icon: Icons.home_rounded,
                    iconColor: const Color(0xFF4CAF50),
                    title: 'داخلي (نفس المنطقة)',
                    subtitle: 'شمال→شمال | وسطى→وسطى | جنوب→جنوب',
                    controller: _sameZoneCtrl,
                    routeKey: 'same_zone',
                  ),
                  const SizedBox(height: 12),

                  _routeCard(
                    icon: Icons.swap_horiz_rounded,
                    iconColor: const Color(0xFF2196F3),
                    title: 'غزة ↔ الوسطى',
                    subtitle: 'من الشمال إلى الوسطى والعكس',
                    controller: _northCentralCtrl,
                    routeKey: 'north_central',
                  ),
                  const SizedBox(height: 12),

                  _routeCard(
                    icon: Icons.swap_horiz_rounded,
                    iconColor: const Color(0xFFFF9800),
                    title: 'الوسطى ↔ خانيونس',
                    subtitle: 'من الوسطى إلى الجنوب والعكس',
                    controller: _centralSouthCtrl,
                    routeKey: 'central_south',
                  ),
                  const SizedBox(height: 12),

                  _routeCard(
                    icon: Icons.multiple_stop_rounded,
                    iconColor: const Color(0xFFF44336),
                    title: 'غزة ↔ خانيونس',
                    subtitle: 'من الشمال إلى الجنوب والعكس (أبعد مسافة)',
                    controller: _northSouthCtrl,
                    routeKey: 'north_south',
                  ),
                  const SizedBox(height: 32),

                  // Save all button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _saveAll,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.save),
                      label: Text(
                          _isSaving ? 'جاري الحفظ...'.tr : 'حفظ جميع التغييرات'.tr),
                      style: ElevatedButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(vertical: 16)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _routeCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required TextEditingController controller,
    required String routeKey,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppColors.divider.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: '0',
                    prefixIcon: const Icon(Icons.attach_money),
                    suffixText: '₪',
                    suffixStyle: TextStyle(
                        color: iconColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed:
                      _isSaving ? null : () => _saveRoute(routeKey, controller),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: iconColor.withValues(alpha: 0.2),
                    foregroundColor: iconColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Icon(Icons.save_outlined, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
