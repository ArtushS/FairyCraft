// PERFORMANCE FIX #2: Defer Image Precaching and Heavy Initialization
//
// Place this mixin or pattern in your home screen or main app shell to defer heavy work
// to after the first frame is rendered. This keeps startup on the critical path minimal.
//
// Usage in a StatefulWidget:
//   WidgetsBinding.instance.addPostFrameCallback((_) async {
//     await _precacheAssets();
//   });

import 'package:flutter/material.dart';

/// Mixin to defer expensive asset precaching to post-frame callback.
///
/// Prevents image decoding and I/O from blocking the critical path to first frame.
/// Estimated impact: 100–200ms reduction in startup time.
mixin DeferredAssetPreloading {
  /// Call this in State.initState() or similar to defer asset loading.
  ///
  /// Example usage:
  /// ```dart
  /// @override
  /// void initState() {
  ///   super.initState();
  ///   deferAssetPreloading();
  /// }
  /// ```
  void deferAssetPreloading() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await precacheAssets();
    });
  }

  /// Override this method to define which assets to precache.
  /// Called after the first frame has rendered.
  Future<void> precacheAssets() async {
    // Example: precache images
    // await precacheImage(AssetImage('assets/icons/logo.png'), context);
    // await precacheImage(AssetImage('assets/images/onboarding_bg.png'), context);
    // ... etc
  }
}

/// Example implementation in home screen or app shell:
///
/// ```dart
/// class MyHomeScreenState extends State<MyHomeScreen> with DeferredAssetPreloading {
///   @override
///   void initState() {
///     super.initState();
///     deferAssetPreloading();
///   }
///
///   @override
///   Future<void> precacheAssets() async {
///     if (!mounted) return;
///     // Precache frequently-used images here
///     final ctx = context;
///     await Future.wait([
///       precacheImage(AssetImage('assets/icons/play.png'), ctx),
///       precacheImage(AssetImage('assets/icons/pause.png'), ctx),
///     ]);
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     // ... UI code ...
///   }
/// }
/// ```

/// Alternative pattern: Use WidgetsBinding directly in a StatelessWidget.
///
/// This defers heavy computations (not just assets) to after first frame:
///
/// ```dart
/// class MyApp extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     WidgetsBinding.instance.addPostFrameCallback((_) {
///       // Heavy work here (fetch story catalog, load voices, etc.)
///       _loadInitialData(context);
///     });
///
///     return MaterialApp(
///       // ... app config ...
///     );
///   }
///
///   Future<void> _loadInitialData(BuildContext context) async {
///     // Fetch stories, voices, etc. after first frame
///   }
/// }
/// ```
