import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Conditional import: web gets the real implementation, others get a stub.
import 'web_image_stub.dart' if (dart.library.html) 'web_image_web.dart'
    as web_img;

/// Cross-platform network image:
/// - Web  → native HTML <img> element (completely bypasses CanvasKit CORS)
/// - Mobile/Desktop → [CachedNetworkImage] (disk-cached, bandwidth-efficient)
class AppNetworkImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final Widget Function()? placeholder;
  final Widget Function()? errorWidget;
  final double? width;
  final double? height;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return web_img.buildHtmlImage(
        imageUrl: imageUrl,
        fit: fit,
        width: width,
        height: height,
        placeholder: placeholder,
        errorWidget: errorWidget,
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      placeholder: (_, __) =>
          placeholder?.call() ??
          const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      errorWidget: (_, __, ___) =>
          errorWidget?.call() ??
          const Center(child: Icon(Icons.broken_image, size: 32)),
    );
  }
}
