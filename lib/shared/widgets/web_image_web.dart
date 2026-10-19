// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

/// Renders a native HTML <img> element that completely bypasses
/// CanvasKit's CORS restrictions.
Widget buildHtmlImage({
  required String imageUrl,
  required BoxFit fit,
  double? width,
  double? height,
  Widget Function()? placeholder,
  Widget Function()? errorWidget,
}) {
  return _HtmlImageWidget(
    imageUrl: imageUrl,
    fit: fit,
    width: width,
    height: height,
    placeholder: placeholder,
    errorWidget: errorWidget,
  );
}

class _HtmlImageWidget extends StatefulWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget Function()? placeholder;
  final Widget Function()? errorWidget;

  const _HtmlImageWidget({
    required this.imageUrl,
    required this.fit,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
  });

  @override
  State<_HtmlImageWidget> createState() => _HtmlImageWidgetState();
}

class _HtmlImageWidgetState extends State<_HtmlImageWidget> {
  late String _viewType;
  bool _loaded = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _viewType = 'img-${widget.imageUrl.hashCode}-${identityHashCode(this)}';
    _registerView();
  }

  @override
  void didUpdateWidget(covariant _HtmlImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _loaded = false;
      _error = false;
      _viewType = 'img-${widget.imageUrl.hashCode}-${identityHashCode(this)}';
      _registerView();
    }
  }

  void _registerView() {
    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) {
        final img = html.ImageElement()
          ..src = widget.imageUrl
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.objectFit = _boxFitToCss(widget.fit)
          ..style.display = 'block';

        img.onLoad.listen((_) {
          if (mounted) setState(() => _loaded = true);
        });
        img.onError.listen((_) {
          if (mounted) setState(() => _error = true);
        });

        return img;
      },
    );
  }

  String _boxFitToCss(BoxFit fit) {
    switch (fit) {
      case BoxFit.cover:
        return 'cover';
      case BoxFit.contain:
        return 'contain';
      case BoxFit.fill:
        return 'fill';
      case BoxFit.fitWidth:
        return 'cover'; // closest CSS equivalent
      case BoxFit.fitHeight:
        return 'contain';
      case BoxFit.none:
        return 'none';
      case BoxFit.scaleDown:
        return 'scale-down';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return widget.errorWidget?.call() ??
          const Center(child: Icon(Icons.broken_image, size: 32));
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Show placeholder while loading
        if (!_loaded)
          widget.placeholder?.call() ??
              const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
        // The actual HTML img element
        HtmlElementView(viewType: _viewType),
      ],
    );
  }
}
