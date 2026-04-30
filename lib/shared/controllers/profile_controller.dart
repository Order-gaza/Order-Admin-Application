import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/providers/api_provider.dart';
import '../../app/constants/api_endpoints.dart';
import '../../app/routes/app_routes.dart';
import '../../modules/auth/controllers/auth_controller.dart';

class ProfileController extends GetxController {
  final isLoading = false.obs;
  final isSaving = false.obs;

  // Current profile data
  final name = ''.obs;
  final email = ''.obs;
  final phone = ''.obs;

  // Text Controllers (for editing)
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final currentPassCtrl = TextEditingController();
  final newPassCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();

  // Password visibility toggles
  final obscureCurrent = true.obs;
  final obscureNew = true.obs;
  final obscureConfirm = true.obs;

  // Vendor-specific
  final vendorName = ''.obs;
  final vendorPhone = ''.obs;
  final vendorAddress = ''.obs;
  final vendorDescription = ''.obs;
  final vendorLogoUrl = ''.obs;
  final vendorCoverUrl = ''.obs;
  final vendorStatus = ''.obs;
  final isVendorOpen = false.obs;
  final openingTime = ''.obs;
  final closingTime = ''.obs;
  final estDeliveryTime = ''.obs;

  final vendorNameCtrl = TextEditingController();
  final vendorPhoneCtrl = TextEditingController();
  final vendorAddressCtrl = TextEditingController();
  final vendorDescCtrl = TextEditingController();
  final openingTimeCtrl = TextEditingController();
  final closingTimeCtrl = TextEditingController();
  final estDeliveryTimeCtrl = TextEditingController();

  final isUploadingLogo = false.obs;
  final isUploadingCover = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    currentPassCtrl.dispose();
    newPassCtrl.dispose();
    confirmPassCtrl.dispose();
    vendorNameCtrl.dispose();
    vendorPhoneCtrl.dispose();
    vendorAddressCtrl.dispose();
    vendorDescCtrl.dispose();
    openingTimeCtrl.dispose();
    closingTimeCtrl.dispose();
    estDeliveryTimeCtrl.dispose();
    super.onClose();
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    try {
      final res = await ApiProvider.get(ApiEndpoints.profileGet);
      if (res.success && res.data != null) {
        final d = res.data as Map<String, dynamic>;
        name.value = d['name'] ?? '';
        email.value = d['email'] ?? '';
        phone.value = d['phone'] ?? '';
        nameCtrl.text = name.value;
        phoneCtrl.text = phone.value;

        // Vendor-specific
        if (d['vendor'] != null) {
          final v = d['vendor'] as Map<String, dynamic>;
          vendorName.value = v['name'] ?? '';
          vendorPhone.value = v['phone'] ?? '';
          vendorAddress.value = v['address'] ?? '';
          vendorDescription.value = v['description'] ?? '';
          vendorLogoUrl.value = v['logo_url'] ?? '';
          vendorCoverUrl.value = v['cover_url'] ?? '';
          vendorStatus.value = v['status'] ?? 'pending';
          isVendorOpen.value = (v['is_currently_open'] ?? v['is_open'] ?? 0) == 1;
          openingTime.value = v['opening_time'] ?? '';
          closingTime.value = v['closing_time'] ?? '';
          estDeliveryTime.value = v['estimated_delivery_time']?.toString() ?? '';
          vendorNameCtrl.text = vendorName.value;
          vendorPhoneCtrl.text = vendorPhone.value;
          vendorAddressCtrl.text = vendorAddress.value;
          vendorDescCtrl.text = vendorDescription.value;
          openingTimeCtrl.text = openingTime.value;
          closingTimeCtrl.text = closingTime.value;
          estDeliveryTimeCtrl.text = estDeliveryTime.value;
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateProfile() async {
    isSaving.value = true;
    try {
      final res = await ApiProvider.post(ApiEndpoints.profileUpdate, body: {
        'name': nameCtrl.text,
        'phone': phoneCtrl.text,
      });
      if (res.success) {
        name.value = nameCtrl.text;
        phone.value = phoneCtrl.text;
        return true;
      } else {
        Get.snackbar('Error'.tr, res.message?.tr ?? 'Update failed'.tr,
            backgroundColor: const Color(0xFFF44336),
            colorText: const Color(0xFFFFFFFF));
        return false;
      }
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> changePassword() async {
    if (newPassCtrl.text != confirmPassCtrl.text) {
      Get.snackbar('Error'.tr, 'Passwords do not match'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
      return;
    }
    isSaving.value = true;
    try {
      final res =
          await ApiProvider.post(ApiEndpoints.profileChangePassword, body: {
        'current_password': currentPassCtrl.text,
        'new_password': newPassCtrl.text,
        'new_password_confirmation': confirmPassCtrl.text,
      });
      if (res.success) {
        currentPassCtrl.clear();
        newPassCtrl.clear();
        confirmPassCtrl.clear();
        Get.snackbar(
          'Password Changed'.tr,
          'Logging out for security. Please login with your new password.'.tr,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF),
          duration: const Duration(seconds: 3),
        );
        Future.delayed(const Duration(seconds: 3), () {
          ApiProvider.clearAuth();
          Get.offAllNamed(AppRoutes.login);
        });
      } else {
        Get.snackbar('Error'.tr, res.message?.tr ?? 'Change failed'.tr,
            backgroundColor: const Color(0xFFF44336),
            colorText: const Color(0xFFFFFFFF));
      }
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> updateVendorProfile() async {
    isSaving.value = true;
    try {
      final res =
          await ApiProvider.post(ApiEndpoints.vendorProfileUpdate, body: {
        'name': vendorNameCtrl.text,
        'phone': vendorPhoneCtrl.text,
        'address': vendorAddressCtrl.text,
        'description': vendorDescCtrl.text,
        'opening_time': openingTimeCtrl.text,
        'closing_time': closingTimeCtrl.text,
        'estimated_delivery_time': estDeliveryTimeCtrl.text,
      });
      if (res.success) {
        vendorName.value = vendorNameCtrl.text;
        openingTime.value = openingTimeCtrl.text;
        closingTime.value = closingTimeCtrl.text;
        estDeliveryTime.value = estDeliveryTimeCtrl.text;
        return true;
      } else {
        Get.snackbar('Error'.tr, res.message?.tr ?? 'Update failed'.tr,
            backgroundColor: const Color(0xFFF44336),
            colorText: const Color(0xFFFFFFFF));
        return false;
      }
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> toggleVendorOpen() async {
    if (vendorStatus.value != 'approved') {
      Get.snackbar('Not Allowed'.tr,
          'Your store must be approved before you can open it'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
      return;
    }
    final res = await ApiProvider.post(ApiEndpoints.vendorToggleOpen, body: {});
    if (res.success) {
      isVendorOpen.value = !isVendorOpen.value;
      Get.snackbar(
        isVendorOpen.value ? 'Open'.tr : 'Closed'.tr,
        isVendorOpen.value
            ? 'Your store is now open'.tr
            : 'Your store is now closed'.tr,
        backgroundColor: isVendorOpen.value
            ? const Color(0xFF4CAF50)
            : const Color(0xFFF44336),
        colorText: const Color(0xFFFFFFFF),
      );
    }
  }

  Future<void> uploadLogo() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked == null) return;

    isUploadingLogo.value = true;
    try {
      final res = await ApiProvider.uploadMultipart(
        ApiEndpoints.vendorProfileUploadLogo,
        fileField: 'logo',
        filePath: picked.path,
      );
      if (res.success && res.data != null) {
        final d = res.data as Map<String, dynamic>;
        vendorLogoUrl.value = d['logo_url'] ?? '';
        Get.snackbar('Uploaded'.tr, 'Logo updated successfully'.tr,
            backgroundColor: const Color(0xFF4CAF50),
            colorText: const Color(0xFFFFFFFF));
      } else {
        Get.snackbar('Error'.tr, res.message?.tr ?? 'Upload failed'.tr,
            backgroundColor: const Color(0xFFF44336),
            colorText: const Color(0xFFFFFFFF));
      }
    } catch (e) {
      Get.snackbar('Error'.tr, 'Failed to upload logo'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
    } finally {
      isUploadingLogo.value = false;
    }
  }

  Future<void> uploadCover() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1280,
      maxHeight: 720,
      imageQuality: 85,
    );
    if (picked == null) return;

    isUploadingCover.value = true;
    try {
      final res = await ApiProvider.uploadMultipart(
        ApiEndpoints.vendorProfileUploadCover,
        fileField: 'cover',
        filePath: picked.path,
      );
      if (res.success && res.data != null) {
        final d = res.data as Map<String, dynamic>;
        vendorCoverUrl.value = d['cover_url'] ?? '';
        Get.snackbar('Uploaded'.tr, 'Cover image updated'.tr,
            backgroundColor: const Color(0xFF4CAF50),
            colorText: const Color(0xFFFFFFFF));
      } else {
        Get.snackbar('Error'.tr, res.message?.tr ?? 'Upload failed'.tr,
            backgroundColor: const Color(0xFFF44336),
            colorText: const Color(0xFFFFFFFF));
      }
    } catch (e) {
      Get.snackbar('Error'.tr, 'Failed to upload cover'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
    } finally {
      isUploadingCover.value = false;
    }
  }

  Future<void> pickTime(BuildContext context, {required bool isOpening}) async {
    final initial = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFF6B35),
              surface: Color(0xFF2C2C2C),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final formatted =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      if (isOpening) {
        openingTimeCtrl.text = formatted;
        openingTime.value = formatted;
      } else {
        closingTimeCtrl.text = formatted;
        closingTime.value = formatted;
      }
    }
  }

  void logout() {
    Get.dialog(AlertDialog(
      backgroundColor: const Color(0xFF2C2C2C),
      title: Text('Logout'.tr, style: const TextStyle(color: Colors.white)),
      content: Text('Are you sure you want to logout?'.tr,
          style: const TextStyle(color: Color(0xFF9E9E9E))),
      actions: [
        TextButton(onPressed: () => Get.back(), child: Text('Cancel'.tr)),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF44336)),
          onPressed: () {
            Get.back();
            Get.put(AuthController()).logout();
          },
          child: Text('Logout'.tr),
        ),
      ],
    ));
  }

  void navigateToCorrectDashboard() {
    if (Get.currentRoute == AppRoutes.saProfile) {
      Get.offAllNamed(AppRoutes.saDashboard);
    } else if (Get.currentRoute == AppRoutes.adminProfile) {
      Get.offAllNamed(AppRoutes.adminDashboard);
    } else if (Get.currentRoute == AppRoutes.vendorProfile) {
      Get.offAllNamed(AppRoutes.vendorDashboard);
    }
  }
}
