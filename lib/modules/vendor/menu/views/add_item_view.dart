import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../shared/widgets/app_network_image.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../data/providers/api_provider.dart';
import '../../../../app/constants/api_endpoints.dart';
import '../../../../shared/localization/app_translations.dart';
import '../../../../shared/utils/app_navigator.dart';

class AddItemView extends StatefulWidget {
  const AddItemView({super.key});

  @override
  State<AddItemView> createState() => _AddItemViewState();
}

class _AddItemViewState extends State<AddItemView> {
  bool _isSaving = false;

  // Form fields
  late final TextEditingController _nameCtrl;
  late final TextEditingController _nameArCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _descArCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _discountPriceCtrl;
  late final TextEditingController _prepTimeCtrl;

  String? _selectedCategoryId;
  List<Map<String, dynamic>> _categories = [];
  bool _isAvailable = true;

  // Image — XFile is web-compatible
  XFile? _selectedImage;
  String? _existingImageUrl;

  // Edit mode
  bool get _isEditMode => _editItemId != null;
  String? _editItemId;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _nameArCtrl = TextEditingController();
    _descCtrl = TextEditingController();
    _descArCtrl = TextEditingController();
    _priceCtrl = TextEditingController();
    _discountPriceCtrl = TextEditingController();
    _prepTimeCtrl = TextEditingController();

    _loadCategories();

    // Check if editing
    final args = AppNavigator.arguments;
    if (args is Map<String, dynamic> && args['id'] != null) {
      _editItemId = args['id'].toString();
      _nameCtrl.text = args['name'] ?? '';
      _nameArCtrl.text = args['name_ar'] ?? '';
      _descCtrl.text = args['description'] ?? '';
      _descArCtrl.text = args['description_ar'] ?? '';
      _priceCtrl.text = args['base_price']?.toString() ?? '';
      _discountPriceCtrl.text = args['discount_price']?.toString() ?? '';
      _prepTimeCtrl.text = args['preparation_time']?.toString() ?? '';
      _selectedCategoryId = args['category_id']?.toString();
      _isAvailable = (args['is_available'] ?? 1) == 1;
      final imgUrl = args['image_url'] as String?;
      if (imgUrl != null && imgUrl.isNotEmpty) {
        _existingImageUrl = imgUrl;
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nameArCtrl.dispose();
    _descCtrl.dispose();
    _descArCtrl.dispose();
    _priceCtrl.dispose();
    _discountPriceCtrl.dispose();
    _prepTimeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final res = await ApiProvider.get(ApiEndpoints.vendorCategoriesGetAll);
    if (!mounted) return;
    if (res.success && res.data != null) {
      final d = res.data;
      if (d is Map<String, dynamic>) {
        setState(() {
          _categories =
              List<Map<String, dynamic>>.from(d['categories'] as List? ?? []);
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedImage = picked;
        _existingImageUrl = null;
      });
    }
  }

  Future<void> _save() async {
    if (_nameCtrl.text.isEmpty) {
      AppNavigator.snackbar('Validation'.tr, 'Item name is required'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
      return;
    }
    if (_nameArCtrl.text.isEmpty) {
      AppNavigator.snackbar('Validation'.tr, 'Arabic item name is required'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
      return;
    }
    if (_priceCtrl.text.isEmpty) {
      AppNavigator.snackbar('Validation'.tr, 'Price is required'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
      return;
    }
    if (_selectedCategoryId == null) {
      AppNavigator.snackbar('Validation'.tr, 'Please select a category'.tr,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
      return;
    }

    setState(() => _isSaving = true);
    try {
      ApiResponse res;

      final body = <String, String>{
        'name': _nameCtrl.text,
        'name_ar': _nameArCtrl.text,
        'description': _descCtrl.text,
        'description_ar': _descArCtrl.text,
        'price': _priceCtrl.text,
        'category_id': _selectedCategoryId!,
        if (_discountPriceCtrl.text.isNotEmpty)
          'discount_price': _discountPriceCtrl.text,
        if (_prepTimeCtrl.text.isNotEmpty)
          'preparation_time': _prepTimeCtrl.text,
      };

      if (_isEditMode) {
        body['item_id'] = _editItemId!;
        res = await ApiProvider.post(ApiEndpoints.vendorItemsUpdate, body: body);
      } else {
        body['is_available'] = _isAvailable ? '1' : '0';
        res = await ApiProvider.post(ApiEndpoints.vendorItemsAdd, body: body);
      }

      if (kDebugMode) debugPrint('[AddItem] save response: success=${res.success}, data=${res.data}');

      if (res.success) {
        // Upload image if a new one was selected
        if (_selectedImage != null) {
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

          if (kDebugMode) debugPrint('[AddItem] uploading image for itemId=$itemId, file=${_selectedImage!.path}');

          if (itemId != null) {
            final imgFile = _selectedImage!;
            final bytes = await imgFile.readAsBytes();
            final filename = imgFile.name.isNotEmpty ? imgFile.name : 'item_image.jpg';
            final uploadRes = await ApiProvider.uploadMultipartBytes(
              ApiEndpoints.vendorItemsUploadImage,
              fields: {'item_id': itemId},
              fileField: 'image',
              bytes: bytes,
              filename: filename,
            );
            if (kDebugMode) debugPrint('[AddItem] upload response: success=${uploadRes.success}, message=${uploadRes.message}, data=${uploadRes.data}');
          } else {
            if (kDebugMode) debugPrint('[AddItem] ERROR: could not extract item_id from response');
          }
        }

        AppNavigator.back(result: true);
        AppNavigator.snackbar(
          _isEditMode ? 'Updated'.tr : 'Added'.tr,
          _isEditMode ? 'Menu item updated'.tr : 'Menu item created'.tr,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF),
        );
      } else {
        AppNavigator.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
            backgroundColor: const Color(0xFFF44336),
            colorText: const Color(0xFFFFFFFF));
      }
    } catch (e, st) {
      if (kDebugMode) debugPrint('[AddItem] Error: $e\n$st');
      AppNavigator.snackbar('Error'.tr, 'Something went wrong: '.tr + '$e',
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Menu Item'.tr : 'Add Menu Item'.tr),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => AppNavigator.back(),
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: AppColors.primaryOrange, strokeWidth: 2)),
            )
          else
            TextButton(
              onPressed: _save,
              child: Text('Save'.tr,
                  style: const TextStyle(
                      color: AppColors.primaryOrange,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image picker ──
            GestureDetector(
              onTap: _pickImage,
              child: Builder(builder: (context) {
                final hasNewImage = _selectedImage != null;
                final hasExistingImage = _existingImageUrl != null;

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
                          kIsWeb
                              ? Image.network(_selectedImage!.path,
                                  fit: BoxFit.cover)
                              : Image.file(File(_selectedImage!.path),
                                  fit: BoxFit.cover)
                        else if (hasExistingImage)
                          AppNetworkImage(
                            imageUrl: _existingImageUrl!,
                            fit: BoxFit.cover,
                            placeholder: () => const Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.primaryOrange,
                                  strokeWidth: 2),
                            ),
                            errorWidget: () => _imagePlaceholder(),
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
                                setState(() {
                                  _selectedImage = null;
                                  _existingImageUrl = null;
                                });
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
              controller: _nameCtrl,
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
              controller: _nameArCtrl,
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
              controller: _descCtrl,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Describe the item ingredients...'.tr,
              ),
            ),
            const SizedBox(height: 16),

            _label('Description (Arabic)'.tr),
            TextField(
              controller: _descArCtrl,
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
                        controller: _priceCtrl,
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
                        controller: _discountPriceCtrl,
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
            Container(
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
                  value: _selectedCategoryId,
                  hint: Text('Select category *'.tr,
                      style: const TextStyle(color: AppColors.textSecondary)),
                  items: _categories
                      .map((c) => DropdownMenuItem(
                            value: c['id']?.toString(),
                            child: Text(c['name'] ?? '',
                                style:
                                    const TextStyle(color: Colors.white)),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCategoryId = v),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Preparation Time ──
            _label('Preparation Time (minutes)'.tr),
            TextField(
              controller: _prepTimeCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'e.g. 15'.tr,
                prefixIcon: const Icon(Icons.timer),
              ),
            ),
            const SizedBox(height: 16),

            // ── Availability toggle ──
            Container(
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
                    _isAvailable
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: _isAvailable
                        ? AppColors.success
                        : AppColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _isAvailable
                          ? 'Available to order'.tr
                          : 'Not available'.tr,
                      style: TextStyle(
                        color: _isAvailable
                            ? AppColors.success
                            : AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Switch(
                    value: _isAvailable,
                    onChanged: (v) => setState(() => _isAvailable = v),
                    activeThumbColor: AppColors.success,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Submit ──
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: Icon(_isEditMode
                    ? Icons.save_outlined
                    : Icons.add_circle_outline),
                label: Text(_isSaving
                    ? 'Saving...'.tr
                    : _isEditMode
                        ? 'Save Changes'.tr
                        : 'Add to Menu'.tr),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
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
