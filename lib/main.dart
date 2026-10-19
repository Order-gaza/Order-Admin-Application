import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';
import 'firebase_options.dart';
import 'shared/controllers/language_controller.dart';
import 'shared/services/fcm_service.dart';
import 'shared/services/secure_storage_service.dart';
import 'shared/utils/app_navigator.dart';

/// Background handler — only registered on supported platforms.
Future<void> firebaseMessagingBackgroundHandler(dynamic message) async {}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await SecureStorageService.instance.init();

  final isDesktop = !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS);

  if (!isDesktop) {
    // Firebase on mobile + web
    try {
      final core = await _initFirebase();
      if (core) {
        final fcmService = FcmService.to;
        await fcmService.init();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[main] Firebase init failed: $e');
    }
  }

  // Initialize LanguageController singleton
  LanguageController.to;

  runApp(const ProviderScope(child: OrderAdminApp()));
}

Future<bool> _initFirebase() async {
  try {
    // Web: use explicit FirebaseOptions; Android/iOS: auto-init from native files
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      await Firebase.initializeApp();
    }
    return true;
  } catch (e) {
    if (kDebugMode) debugPrint('[main] Firebase initializeApp error: $e');
    return false;
  }
}

class OrderAdminApp extends ConsumerWidget {
  const OrderAdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);

    return MaterialApp(
      title: 'Order Delivery Admin',
      debugShowCheckedModeBanner: false,
      navigatorKey: AppNavigator.navigatorKey,
      scaffoldMessengerKey: AppNavigator.messengerKey,

      // Localization
      locale: Locale(language.currentLanguage),

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,

      // Routes
      initialRoute: AppRoutes.splash,
      routes: AppPages.routes,
      onGenerateRoute: AppPages.onGenerateRoute,
    );
  }
}
