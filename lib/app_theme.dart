import 'package:flutter/material.dart';

import 'game_status_theme.dart';

ThemeData buildAppTheme([Brightness brightness = Brightness.light]) {
  // blue for actions, white cards on the light canvas
  final isLight = brightness == Brightness.light;
  final seeded = ColorScheme.fromSeed(
    seedColor: const Color(0xFF3555B8),
    brightness: brightness,
  );
  final colors = brightness == Brightness.dark
      ? seeded
      : seeded.copyWith(
          primary: const Color(0xFF3555B8),
          onPrimary: Colors.white,
          surface: const Color(0xFFF0F3F8),
          surfaceContainerLow: Colors.white,
          surfaceContainer: const Color(0xFFE9EEF5),
          surfaceContainerHighest: const Color(0xFFE1E7F0),
          onSurface: const Color(0xFF192337),
          onSurfaceVariant: const Color(0xFF47546A),
          outline: const Color(0xFF758297),
          outlineVariant: const Color(0xFFCCD5E2),
          primaryContainer: const Color(0xFFDFE8FF),
          onPrimaryContainer: const Color(0xFF173577),
          secondary: const Color(0xFF47546A),
          secondaryContainer: const Color(0xFFE9EEF5),
          onSecondaryContainer: const Color(0xFF334155),
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
    borderRadius: BorderRadius.circular(14),
  );

  var cardShape = buttonShape;
  if (isLight) {
    cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: colors.outlineVariant),
    );
  }

  return base.copyWith(
    extensions: [GameStatusTheme.forBrightness(brightness)],
    textTheme: text,
    cardTheme: CardThemeData(
      color: colors.surfaceContainerLow,
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: cardShape,
      clipBehavior: Clip.antiAlias,
    ),
    scaffoldBackgroundColor: colors.surface,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.outlineVariant),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 72,
      backgroundColor: colors.surfaceContainerLow,
      indicatorColor: colors.primaryContainer,
    ),
    appBarTheme: AppBarThemeData(
      centerTitle: false,
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
      style: FilledButton.styleFrom(
        shape: buttonShape,
        elevation: 0,
        minimumSize: const Size(48, 48),
      ),
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
