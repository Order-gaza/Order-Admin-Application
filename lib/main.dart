import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';
import 'shared/localization/app_translations.dart';
import 'shared/controllers/language_controller.dart';
import 'shared/services/fcm_service.dart';
import 'shared/services/secure_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await SecureStorageService.instance.init();

  // Initialize Firebase
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  Get.put(LanguageController());

  // Initialize FCM service
  final fcmService = FcmService();
  Get.put(fcmService, permanent: true);
  await fcmService.init();

  runApp(const OrderAdminApp());
}

class OrderAdminApp extends StatelessWidget {
  const OrderAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageController = LanguageController.to;

    return GetMaterialApp(
      title: 'Order Delivery Admin',
      debugShowCheckedModeBanner: false,

      // Localization
      translations: AppTranslations(),
      locale: Locale(languageController.currentLanguage.value),
      fallbackLocale: const Locale('en'),

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,

      // Routes
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,

      // Default transition
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
    );
  }
}

