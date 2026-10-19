import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/localization/app_translations.dart';
import '../../../../shared/utils/app_navigator.dart';
import '../controllers/sa_promo_codes_controller.dart';

class SaPromoCodeFormView extends StatefulWidget {
  const SaPromoCodeFormView({super.key});
  @override
  State<SaPromoCodeFormView> createState() => _SaPromoCodeFormViewState();
}

class _SaPromoCodeFormViewState extends State<SaPromoCodeFormView> {
  final _codeCtrl = TextEditingController();
  final _percentageCtrl = TextEditingController();
  final _maxCapCtrl = TextEditingController();
  final _maxUsesCtrl = TextEditingController();
  String _limitMode = 'unlimited';
  DateTime? _expiresAt;
  bool _isSaving = false;
  Map<String, dynamic>? _editData;

  @override
  void initState() {
    super.initState();
    final args = AppNavigator.arguments as Map<String, dynamic>?;
    if (args != null && args['promo'] != null) {
      _editData = args['promo'];
      _codeCtrl.text = _editData!['code']?.toString() ?? '';
      _percentageCtrl.text = _editData!['discount_percentage']?.toString() ?? '';
      _maxCapCtrl.text = _editData!['max_discount_amount']?.toString() ?? '';
      _limitMode = _editData!['limit_mode']?.toString() ?? 'unlimited';
      _maxUsesCtrl.text = _editData!['max_uses']?.toString() ?? '';
      if (_editData!['expires_at'] != null) {
        _expiresAt = DateTime.tryParse(_editData!['expires_at']);
      }
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _percentageCtrl.dispose();
    _maxCapCtrl.dispose();
    _maxUsesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_codeCtrl.text.trim().isEmpty || _percentageCtrl.text.isEmpty || _maxCapCtrl.text.isEmpty) {
      AppNavigator.snackbar('Error'.tr, 'Please fill all required fields'.tr,
          backgroundColor: const Color(0xFFF44336), colorText: Colors.white);
      return;
    }
    setState(() => _isSaving = true);
    final controller = SaPromoCodesController.to;
    final body = <String, String>{
      'code': _codeCtrl.text.trim().toUpperCase(),
      'discount_percentage': _percentageCtrl.text,
      'max_discount_amount': _maxCapCtrl.text,
      'limit_mode': _limitMode,
    };
    if (_limitMode == 'count' && _maxUsesCtrl.text.isNotEmpty) body['max_uses'] = _maxUsesCtrl.text;
    if (_limitMode == 'date' && _expiresAt != null) body['expires_at'] = _expiresAt!.toIso8601String();

    bool ok;
    if (_editData != null) {
      body['id'] = _editData!['id'];
      ok = await controller.updatePromo(body);
    } else {
      ok = await controller.createPromo(body);
    }
    if (mounted) {
      setState(() => _isSaving = false);
    }
    if (ok) AppNavigator.back();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = _editData != null;
    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(title: Text(isEdit ? 'Edit Promo Code'.tr : 'Create Promo Code'.tr)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _label('Promo Code *'.tr),
          TextField(
            controller: _codeCtrl, enabled: !isEdit,
            textCapitalization: TextCapitalization.characters,
            style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 2),
            decoration: const InputDecoration(hintText: 'WELCOME50', prefixIcon: Icon(Icons.confirmation_number)),
          ),
          const SizedBox(height: 20),
          _label('Discount Percentage (%) *'.tr),
          TextField(
            controller: _percentageCtrl, keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: const InputDecoration(hintText: '50', prefixIcon: Icon(Icons.percent)),
          ),
          const SizedBox(height: 20),
          _label('Max Discount Cap (₪) *'.tr),
          TextField(
            controller: _maxCapCtrl, keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: const InputDecoration(hintText: '50', prefixIcon: Icon(Icons.money)),
          ),
          const SizedBox(height: 24),
          _label('Limit Mode'.tr),
          _limitModeSelector(),
          const SizedBox(height: 16),
          if (_limitMode == 'count') ...[
            _label('Max Uses'.tr),
            TextField(
              controller: _maxUsesCtrl, keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: const InputDecoration(hintText: '100', prefixIcon: Icon(Icons.people)),
            ),
            const SizedBox(height: 16),
          ],
          if (_limitMode == 'date') ...[
            _label('Expires At'.tr),
            _datePicker(),
            const SizedBox(height: 16),
          ],
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Icon(isEdit ? Icons.save : Icons.add),
              label: Text(_isSaving ? 'Saving...'.tr : (isEdit ? 'Update'.tr : 'Create'.tr)),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _datePicker() => InkWell(
    onTap: () async {
      final d = await showDatePicker(context: context,
        initialDate: _expiresAt ?? DateTime.now().add(const Duration(days: 30)),
        firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
      if (d != null) setState(() => _expiresAt = d);
    },
    child: Container(
      width: double.infinity, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.4))),
      child: Row(children: [
        const Icon(Icons.calendar_today, color: AppColors.textSecondary, size: 18),
        const SizedBox(width: 12),
        Text(_expiresAt != null ? _expiresAt.toString().split(' ').first : 'Select date'.tr,
          style: TextStyle(color: _expiresAt != null ? Colors.white : AppColors.textSecondary, fontSize: 16)),
      ]),
    ),
  );

  Widget _limitModeSelector() => Row(children: [
    _modeChip('unlimited', 'Unlimited'.tr, Icons.all_inclusive),
    const SizedBox(width: 8),
    _modeChip('count', 'Fixed Count'.tr, Icons.people),
    const SizedBox(width: 8),
    _modeChip('date', 'Date'.tr, Icons.calendar_today),
  ]);

  Widget _modeChip(String value, String label, IconData icon) {
    final sel = _limitMode == value;
    return Expanded(child: GestureDetector(
      onTap: () => setState(() => _limitMode = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: sel ? AppColors.primaryOrange.withValues(alpha: 0.15) : AppColors.cardDark,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: sel ? AppColors.primaryOrange : AppColors.divider.withValues(alpha: 0.4), width: sel ? 2 : 1)),
        child: Column(children: [
          Icon(icon, color: sel ? AppColors.primaryOrange : AppColors.textSecondary, size: 20),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center,
            style: TextStyle(color: sel ? AppColors.primaryOrange : AppColors.textSecondary, fontSize: 11)),
        ]),
      ),
    ));
  }

  Widget _label(String t) => Padding(padding: const EdgeInsets.only(bottom: 8),
    child: Text(t, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)));
}
