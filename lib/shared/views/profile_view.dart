import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/routes/app_routes.dart';
import '../../shared/localization/app_translations.dart';
import '../../shared/utils/app_navigator.dart';
import '../controllers/profile_controller.dart';
import '../widgets/app_drawer.dart';
import '../controllers/language_controller.dart';

/// Shared profile screen used by all three roles.
/// For vendors: shows cover/logo in the app bar, consolidated save button,
/// operating hours, and open/close toggle.
class ProfileView extends ConsumerWidget {
  final String currentRoute;
  final bool isVendor;
  final String title;

  const ProfileView({
    super.key,
    required this.currentRoute,
    this.isVendor = false,
    this.title = 'Profile',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.watch(profileProvider);
    final langCtrl = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      drawer: AppDrawer(currentRoute: currentRoute),
      body: ctrl.isLoading
          ? CustomScrollView(
              slivers: [
                _buildAppBar(ctrl),
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryOrange,
                    ),
                  ),
                ),
              ],
            )
          : RefreshIndicator(
              color: AppColors.primaryOrange,
              onRefresh: ctrl.fetchProfile,
              child: CustomScrollView(
                slivers: [
                  _buildAppBar(ctrl),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Vendor open/close toggle ──
                          if (isVendor) ...[
                            _card(
                              child: Row(
                                children: [
                                  Icon(
                                    ctrl.isVendorOpen
                                        ? Icons.store
                                        : Icons.store_mall_directory,
                                    color: ctrl.isVendorOpen
                                        ? AppColors.success
                                        : AppColors.error,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ctrl.isVendorOpen
                                              ? 'Store is Open'.tr
                                              : 'Store is Closed'.tr,
                                          style: TextStyle(
                                            color: ctrl.isVendorOpen
                                                ? AppColors.success
                                                : AppColors.error,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          ctrl.vendorStatus == 'approved'
                                              ? 'Tap to toggle store status'.tr
                                              : 'Store must be approved first'.tr,
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: ctrl.isVendorOpen,
                                    onChanged: (_) => ctrl.toggleVendorOpen(),
                                    activeThumbColor: AppColors.success,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // ── System Settings ──
                          _sectionTitle('System Settings'.tr),
                          const SizedBox(height: 10),
                          _card(
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Language'.tr,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                                DropdownButton<String>(
                                  value: langCtrl.currentLanguage,
                                  dropdownColor: AppColors.cardDark,
                                  style: const TextStyle(
                                    color: AppColors.primaryOrange,
                                  ),
                                  underline: const SizedBox(),
                                  items: [
                                    DropdownMenuItem(
                                      value: 'en',
                                      child: Text('English'.tr),
                                    ),
                                    DropdownMenuItem(
                                      value: 'ar',
                                      child: Text('Arabic'.tr),
                                    ),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) {
                                      langCtrl.changeLanguage(val);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // ── Personal Info ──
                          _sectionTitle('Personal Information'.tr),
                          const SizedBox(height: 10),
                          _card(
                            child: Column(
                              children: [
                                _tf(ctrl.nameCtrl, 'Full Name'.tr,
                                    Icons.person),
                                const SizedBox(height: 12),
                                _tf(ctrl.phoneCtrl, 'Phone'.tr, Icons.phone,
                                    type: TextInputType.phone),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // ── Vendor business profile ──
                          if (isVendor) ...[
                            _sectionTitle('Business Profile'.tr),
                            const SizedBox(height: 10),
                            _card(
                              child: Column(
                                children: [
                                  _tf(ctrl.vendorNameCtrl,
                                      'Business Name'.tr, Icons.business),
                                  const SizedBox(height: 12),
                                  _tf(ctrl.vendorPhoneCtrl,
                                      'Business Phone'.tr, Icons.phone,
                                      type: TextInputType.phone),
                                  const SizedBox(height: 12),
                                  _tf(ctrl.vendorAddressCtrl, 'Address'.tr,
                                      Icons.location_on),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: ctrl.vendorDescCtrl,
                                    maxLines: 3,
                                    style: const TextStyle(
                                        color: Colors.white),
                                    decoration: InputDecoration(
                                      labelText: 'Description'.tr,
                                      labelStyle: const TextStyle(
                                          color: AppColors.textSecondary),
                                      floatingLabelStyle: const TextStyle(
                                          color: AppColors.primaryOrange,
                                          fontSize: 14),
                                      alignLabelWithHint: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // ── Operating Hours ──
                            _sectionTitle('Operating Hours'.tr),
                            const SizedBox(height: 10),
                            _card(
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () => ctrl.pickTime(
                                            context,
                                            isOpening: true,
                                          ),
                                          child: AbsorbPointer(
                                            child: TextField(
                                              controller:
                                                  ctrl.openingTimeCtrl,
                                              style: const TextStyle(
                                                  color: Colors.white),
                                              decoration: InputDecoration(
                                                labelText: 'Opening Time'.tr,
                                                labelStyle: const TextStyle(
                                                  color: AppColors
                                                      .textSecondary,
                                                ),
                                                floatingLabelStyle:
                                                    const TextStyle(
                                                  color: AppColors
                                                      .primaryOrange,
                                                  fontSize: 14,
                                                ),
                                                prefixIcon: const Icon(
                                                    Icons.access_time),
                                                suffixIcon: const Icon(
                                                    Icons.edit,
                                                    size: 16),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () => ctrl.pickTime(
                                            context,
                                            isOpening: false,
                                          ),
                                          child: AbsorbPointer(
                                            child: TextField(
                                              controller:
                                                  ctrl.closingTimeCtrl,
                                              style: const TextStyle(
                                                  color: Colors.white),
                                              decoration: InputDecoration(
                                                labelText: 'Closing Time'.tr,
                                                labelStyle: const TextStyle(
                                                  color: AppColors
                                                      .textSecondary,
                                                ),
                                                floatingLabelStyle:
                                                    const TextStyle(
                                                  color: AppColors
                                                      .primaryOrange,
                                                  fontSize: 14,
                                                ),
                                                prefixIcon: const Icon(Icons
                                                    .access_time_filled),
                                                suffixIcon: const Icon(
                                                    Icons.edit,
                                                    size: 16),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // ── Estimated Delivery Time ──
                            _sectionTitle('Estimated Delivery Time'.tr),
                            const SizedBox(height: 10),
                            _card(
                              child: TextField(
                                controller: ctrl.estDeliveryTimeCtrl,
                                style:
                                    const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Est. Delivery Time'.tr,
                                  labelStyle: const TextStyle(
                                      color: AppColors.textSecondary),
                                  floatingLabelStyle: const TextStyle(
                                      color: AppColors.primaryOrange,
                                      fontSize: 14),
                                  prefixIcon:
                                      const Icon(Icons.delivery_dining),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // ── Single Save Button ──
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: ctrl.isSaving
                                  ? null
                                  : () => _saveAll(ctrl),
                              icon: ctrl.isSaving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.save_outlined),
                              label: Text(ctrl.isSaving
                                  ? 'Saving...'.tr
                                  : 'Save All Changes'.tr),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // ── Change Password ──
                          _sectionTitle('Change Password'.tr),
                          const SizedBox(height: 10),
                          _card(
                            child: Column(
                              children: [
                                TextField(
                                  controller: ctrl.currentPassCtrl,
                                  obscureText: ctrl.obscureCurrent,
                                  style:
                                      const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: 'Current Password'.tr,
                                    prefixIcon: const Icon(Icons.lock),
                                    suffixIcon: IconButton(
                                      icon: Icon(ctrl.obscureCurrent
                                          ? Icons.visibility_off
                                          : Icons.visibility),
                                      onPressed: ctrl.toggleCurrent,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: ctrl.newPassCtrl,
                                  obscureText: ctrl.obscureNew,
                                  style:
                                      const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: 'New Password'.tr,
                                    prefixIcon:
                                        const Icon(Icons.lock_open),
                                    suffixIcon: IconButton(
                                      icon: Icon(ctrl.obscureNew
                                          ? Icons.visibility_off
                                          : Icons.visibility),
                                      onPressed: ctrl.toggleNew,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: ctrl.confirmPassCtrl,
                                  obscureText: ctrl.obscureConfirm,
                                  style:
                                      const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: 'Confirm New Password'.tr,
                                    prefixIcon:
                                        const Icon(Icons.lock_reset),
                                    suffixIcon: IconButton(
                                      icon: Icon(ctrl.obscureConfirm
                                          ? Icons.visibility_off
                                          : Icons.visibility),
                                      onPressed: ctrl.toggleConfirm,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: ctrl.changePassword,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.primaryOrange,
                                      side: const BorderSide(
                                          color: AppColors.primaryOrange),
                                    ),
                                    child: Text('Change Password'.tr),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // ── Logout ──
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: ctrl.logout,
                              icon: const Icon(Icons.logout,
                                  color: AppColors.error),
                              label: Text('Logout'.tr,
                                  style: const TextStyle(
                                      color: AppColors.error)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: AppColors.error),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  /// Builds the SliverAppBar — for vendors, shows cover image + logo
  SliverAppBar _buildAppBar(ProfileController ctrl) {
    if (!isVendor) {
      // Non-vendor: simple AppBar with letter avatar
      return SliverAppBar(
        expandedHeight: 180,
        pinned: true,
        backgroundColor: AppColors.charcoalBlack,
        flexibleSpace: FlexibleSpaceBar(
          background: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.charcoalBlack, Color(0xFF2C2C2C)],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryOrange,
                        AppColors.darkOrange
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      ctrl.name.isNotEmpty
                          ? ctrl.name[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(ctrl.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600)),
                Text(ctrl.email,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
        ),
      );
    }

    // Vendor: cover image background + logo + status
    final cover = ctrl.vendorCoverUrl;
    final logo = ctrl.vendorLogoUrl;
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      backgroundColor: AppColors.charcoalBlack,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Cover image
            if (cover.isNotEmpty)
              Image.network(
                cover,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _vendorGradientBg(),
              )
            else
              _vendorGradientBg(),
            // Dark overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.75),
                  ],
                ),
              ),
            ),
            // Logo + Name + Status
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  // Logo
                  GestureDetector(
                    onTap: ctrl.uploadLogo,
                    child: Stack(
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.4),
                                width: 2),
                            color: AppColors.cardDark,
                          ),
                          child: logo.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(logo,
                                      fit: BoxFit.cover,
                                      width: 68,
                                      height: 68,
                                      errorBuilder: (_, __, ___) =>
                                          _logoLetter(ctrl)))
                              : _logoLetter(ctrl),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.primaryOrange,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.scaffoldDark,
                                  width: 2),
                            ),
                            child: ctrl.isUploadingLogo
                                ? const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white))
                                : const Icon(Icons.camera_alt,
                                    size: 12, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Name + email + status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          ctrl.vendorName.isNotEmpty
                              ? ctrl.vendorName
                              : ctrl.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                    color: Colors.black54,
                                    blurRadius: 6)
                              ]),
                        ),
                        const SizedBox(height: 2),
                        Text(ctrl.email,
                            style: TextStyle(
                                color:
                                    Colors.white.withValues(alpha: 0.7),
                                fontSize: 12)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _statusChip(ctrl.vendorStatus),
                            const SizedBox(width: 6),
                            _statusChip(
                              ctrl.isVendorOpen
                                  ? 'open'
                                  : 'closed',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Cover upload button
            Positioned(
              top: 80,
              right: 16,
              child: GestureDetector(
                onTap: ctrl.uploadCover,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: ctrl.isUploadingCover
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.camera_alt,
                                size: 14, color: Colors.white70),
                            const SizedBox(width: 4),
                            Text('Cover'.tr,
                                style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11)),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _vendorGradientBg() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2C2C2C), Color(0xFF1A1A1A), Color(0xFF3D2C1E)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _logoLetter(ProfileController ctrl) {
    return Center(
      child: Text(
        ctrl.vendorName.isNotEmpty
            ? ctrl.vendorName[0].toUpperCase()
            : 'V',
        style: const TextStyle(
            fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color;
    String label;
    switch (status) {
      case 'approved':
        color = AppColors.success;
        label = 'Approved'.tr;
        break;
      case 'suspended':
        color = AppColors.error;
        label = 'Suspended'.tr;
        break;
      case 'pending':
        color = AppColors.warning;
        label = 'Pending'.tr;
        break;
      case 'open':
        color = AppColors.success;
        label = 'Open'.tr;
        break;
      case 'closed':
        color = AppColors.error;
        label = 'Closed'.tr;
        break;
      default:
        color = AppColors.textSecondary;
        label = status.isNotEmpty
            ? status[0].toUpperCase() + status.substring(1)
            : 'Unknown';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }

  /// Saves both personal info and vendor business profile in one call
  Future<void> _saveAll(ProfileController ctrl) async {
    final profileOk = await ctrl.updateProfile();
    bool vendorOk = true;
    if (isVendor) {
      vendorOk = await ctrl.updateVendorProfile();
    }
    if (profileOk && vendorOk) {
      AppNavigator.snackbar('Saved'.tr, 'All changes saved successfully'.tr,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF));
    }
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.3)),
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600));
  }

  Widget _tf(TextEditingController ctrl, String hint, IconData icon,
      {TextInputType type = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        floatingLabelStyle:
            const TextStyle(color: AppColors.primaryOrange, fontSize: 14),
        prefixIcon: Icon(icon),
      ),
    );
  }
}

// ── Role-specific thin-wrapper views ──

class SaProfileView extends StatelessWidget {
  const SaProfileView({super.key});
  @override
  Widget build(BuildContext context) {
    return const ProfileView(
      currentRoute: AppRoutes.saProfile,
      title: 'My Profile',
    );
  }
}

class AdminProfileView extends StatelessWidget {
  const AdminProfileView({super.key});
  @override
  Widget build(BuildContext context) {
    return const ProfileView(
      currentRoute: AppRoutes.adminProfile,
      title: 'My Profile',
    );
  }
}

class VendorProfileView extends StatelessWidget {
  const VendorProfileView({super.key});
  @override
  Widget build(BuildContext context) {
    return ProfileView(
      currentRoute: AppRoutes.vendorProfile,
      isVendor: true,
      title: 'Business Profile'.tr,
    );
  }
}
