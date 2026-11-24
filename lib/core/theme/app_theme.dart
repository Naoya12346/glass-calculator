import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../features/settings/data/settings_state.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData themeData(AppThemeMode mode, Color accent) {
    final isDark = mode == AppThemeMode.dark || mode == AppThemeMode.amoled;
    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: isDark ? Brightness.dark : Brightness.light,
    );
    final resolvedScheme = mode == AppThemeMode.amoled
        ? scheme.copyWith(
            surface: Colors.black,
            onSurface: Colors.white,
            surfaceContainerHighest: const Color(0xFF121212),
          )
        : scheme;

    final baseText = GoogleFonts.poppinsTextTheme();
    final textTheme = baseText.copyWith(
      displayLarge: baseText.displayLarge?.copyWith(
        fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
        letterSpacing: -1.5,
      ),
      displayMedium: baseText.displayMedium?.copyWith(
        fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
        letterSpacing: -1,
      ),
      headlineMedium: baseText.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
      titleLarge: baseText.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: baseText.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: resolvedScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: mode == AppThemeMode.amoled
          ? AppColors.amoledCanvas
          : (isDark ? AppColors.darkCanvasBottom : AppColors.lightCanvasBottom),
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      iconTheme: IconThemeData(
        color: isDark ? Colors.white : Colors.black87,
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.cardRadius),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        indicatorColor: accent.withValues(alpha: 0.20),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: accent,
        thumbColor: accent,
        overlayColor: accent.withValues(alpha: 0.18),
      ),
      pageTransitionsTheme: PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData systemLight(Color accent) => themeData(AppThemeMode.light, accent);
  static ThemeData systemDark(Color accent) => themeData(AppThemeMode.dark, accent);
}
