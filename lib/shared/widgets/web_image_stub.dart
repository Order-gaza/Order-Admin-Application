import 'package:flutter/material.dart';

/// Stub for non-web platforms — should never be called (guarded by kIsWeb).
Widget buildHtmlImage({
  required String imageUrl,
  required BoxFit fit,
  double? width,
  double? height,
  Widget Function()? placeholder,
  Widget Function()? errorWidget,
}) {
  // Fallback: should never reach here because kIsWeb is false on mobile.
  return Image.network(imageUrl, fit: fit, width: width, height: height);
}
