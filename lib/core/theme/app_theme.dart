import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiaryContainer,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
        inversePrimary: AppColors.inversePrimary,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        centerTitle: true,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondaryContainer,
          foregroundColor: AppColors.onSecondaryContainer,
          textStyle: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: const StadiumBorder(),
          elevation: 2,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.labelSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            );
          }
          return AppTextStyles.labelSmall.copyWith(
            color: AppColors.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.onPrimary);
          }
          return const IconThemeData(color: AppColors.onSurfaceVariant);
        }),
      ),
    );
  }

  static ThemeData get darkTheme {
    const darkBackground = Color(0xFF0F172A); // Rich Dark Slate
    const darkSurface = Color(0xFF1E293B);    // Slate Card Surface
    const darkPrimary = Color(0xFF2DD4BF);    // Vibrant Emerald / Teal Accent
    const darkSecondary = Color(0xFFF59E0B);  // Warm Gold Accent
    const darkOnSurface = Color(0xFFF8FAFC);  // Crisp Bright Text
    const darkOnSurfaceVariant = Color(0xFF94A3B8); // Muted Subtitle Text

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: darkPrimary,
        onPrimary: Color(0xFF0F172A),
        primaryContainer: Color(0xFF134E4A),
        onPrimaryContainer: Color(0xFFCCFBF1),
        secondary: darkSecondary,
        onSecondary: Color(0xFF0F172A),
        secondaryContainer: Color(0xFF78350F),
        onSecondaryContainer: Color(0xFFFEF3C7),
        tertiary: Color(0xFF818CF8),
        onTertiary: Colors.white,
        tertiaryContainer: Color(0xFF312E81),
        onTertiaryContainer: Color(0xFFE0E7FF),
        error: Color(0xFFF87171),
        onError: Colors.white,
        errorContainer: Color(0xFF7F1D1D),
        onErrorContainer: Color(0xFFFEE2E2),
        surface: darkSurface,
        onSurface: darkOnSurface,
        onSurfaceVariant: darkOnSurfaceVariant,
        outline: Color(0xFF475569),
        outlineVariant: Color(0xFF334155),
        inversePrimary: AppColors.primary,
      ),
      scaffoldBackgroundColor: darkBackground,
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(color: darkOnSurface),
        headlineMedium: AppTextStyles.headlineMedium.copyWith(color: darkOnSurface),
        headlineSmall: AppTextStyles.headlineSmall.copyWith(color: darkOnSurface),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: darkOnSurface),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: darkOnSurfaceVariant),
        labelMedium: AppTextStyles.labelMedium.copyWith(color: darkOnSurface),
        labelSmall: AppTextStyles.labelSmall.copyWith(color: darkOnSurfaceVariant),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkOnSurface,
        centerTitle: true,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimary,
          foregroundColor: const Color(0xFF0F172A),
          textStyle: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: const StadiumBorder(),
          elevation: 2,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkSurface,
        indicatorColor: darkPrimary.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.labelSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: darkPrimary,
            );
          }
          return AppTextStyles.labelSmall.copyWith(
            color: darkOnSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: darkPrimary);
          }
          return const IconThemeData(color: darkOnSurfaceVariant);
        }),
      ),
    );
  }
}
