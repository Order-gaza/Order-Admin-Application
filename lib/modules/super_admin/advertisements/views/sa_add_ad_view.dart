import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../app/theme/app_colors.dart';
import '../controllers/sa_ads_controller.dart';

class SaAddAdView extends StatelessWidget {
  const SaAddAdView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(SaAddAdController());
    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        title: Text(ctrl.isEditMode ? 'Edit Advertisement'.tr : 'New Advertisement'.tr),
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
                  child: Text('Save'.tr,
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
            // ── Image picker ──
            GestureDetector(
              onTap: ctrl.pickImage,
              child: Obx(() {
                final hasNewImage = ctrl.selectedImage.value != null;
                final hasExistingImage = ctrl.existingImageUrl.value != null;

                return Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.primaryOrange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (hasNewImage)
                          Image.file(ctrl.selectedImage.value!,
                              fit: BoxFit.cover)
                        else if (hasExistingImage)
                          CachedNetworkImage(
                            imageUrl: ctrl.existingImageUrl.value!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => const Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.primaryOrange,
                                  strokeWidth: 2),
                            ),
                            errorWidget: (_, __, ___) =>
                                _imagePlaceholder(),
                          )
                        else
                          _imagePlaceholder(),

                        // Remove button
                        if (hasNewImage || hasExistingImage)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () {
                                ctrl.selectedImage.value = null;
                                ctrl.existingImageUrl.value = null;
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close,
                                    color: Colors.white, size: 18),
                              ),
                            ),
                          ),

                        // Change overlay
                        if (hasNewImage || hasExistingImage)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 6),
                              color: Colors.black45,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.camera_alt,
                                      color: Colors.white70, size: 14),
                                  const SizedBox(width: 4),
                                  Text('Tap to change'.tr,
                                      style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 11)),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // ── Title ──
            _label('Ad Title *'.tr),
            TextField(
              controller: ctrl.titleCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'e.g. Summer Sale 50% Off'.tr,
                prefixIcon: const Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 16),

            // ── Description ──
            _label('Description'.tr),
            TextField(
              controller: ctrl.descCtrl,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Advertisement details...'.tr,
              ),
            ),
            const SizedBox(height: 16),

            // ── Target URL ──
            _label('Target URL'.tr),
            TextField(
              controller: ctrl.urlCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'https://...',
                prefixIcon: Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 24),

            // ── Vendor selector ──
            _label('Link to Vendor'.tr),
            _buildVendorSelector(ctrl),
            const SizedBox(height: 24),

            // ── Date pickers ──
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Start Date *'.tr),
                      Obx(() => _dateTile(
                            context,
                            date: ctrl.startDate.value,
                            onTap: () async {
                              final d = await showDatePicker(
                                context: context,
                                initialDate: ctrl.startDate.value,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (d != null) ctrl.startDate.value = d;
                            },
                          )),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('End Date *'.tr),
                      Obx(() => _dateTile(
                            context,
                            date: ctrl.endDate.value,
                            onTap: () async {
                              final d = await showDatePicker(
                                context: context,
                                initialDate: ctrl.endDate.value,
                                firstDate: ctrl.startDate.value,
                                lastDate: DateTime(2030),
                              );
                              if (d != null) ctrl.endDate.value = d;
                            },
                          )),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Sort order ──
            _label('Sort Order'.tr),
            TextField(
              controller: ctrl.sortOrderCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: '0',
                prefixIcon: Icon(Icons.sort),
              ),
            ),
            const SizedBox(height: 32),

            // ── Submit ──
            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton.icon(
                    onPressed: ctrl.isSaving.value ? null : ctrl.save,
                    icon: Icon(ctrl.isEditMode
                        ? Icons.save_outlined
                        : Icons.add_circle_outline),
                    label: Text(ctrl.isSaving.value
                        ? 'Saving...'.tr
                        : ctrl.isEditMode
                            ? 'Save Changes'.tr
                            : 'Create Advertisement'.tr),
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

  /// Vendor selection area: shows currently selected vendor or a "Select" button.
  /// Tapping opens a bottom sheet with searchable vendor cards.
  Widget _buildVendorSelector(SaAddAdController ctrl) {
    return Obx(() {
      if (ctrl.isLoadingVendors.value) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.primaryOrange)),
              const SizedBox(width: 12),
              Text('Loading vendors...'.tr,
                  style: const TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        );
      }

      final selectedVendor = ctrl.selectedVendorId.value != null
          ? ctrl.vendors.firstWhereOrNull(
              (v) => v['id']?.toString() == ctrl.selectedVendorId.value)
          : null;

      return GestureDetector(
        onTap: () => _showVendorPicker(ctrl),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selectedVendor != null
                  ? AppColors.goldenYellow.withValues(alpha: 0.4)
                  : AppColors.divider.withValues(alpha: 0.3),
            ),
          ),
          child: selectedVendor != null
              ? Row(
                  children: [
                    // Vendor logo
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: selectedVendor['logo_url'] != null &&
                              selectedVendor['logo_url'].toString().isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                selectedVendor['logo_url'],
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                    Icons.store,
                                    color: AppColors.primaryOrange,
                                    size: 20),
                              ),
                            )
                          : const Icon(Icons.store,
                              color: AppColors.primaryOrange, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedVendor['vendor_name'] ??
                                selectedVendor['name'] ??
                                '',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            selectedVendor['owner_email'] ?? '',
                            style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    // Clear button
                    GestureDetector(
                      onTap: () => ctrl.selectedVendorId.value = null,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            size: 16, color: AppColors.error),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right,
                        color: AppColors.textSecondary),
                  ],
                )
              : Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.darkSurface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.store_mall_directory,
                          color: AppColors.textSecondary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tap to select a vendor (optional)'.tr,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ),
                    const Icon(Icons.chevron_right,
                        color: AppColors.textSecondary),
                  ],
                ),
        ),
      );
    });
  }

  /// Bottom sheet showing searchable vendor cards
  void _showVendorPicker(SaAddAdController ctrl) {
    final searchCtrl = TextEditingController();
    final filteredVendors = <Map<String, dynamic>>[].obs;
    filteredVendors.value = List.from(ctrl.vendors);

    void filter(String q) {
      if (q.isEmpty) {
        filteredVendors.value = List.from(ctrl.vendors);
      } else {
        final lq = q.toLowerCase();
        filteredVendors.value = ctrl.vendors.where((v) {
          final name =
              (v['vendor_name'] ?? v['name'] ?? '').toString().toLowerCase();
          final email = (v['owner_email'] ?? '').toString().toLowerCase();
          final id = (v['id'] ?? '').toString().toLowerCase();
          return name.contains(lq) || email.contains(lq) || id.contains(lq);
        }).toList();
      }
    }

    Get.bottomSheet(
      Container(
        height: Get.height * 0.75,
        decoration: const BoxDecoration(
          color: AppColors.scaffoldDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Select Vendor'.tr,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: searchCtrl,
                onChanged: filter,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search by name, email, or ID...'.tr,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      searchCtrl.clear();
                      filter('');
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Vendor cards
            Expanded(
              child: Obx(() {
                if (filteredVendors.isEmpty) {
                  return Center(
                    child: Text('No vendors found'.tr,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4))),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredVendors.length,
                  itemBuilder: (_, i) {
                    final v = filteredVendors[i];
                    final vendorId = v['id']?.toString() ?? '';
                    final isSelected =
                        ctrl.selectedVendorId.value == vendorId;

                    return GestureDetector(
                      onTap: () {
                        ctrl.selectedVendorId.value = vendorId;
                        Get.back();
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryOrange.withValues(alpha: 0.12)
                              : AppColors.cardDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryOrange
                                    .withValues(alpha: 0.5)
                                : AppColors.divider.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Logo
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.primaryOrange
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: v['logo_url'] != null &&
                                      v['logo_url']
                                          .toString()
                                          .isNotEmpty
                                  ? ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      child: Image.network(
                                        v['logo_url'],
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.store,
                                                color: AppColors
                                                    .primaryOrange,
                                                size: 24),
                                      ),
                                    )
                                  : const Icon(Icons.store,
                                      color: AppColors.primaryOrange,
                                      size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    v['vendor_name'] ??
                                        v['name'] ??
                                        '',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14),
                                  ),
                                  const SizedBox(height: 2),
                                  if (v['owner_email'] != null)
                                    Text(
                                      v['owner_email'],
                                      style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 11),
                                    ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'ID: ${_truncateId(vendorId)}',
                                    style: TextStyle(
                                        color: Colors.white
                                            .withValues(alpha: 0.3),
                                        fontSize: 10,
                                        fontFamily: 'monospace'),
                                  ),
                                ],
                              ),
                            ),
                            // Type badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.info.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                v['type'] ?? '',
                                style: const TextStyle(
                                    color: AppColors.info,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            if (isSelected) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.check_circle,
                                  color: AppColors.primaryOrange,
                                  size: 22),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  String _truncateId(String id) {
    if (id.length > 12) return '${id.substring(0, 8)}...';
    return id;
  }

  Widget _dateTile(BuildContext context,
      {required DateTime date, required VoidCallback onTap}) {
    return Material(
      color: AppColors.cardDark,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border:
                Border.all(color: AppColors.divider.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today,
                  size: 16, color: AppColors.primaryOrange),
              const SizedBox(width: 8),
              Text(
                '${date.day}/${date.month}/${date.year}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.add_photo_alternate,
            color: AppColors.primaryOrange, size: 44),
        const SizedBox(height: 8),
        Text('Tap to add banner image'.tr,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 4),
        Text('(Recommended: 1200×400)'.tr,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3), fontSize: 11)),
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
