import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/constants/api_endpoints.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/providers/api_provider.dart';

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
class VendorRegisterView extends StatelessWidget {
  const VendorRegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    // Account fields
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    // Business fields
    final bizNameCtrl = TextEditingController();
    final bizPhoneCtrl = TextEditingController();

    final bizType = 'restaurant'.obs;
    final selectedCity = Rxn<String>();
    final selectedNeighborhood = Rxn<String>();
    final neighborhoods = <String>[].obs;
    final isLoading = false.obs;
    final error = ''.obs;
    final obscure1 = true.obs;
    final obscure2 = true.obs;

    void onCityChanged(String? city) {
      selectedCity.value = city;
      selectedNeighborhood.value = null;
      neighborhoods.value =
          city != null ? _LocationData.getNeighborhoods(city) : [];
    }

    Future<void> register() async {
      // Validation
      if (nameCtrl.text.trim().isEmpty ||
          emailCtrl.text.trim().isEmpty ||
          passCtrl.text.isEmpty ||
          confirmPassCtrl.text.isEmpty ||
          phoneCtrl.text.trim().isEmpty) {
        error.value = 'All account fields are required'.tr;
        return;
      }
      if (passCtrl.text.length < 6) {
        error.value = 'Password must be at least 6 characters'.tr;
        return;
      }
      if (passCtrl.text != confirmPassCtrl.text) {
        error.value = 'Passwords do not match'.tr;
        return;
      }
      if (bizNameCtrl.text.trim().isEmpty ||
          bizPhoneCtrl.text.trim().isEmpty) {
        error.value = 'All business fields are required'.tr;
        return;
      }
      if (selectedCity.value == null || selectedCity.value!.isEmpty) {
        error.value = 'يجب اختيار المدينة'.tr;
        return;
      }
      if (selectedNeighborhood.value == null ||
          selectedNeighborhood.value!.isEmpty) {
        error.value = 'يجب اختيار الحي'.tr;
        return;
      }

      isLoading.value = true;
      error.value = '';

      final zone = _LocationData.getZone(selectedCity.value!) ?? 'north';
      final res = await ApiProvider.post(
        ApiEndpoints.registerVendor,
        body: {
          'name': nameCtrl.text.trim(),
          'email': emailCtrl.text.trim(),
          'password': passCtrl.text,
          'confirm_password': confirmPassCtrl.text,
          'phone': phoneCtrl.text.trim(),
          'business_name': bizNameCtrl.text.trim(),
          'business_type': bizType.value,
          'business_phone': bizPhoneCtrl.text.trim(),
          'business_address':
              '${selectedCity.value} - ${selectedNeighborhood.value}',
          'business_city': selectedCity.value!,
          'business_neighborhood': selectedNeighborhood.value!,
          'delivery_zone': zone,
          'latitude': '31.50000000',
          'longitude': '34.47000000',
        },
      );

      isLoading.value = false;

      if (res.success) {
        Get.dialog(
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
                  Get.back();
                  Get.offAllNamed(AppRoutes.login);
                },
                child: Text('Go to Login'.tr),
              ),
            ],
          ),
          barrierDismissible: false,
        );
      } else {
        error.value = res.message?.tr ?? 'Registration failed'.tr;
      }
    }

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
                _tf(nameCtrl, 'Full Name'.tr, Icons.person),
                const SizedBox(height: 12),
                _tf(emailCtrl, 'Email'.tr, Icons.email_outlined,
                    type: TextInputType.emailAddress),
                const SizedBox(height: 12),
                _tf(phoneCtrl, 'Phone Number'.tr, Icons.phone,
                    type: TextInputType.phone),
                const SizedBox(height: 12),
                Obx(() => TextField(
                      controller: passCtrl,
                      obscureText: obscure1.value,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Password'.tr,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscure1.value
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () => obscure1.value = !obscure1.value,
                        ),
                      ),
                    )),
                const SizedBox(height: 12),
                Obx(() => TextField(
                      controller: confirmPassCtrl,
                      obscureText: obscure2.value,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Confirm Password'.tr,
                        prefixIcon: const Icon(Icons.lock_reset),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscure2.value
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () => obscure2.value = !obscure2.value,
                        ),
                      ),
                    )),
              ],
            ),
            const SizedBox(height: 20),

            // ── Section: Business Info ──
            _sectionTitle('Business Information'.tr),
            const SizedBox(height: 12),
            _card(
              children: [
                _tf(bizNameCtrl, 'Business Name'.tr, Icons.business),
                const SizedBox(height: 12),

                // ── Business Type Picker ──
                Text('Business Type'.tr,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 8),
                Obx(() => Wrap(
                      spacing: 8,
                      children: ['restaurant', 'store', 'cafe'].map((t) {
                        final sel = bizType.value == t;
                        return ChoiceChip(
                          label: Text(t.tr),
                          selected: sel,
                          onSelected: (_) => bizType.value = t,
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
                    )),

                _tf(bizPhoneCtrl, 'Business Phone'.tr, Icons.phone_android,
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
                Obx(() => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.darkSurface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selectedCity.value != null
                              ? _zoneColor(
                                  _LocationData.getZone(selectedCity.value!))
                              : AppColors.divider,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          dropdownColor: AppColors.darkSurface,
                          value: selectedCity.value,
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
                          onChanged: (v) => onCityChanged(v),
                        ),
                      ),
                    )),
                const SizedBox(height: 14),
                Text('الحي / المنطقة *'.tr,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 8),
                Obx(() {
                  if (selectedCity.value == null) {
                    return Container(
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
                    );
                  }
                  return Container(
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
                        value: selectedNeighborhood.value,
                        hint: Text('اختر الحي'.tr,
                            style: const TextStyle(
                                color: AppColors.textSecondary)),
                        items: neighborhoods
                            .map((n) => DropdownMenuItem(
                                  value: n,
                                  child: Text(n,
                                      style: const TextStyle(
                                          color: Colors.white)),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            selectedNeighborhood.value = v,
                      ),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 20),

            // ── Error ──
            Obx(() {
              if (error.value.isEmpty) return const SizedBox.shrink();
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Text(error.value,
                    style:
                        const TextStyle(color: AppColors.error, fontSize: 13)),
              );
            }),

            // ── Submit button ──
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading.value ? null : register,
                    child: isLoading.value
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5))
                        : Text('Submit Registration'.tr,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                )),

            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => Get.back(),
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
