import 'package:flutter/material.dart';

ThemeData buildAppTheme([Brightness brightness = Brightness.light]) {
  // blue for selections and actions, neutral surfaces for the files
  final seeded = ColorScheme.fromSeed(
    seedColor: const Color(0xFF3555B8),
    brightness: brightness,
  );
  final colors = brightness == Brightness.dark
      ? seeded
      : seeded.copyWith(
          primary: const Color(0xFF3555B8),
          onPrimary: Colors.white,
          surface: Colors.white,
          surfaceContainerLow: const Color(0xFFF7F8FA),
          surfaceContainer: const Color(0xFFF1F2F4),
          surfaceContainerHighest: const Color(0xFFE9EBEF),
          onSurface: const Color(0xFF202124),
          onSurfaceVariant: const Color(0xFF565B65),
          secondary: const Color(0xFF6655A1),
          secondaryContainer: const Color(0xFFECE7FA),
          onSecondaryContainer: const Color(0xFF30244F),
          tertiary: const Color(0xFF326B50),
          tertiaryContainer: const Color(0xFFDDF0E4),
          onTertiaryContainer: const Color(0xFF153C29),
        );
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: colors,
    fontFamily: 'SourceSans3',
  );
  final text = base.textTheme.copyWith(
    titleLarge: base.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w600,
    ),
    titleMedium: base.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
    ),
    labelSmall: base.textTheme.labelSmall?.copyWith(fontSize: 11),
  );
  final buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
  );

  return base.copyWith(
    textTheme: text,
    cardTheme: CardThemeData(
      color: colors.surfaceContainerLow,
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: buttonShape,
      clipBehavior: Clip.antiAlias,
    ),
    scaffoldBackgroundColor: colors.surface,
    appBarTheme: AppBarThemeData(
      backgroundColor: colors.surface,
      foregroundColor: colors.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: text.titleLarge,
    ),
    bottomAppBarTheme: BottomAppBarThemeData(
      color: colors.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    iconTheme: IconThemeData(color: colors.onSurfaceVariant),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: colors.primary,
      linearTrackColor: colors.surfaceContainerHighest,
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: colors.surface,
      selectedColor: colors.primaryContainer,
      checkmarkColor: colors.onPrimaryContainer,
      labelStyle: text.labelLarge,
      side: BorderSide(color: colors.outlineVariant),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(shape: buttonShape, elevation: 0),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(shape: buttonShape),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.primary,
        side: BorderSide(color: colors.outlineVariant),
        shape: buttonShape,
      ),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: colors.onSurfaceVariant,
      textColor: colors.onSurface,
      titleTextStyle: text.bodyLarge,
      subtitleTextStyle: text.bodyMedium?.copyWith(
        color: colors.onSurfaceVariant,
      ),
    ),
    dividerTheme: DividerThemeData(color: colors.outlineVariant, thickness: 1),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: colors.inverseSurface,
      contentTextStyle: text.bodyMedium?.copyWith(
        color: colors.onInverseSurface,
      ),
      elevation: 0,
    ),
  );
}
