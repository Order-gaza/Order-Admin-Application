import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/services/secure_storage_service.dart';
import '../../shared/localization/app_translations.dart';
import '../../app/constants/app_constants.dart';

class LanguageController extends ChangeNotifier {
  static LanguageController? _instance;
  static LanguageController get to => _instance ??= LanguageController();

  static const String _baseLanguageKey = 'language_code';

  String _currentLanguage = 'ar';
  String get currentLanguage => _currentLanguage;
  bool get isArabic => _currentLanguage == 'ar';

  String get _currentLanguageKey {
    final userId =
        SecureStorageService.instance.read(AppConstants.storageUserId);
    if (userId != null && userId.trim().isNotEmpty) {
      return '${_baseLanguageKey}_$userId';
    }
    return _baseLanguageKey;
  }

  LanguageController() {
    _instance = this;
    _loadSavedLanguage();
  }

  Future<void> reloadLanguage() async {
    await _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_currentLanguageKey);
    if (savedCode != null) {
      _currentLanguage = savedCode;
    } else {
      _currentLanguage = 'ar';
    }
    AppTranslations.currentLocaleCode = _currentLanguage;
    notifyListeners();
  }

  Future<void> changeLanguage(String languageCode) async {
    if (_currentLanguage == languageCode) return;

    _currentLanguage = languageCode;
    AppTranslations.currentLocaleCode = languageCode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentLanguageKey, languageCode);
  }
}

final languageProvider =
    ChangeNotifierProvider<LanguageController>((ref) => LanguageController.to);

