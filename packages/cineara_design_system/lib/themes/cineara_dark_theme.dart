import 'package:flutter/material.dart';

import '../tokens/colour_tokens.dart';
import '../tokens/radius_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';
import 'theme_extensions.dart';

/// Dark Material 3 theme for Cineara.
///
/// This class maps Cineara's design tokens to Flutter's Material theme system.
///
/// The theme defines:
/// - the Material [ColorScheme];
/// - typography;
/// - application surfaces;
/// - cards;
/// - navigation components;
/// - buttons and controls;
/// - text fields;
/// - dialogs and bottom sheets;
/// - feedback components;
/// - Cineara-specific semantic colours through [CinearaThemeExtension].
///
/// Feature widgets should generally obtain visual values from:
///
/// ```dart
/// Theme.of(context).colorScheme
/// Theme.of(context).textTheme
/// ```
///
/// Cineara-specific semantic values that are not represented by Material's
/// standard colour roles are available through [CinearaThemeExtension].
abstract final class CinearaDarkTheme {
  /// Complete dark theme used by Cineara.
  static ThemeData get theme {
    final ColorScheme colorScheme = _colorScheme;

    return ThemeData(
      // -----------------------------------------------------------------------
      // Material configuration
      // -----------------------------------------------------------------------
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,

      // Cineara defines its own surface hierarchy, so Material should not add
      // additional elevation tinting on top of these colours.
      applyElevationOverlayColor: false,

      // -----------------------------------------------------------------------
      // Application surfaces
      // -----------------------------------------------------------------------
      scaffoldBackgroundColor: CinearaColours.darkBackground,
      canvasColor: CinearaColours.darkBackground,
      cardColor: CinearaColours.darkSurface,
      dividerColor: CinearaColours.darkOutline,
      disabledColor: CinearaColours.darkTextDisabled,

      // -----------------------------------------------------------------------
      // Typography
      // -----------------------------------------------------------------------
      textTheme: _textTheme,

      // -----------------------------------------------------------------------
      // Icons
      // -----------------------------------------------------------------------
      iconTheme: const IconThemeData(
        color: CinearaColours.darkTextSecondary,
        size: 24,
      ),

      // -----------------------------------------------------------------------
      // App bar
      // -----------------------------------------------------------------------
      appBarTheme: const AppBarThemeData(
        backgroundColor: CinearaColours.darkBackground,
        foregroundColor: CinearaColours.darkTextPrimary,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(
          color: CinearaColours.darkTextPrimary,
          size: 24,
        ),
        actionsIconTheme: IconThemeData(
          color: CinearaColours.darkTextPrimary,
          size: 24,
        ),
        titleTextStyle: TextStyle(
          color: CinearaColours.darkTextPrimary,
          fontSize: CinearaFontSizes.titleSmall,
          fontWeight: FontWeight.w600,
          height: 1.25,
        ),
      ),

      // -----------------------------------------------------------------------
      // Cards
      // -----------------------------------------------------------------------
      cardTheme: CardThemeData(
        color: CinearaColours.darkSurface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.30),
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CinearaRadii.lg),
        ),
      ),

      // -----------------------------------------------------------------------
      // Bottom navigation
      // -----------------------------------------------------------------------
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: CinearaColours.darkSurface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: CinearaColours.darkSurfaceBrand,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CinearaRadii.lg),
        ),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: CinearaColours.brand300,
              size: 24,
            );
          }

          return const IconThemeData(
            color: CinearaColours.darkTextSecondary,
            size: 24,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: CinearaColours.brand200,
              fontSize: CinearaFontSizes.labelMedium,
              fontWeight: FontWeight.w600,
            );
          }

          return const TextStyle(
            color: CinearaColours.darkTextSecondary,
            fontSize: CinearaFontSizes.labelMedium,
            fontWeight: FontWeight.w500,
          );
        }),
      ),

      // -----------------------------------------------------------------------
      // Tablet navigation rail
      // -----------------------------------------------------------------------
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: CinearaColours.darkSurface,
        elevation: 0,
        useIndicator: true,
        indicatorColor: CinearaColours.darkSurfaceBrand,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CinearaRadii.lg),
        ),
        minWidth: 80,
        minExtendedWidth: 220,
        selectedIconTheme: const IconThemeData(
          color: CinearaColours.brand300,
          size: 24,
        ),
        unselectedIconTheme: const IconThemeData(
          color: CinearaColours.darkTextSecondary,
          size: 24,
        ),
        selectedLabelTextStyle: const TextStyle(
          color: CinearaColours.brand200,
          fontSize: CinearaFontSizes.bodySmall,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: const TextStyle(
          color: CinearaColours.darkTextSecondary,
          fontSize: CinearaFontSizes.bodySmall,
          fontWeight: FontWeight.w500,
        ),
      ),

      // -----------------------------------------------------------------------
      // Internal tab bars
      // -----------------------------------------------------------------------
      tabBarTheme: TabBarThemeData(
        indicatorColor: CinearaColours.brand400,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: CinearaColours.darkOutline,
        labelColor: CinearaColours.darkTextPrimary,
        unselectedLabelColor: CinearaColours.darkTextSecondary,
        labelPadding: const EdgeInsets.symmetric(horizontal: CinearaSpacing.md),
        splashBorderRadius: BorderRadius.circular(CinearaRadii.md),
        labelStyle: const TextStyle(
          fontSize: CinearaFontSizes.bodySmall,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: CinearaFontSizes.bodySmall,
          fontWeight: FontWeight.w500,
        ),
      ),

      // -----------------------------------------------------------------------
      // Text fields
      // -----------------------------------------------------------------------
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: CinearaColours.darkSurfaceElevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: CinearaSpacing.md,
          vertical: CinearaSpacing.sm,
        ),
        hintStyle: const TextStyle(
          color: CinearaColours.darkTextDisabled,
          fontSize: CinearaFontSizes.bodySmall,
        ),
        labelStyle: const TextStyle(
          color: CinearaColours.darkTextSecondary,
          fontSize: CinearaFontSizes.bodySmall,
        ),
        floatingLabelStyle: const TextStyle(
          color: CinearaColours.brand300,
          fontSize: CinearaFontSizes.bodySmall,
          fontWeight: FontWeight.w500,
        ),
        helperStyle: const TextStyle(
          color: CinearaColours.darkTextSecondary,
          fontSize: CinearaFontSizes.labelMedium,
        ),
        errorStyle: const TextStyle(
          color: CinearaColours.error,
          fontSize: CinearaFontSizes.labelMedium,
        ),
        prefixIconColor: CinearaColours.darkTextSecondary,
        suffixIconColor: CinearaColours.darkTextSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CinearaRadii.md),
          borderSide: const BorderSide(color: CinearaColours.darkOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CinearaRadii.md),
          borderSide: const BorderSide(color: CinearaColours.darkOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CinearaRadii.md),
          borderSide: const BorderSide(
            color: CinearaColours.brand400,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CinearaRadii.md),
          borderSide: const BorderSide(color: CinearaColours.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CinearaRadii.md),
          borderSide: const BorderSide(color: CinearaColours.error, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CinearaRadii.md),
          borderSide: const BorderSide(color: CinearaColours.neutral800),
        ),
      ),

      // -----------------------------------------------------------------------
      // Primary buttons
      // -----------------------------------------------------------------------
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll<Size>(Size(0, 48)),
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
            EdgeInsets.symmetric(
              horizontal: CinearaSpacing.lg,
              vertical: CinearaSpacing.sm,
            ),
          ),
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((
            Set<WidgetState> states,
          ) {
            if (states.contains(WidgetState.disabled)) {
              return CinearaColours.neutral700;
            }

            if (states.contains(WidgetState.pressed)) {
              return CinearaColours.brand700;
            }

            return CinearaColours.primary;
          }),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>((
            Set<WidgetState> states,
          ) {
            if (states.contains(WidgetState.disabled)) {
              return CinearaColours.darkTextDisabled;
            }

            return CinearaColours.onPrimary;
          }),
          overlayColor: WidgetStatePropertyAll<Color>(
            CinearaColours.neutral0.withValues(alpha: 0.08),
          ),
          elevation: const WidgetStatePropertyAll<double>(0),
          textStyle: const WidgetStatePropertyAll<TextStyle>(
            TextStyle(
              fontSize: CinearaFontSizes.bodyMedium,
              fontWeight: FontWeight.w600,
            ),
          ),
          shape: WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(CinearaRadii.md),
            ),
          ),
        ),
      ),

      // -----------------------------------------------------------------------
      // Secondary buttons
      // -----------------------------------------------------------------------
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll<Size>(Size(0, 48)),
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
            EdgeInsets.symmetric(
              horizontal: CinearaSpacing.lg,
              vertical: CinearaSpacing.sm,
            ),
          ),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>((
            Set<WidgetState> states,
          ) {
            if (states.contains(WidgetState.disabled)) {
              return CinearaColours.darkTextDisabled;
            }

            return CinearaColours.brand200;
          }),
          side: WidgetStateProperty.resolveWith<BorderSide>((
            Set<WidgetState> states,
          ) {
            if (states.contains(WidgetState.disabled)) {
              return const BorderSide(color: CinearaColours.neutral700);
            }

            if (states.contains(WidgetState.pressed)) {
              return const BorderSide(color: CinearaColours.brand400);
            }

            return const BorderSide(color: CinearaColours.brand600);
          }),
          textStyle: const WidgetStatePropertyAll<TextStyle>(
            TextStyle(
              fontSize: CinearaFontSizes.bodyMedium,
              fontWeight: FontWeight.w600,
            ),
          ),
          shape: WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(CinearaRadii.md),
            ),
          ),
        ),
      ),

      // -----------------------------------------------------------------------
      // Text buttons
      // -----------------------------------------------------------------------
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith<Color?>((
            Set<WidgetState> states,
          ) {
            if (states.contains(WidgetState.disabled)) {
              return CinearaColours.darkTextDisabled;
            }

            return CinearaColours.brand300;
          }),
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
            EdgeInsets.symmetric(
              horizontal: CinearaSpacing.sm,
              vertical: CinearaSpacing.xs,
            ),
          ),
          textStyle: const WidgetStatePropertyAll<TextStyle>(
            TextStyle(
              fontSize: CinearaFontSizes.bodySmall,
              fontWeight: FontWeight.w600,
            ),
          ),
          shape: WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(CinearaRadii.md),
            ),
          ),
        ),
      ),

      // -----------------------------------------------------------------------
      // Icon buttons
      // -----------------------------------------------------------------------
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith<Color?>((
            Set<WidgetState> states,
          ) {
            if (states.contains(WidgetState.disabled)) {
              return CinearaColours.darkTextDisabled;
            }

            if (states.contains(WidgetState.selected)) {
              return CinearaColours.brand300;
            }

            return CinearaColours.darkTextSecondary;
          }),
          overlayColor: WidgetStatePropertyAll<Color>(
            CinearaColours.brand400.withValues(alpha: 0.10),
          ),
        ),
      ),

      // -----------------------------------------------------------------------
      // Chips
      // -----------------------------------------------------------------------
      chipTheme: ChipThemeData(
        backgroundColor: CinearaColours.darkSurfaceElevated,
        selectedColor: CinearaColours.darkSurfaceBrand,
        disabledColor: CinearaColours.darkSurface,
        side: const BorderSide(color: CinearaColours.darkOutline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CinearaRadii.pill),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: CinearaSpacing.sm,
          vertical: CinearaSpacing.xxs,
        ),
        labelStyle: const TextStyle(
          color: CinearaColours.darkTextPrimary,
          fontSize: CinearaFontSizes.bodySmall,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: const TextStyle(
          color: CinearaColours.brand100,
          fontSize: CinearaFontSizes.bodySmall,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(
          color: CinearaColours.darkTextSecondary,
          size: 18,
        ),
        checkmarkColor: CinearaColours.brand200,
      ),

      // -----------------------------------------------------------------------
      // List tiles
      // -----------------------------------------------------------------------
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        selectedTileColor: CinearaColours.darkSurfaceBrand,
        textColor: CinearaColours.darkTextPrimary,
        selectedColor: CinearaColours.brand200,
        iconColor: CinearaColours.darkTextSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CinearaRadii.md),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: CinearaSpacing.md,
          vertical: CinearaSpacing.xxs,
        ),
        titleTextStyle: const TextStyle(
          color: CinearaColours.darkTextPrimary,
          fontSize: CinearaFontSizes.bodyMedium,
          fontWeight: FontWeight.w500,
        ),
        subtitleTextStyle: const TextStyle(
          color: CinearaColours.darkTextSecondary,
          fontSize: CinearaFontSizes.bodySmall,
          fontWeight: FontWeight.w400,
        ),
      ),

      // -----------------------------------------------------------------------
      // Dividers
      // -----------------------------------------------------------------------
      dividerTheme: const DividerThemeData(
        color: CinearaColours.darkOutline,
        thickness: 1,
        space: 1,
      ),

      // -----------------------------------------------------------------------
      // Progress indicators
      // -----------------------------------------------------------------------
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: CinearaColours.brand400,
        linearTrackColor: CinearaColours.darkOutline,
        circularTrackColor: CinearaColours.darkOutline,
      ),

      // -----------------------------------------------------------------------
      // Sliders
      // -----------------------------------------------------------------------
      sliderTheme: SliderThemeData(
        activeTrackColor: CinearaColours.brand500,
        inactiveTrackColor: CinearaColours.darkOutline,
        thumbColor: CinearaColours.brand300,
        overlayColor: CinearaColours.brand400.withValues(alpha: 0.16),
        valueIndicatorColor: CinearaColours.darkSurfaceElevated,
        valueIndicatorTextStyle: const TextStyle(
          color: CinearaColours.darkTextPrimary,
          fontSize: CinearaFontSizes.labelMedium,
          fontWeight: FontWeight.w600,
        ),
      ),

      // -----------------------------------------------------------------------
      // Switches
      // -----------------------------------------------------------------------
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.disabled)) {
            return CinearaColours.darkTextDisabled;
          }

          if (states.contains(WidgetState.selected)) {
            return CinearaColours.brand100;
          }

          return CinearaColours.darkTextSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.disabled)) {
            return CinearaColours.neutral800;
          }

          if (states.contains(WidgetState.selected)) {
            return CinearaColours.brand600;
          }

          return CinearaColours.darkOutline;
        }),
      ),

      // -----------------------------------------------------------------------
      // Checkboxes
      // -----------------------------------------------------------------------
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.disabled)) {
            return CinearaColours.neutral700;
          }

          if (states.contains(WidgetState.selected)) {
            return CinearaColours.primary;
          }

          return Colors.transparent;
        }),
        checkColor: const WidgetStatePropertyAll<Color>(
          CinearaColours.onPrimary,
        ),
        side: const BorderSide(color: CinearaColours.darkTextSecondary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CinearaRadii.xs),
        ),
      ),

      // -----------------------------------------------------------------------
      // Radio controls
      // -----------------------------------------------------------------------
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.disabled)) {
            return CinearaColours.darkTextDisabled;
          }

          if (states.contains(WidgetState.selected)) {
            return CinearaColours.brand400;
          }

          return CinearaColours.darkTextSecondary;
        }),
      ),

      // -----------------------------------------------------------------------
      // Dialogs
      // -----------------------------------------------------------------------
      dialogTheme: DialogThemeData(
        backgroundColor: CinearaColours.darkSurfaceElevated,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.45),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CinearaRadii.xl),
        ),
        titleTextStyle: const TextStyle(
          color: CinearaColours.darkTextPrimary,
          fontSize: CinearaFontSizes.titleSmall,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        contentTextStyle: const TextStyle(
          color: CinearaColours.darkTextSecondary,
          fontSize: CinearaFontSizes.bodyMedium,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
      ),

      // -----------------------------------------------------------------------
      // Bottom sheets
      // -----------------------------------------------------------------------
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: CinearaColours.darkSurfaceElevated,
        modalBackgroundColor: CinearaColours.darkSurfaceElevated,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        modalElevation: 8,
        showDragHandle: true,
        dragHandleColor: CinearaColours.darkTextDisabled,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(CinearaRadii.xl),
          ),
        ),
      ),

      // -----------------------------------------------------------------------
      // Snack bars
      // -----------------------------------------------------------------------
      snackBarTheme: SnackBarThemeData(
        backgroundColor: CinearaColours.neutral800,
        contentTextStyle: const TextStyle(
          color: CinearaColours.darkTextPrimary,
          fontSize: CinearaFontSizes.bodySmall,
        ),
        actionTextColor: CinearaColours.brand200,
        disabledActionTextColor: CinearaColours.darkTextDisabled,
        elevation: 6,
        behavior: SnackBarBehavior.floating,
        insetPadding: const EdgeInsets.all(CinearaSpacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CinearaRadii.md),
        ),
      ),

      // -----------------------------------------------------------------------
      // Tooltips
      // -----------------------------------------------------------------------
      tooltipTheme: TooltipThemeData(
        padding: const EdgeInsets.symmetric(
          horizontal: CinearaSpacing.sm,
          vertical: CinearaSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: CinearaColours.neutral800,
          borderRadius: BorderRadius.circular(CinearaRadii.sm),
        ),
        textStyle: const TextStyle(
          color: CinearaColours.darkTextPrimary,
          fontSize: CinearaFontSizes.labelMedium,
          fontWeight: FontWeight.w500,
        ),
      ),

      // -----------------------------------------------------------------------
      // Text selection
      // -----------------------------------------------------------------------
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: CinearaColours.brand300,
        selectionColor: CinearaColours.brand500.withValues(alpha: 0.35),
        selectionHandleColor: CinearaColours.brand300,
      ),

      // -----------------------------------------------------------------------
      // Cineara-specific semantic colours
      // -----------------------------------------------------------------------
      extensions: const <ThemeExtension<dynamic>>[
        CinearaThemeExtension(
          heroOverlay: CinearaColours.heroOverlay,
          skeletonBase: CinearaColours.neutral800,
          skeletonHighlight: CinearaColours.darkOutline,
          progressTrack: CinearaColours.darkOutline,
          posterPlaceholder: CinearaColours.darkSurfaceElevated,
        ),
      ],
    );
  }

  // ===========================================================================
  // Material colour scheme
  // ===========================================================================

  static const ColorScheme _colorScheme = ColorScheme(
    brightness: Brightness.dark,

    // -------------------------------------------------------------------------
    // Primary
    // -------------------------------------------------------------------------
    primary: CinearaColours.primary,
    onPrimary: CinearaColours.onPrimary,
    primaryContainer: CinearaColours.primaryContainer,
    onPrimaryContainer: CinearaColours.onPrimaryContainer,

    // -------------------------------------------------------------------------
    // Secondary
    //
    // Cineara's blue logo accent is used as the secondary accent colour.
    // -------------------------------------------------------------------------
    secondary: CinearaColours.logoBlue,
    onSecondary: CinearaColours.neutral0,
    secondaryContainer: CinearaColours.darkSurfaceBrand,
    onSecondaryContainer: CinearaColours.brand100,

    // -------------------------------------------------------------------------
    // Tertiary
    //
    // Cineara's pink logo accent acts as the tertiary accent.
    // -------------------------------------------------------------------------
    tertiary: CinearaColours.logoPink,
    onTertiary: CinearaColours.neutral950,
    tertiaryContainer: CinearaColours.brand900,
    onTertiaryContainer: CinearaColours.brand100,

    // -------------------------------------------------------------------------
    // Error
    // -------------------------------------------------------------------------
    error: CinearaColours.error,
    onError: CinearaColours.neutral950,

    // -------------------------------------------------------------------------
    // Surface hierarchy
    // -------------------------------------------------------------------------
    surface: CinearaColours.darkSurface,
    onSurface: CinearaColours.darkTextPrimary,
    onSurfaceVariant: CinearaColours.darkTextSecondary,

    surfaceDim: CinearaColours.darkBackground,
    surfaceBright: CinearaColours.darkSurfaceElevated,

    surfaceContainerLowest: CinearaColours.darkBackground,
    surfaceContainerLow: CinearaColours.darkSurface,
    surfaceContainer: CinearaColours.darkSurface,
    surfaceContainerHigh: CinearaColours.darkSurfaceElevated,
    surfaceContainerHighest: CinearaColours.darkSurfaceBrand,

    // -------------------------------------------------------------------------
    // Borders
    // -------------------------------------------------------------------------
    outline: CinearaColours.darkOutline,
    outlineVariant: CinearaColours.neutral800,

    // -------------------------------------------------------------------------
    // Inverse surfaces
    // -------------------------------------------------------------------------
    inverseSurface: CinearaColours.lightSurface,
    onInverseSurface: CinearaColours.lightTextPrimary,
    inversePrimary: CinearaColours.brand400,

    // -------------------------------------------------------------------------
    // Miscellaneous
    // -------------------------------------------------------------------------
    shadow: Colors.black,
    scrim: Colors.black,
    surfaceTint: Colors.transparent,
  );

  // ===========================================================================
  // Typography
  // ===========================================================================

  /// Dark-theme typography.
  ///
  /// Cineara defines fewer font-size tokens than Material's [TextTheme]
  /// contains roles. Related Material roles therefore intentionally share
  /// Cineara font-size tokens.
  static const TextTheme _textTheme = TextTheme(
    // -------------------------------------------------------------------------
    // Display
    // -------------------------------------------------------------------------
    displayLarge: TextStyle(
      color: CinearaColours.darkTextPrimary,
      fontSize: CinearaFontSizes.display,
      fontWeight: FontWeight.w700,
      height: 1.10,
      letterSpacing: -0.8,
    ),
    displayMedium: TextStyle(
      color: CinearaColours.darkTextPrimary,
      fontSize: CinearaFontSizes.display,
      fontWeight: FontWeight.w600,
      height: 1.10,
      letterSpacing: -0.6,
    ),
    displaySmall: TextStyle(
      color: CinearaColours.darkTextPrimary,
      fontSize: CinearaFontSizes.titleLarge,
      fontWeight: FontWeight.w700,
      height: 1.15,
      letterSpacing: -0.4,
    ),

    // -------------------------------------------------------------------------
    // Headlines
    // -------------------------------------------------------------------------
    headlineLarge: TextStyle(
      color: CinearaColours.darkTextPrimary,
      fontSize: CinearaFontSizes.titleLarge,
      fontWeight: FontWeight.w700,
      height: 1.20,
    ),
    headlineMedium: TextStyle(
      color: CinearaColours.darkTextPrimary,
      fontSize: CinearaFontSizes.titleMedium,
      fontWeight: FontWeight.w600,
      height: 1.20,
    ),
    headlineSmall: TextStyle(
      color: CinearaColours.darkTextPrimary,
      fontSize: CinearaFontSizes.titleSmall,
      fontWeight: FontWeight.w600,
      height: 1.25,
    ),

    // -------------------------------------------------------------------------
    // Titles
    // -------------------------------------------------------------------------
    titleLarge: TextStyle(
      color: CinearaColours.darkTextPrimary,
      fontSize: CinearaFontSizes.titleMedium,
      fontWeight: FontWeight.w600,
      height: 1.25,
    ),
    titleMedium: TextStyle(
      color: CinearaColours.darkTextPrimary,
      fontSize: CinearaFontSizes.titleSmall,
      fontWeight: FontWeight.w600,
      height: 1.30,
    ),
    titleSmall: TextStyle(
      color: CinearaColours.darkTextPrimary,
      fontSize: CinearaFontSizes.bodyLarge,
      fontWeight: FontWeight.w600,
      height: 1.30,
    ),

    // -------------------------------------------------------------------------
    // Body
    // -------------------------------------------------------------------------
    bodyLarge: TextStyle(
      color: CinearaColours.darkTextPrimary,
      fontSize: CinearaFontSizes.bodyLarge,
      fontWeight: FontWeight.w400,
      height: 1.50,
    ),
    bodyMedium: TextStyle(
      color: CinearaColours.darkTextSecondary,
      fontSize: CinearaFontSizes.bodyMedium,
      fontWeight: FontWeight.w400,
      height: 1.50,
    ),
    bodySmall: TextStyle(
      color: CinearaColours.darkTextSecondary,
      fontSize: CinearaFontSizes.bodySmall,
      fontWeight: FontWeight.w400,
      height: 1.45,
    ),

    // -------------------------------------------------------------------------
    // Labels
    // -------------------------------------------------------------------------
    labelLarge: TextStyle(
      color: CinearaColours.darkTextPrimary,
      fontSize: CinearaFontSizes.bodySmall,
      fontWeight: FontWeight.w600,
      height: 1.30,
    ),
    labelMedium: TextStyle(
      color: CinearaColours.darkTextSecondary,
      fontSize: CinearaFontSizes.labelMedium,
      fontWeight: FontWeight.w600,
      height: 1.30,
    ),
    labelSmall: TextStyle(
      color: CinearaColours.darkTextSecondary,
      fontSize: CinearaFontSizes.labelSmall,
      fontWeight: FontWeight.w500,
      height: 1.30,
    ),
  );
}
