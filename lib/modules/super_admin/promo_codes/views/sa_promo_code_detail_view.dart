import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/constants/api_endpoints.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../data/providers/api_provider.dart';
import '../../../../shared/localization/app_translations.dart';
import '../../../../shared/utils/app_navigator.dart';

class SaPromoCodeDetailView extends StatefulWidget {
  const SaPromoCodeDetailView({super.key});
  @override
  State<SaPromoCodeDetailView> createState() => _State();
}

class _State extends State<SaPromoCodeDetailView> {
  bool _loading = true;
  Map<String, dynamic>? _promo;
  List<dynamic> _usages = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = (AppNavigator.arguments as Map?)?['id'];
    if (id == null) return;
    setState(() => _loading = true);
    final res = await ApiProvider.get(ApiEndpoints.saPromoCodesGetById, queryParams: {'id': id.toString()});
    debugPrint('[PromoDetail] success=${res.success}, message=${res.message}, data=${res.data}');
    if (res.success && res.data != null) {
      _promo = res.data['promo_code'];
      _usages = res.data['usages'] ?? [];
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        title: Text(_promo?['code']?.toString() ?? 'Promo Code'.tr),
        actions: [
          if (_promo != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                await AppNavigator.toNamed(AppRoutes.saPromoCodeForm, arguments: {'promo': _promo});
                _load();
              },
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryOrange))
          : _promo == null
              ? Center(child: Text('Not found'.tr, style: const TextStyle(color: AppColors.textSecondary)))
              : RefreshIndicator(onRefresh: _load, color: AppColors.primaryOrange, child: _buildContent()),
    );
  }

  Widget _buildContent() {
    final p = _promo!;
    final isActive = p['is_active'] == true || p['is_active'] == 1;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Code header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(14)),
          child: Column(children: [
            Text(p['code']?.toString() ?? '',
                style: const TextStyle(color: AppColors.primaryOrange, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: (isActive ? AppColors.success : AppColors.error).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6)),
              child: Text(isActive ? 'Active'.tr : 'Inactive'.tr,
                  style: TextStyle(color: isActive ? AppColors.success : AppColors.error, fontSize: 13)),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        // Details
        _detailCard([
          _row('Discount'.tr, '${(p['discount_percentage'] ?? 0).toDouble().toStringAsFixed(0)}%'),
          _row('Max Cap'.tr, '₪${(p['max_discount_amount'] ?? 0).toDouble().toStringAsFixed(2)}'),
          _row('Limit Mode'.tr, p['limit_mode']?.toString() ?? '-'),
          if (p['limit_mode'] == 'count') _row('Max Uses'.tr, '${p['max_uses'] ?? '-'}'),
          if (p['limit_mode'] == 'date') _row('Expires'.tr, p['expires_at']?.toString().split(' ').first ?? '-'),
          _row('Used'.tr, '${p['current_uses'] ?? 0} times'),
          _row('Created'.tr, p['created_at']?.toString().split(' ').first ?? '-'),
        ]),
        const SizedBox(height: 24),
        // Usage history
        Text('Usage History'.tr, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        if (_usages.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text('No one has used this code yet'.tr,
                style: const TextStyle(color: AppColors.textSecondary))),
          )
        else
          ..._usages.map((u) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  const Icon(Icons.person_outline, color: AppColors.textSecondary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(u['customer_name'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                      Text('Order #${u['order_number']} — saved ₪${(u['discount_applied'] ?? 0).toDouble().toStringAsFixed(2)}',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ]),
                  ),
                  Text(u['used_at']?.toString().split(' ').first ?? '',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                ]),
              )),
      ],
    );
  }

  Widget _detailCard(List<Widget> children) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(14)),
    child: Column(children: children),
  );

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
    ]),
  );
}
