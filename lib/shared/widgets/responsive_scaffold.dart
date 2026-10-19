import 'package:flutter/material.dart';

/// A scaffold that switches between a permanent side-nav (desktop ≥900 px)
/// and a standard drawer (mobile / narrow screens).
class ResponsiveScaffold extends StatelessWidget {
  const ResponsiveScaffold({
    super.key,
    required this.appBar,
    required this.body,
    required this.drawer,
    this.backgroundColor,
    this.floatingActionButton,
  });

  final PreferredSizeWidget appBar;
  final Widget body;
  final Widget drawer;
  final Color? backgroundColor;
  final Widget? floatingActionButton;

  static const double _breakpoint = 900;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= _breakpoint;

    if (isDesktop) {
      return Scaffold(
        backgroundColor: backgroundColor,
        floatingActionButton: floatingActionButton,
        body: Row(
          children: [
            // ── Permanent side panel ──
            SizedBox(
              width: 280,
              child: Scaffold(
                backgroundColor: const Color(0xFF15151F),
                body: drawer,
              ),
            ),
            // ── Main content ──
            Expanded(
              child: Scaffold(
                backgroundColor: backgroundColor,
                appBar: appBar,
                body: body,
                floatingActionButton: floatingActionButton,
              ),
            ),
          ],
        ),
      );
    }

    // Mobile layout — normal drawer
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      drawer: drawer,
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
