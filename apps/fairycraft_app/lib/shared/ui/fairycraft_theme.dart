import 'package:flutter/material.dart';

class FairyCraftPalette {
  const FairyCraftPalette._();

  static const Color primary = Color(0xFF7B619A);
  static const Color secondary = Color(0xFFEFA790);
  static const Color background = Color(0xFFF9F4F1);
  static const Color surface = Color(0xFFF2EBF0);
  static const Color outline = Color(0xFFE4D7E8);
  static const Color textPrimary = Color(0xFF59436F);
  static const Color textSecondary = Color(0xFF806995);
  static const Color error = Color(0xFFD77A7A);
}

class FairyCraftSpacing {
  const FairyCraftSpacing._();

  static const double element = 12;
  static const double padding = 16;
  static const double section = 24;
  static const EdgeInsets page = EdgeInsets.all(padding);
}

class FairyCraftMotion {
  const FairyCraftMotion._();

  static const Duration standard = Duration(milliseconds: 250);
  static const Curve curve = Curves.easeInOut;
}

class FairyCraftTheme {
  const FairyCraftTheme._();

  static ThemeData light({bool motionEnabled = true}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: FairyCraftPalette.primary,
      primary: FairyCraftPalette.primary,
      secondary: FairyCraftPalette.secondary,
      brightness: Brightness.light,
      surface: FairyCraftPalette.surface,
      error: FairyCraftPalette.error,
    );

    final base = ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: FairyCraftPalette.background,
      useMaterial3: true,
    );

    return base.copyWith(
      pageTransitionsTheme: motionEnabled
          ? base.pageTransitionsTheme
          : _noMotionPageTransitionsTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: FairyCraftPalette.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: FairyCraftPalette.textPrimary,
        centerTitle: false,
        elevation: 0,
        titleTextStyle: const TextStyle(
          fontSize: 24,
          height: 1.2,
          fontWeight: FontWeight.w700,
          color: FairyCraftPalette.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: FairyCraftPalette.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: FairyCraftPalette.outline),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.75),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: FairyCraftPalette.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: FairyCraftPalette.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: FairyCraftPalette.primary,
            width: 1.5,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: FairyCraftPalette.secondary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: FairyCraftPalette.secondary.withValues(
            alpha: 0.45,
          ),
          disabledForegroundColor: Colors.white70,
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: FairyCraftPalette.primary,
          side: const BorderSide(color: FairyCraftPalette.outline),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        ),
      ),
      sliderTheme: base.sliderTheme.copyWith(
        activeTrackColor: FairyCraftPalette.primary,
        inactiveTrackColor: FairyCraftPalette.outline,
        thumbColor: FairyCraftPalette.secondary,
        overlayColor: FairyCraftPalette.secondary.withValues(alpha: 0.2),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return FairyCraftPalette.surface;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return FairyCraftPalette.secondary;
          }
          return FairyCraftPalette.outline;
        }),
      ),
      textTheme: base.textTheme.copyWith(
        headlineLarge: const TextStyle(
          fontSize: 38,
          height: 1.2,
          fontWeight: FontWeight.w700,
          color: FairyCraftPalette.textPrimary,
        ),
        headlineMedium: const TextStyle(
          fontSize: 30,
          height: 1.2,
          fontWeight: FontWeight.w700,
          color: FairyCraftPalette.textPrimary,
        ),
        titleLarge: const TextStyle(
          fontSize: 24,
          height: 1.25,
          fontWeight: FontWeight.w700,
          color: FairyCraftPalette.textPrimary,
        ),
        titleMedium: const TextStyle(
          fontSize: 20,
          height: 1.3,
          fontWeight: FontWeight.w700,
          color: FairyCraftPalette.textPrimary,
        ),
        bodyLarge: const TextStyle(
          fontSize: 18,
          height: 1.5,
          color: FairyCraftPalette.textPrimary,
        ),
        bodyMedium: const TextStyle(
          fontSize: 16,
          height: 1.45,
          color: FairyCraftPalette.textSecondary,
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    );
  }

  static ThemeData dark({bool motionEnabled = true}) {
    final scheme = ColorScheme.fromSeed(
      seedColor: FairyCraftPalette.primary,
      brightness: Brightness.dark,
    );
    final base = ThemeData(colorScheme: scheme, useMaterial3: true);
    return base.copyWith(
      pageTransitionsTheme: motionEnabled
          ? base.pageTransitionsTheme
          : _noMotionPageTransitionsTheme,
    );
  }

  static const PageTransitionsTheme _noMotionPageTransitionsTheme =
      PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: _NoAnimationPageTransitionsBuilder(),
          TargetPlatform.iOS: _NoAnimationPageTransitionsBuilder(),
          TargetPlatform.macOS: _NoAnimationPageTransitionsBuilder(),
          TargetPlatform.windows: _NoAnimationPageTransitionsBuilder(),
          TargetPlatform.linux: _NoAnimationPageTransitionsBuilder(),
          TargetPlatform.fuchsia: _NoAnimationPageTransitionsBuilder(),
        },
      );
}

class _NoAnimationPageTransitionsBuilder extends PageTransitionsBuilder {
  const _NoAnimationPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}
