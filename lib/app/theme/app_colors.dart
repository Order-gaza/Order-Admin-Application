import 'package:flutter/material.dart';

/// Order Delivery Admin — Color palette derived from the logo
class AppColors {
  AppColors._();

  // ── Primary (Orange) ──
  static const Color primaryOrange = Color(0xFFF37A20);
  static const Color darkOrange = Color(0xFFE06B10);
  static const Color lightOrange = Color(0xFFFFF3E0);
  static const Color orangeAccent = Color(0xFFFF9800);

  // ── Dark surfaces ──
  static const Color charcoalBlack = Color(0xFF1E1E1E);
  static const Color darkSurface = Color(0xFF2C2C2C);
  static const Color scaffoldDark = Color(0xFF121212);
  static const Color cardDark = Color(0xFF1E1E1E);

  // ── Light surfaces ──
  static const Color scaffoldLight = Color(0xFFF5F5F5);
  static const Color cardLight = Color(0xFFFFFFFF);

  // ── Accent colors ──
  static const Color goldenYellow = Color(0xFFF5A623);

  // ── Status colors ──
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // ── Text ──
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFBDBDBD);
  static const Color textDark = Color(0xFF212121);
  static const Color textMuted = Color(0xFF757575);

  // ── Misc ──
  static const Color divider = Color(0xFF424242);
  static const Color dividerLight = Color(0xFFE0E0E0);
  static const Color shimmerBase = Color(0xFF2C2C2C);
  static const Color shimmerHighlight = Color(0xFF3E3E3E);

  // ── Order status colors ──
  static const Color statusPending = Color(0xFFFF9800);
  static const Color statusConfirmed = Color(0xFF2196F3);
  static const Color statusSentToVendor = Color(0xFF9C27B0);
  static const Color statusAccepted = Color(0xFF00BCD4);
  static const Color statusPreparing = Color(0xFFFF5722);
  static const Color statusReady = Color(0xFF8BC34A);
  static const Color statusDispatched = Color(0xFF3F51B5);
  static const Color statusDelivered = Color(0xFF4CAF50);
  static const Color statusCancelled = Color(0xFFF44336);
}
