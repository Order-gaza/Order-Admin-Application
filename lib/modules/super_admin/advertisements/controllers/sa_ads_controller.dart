import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../data/providers/api_provider.dart';
import '../../../../app/constants/api_endpoints.dart';
import '../../../../shared/localization/app_translations.dart';
import '../../../../shared/utils/app_navigator.dart';

final saAdsProvider = ChangeNotifierProvider<SaAdsController>((ref) {
  return SaAdsController.to;
});

class SaAdsController extends ChangeNotifier {
  static SaAdsController? _instance;
  static SaAdsController get to => _instance ??= SaAdsController();

  bool isLoading = false;
  List<Map<String, dynamic>> ads = [];

  SaAdsController() {
    fetchAds();
  }

  Future<void> fetchAds() async {
    isLoading = true;
    notifyListeners();
    try {
      final res = await ApiProvider.get(ApiEndpoints.saAdsGetAll);
      if (res.success && res.data != null) {
        final d = res.data as Map<String, dynamic>;
        ads = List<Map<String, dynamic>>.from(d['advertisements'] as List? ?? []);
      }
    } finally {
      isLoading = false;
      notifyListeners();
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
        notifyListeners();
      }
    } else {
      AppNavigator.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
    }
  }

  Future<void> deleteAd(String adId) async {
    final res =
        await ApiProvider.post(ApiEndpoints.saAdsDelete, body: {'ad_id': adId});
    if (res.success) {
      ads.removeWhere((a) => a['id']?.toString() == adId);
      notifyListeners();
      AppNavigator.snackbar('Deleted'.tr, 'Ad removed'.tr,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF));
    } else {
      AppNavigator.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
    }
  }
}

/// ─────────────────────────────────────────────────
/// Controller for Add/Edit Ad full page
/// ─────────────────────────────────────────────────
final saAddAdProvider =
    ChangeNotifierProvider.autoDispose<SaAddAdController>((ref) {
  final ctrl = SaAddAdController();
  ctrl.init(AppNavigator.arguments);
  return ctrl;
});

class SaAddAdController extends ChangeNotifier {
  bool isSaving = false;
  bool isLoadingVendors = false;

  // Form fields
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final urlCtrl = TextEditingController();
  final sortOrderCtrl = TextEditingController(text: '0');

  // Dates
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(const Duration(days: 30));

  // Image — XFile is web-compatible (image_picker supports web natively)
  XFile? selectedImage;
  String? existingImageUrl;

  // Vendor selection
  List<Map<String, dynamic>> vendors = [];
  String? selectedVendorId;

  // Edit mode
  bool get isEditMode => _editAdId != null;
  String? _editAdId;

  void init(dynamic args) {
    _loadVendors();

    // Check if editing
    if (args is Map<String, dynamic> && args['id'] != null) {
      _editAdId = args['id'].toString();
      titleCtrl.text = args['title'] ?? '';
      descCtrl.text = args['description'] ?? '';
      urlCtrl.text = args['target_url'] ?? '';
      sortOrderCtrl.text = (args['sort_order'] ?? 0).toString();

      final imgUrl = args['image_url'] as String?;
      if (imgUrl != null && imgUrl.isNotEmpty) {
        existingImageUrl = imgUrl;
      }

      if (args['vendor_id'] != null &&
          args['vendor_id'].toString().isNotEmpty) {
        selectedVendorId = args['vendor_id'].toString();
      }

      // Parse dates
      final sa = args['starts_at'];
      final ea = args['ends_at'];
      if (sa != null) {
        try {
          startDate = DateTime.parse(sa.toString());
        } catch (_) {}
      }
      if (ea != null) {
        try {
          endDate = DateTime.parse(ea.toString());
        } catch (_) {}
      }
      notifyListeners();
    }
  }

  void setStartDate(DateTime date) {
    startDate = date;
    notifyListeners();
  }

  void setEndDate(DateTime date) {
    endDate = date;
    notifyListeners();
  }

  void setSelectedVendorId(String? id) {
    selectedVendorId = id;
    notifyListeners();
  }

  void clearImages() {
    selectedImage = null;
    existingImageUrl = null;
    notifyListeners();
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    urlCtrl.dispose();
    sortOrderCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadVendors() async {
    isLoadingVendors = true;
    notifyListeners();
    try {
      final res = await ApiProvider.get(
        ApiEndpoints.saVendorsGetAll,
        queryParams: {'status': 'approved', 'limit': '100'},
      );
      if (res.success && res.data != null) {
        final d = res.data as Map<String, dynamic>;
        vendors =
            List<Map<String, dynamic>>.from(d['vendors'] as List? ?? []);
      }
    } finally {
      isLoadingVendors = false;
      notifyListeners();
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
      selectedImage = picked;
      existingImageUrl = null;
      notifyListeners();
    }
  }

  Future<void> save() async {
    if (titleCtrl.text.trim().isEmpty) {
      AppNavigator.snackbar('Validation'.tr, 'Title is required'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
      return;
    }

    isSaving = true;
    notifyListeners();
    try {
      final startsAtStr =
          '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')} 00:00:00';
      final endsAtStr =
          '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')} 23:59:59';

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
      if (selectedVendorId != null) {
        body['vendor_id'] = selectedVendorId!;
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
        if (selectedImage != null) {
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
            final imgFile = selectedImage!;
            final bytes = await imgFile.readAsBytes();
            final filename = imgFile.name.isNotEmpty ? imgFile.name : 'ad_image.jpg';
            final uploadRes = await ApiProvider.uploadMultipartBytes(
              ApiEndpoints.saAdsUploadImage,
              fields: {'ad_id': adId},
              fileField: 'image',
              bytes: bytes,
              filename: filename,
            );
            if (kDebugMode) {
              debugPrint(
                  '[AddAd] upload response: success=${uploadRes.success}, message=${uploadRes.message}');
            }
          }
        }

        AppNavigator.back(result: true);
        AppNavigator.snackbar(
          isEditMode ? 'Updated'.tr : 'Created'.tr,
          isEditMode
              ? 'Advertisement updated'.tr
              : 'Advertisement created'.tr,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF),
        );
      } else {
        AppNavigator.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
            backgroundColor: const Color(0xFFF44336),
            colorText: const Color(0xFFFFFFFF));
      }
    } catch (e, st) {
      if (kDebugMode) debugPrint('[AddAd] Error: $e\n$st');
      AppNavigator.snackbar('Error'.tr, 'Something went wrong'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
