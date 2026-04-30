import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/constants/api_endpoints.dart';
import '../../../../data/providers/api_provider.dart';

/// Static location data for vendor zone city/neighborhood picker (admin side)
class _VendorLocationData {
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

class SaCreateVendorController extends GetxController {
  final isSaving = false.obs;
  final obscurePassword = true.obs;

  // Owner fields
  final ownerNameCtrl = TextEditingController();
  final ownerEmailCtrl = TextEditingController();
  final ownerPhoneCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  // Business fields
  final businessNameCtrl = TextEditingController();
  final businessPhoneCtrl = TextEditingController();
  final commissionCtrl = TextEditingController(text: '12.00');

  // Business type
  final businessType = 'restaurant'.obs;

  // Zone location fields
  final selectedCity = Rxn<String>();
  final selectedNeighborhood = Rxn<String>();
  final neighborhoods = <String>[].obs;

  void onCityChanged(String? city) {
    selectedCity.value = city;
    selectedNeighborhood.value = null;
    neighborhoods.value =
        city != null ? _VendorLocationData.getNeighborhoods(city) : [];
  }

  @override
  void onClose() {
    ownerNameCtrl.dispose();
    ownerEmailCtrl.dispose();
    ownerPhoneCtrl.dispose();
    passwordCtrl.dispose();
    businessNameCtrl.dispose();
    businessPhoneCtrl.dispose();
    commissionCtrl.dispose();
    super.onClose();
  }

  Future<void> save() async {
    // Validate
    if (ownerNameCtrl.text.trim().isEmpty) {
      _error('Owner name is required'.tr);
      return;
    }
    if (ownerEmailCtrl.text.trim().isEmpty) {
      _error('Owner email is required'.tr);
      return;
    }
    if (passwordCtrl.text.trim().isEmpty || passwordCtrl.text.trim().length < 6) {
      _error('Password must be at least 6 characters'.tr);
      return;
    }
    if (ownerPhoneCtrl.text.trim().isEmpty) {
      _error('Owner phone is required'.tr);
      return;
    }
    if (businessNameCtrl.text.trim().isEmpty) {
      _error('Business name is required'.tr);
      return;
    }
    if (businessPhoneCtrl.text.trim().isEmpty) {
      _error('Business phone is required'.tr);
      return;
    }
    if (selectedCity.value == null || selectedCity.value!.isEmpty) {
      _error('يجب اختيار المدينة'.tr);
      return;
    }
    if (selectedNeighborhood.value == null || selectedNeighborhood.value!.isEmpty) {
      _error('يجب اختيار الحي'.tr);
      return;
    }

    isSaving.value = true;
    try {
      final zone = _VendorLocationData.getZone(selectedCity.value!) ?? 'north';
      final res = await ApiProvider.post(
        ApiEndpoints.saVendorsCreate,
        body: {
          'name': ownerNameCtrl.text.trim(),
          'email': ownerEmailCtrl.text.trim(),
          'password': passwordCtrl.text.trim(),
          'phone': ownerPhoneCtrl.text.trim(),
          'business_name': businessNameCtrl.text.trim(),
          'business_type': businessType.value,
          'business_phone': businessPhoneCtrl.text.trim(),
          'business_address':
              '${selectedCity.value} - ${selectedNeighborhood.value}',
          'business_city': selectedCity.value!,
          'business_neighborhood': selectedNeighborhood.value!,
          'delivery_zone': zone,
          'commission_rate': commissionCtrl.text.trim().isEmpty
              ? '12.00'
              : commissionCtrl.text.trim(),
        },
      );

      if (res.success) {
        Get.back(result: true);
        Get.snackbar('Success'.tr, 'Vendor created & approved'.tr,
            backgroundColor: const Color(0xFF4CAF50),
            colorText: const Color(0xFFFFFFFF));
      } else {
        _error(res.message?.tr ?? 'Failed to create vendor'.tr);
      }
    } catch (e) {
      _error('Something went wrong'.tr);
    } finally {
      isSaving.value = false;
    }
  }

  void _error(String msg) {
    Get.snackbar('Validation'.tr, msg,
        backgroundColor: const Color(0xFFF44336),
        colorText: const Color(0xFFFFFFFF));
  }
}

class SaCreateVendorView extends StatelessWidget {
  const SaCreateVendorView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(SaCreateVendorController());

    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        title: Text('Create Vendor'.tr),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() => ctrl.isSaving.value
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
                  child: Text('Create'.tr,
                      style: const TextStyle(
                          color: AppColors.primaryOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                )),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Pre-approved badge ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified, color: AppColors.success, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This vendor will be created with approved status and can login immediately.'.tr,
                      style: const TextStyle(
                          color: AppColors.success,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Owner Info Section ──
            _sectionTitle(Icons.person, 'Owner Information'.tr),
            const SizedBox(height: 12),
            _label('Owner Full Name *'.tr),
            TextField(
              controller: ctrl.ownerNameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'e.g. Ahmed Hassan'.tr,
                prefixIcon: const Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 14),

            _label('Owner Email *'.tr),
            TextField(
              controller: ctrl.ownerEmailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'owner@example.com'.tr,
                prefixIcon: const Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 14),

            _label('Owner Phone *'.tr),
            TextField(
              controller: ctrl.ownerPhoneCtrl,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: '01003640090'.tr,
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 14),

            _label('Password *'.tr),
            Obx(() => TextField(
                  controller: ctrl.passwordCtrl,
                  obscureText: ctrl.obscurePassword.value,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Min 6 characters'.tr,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(ctrl.obscurePassword.value
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () => ctrl.obscurePassword.toggle(),
                    ),
                  ),
                )),
            const SizedBox(height: 28),

            // ── Business Info Section ──
            _sectionTitle(Icons.store, 'Business Information'.tr),
            const SizedBox(height: 12),
            _label('Business Name *'.tr),
            TextField(
              controller: ctrl.businessNameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'e.g. Gaza Grill Restaurant'.tr,
                prefixIcon: const Icon(Icons.storefront),
              ),
            ),
            const SizedBox(height: 14),

            _label('Business Type *'.tr),
            Obx(() => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.darkSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      dropdownColor: AppColors.darkSurface,
                      value: ctrl.businessType.value,
                      items: [
                        DropdownMenuItem(
                            value: 'restaurant',
                            child: Row(children: [
                              const Icon(Icons.restaurant,
                                  color: AppColors.primaryOrange, size: 18),
                              const SizedBox(width: 8),
                              Text('Restaurant'.tr,
                                  style: const TextStyle(color: Colors.white)),
                            ])),
                        DropdownMenuItem(
                            value: 'store',
                            child: Row(children: [
                              const Icon(Icons.shopping_bag,
                                  color: AppColors.info, size: 18),
                              const SizedBox(width: 8),
                              Text('Store'.tr,
                                  style: const TextStyle(color: Colors.white)),
                            ])),
                        DropdownMenuItem(
                            value: 'cafe',
                            child: Row(children: [
                              const Icon(Icons.coffee,
                                  color: AppColors.goldenYellow, size: 18),
                              const SizedBox(width: 8),
                              Text('Café'.tr,
                                  style: const TextStyle(color: Colors.white)),
                            ])),
                      ],
                      onChanged: (v) {
                        if (v != null) ctrl.businessType.value = v;
                      },
                    ),
                  ),
                )),
            const SizedBox(height: 14),

            _label('Business Phone *'.tr),
            TextField(
              controller: ctrl.businessPhoneCtrl,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: '01003640090'.tr,
                prefixIcon: const Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 20),

            // ── Location Section ──
            _sectionTitle(Icons.location_on, 'الموقع - Delivery Zone *'.tr),
            const SizedBox(height: 12),

            _label('المدينة *'.tr),
            Obx(() => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.darkSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ctrl.selectedCity.value != null
                          ? _zoneColor(
                              _VendorLocationData.getZone(ctrl.selectedCity.value!))
                          : AppColors.divider,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      dropdownColor: AppColors.darkSurface,
                      value: ctrl.selectedCity.value,
                      hint: Text('اختر المدينة'.tr,
                          style: const TextStyle(color: AppColors.textSecondary)),
                      items: _VendorLocationData.getAllCities().map((c) {
                        return DropdownMenuItem(
                          value: c['name'],
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _zoneColor(c['zone'])
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(c['zoneAr']!,
                                    style: TextStyle(
                                        color: _zoneColor(c['zone']),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600)),
                              ),
                              const SizedBox(width: 10),
                              Text(c['name']!,
                                  style: const TextStyle(color: Colors.white)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (v) => ctrl.onCityChanged(v),
                    ),
                  ),
                )),
            const SizedBox(height: 14),

            _label('الحي / المنطقة *'.tr),
            Obx(() {
              final hoods = ctrl.neighborhoods;
              if (ctrl.selectedCity.value == null) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.darkSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Text('اختر المدينة أولاً'.tr,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13)),
                );
              }
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    dropdownColor: AppColors.darkSurface,
                    value: ctrl.selectedNeighborhood.value,
                    hint: Text('اختر الحي'.tr,
                        style: const TextStyle(color: AppColors.textSecondary)),
                    items: hoods
                        .map((n) => DropdownMenuItem(
                              value: n,
                              child: Text(n,
                                  style:
                                      const TextStyle(color: Colors.white)),
                            ))
                        .toList(),
                    onChanged: (v) => ctrl.selectedNeighborhood.value = v,
                  ),
                ),
              );
            }),

            // Zone badge display
            Obx(() {
              if (ctrl.selectedCity.value == null) return const SizedBox.shrink();
              final zone =
                  _VendorLocationData.getZone(ctrl.selectedCity.value!);
              final zoneAr = zone == 'north'
                  ? 'الشمال'
                  : zone == 'central'
                      ? 'الوسطى'
                      : 'الجنوب';
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _zoneColor(zone).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: _zoneColor(zone).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.delivery_dining,
                          color: _zoneColor(zone), size: 18),
                      const SizedBox(width: 8),
                      Text('منطقة التوصيل: $zoneAr',
                          style: TextStyle(
                              color: _zoneColor(zone),
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 14),

            _label('Commission Rate (%)'.tr),
            TextField(
              controller: ctrl.commissionCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: '12.00',
                prefixIcon: Icon(Icons.percent),
              ),
            ),
            const SizedBox(height: 32),

            // ── Submit ──
            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton.icon(
                    onPressed: ctrl.isSaving.value ? null : ctrl.save,
                    icon: const Icon(Icons.add_business),
                    label: Text(ctrl.isSaving.value
                        ? 'Creating...'.tr
                        : 'Create & Approve Vendor'.tr),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  )),
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
        Expanded(
          child: Text(text,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
        ),
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
