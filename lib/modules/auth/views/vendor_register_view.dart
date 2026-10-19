import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/constants/api_endpoints.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/providers/api_provider.dart';
import '../../../shared/localization/app_translations.dart';
import '../../../shared/utils/app_navigator.dart';

/// Static location data for vendor registration (same as order app)
class _LocationData {
  static const List<Map<String, dynamic>> zones = [
    {
      'zone': 'north',
      'zoneAr': 'الشمال',
      'cities': [
        {
          'name': 'مدينة غزة',
          'neighborhoods': [
            'حي الرمال', 'حي الشجاعية', 'حي الزيتون', 'حي التفاح',
            'حي الدرج', 'حي الصبرة', 'حي الشيخ رضوان', 'حي النصر',
            'حي تل الهوا', 'حي الشيخ عجلين', 'مخيم الشاطئ',
          ],
        },
      ],
    },
    {
      'zone': 'central',
      'zoneAr': 'الوسطى',
      'cities': [
        {
          'name': 'مدينة دير البلح',
          'neighborhoods': ['منطقة حكر الجامع', 'منطقة المشاعلة', 'منطقة طريق النخل'],
        },
        {
          'name': 'مخيم النصيرات',
          'neighborhoods': ['مخيم 1', 'مخيم 2', 'مخيم 5', 'منطقة الحساينة'],
        },
        {
          'name': 'مخيم البريج',
          'neighborhoods': [
            'بلوك 1', 'بلوك 2', 'بلوك 3', 'بلوك 4', 'بلوك 5', 'بلوك 6',
            'بلوك 7', 'بلوك 8', 'بلوك 9', 'بلوك 10', 'بلوك 11', 'بلوك 12',
          ],
        },
        {
          'name': 'مخيم المغازي',
          'neighborhoods': ['منطقة وسط المخيم'],
        },
      ],
    },
    {
      'zone': 'south',
      'zoneAr': 'الجنوب',
      'cities': [
        {
          'name': 'مدينة خانيونس',
          'neighborhoods': [
            'حي الأمل', 'حي الكتيبة', 'حي الشيخ ناصر', 'جورة العقاد',
            'منطقة السطر', 'منطقة معن', 'منطقة المواسي', 'مخيم خانيونس',
          ],
        },
      ],
    },
  ];

  static List<Map<String, String>> getAllCities() {
    final result = <Map<String, String>>[];
    for (final zone in zones) {
      for (final city in zone['cities'] as List) {
        result.add({
          'name': city['name'] as String,
          'zone': zone['zone'] as String,
          'zoneAr': zone['zoneAr'] as String,
        });
      }
    }
    return result;
  }

  static List<String> getNeighborhoods(String cityName) {
    for (final zone in zones) {
      for (final city in zone['cities'] as List) {
        if (city['name'] == cityName) {
          return List<String>.from(city['neighborhoods'] as List);
        }
      }
    }
    return [];
  }

  static String? getZone(String cityName) {
    for (final zone in zones) {
      for (final city in zone['cities'] as List) {
        if (city['name'] == cityName) return zone['zone'] as String;
      }
    }
    return null;
  }
}

/// Vendor self-registration form
class VendorRegisterView extends StatefulWidget {
  const VendorRegisterView({super.key});

  @override
  State<VendorRegisterView> createState() => _VendorRegisterViewState();
}

class _VendorRegisterViewState extends State<VendorRegisterView> {
  // Account fields
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _passCtrl;
  late final TextEditingController _confirmPassCtrl;
  late final TextEditingController _phoneCtrl;

  // Business fields
  late final TextEditingController _bizNameCtrl;
  late final TextEditingController _bizPhoneCtrl;

  String _bizType = 'restaurant';
  String? _selectedCity;
  String? _selectedNeighborhood;
  List<String> _neighborhoods = [];
  late final TextEditingController _detailedAddrCtrl;
  bool _isLoading = false;
  String _error = '';
  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _passCtrl = TextEditingController();
    _confirmPassCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _bizNameCtrl = TextEditingController();
    _bizPhoneCtrl = TextEditingController();
    _detailedAddrCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    _phoneCtrl.dispose();
    _bizNameCtrl.dispose();
    _bizPhoneCtrl.dispose();
    _detailedAddrCtrl.dispose();
    super.dispose();
  }

  void _onCityChanged(String? city) {
    setState(() {
      _selectedCity = city;
      _selectedNeighborhood = null;
      _neighborhoods = city != null ? _LocationData.getNeighborhoods(city) : [];
    });
  }

  Future<void> _register() async {
    // Validation
    if (_nameCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty ||
        _passCtrl.text.isEmpty ||
        _confirmPassCtrl.text.isEmpty ||
        _phoneCtrl.text.trim().isEmpty) {
      setState(() => _error = 'All account fields are required'.tr);
      return;
    }
    if (_passCtrl.text.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters'.tr);
      return;
    }
    if (_passCtrl.text != _confirmPassCtrl.text) {
      setState(() => _error = 'Passwords do not match'.tr);
      return;
    }
    if (_bizNameCtrl.text.trim().isEmpty ||
        _bizPhoneCtrl.text.trim().isEmpty) {
      setState(() => _error = 'All business fields are required'.tr);
      return;
    }
    if (_selectedCity == null || _selectedCity!.isEmpty) {
      setState(() => _error = 'يجب اختيار المدينة'.tr);
      return;
    }
    if (_selectedNeighborhood == null || _selectedNeighborhood!.isEmpty) {
      setState(() => _error = 'يجب اختيار الحي'.tr);
      return;
    }

    setState(() {
      _isLoading = true;
      _error = '';
    });

    final zone = _LocationData.getZone(_selectedCity!) ?? 'north';
    final res = await ApiProvider.post(
      ApiEndpoints.registerVendor,
      body: {
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'password': _passCtrl.text,
        'confirm_password': _confirmPassCtrl.text,
        'phone': _phoneCtrl.text.trim(),
        'business_name': _bizNameCtrl.text.trim(),
        'business_type': _bizType,
        'business_phone': _bizPhoneCtrl.text.trim(),
        'business_address': '$_selectedCity - $_selectedNeighborhood',
        'business_city': _selectedCity!,
        'business_neighborhood': _selectedNeighborhood!,
        'detailed_address': _detailedAddrCtrl.text.trim(),
        'delivery_zone': zone,
        'latitude': '31.50000000',
        'longitude': '34.47000000',
      },
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (res.success) {
      AppNavigator.dialog(
        AlertDialog(
          backgroundColor: AppColors.darkSurface,
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.success),
              const SizedBox(width: 8),
              Text('Submitted!'.tr,
                  style: const TextStyle(color: Colors.white)),
            ],
          ),
          content: Text(
            'Your vendor registration has been submitted.\n\n'
            'A Super Admin will review your application. '
            'You will be able to login once your account is approved.'.tr,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                AppNavigator.back();
                AppNavigator.offAllNamed(AppRoutes.login);
              },
              child: Text('Go to Login'.tr),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    } else {
      setState(() => _error = res.message?.tr ?? 'Registration failed'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        title: Text('Register as Vendor'.tr),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.store_outlined,
                    size: 40, color: AppColors.primaryOrange),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text('Join as a Vendor'.tr,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                'Fill in your details to register your business'.tr,
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.6)),
              ),
            ),
            const SizedBox(height: 28),

            // ── Section: Account Info ──
            _sectionTitle('Account Information'.tr),
            const SizedBox(height: 12),
            _card(
              children: [
                _tf(_nameCtrl, 'Full Name'.tr, Icons.person),
                const SizedBox(height: 12),
                _tf(_emailCtrl, 'Email'.tr, Icons.email_outlined,
                    type: TextInputType.emailAddress),
                const SizedBox(height: 12),
                _tf(_phoneCtrl, 'Phone Number'.tr, Icons.phone,
                    type: TextInputType.phone),
                const SizedBox(height: 12),
                TextField(
                  controller: _passCtrl,
                  obscureText: _obscure1,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Password'.tr,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure1
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => setState(() => _obscure1 = !_obscure1),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _confirmPassCtrl,
                  obscureText: _obscure2,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Confirm Password'.tr,
                    prefixIcon: const Icon(Icons.lock_reset),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure2
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => setState(() => _obscure2 = !_obscure2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Section: Business Info ──
            _sectionTitle('Business Information'.tr),
            const SizedBox(height: 12),
            _card(
              children: [
                _tf(_bizNameCtrl, 'Business Name'.tr, Icons.business),
                const SizedBox(height: 12),

                // ── Business Type Picker ──
                Text('Business Type'.tr,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['restaurant', 'store', 'cafe'].map((t) {
                    final sel = _bizType == t;
                    return ChoiceChip(
                      label: Text(t.tr),
                      selected: sel,
                      onSelected: (_) => setState(() => _bizType = t),
                      selectedColor: AppColors.primaryOrange,
                      backgroundColor: AppColors.cardDark,
                      labelStyle: TextStyle(
                        color: sel ? Colors.white : AppColors.textSecondary,
                        fontWeight:
                            sel ? FontWeight.w600 : FontWeight.normal,
                      ),
                      side: BorderSide(
                        color: sel
                            ? AppColors.primaryOrange
                            : AppColors.divider,
                      ),
                    );
                  }).toList(),
                ),

                _tf(_bizPhoneCtrl, 'Business Phone'.tr, Icons.phone_android,
                    type: TextInputType.phone),
              ],
            ),
            const SizedBox(height: 20),

            // ── Section: Location ──
            _sectionTitle('موقع المتجر - Location *'.tr),
            const SizedBox(height: 12),
            _card(
              children: [
                Text('المدينة *'.tr,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.darkSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _selectedCity != null
                          ? _zoneColor(
                              _LocationData.getZone(_selectedCity!))
                          : AppColors.divider,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      dropdownColor: AppColors.darkSurface,
                      value: _selectedCity,
                      hint: Text('اختر المدينة'.tr,
                          style: const TextStyle(
                              color: AppColors.textSecondary)),
                      items: _LocationData.getAllCities().map((c) {
                        return DropdownMenuItem(
                          value: c['name'],
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _zoneColor(c['zone'])
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(c['zoneAr']!,
                                    style: TextStyle(
                                        color: _zoneColor(c['zone']),
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600)),
                              ),
                              const SizedBox(width: 8),
                              Text(c['name']!,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 14)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (v) => _onCityChanged(v),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text('الحي / المنطقة *'.tr,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 8),
                if (_selectedCity == null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Text('اختر المدينة أولاً'.tr,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13)),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        dropdownColor: AppColors.darkSurface,
                        value: _selectedNeighborhood,
                        hint: Text('اختر الحي'.tr,
                            style: const TextStyle(
                                color: AppColors.textSecondary)),
                        items: _neighborhoods
                            .map((n) => DropdownMenuItem(
                                  value: n,
                                  child: Text(n,
                                      style: const TextStyle(
                                          color: Colors.white)),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedNeighborhood = v),
                      ),
                    ),
                  ),
                const SizedBox(height: 14),
                Text('Detailed Address'.tr,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 8),
                TextField(
                  controller: _detailedAddrCtrl,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'e.g. Street name, building, floor...'.tr,
                    prefixIcon: const Icon(Icons.edit_location_alt_outlined),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Error ──
            if (_error.isNotEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Text(_error,
                    style:
                        const TextStyle(color: AppColors.error, fontSize: 13)),
              ),

            // ── Submit button ──
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _register,
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : Text('Submit Registration'.tr,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),

            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => AppNavigator.back(),
                child: Text('Already have an account? Sign In'.tr,
                    style: const TextStyle(
                        color: AppColors.primaryOrange, fontSize: 14)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  static Color _zoneColor(String? zone) {
    switch (zone) {
      case 'north':
        return const Color(0xFF2196F3);
      case 'central':
        return const Color(0xFF4CAF50);
      case 'south':
        return const Color(0xFFFF9800);
      default:
        return AppColors.primaryOrange;
    }
  }

  static Widget _sectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            color: AppColors.primaryOrange,
            fontSize: 16,
            fontWeight: FontWeight.w600));
  }

  static Widget _card({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  static Widget _tf(TextEditingController ctrl, String hint, IconData icon,
      {TextInputType type = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
    );
  }
}
