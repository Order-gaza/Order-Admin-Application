import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../data/providers/api_provider.dart';
import '../../../../app/constants/api_endpoints.dart';

class AddItemController extends GetxController {
  final isSaving = false.obs;

  // Form fields
  final nameCtrl = TextEditingController();
  final nameArCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final descArCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final discountPriceCtrl = TextEditingController();
  final prepTimeCtrl = TextEditingController();
  final selectedCategoryId = Rxn<String>();
  final categories = <Map<String, dynamic>>[].obs;
  final isAvailable = true.obs;

  // Image
  final selectedImage = Rxn<File>();
  final existingImageUrl = Rxn<String>();

  // Edit mode
  bool get isEditMode => _editItemId != null;
  String? _editItemId;

  @override
  void onInit() {
    super.onInit();
    _loadCategories();

    // Check if editing
    final args = Get.arguments;
    if (args is Map<String, dynamic> && args['id'] != null) {
      _editItemId = args['id'].toString();
      nameCtrl.text = args['name'] ?? '';
      nameArCtrl.text = args['name_ar'] ?? '';
      descCtrl.text = args['description'] ?? '';
      descArCtrl.text = args['description_ar'] ?? '';
      priceCtrl.text = args['base_price']?.toString() ?? '';
      discountPriceCtrl.text = args['discount_price']?.toString() ?? '';
      prepTimeCtrl.text = args['preparation_time']?.toString() ?? '';
      selectedCategoryId.value = args['category_id']?.toString();
      isAvailable.value = (args['is_available'] ?? 1) == 1;
      final imgUrl = args['image_url'] as String?;
      if (imgUrl != null && imgUrl.isNotEmpty) {
        existingImageUrl.value = imgUrl;
      }
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    nameArCtrl.dispose();
    descCtrl.dispose();
    descArCtrl.dispose();
    priceCtrl.dispose();
    discountPriceCtrl.dispose();
    prepTimeCtrl.dispose();
    super.onClose();
  }

  Future<void> _loadCategories() async {
    final res = await ApiProvider.get(ApiEndpoints.vendorCategoriesGetAll);
    if (res.success && res.data != null) {
      final d = res.data;
      if (d is Map<String, dynamic>) {
        categories.value =
            List<Map<String, dynamic>>.from(d['categories'] as List? ?? []);
      }
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked != null) {
      selectedImage.value = File(picked.path);
      existingImageUrl.value = null;
    }
  }

  Future<void> save() async {
    if (nameCtrl.text.isEmpty) {
      Get.snackbar('Validation'.tr, 'Item name is required'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
      return;
    }
    if (nameArCtrl.text.isEmpty) {
      Get.snackbar('Validation'.tr, 'Arabic item name is required'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
      return;
    }
    if (priceCtrl.text.isEmpty) {
      Get.snackbar('Validation'.tr, 'Price is required'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
      return;
    }
    if (selectedCategoryId.value == null) {
      Get.snackbar('Validation'.tr, 'Please select a category'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
      return;
    }

    isSaving.value = true;
    try {
      ApiResponse res;

      final body = <String, String>{
        'name': nameCtrl.text,
        'name_ar': nameArCtrl.text,
        'description': descCtrl.text,
        'description_ar': descArCtrl.text,
        'price': priceCtrl.text,
        'category_id': selectedCategoryId.value!,
        if (discountPriceCtrl.text.isNotEmpty)
          'discount_price': discountPriceCtrl.text,
        if (prepTimeCtrl.text.isNotEmpty)
          'preparation_time': prepTimeCtrl.text,
      };

      if (isEditMode) {
        body['item_id'] = _editItemId!;
        res = await ApiProvider.post(ApiEndpoints.vendorItemsUpdate, body: body);
      } else {
        body['is_available'] = isAvailable.value ? '1' : '0';
        res = await ApiProvider.post(ApiEndpoints.vendorItemsAdd, body: body);
      }

      if (kDebugMode) debugPrint('[AddItem] save response: success=${res.success}, data=${res.data}');

      if (res.success) {
        // Upload image if a new one was selected
        if (selectedImage.value != null) {
          String? itemId = _editItemId;

          if (itemId == null && res.data != null) {
            final data = res.data;
            if (data is Map<String, dynamic>) {
              final itemData = data['item'];
              if (itemData is Map<String, dynamic>) {
                itemId = itemData['id']?.toString();
              }
            }
          }

          if (kDebugMode) debugPrint('[AddItem] uploading image for itemId=$itemId, file=${selectedImage.value!.path}');

          if (itemId != null) {
            final uploadRes = await ApiProvider.uploadMultipart(
              ApiEndpoints.vendorItemsUploadImage,
              fields: {'item_id': itemId},
              fileField: 'image',
              filePath: selectedImage.value!.path,
            );
            if (kDebugMode) debugPrint('[AddItem] upload response: success=${uploadRes.success}, message=${uploadRes.message}, data=${uploadRes.data}');
          } else {
            if (kDebugMode) debugPrint('[AddItem] ERROR: could not extract item_id from response');
          }
        }

        Get.back(result: true);
        Get.snackbar(
          isEditMode ? 'Updated'.tr : 'Added'.tr,
          isEditMode ? 'Menu item updated'.tr : 'Menu item created'.tr,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF),
        );
      } else {
        Get.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
            backgroundColor: const Color(0xFFF44336),
            colorText: const Color(0xFFFFFFFF));
      }
    } catch (e, st) {
      if (kDebugMode) debugPrint('[AddItem] Error: $e\n$st');
      Get.snackbar('Error'.tr, 'Something went wrong: '.tr + '$e',
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
    } finally {
      isSaving.value = false;
    }
  }
}

class AddItemView extends StatelessWidget {
  const AddItemView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(AddItemController());
    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        title: Text(ctrl.isEditMode ? 'Edit Menu Item'.tr : 'Add Menu Item'.tr),
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
                  height: 160,
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
                            errorWidget: (_, __, ___) => _imagePlaceholder(),
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
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              color: Colors.black45,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.camera_alt,
                                      color: Colors.white70, size: 14),
                                  const SizedBox(width: 4),
                                  Text('Tap to change'.tr,
                                      style: const TextStyle(
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
            const SizedBox(height: 20),

            // ── Fields ──
            _label('Item Name (English) *'.tr),
            TextField(
              controller: ctrl.nameCtrl,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'e.g. Grilled Chicken Sandwich'.tr,
                prefixIcon: const Icon(Icons.fastfood),
              ),
            ),
            const SizedBox(height: 16),

            _label('Item Name (Arabic) *'.tr),
            TextField(
              controller: ctrl.nameArCtrl,
              style: const TextStyle(color: Colors.white),
              textDirection: TextDirection.rtl,
              decoration: const InputDecoration(
                hintText: 'مثال: ساندويش دجاج مشوي',
                prefixIcon: Icon(Icons.translate),
              ),
            ),
            const SizedBox(height: 16),

            _label('Description (English)'.tr),
            TextField(
              controller: ctrl.descCtrl,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Describe the item ingredients...'.tr,
              ),
            ),
            const SizedBox(height: 16),

            _label('Description (Arabic)'.tr),
            TextField(
              controller: ctrl.descArCtrl,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              textDirection: TextDirection.rtl,
              decoration: const InputDecoration(
                hintText: 'وصف المنتج بالعربي...',
              ),
            ),
            const SizedBox(height: 16),

            // ── Price row ──
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Base Price (₪) *'.tr),
                      TextField(
                        controller: ctrl.priceCtrl,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: '0.00'.tr,
                          prefixIcon: const Icon(Icons.attach_money),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Discount Price (₪)'.tr),
                      TextField(
                        controller: ctrl.discountPriceCtrl,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Optional'.tr,
                          prefixIcon: const Icon(Icons.discount),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Category (required) ──
            _label('Category *'.tr),
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
                      value: ctrl.selectedCategoryId.value,
                      hint: Text('Select category *'.tr,
                          style: const TextStyle(color: AppColors.textSecondary)),
                      items: ctrl.categories
                          .map((c) => DropdownMenuItem(
                                value: c['id']?.toString(),
                                child: Text(c['name'] ?? '',
                                    style:
                                        const TextStyle(color: Colors.white)),
                              ))
                          .toList(),
                      onChanged: (v) => ctrl.selectedCategoryId.value = v,
                    ),
                  ),
                )),
            const SizedBox(height: 16),

            // ── Preparation Time ──
            _label('Preparation Time (minutes)'.tr),
            TextField(
              controller: ctrl.prepTimeCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'e.g. 15'.tr,
                prefixIcon: const Icon(Icons.timer),
              ),
            ),
            const SizedBox(height: 16),

            // ── Availability toggle ──
            Obx(() => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.divider.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        ctrl.isAvailable.value
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: ctrl.isAvailable.value
                            ? AppColors.success
                            : AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          ctrl.isAvailable.value
                              ? 'Available to order'.tr
                              : 'Not available'.tr,
                          style: TextStyle(
                            color: ctrl.isAvailable.value
                                ? AppColors.success
                                : AppColors.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Switch(
                        value: ctrl.isAvailable.value,
                        onChanged: (v) => ctrl.isAvailable.value = v,
                        activeThumbColor: AppColors.success,
                      ),
                    ],
                  ),
                )),
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
                            : 'Add to Menu'.tr),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.add_photo_alternate,
            color: AppColors.primaryOrange, size: 40),
        const SizedBox(height: 8),
        Text('Tap to add photo'.tr,
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 4),
        Text('(Optional)'.tr,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 11)),
      ],
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 13)),
    );
  }
}
