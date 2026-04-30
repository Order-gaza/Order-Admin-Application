import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../data/providers/api_provider.dart';
import '../../../../app/constants/api_endpoints.dart';

class SaAdsController extends GetxController {
  final isLoading = false.obs;
  final ads = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAds();
  }

  Future<void> fetchAds() async {
    isLoading.value = true;
    try {
      final res = await ApiProvider.get(ApiEndpoints.saAdsGetAll);
      if (res.success && res.data != null) {
        final d = res.data as Map<String, dynamic>;
        ads.value =
            List<Map<String, dynamic>>.from(d['advertisements'] as List? ?? []);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleAd(String adId) async {
    final res =
        await ApiProvider.post(ApiEndpoints.saAdsToggle, body: {'ad_id': adId});
    if (res.success) {
      final idx = ads.indexWhere((a) => a['id']?.toString() == adId);
      if (idx != -1) {
        final cur = (ads[idx]['is_active'] ?? 1) as int;
        ads[idx] = {...ads[idx], 'is_active': cur == 1 ? 0 : 1};
        ads.refresh();
      }
    } else {
      Get.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
    }
  }

  Future<void> deleteAd(String adId) async {
    final res =
        await ApiProvider.post(ApiEndpoints.saAdsDelete, body: {'ad_id': adId});
    if (res.success) {
      ads.removeWhere((a) => a['id']?.toString() == adId);
      Get.snackbar('Deleted'.tr, 'Ad removed'.tr,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF));
    } else {
      Get.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
    }
  }
}

/// ─────────────────────────────────────────────────
/// Controller for Add/Edit Ad full page
/// ─────────────────────────────────────────────────
class SaAddAdController extends GetxController {
  final isSaving = false.obs;
  final isLoadingVendors = false.obs;

  // Form fields
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final urlCtrl = TextEditingController();
  final sortOrderCtrl = TextEditingController(text: '0');

  // Dates
  final startDate = Rx<DateTime>(DateTime.now());
  final endDate = Rx<DateTime>(DateTime.now().add(const Duration(days: 30)));

  // Image
  final selectedImage = Rxn<File>();
  final existingImageUrl = Rxn<String>();

  // Vendor selection
  final vendors = <Map<String, dynamic>>[].obs;
  final selectedVendorId = Rxn<String>();

  // Edit mode
  bool get isEditMode => _editAdId != null;
  String? _editAdId;

  @override
  void onInit() {
    super.onInit();
    _loadVendors();

    // Check if editing
    final args = Get.arguments;
    if (args is Map<String, dynamic> && args['id'] != null) {
      _editAdId = args['id'].toString();
      titleCtrl.text = args['title'] ?? '';
      descCtrl.text = args['description'] ?? '';
      urlCtrl.text = args['target_url'] ?? '';
      sortOrderCtrl.text = (args['sort_order'] ?? 0).toString();

      final imgUrl = args['image_url'] as String?;
      if (imgUrl != null && imgUrl.isNotEmpty) {
        existingImageUrl.value = imgUrl;
      }

      if (args['vendor_id'] != null &&
          args['vendor_id'].toString().isNotEmpty) {
        selectedVendorId.value = args['vendor_id'].toString();
      }

      // Parse dates
      final sa = args['starts_at'];
      final ea = args['ends_at'];
      if (sa != null) {
        try {
          startDate.value = DateTime.parse(sa.toString());
        } catch (_) {}
      }
      if (ea != null) {
        try {
          endDate.value = DateTime.parse(ea.toString());
        } catch (_) {}
      }
    }
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    urlCtrl.dispose();
    sortOrderCtrl.dispose();
    super.onClose();
  }

  Future<void> _loadVendors() async {
    isLoadingVendors.value = true;
    try {
      final res = await ApiProvider.get(
        ApiEndpoints.saVendorsGetAll,
        queryParams: {'status': 'approved', 'limit': '100'},
      );
      if (res.success && res.data != null) {
        final d = res.data as Map<String, dynamic>;
        vendors.value =
            List<Map<String, dynamic>>.from(d['vendors'] as List? ?? []);
      }
    } finally {
      isLoadingVendors.value = false;
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (picked != null) {
      selectedImage.value = File(picked.path);
      existingImageUrl.value = null;
    }
  }

  Future<void> save() async {
    if (titleCtrl.text.trim().isEmpty) {
      Get.snackbar('Validation'.tr, 'Title is required'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
      return;
    }

    isSaving.value = true;
    try {
      final startsAtStr =
          '${startDate.value.year}-${startDate.value.month.toString().padLeft(2, '0')}-${startDate.value.day.toString().padLeft(2, '0')} 00:00:00';
      final endsAtStr =
          '${endDate.value.year}-${endDate.value.month.toString().padLeft(2, '0')}-${endDate.value.day.toString().padLeft(2, '0')} 23:59:59';

      final body = <String, String>{
        'title': titleCtrl.text.trim(),
        'starts_at': startsAtStr,
        'ends_at': endsAtStr,
      };

      if (descCtrl.text.trim().isNotEmpty) {
        body['description'] = descCtrl.text.trim();
      }
      if (urlCtrl.text.trim().isNotEmpty) {
        body['target_url'] = urlCtrl.text.trim();
      }
      if (selectedVendorId.value != null) {
        body['vendor_id'] = selectedVendorId.value!;
      }
      body['sort_order'] = sortOrderCtrl.text.trim().isEmpty
          ? '0'
          : sortOrderCtrl.text.trim();

      ApiResponse res;

      if (isEditMode) {
        body['ad_id'] = _editAdId!;
        res = await ApiProvider.post(ApiEndpoints.saAdsUpdate, body: body);
      } else {
        res = await ApiProvider.post(ApiEndpoints.saAdsAdd, body: body);
      }

      if (kDebugMode) debugPrint('[AddAd] save response: success=${res.success}, data=${res.data}');

      if (res.success) {
        // Upload image if a new one was selected
        if (selectedImage.value != null) {
          String? adId = _editAdId;

          if (adId == null && res.data != null) {
            final data = res.data;
            if (data is Map<String, dynamic>) {
              final adData = data['advertisement'];
              if (adData is Map<String, dynamic>) {
                adId = adData['id']?.toString();
              }
            }
          }

          if (kDebugMode) debugPrint('[AddAd] uploading image for adId=$adId');

          if (adId != null) {
            final uploadRes = await ApiProvider.uploadMultipart(
              ApiEndpoints.saAdsUploadImage,
              fields: {'ad_id': adId},
              fileField: 'image',
              filePath: selectedImage.value!.path,
            );
            if (kDebugMode) debugPrint(
                '[AddAd] upload response: success=${uploadRes.success}, message=${uploadRes.message}');
          }
        }

        Get.back(result: true);
        Get.snackbar(
          isEditMode ? 'Updated' : 'Created',
          isEditMode
              ? 'Advertisement updated'
              : 'Advertisement created',
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF),
        );
      } else {
        Get.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
            backgroundColor: const Color(0xFFF44336),
            colorText: const Color(0xFFFFFFFF));
      }
    } catch (e, st) {
      if (kDebugMode) debugPrint('[AddAd] Error: $e\n$st');
      Get.snackbar('Error'.tr, 'Something went wrong'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
    } finally {
      isSaving.value = false;
    }
  }
}
