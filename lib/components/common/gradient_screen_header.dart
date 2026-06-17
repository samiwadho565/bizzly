import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// Shared gradient header used across all inner screens.
/// Embed this as the first child of a [Column] in your [Scaffold] body.
/// Remember to set [extendBodyBehindAppBar: false] and no scaffold [appBar:].
class GradientScreenHeader extends StatelessWidget {
  final String title;
  final List<Widget>? actions;

  /// Optional widget rendered below the title row (e.g. a search bar).
  final Widget? bottom;

  const GradientScreenHeader({
    super.key,
    required this.title,
    this.actions,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final double top = MediaQuery.of(context).padding.top;

    // Force white status-bar icons while this header is visible
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D1B4B), Color(0xFF0D47A1), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -40,
            right: -40,
            child: _Circle(size: 160),
          ),
          Positioned(
            bottom: -20,
            left: -50,
            child: _Circle(size: 130),
          ),

          // Content
          Padding(
            padding: EdgeInsets.fromLTRB(4, top, 4, bottom != null ? 12 : 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title row
                Row(
                  children: [
                    // Back button
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => Get.back(),
                    ),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    if (actions != null) ...actions!,
                  ],
                ),
                if (bottom != null) ...[
                  const SizedBox(height: 4),
                  bottom!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  final double size;
  const _Circle({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
      ),
    );
  }
}
