import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/providers/api_provider.dart';
import '../../app/constants/api_endpoints.dart';
import '../../app/routes/app_routes.dart';
import '../../modules/auth/controllers/auth_controller.dart';
import '../../shared/localization/app_translations.dart';
import '../../shared/utils/app_navigator.dart';

class ProfileController extends ChangeNotifier {
  static ProfileController? _instance;
  static ProfileController get to => _instance ??= ProfileController();

  bool isLoading = false;
  bool isSaving = false;

  // Current profile data
  String name = '';
  String email = '';
  String phone = '';

  // Text Controllers (for editing)
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final currentPassCtrl = TextEditingController();
  final newPassCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();

  // Password visibility toggles
  bool obscureCurrent = true;
  bool obscureNew = true;
  bool obscureConfirm = true;

  void toggleCurrent() {
    obscureCurrent = !obscureCurrent;
    notifyListeners();
  }

  void toggleNew() {
    obscureNew = !obscureNew;
    notifyListeners();
  }

  void toggleConfirm() {
    obscureConfirm = !obscureConfirm;
    notifyListeners();
  }

  // Vendor-specific
  String vendorName = '';
  String vendorPhone = '';
  String vendorAddress = '';
  String vendorDescription = '';
  String vendorLogoUrl = '';
  String vendorCoverUrl = '';
  String vendorStatus = '';
  bool isVendorOpen = false;
  String openingTime = '';
  String closingTime = '';
  String estDeliveryTime = '';

  final vendorNameCtrl = TextEditingController();
  final vendorPhoneCtrl = TextEditingController();
  final vendorAddressCtrl = TextEditingController();
  final vendorDescCtrl = TextEditingController();
  final openingTimeCtrl = TextEditingController();
  final closingTimeCtrl = TextEditingController();
  final estDeliveryTimeCtrl = TextEditingController();

  bool isUploadingLogo = false;
  bool isUploadingCover = false;

  ProfileController() {
    _instance = this;
    fetchProfile();
  }

  @override
  void dispose() {
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
    super.dispose();
  }

  Future<void> fetchProfile() async {
    isLoading = true;
    notifyListeners();
    try {
      final res = await ApiProvider.get(ApiEndpoints.profileGet);
      if (res.success && res.data != null) {
        final d = res.data as Map<String, dynamic>;
        name = d['name'] ?? '';
        email = d['email'] ?? '';
        phone = d['phone'] ?? '';
        nameCtrl.text = name;
        phoneCtrl.text = phone;

        // Vendor-specific
        if (d['vendor'] != null) {
          final v = d['vendor'] as Map<String, dynamic>;
          vendorName = v['name'] ?? '';
          vendorPhone = v['phone'] ?? '';
          vendorAddress = v['address'] ?? '';
          vendorDescription = v['description'] ?? '';
          vendorLogoUrl = v['logo_url'] ?? '';
          vendorCoverUrl = v['cover_url'] ?? '';
          vendorStatus = v['status'] ?? 'pending';
          isVendorOpen = (v['is_currently_open'] ?? v['is_open'] ?? 0) == 1;
          openingTime = v['opening_time'] ?? '';
          closingTime = v['closing_time'] ?? '';
          estDeliveryTime = v['estimated_delivery_time']?.toString() ?? '';
          vendorNameCtrl.text = vendorName;
          vendorPhoneCtrl.text = vendorPhone;
          vendorAddressCtrl.text = vendorAddress;
          vendorDescCtrl.text = vendorDescription;
          openingTimeCtrl.text = openingTime;
          closingTimeCtrl.text = closingTime;
          estDeliveryTimeCtrl.text = estDeliveryTime;
        }
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile() async {
    isSaving = true;
    notifyListeners();
    try {
      final res = await ApiProvider.post(ApiEndpoints.profileUpdate, body: {
        'name': nameCtrl.text,
        'phone': phoneCtrl.text,
      });
      if (res.success) {
        name = nameCtrl.text;
        phone = phoneCtrl.text;
        notifyListeners();
        return true;
      } else {
        AppNavigator.snackbar(
            'Error'.tr, res.message?.tr ?? 'Update failed'.tr,
            backgroundColor: const Color(0xFFF44336),
            colorText: const Color(0xFFFFFFFF));
        return false;
      }
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<void> changePassword() async {
    if (newPassCtrl.text != confirmPassCtrl.text) {
      AppNavigator.snackbar('Error'.tr, 'Passwords do not match'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
      return;
    }
    isSaving = true;
    notifyListeners();
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
        AppNavigator.snackbar(
          'Password Changed'.tr,
          'Logging out for security. Please login with your new password.'.tr,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF),
          duration: const Duration(seconds: 3),
        );
        Future.delayed(const Duration(seconds: 3), () {
          ApiProvider.clearAuth();
          AppNavigator.offAllNamed(AppRoutes.login);
        });
      } else {
        AppNavigator.snackbar('Error'.tr, res.message?.tr ?? 'Change failed'.tr,
            backgroundColor: const Color(0xFFF44336),
            colorText: const Color(0xFFFFFFFF));
      }
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateVendorProfile() async {
    isSaving = true;
    notifyListeners();
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
        vendorName = vendorNameCtrl.text;
        openingTime = openingTimeCtrl.text;
        closingTime = closingTimeCtrl.text;
        estDeliveryTime = estDeliveryTimeCtrl.text;
        notifyListeners();
        return true;
      } else {
        AppNavigator.snackbar('Error'.tr, res.message?.tr ?? 'Update failed'.tr,
            backgroundColor: const Color(0xFFF44336),
            colorText: const Color(0xFFFFFFFF));
        return false;
      }
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<void> toggleVendorOpen() async {
    if (vendorStatus != 'approved') {
      AppNavigator.snackbar('Not Allowed'.tr,
          'Your store must be approved before you can open it'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
      return;
    }
    final res = await ApiProvider.post(ApiEndpoints.vendorToggleOpen, body: {});
    if (res.success) {
      isVendorOpen = !isVendorOpen;
      notifyListeners();
      AppNavigator.snackbar(
        isVendorOpen ? 'Open'.tr : 'Closed'.tr,
        isVendorOpen
            ? 'Your store is now open'.tr
            : 'Your store is now closed'.tr,
        backgroundColor: isVendorOpen
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

    isUploadingLogo = true;
    notifyListeners();
    try {
      final res = await ApiProvider.uploadMultipart(
        ApiEndpoints.vendorProfileUploadLogo,
        fileField: 'logo',
        filePath: picked.path,
      );
      if (res.success && res.data != null) {
        final d = res.data as Map<String, dynamic>;
        vendorLogoUrl = d['logo_url'] ?? '';
        notifyListeners();
        AppNavigator.snackbar('Uploaded'.tr, 'Logo updated successfully'.tr,
            backgroundColor: const Color(0xFF4CAF50),
            colorText: const Color(0xFFFFFFFF));
      } else {
        AppNavigator.snackbar('Error'.tr, res.message?.tr ?? 'Upload failed'.tr,
            backgroundColor: const Color(0xFFF44336),
            colorText: const Color(0xFFFFFFFF));
      }
    } catch (e) {
      AppNavigator.snackbar('Error'.tr, 'Failed to upload logo'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
    } finally {
      isUploadingLogo = false;
      notifyListeners();
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

    isUploadingCover = true;
    notifyListeners();
    try {
      final res = await ApiProvider.uploadMultipart(
        ApiEndpoints.vendorProfileUploadCover,
        fileField: 'cover',
        filePath: picked.path,
      );
      if (res.success && res.data != null) {
        final d = res.data as Map<String, dynamic>;
        vendorCoverUrl = d['cover_url'] ?? '';
        notifyListeners();
        AppNavigator.snackbar('Uploaded'.tr, 'Cover image updated'.tr,
            backgroundColor: const Color(0xFF4CAF50),
            colorText: const Color(0xFFFFFFFF));
      } else {
        AppNavigator.snackbar('Error'.tr, res.message?.tr ?? 'Upload failed'.tr,
            backgroundColor: const Color(0xFFF44336),
            colorText: const Color(0xFFFFFFFF));
      }
    } catch (e) {
      AppNavigator.snackbar('Error'.tr, 'Failed to upload cover'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
    } finally {
      isUploadingCover = false;
      notifyListeners();
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
        openingTime = formatted;
      } else {
        closingTimeCtrl.text = formatted;
        closingTime = formatted;
      }
      notifyListeners();
    }
  }

  void logout() {
    AppNavigator.dialog(AlertDialog(
      backgroundColor: const Color(0xFF2C2C2C),
      title: Text('Logout'.tr, style: const TextStyle(color: Colors.white)),
      content: Text('Are you sure you want to logout?'.tr,
          style: const TextStyle(color: Color(0xFF9E9E9E))),
      actions: [
        TextButton(onPressed: () => AppNavigator.back(), child: Text('Cancel'.tr)),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF44336)),
          onPressed: () {
            AppNavigator.back();
            AuthController.to.logout();
          },
          child: Text('Logout'.tr),
        ),
      ],
    ));
  }

  void navigateToCorrectDashboard() {
    final role = ApiProvider.storedRole;
    if (role == 'vendor') {
      AppNavigator.offAllNamed(AppRoutes.vendorDashboard);
    } else if (role == 'admin') {
      AppNavigator.offAllNamed(AppRoutes.adminDashboard);
    } else {
      AppNavigator.offAllNamed(AppRoutes.saDashboard);
    }
  }
}

final profileProvider =
    ChangeNotifierProvider<ProfileController>((ref) => ProfileController.to);
