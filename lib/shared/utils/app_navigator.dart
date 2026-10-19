import 'dart:async';
import 'package:flutter/material.dart';
import '../localization/app_translations.dart';

// ignore: constant_identifier_names
enum SnackPosition { TOP, BOTTOM }


/// Drop-in navigation and overlay utility replacing GetX navigation.
/// Uses standard Flutter Navigator and Overlay without any external dependencies.
class AppNavigator {
  AppNavigator._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static BuildContext? get context => navigatorKey.currentContext;

  static dynamic _lastArguments;

  /// Returns current route arguments.
  static dynamic get arguments {
    final ctx = navigatorKey.currentContext;
    if (ctx != null) {
      final route = ModalRoute.of(ctx);
      if (route?.settings.arguments != null) {
        return route!.settings.arguments;
      }
    }
    return _lastArguments;
  }

  /// Navigate to named route (like Get.toNamed)
  static Future<T?> toNamed<T extends Object?>(
    String routeName, {
    dynamic arguments,
  }) {
    _lastArguments = arguments;
    return navigatorKey.currentState!.pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  /// Replace current route with named route (like Get.offNamed)
  static Future<T?> offNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    dynamic arguments,
    TO? result,
  }) {
    _lastArguments = arguments;
    return navigatorKey.currentState!.pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  /// Clear stack and push named route (like Get.offAllNamed)
  static Future<T?> offAllNamed<T extends Object?>(
    String routeName, {
    dynamic arguments,
    RoutePredicate? predicate,
  }) {
    _lastArguments = arguments;
    return navigatorKey.currentState!.pushNamedAndRemoveUntil<T>(
      routeName,
      predicate ?? (route) => false,
      arguments: arguments,
    );
  }

  /// Pop current route (like Get.back)
  static void back<T extends Object?>({T? result}) {
    if (navigatorKey.currentState?.canPop() ?? false) {
      navigatorKey.currentState!.pop<T>(result);
    }
  }

  /// Pop until predicate is satisfied (like Get.until)
  static void until(RoutePredicate predicate) {
    navigatorKey.currentState?.popUntil(predicate);
  }

  // ── Overlay / Snackbar support ──
  static OverlayEntry? _topOverlayEntry;
  static Timer? _topOverlayTimer;
  static bool _isSnackbarOpen = false;

  static bool get isSnackbarOpen =>
      _isSnackbarOpen || _topOverlayEntry != null;

  static void closeCurrentSnackbar() {
    messengerKey.currentState?.hideCurrentSnackBar();
    _topOverlayTimer?.cancel();
    _topOverlayTimer = null;
    if (_topOverlayEntry != null) {
      _topOverlayEntry?.remove();
      _topOverlayEntry = null;
    }
    _isSnackbarOpen = false;
  }

  /// Display a snackbar (like Get.snackbar)
  static void snackbar(
    String title,
    String message, {
    SnackPosition snackPosition = SnackPosition.BOTTOM,
    Color? backgroundColor,
    Color? colorText,
    Duration? duration = const Duration(seconds: 3),
    Widget? icon,
    EdgeInsets? margin,
    double? borderRadius,
  }) {
    closeCurrentSnackbar();

    if (snackPosition == SnackPosition.TOP) {
      _showTopBanner(
        content: Row(
          children: [
            if (icon != null) ...[
              icon,
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title.isNotEmpty)
                    Text(
                      title,
                      style: TextStyle(
                        color: colorText ?? Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  if (title.isNotEmpty && message.isNotEmpty)
                    const SizedBox(height: 4),
                  if (message.isNotEmpty)
                    Text(
                      message,
                      style: TextStyle(
                        color: colorText ?? Colors.white,
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor ?? const Color(0xFF1E1E2E),
        margin: margin ?? const EdgeInsets.all(12),
        borderRadius: borderRadius ?? 12,
        duration: duration,
      );
      return;
    }

    _isSnackbarOpen = true;
    messengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              icon,
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title.isNotEmpty)
                    Text(
                      title,
                      style: TextStyle(
                        color: colorText ?? Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  if (title.isNotEmpty && message.isNotEmpty)
                    const SizedBox(height: 4),
                  if (message.isNotEmpty)
                    Text(
                      message,
                      style: TextStyle(
                        color: colorText ?? Colors.white,
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor ?? const Color(0xFF323232),
        behavior: SnackBarBehavior.floating,
        margin: margin ?? const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
        ),
        duration: duration ?? const Duration(seconds: 3),
      ),
    ).closed.then((_) {
      _isSnackbarOpen = false;
    });
  }

  /// Display a raw snackbar (like Get.rawSnackbar)
  static void rawSnackbar({
    required Widget messageText,
    SnackPosition snackPosition = SnackPosition.BOTTOM,
    Color? backgroundColor,
    Duration? duration = const Duration(seconds: 3),
    EdgeInsets? margin,
    EdgeInsets? padding,
    double? borderRadius,
    bool isDismissible = true,
    dynamic snackStyle,
    dynamic animationDuration,
  }) {
    closeCurrentSnackbar();

    if (snackPosition == SnackPosition.TOP) {
      _showTopBanner(
        content: messageText,
        backgroundColor: backgroundColor ?? const Color(0xFF1E1E2E),
        margin: margin ?? const EdgeInsets.all(12),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        borderRadius: borderRadius ?? 12,
        duration: duration,
      );
      return;
    }

    _isSnackbarOpen = true;
    messengerKey.currentState?.showSnackBar(
      SnackBar(
        content: messageText,
        backgroundColor: backgroundColor ?? const Color(0xFF323232),
        behavior: SnackBarBehavior.floating,
        margin: margin ?? const EdgeInsets.all(12),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
        ),
        duration: duration ?? const Duration(days: 365), // persistent if null
      ),
    ).closed.then((_) {
      _isSnackbarOpen = false;
    });
  }

  static void _showTopBanner({
    required Widget content,
    required Color backgroundColor,
    required EdgeInsets margin,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    required double borderRadius,
    Duration? duration,
  }) {
    final overlayState = navigatorKey.currentState?.overlay;
    if (overlayState == null) return;

    _topOverlayEntry = OverlayEntry(
      builder: (context) {
        final topPad = MediaQuery.of(context).padding.top;
        return Positioned(
          top: topPad + margin.top,
          left: margin.left,
          right: margin.right,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: content,
            ),
          ),
        );
      },
    );

    overlayState.insert(_topOverlayEntry!);

    if (duration != null) {
      _topOverlayTimer = Timer(duration, () {
        closeCurrentSnackbar();
      });
    }
  }

  /// Show bottom sheet (like Get.bottomSheet)
  static Future<T?> bottomSheet<T>(
    Widget sheet, {
    bool isScrollControlled = true,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
    ShapeBorder? shape,
  }) {
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return Future.value(null);

    return showModalBottomSheet<T>(
      context: ctx,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: backgroundColor ?? Colors.transparent,
      shape: shape,
      builder: (_) => sheet,
    );
  }

  /// Show dialog (like Get.dialog)
  static Future<T?> dialog<T>(
    Widget dialog, {
    bool barrierDismissible = true,
  }) {
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return Future.value(null);

    return showDialog<T>(
      context: ctx,
      barrierDismissible: barrierDismissible,
      builder: (_) => dialog,
    );
  }

  /// Current locale accessor
  static Locale get currentLocale => AppTranslations.currentLocale;
}
