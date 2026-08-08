import 'package:flutter/material.dart';

import '../tokens/colour_tokens.dart';
import '../tokens/radius_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';
import 'theme_extensions.dart';

/// Light Material 3 theme for Cineara.
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
/// The light theme preserves the same visual hierarchy, component dimensions,
/// spacing, radii and typography as the dark theme. Only semantic colours,
/// shadows and surface treatments differ.
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
abstract final class CinearaLightTheme {
  /// Complete light theme used by Cineara.
  static ThemeData get theme {
    final ColorScheme colorScheme = _colorScheme;

    return ThemeData(
      // -----------------------------------------------------------------------
      // Material configuration
      // -----------------------------------------------------------------------
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,

      // Cineara explicitly defines its own surface hierarchy.
      applyElevationOverlayColor: false,

      // -----------------------------------------------------------------------
      // Application surfaces
      // -----------------------------------------------------------------------
      scaffoldBackgroundColor: CinearaColours.lightBackground,
      canvasColor: CinearaColours.lightBackground,
      cardColor: CinearaColours.lightSurface,
      dividerColor: CinearaColours.lightOutline,
      disabledColor: CinearaColours.lightTextDisabled,

      // -----------------------------------------------------------------------
      // Typography
      // -----------------------------------------------------------------------
      textTheme: _textTheme,

      // -----------------------------------------------------------------------
      // Icons
      // -----------------------------------------------------------------------
      iconTheme: const IconThemeData(
        color: CinearaColours.lightTextSecondary,
        size: 24,
      ),

      // -----------------------------------------------------------------------
      // App bar
      // -----------------------------------------------------------------------
      appBarTheme: const AppBarThemeData(
        backgroundColor: CinearaColours.lightBackground,
        foregroundColor: CinearaColours.lightTextPrimary,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(
          color: CinearaColours.lightTextPrimary,
          size: 24,
        ),
        actionsIconTheme: IconThemeData(
          color: CinearaColours.lightTextPrimary,
          size: 24,
        ),
        titleTextStyle: TextStyle(
          color: CinearaColours.lightTextPrimary,
          fontSize: CinearaFontSizes.titleSmall,
          fontWeight: FontWeight.w600,
          height: 1.25,
        ),
      ),

      // -----------------------------------------------------------------------
      // Cards
      // -----------------------------------------------------------------------
      cardTheme: CardThemeData(
        color: CinearaColours.lightSurface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.10),
        elevation: 1,
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
        backgroundColor: CinearaColours.lightSurface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: CinearaColours.brand50,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CinearaRadii.lg),
        ),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: CinearaColours.brand700,
              size: 24,
            );
          }

          return const IconThemeData(
            color: CinearaColours.lightTextSecondary,
            size: 24,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: CinearaColours.brand700,
              fontSize: CinearaFontSizes.labelMedium,
              fontWeight: FontWeight.w600,
            );
          }

          return const TextStyle(
            color: CinearaColours.lightTextSecondary,
            fontSize: CinearaFontSizes.labelMedium,
            fontWeight: FontWeight.w500,
          );
        }),
      ),

      // -----------------------------------------------------------------------
      // Tablet navigation rail
      // -----------------------------------------------------------------------
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: CinearaColours.lightSurface,
        elevation: 0,
        useIndicator: true,
        indicatorColor: CinearaColours.brand50,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CinearaRadii.lg),
        ),
        minWidth: 80,
        minExtendedWidth: 220,
        selectedIconTheme: const IconThemeData(
          color: CinearaColours.brand700,
          size: 24,
        ),
        unselectedIconTheme: const IconThemeData(
          color: CinearaColours.lightTextSecondary,
          size: 24,
        ),
        selectedLabelTextStyle: const TextStyle(
          color: CinearaColours.brand700,
          fontSize: CinearaFontSizes.bodySmall,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: const TextStyle(
          color: CinearaColours.lightTextSecondary,
          fontSize: CinearaFontSizes.bodySmall,
          fontWeight: FontWeight.w500,
        ),
      ),

      // -----------------------------------------------------------------------
      // Internal tab bars
      // -----------------------------------------------------------------------
      tabBarTheme: TabBarThemeData(
        indicatorColor: CinearaColours.brand600,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: CinearaColours.lightOutline,
        labelColor: CinearaColours.lightTextPrimary,
        unselectedLabelColor: CinearaColours.lightTextSecondary,
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
        fillColor: CinearaColours.lightSurfaceElevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: CinearaSpacing.md,
          vertical: CinearaSpacing.sm,
        ),
        hintStyle: const TextStyle(
          color: CinearaColours.lightTextDisabled,
          fontSize: CinearaFontSizes.bodySmall,
        ),
        labelStyle: const TextStyle(
          color: CinearaColours.lightTextSecondary,
          fontSize: CinearaFontSizes.bodySmall,
        ),
        floatingLabelStyle: const TextStyle(
          color: CinearaColours.brand700,
          fontSize: CinearaFontSizes.bodySmall,
          fontWeight: FontWeight.w500,
        ),
        helperStyle: const TextStyle(
          color: CinearaColours.lightTextSecondary,
          fontSize: CinearaFontSizes.labelMedium,
        ),
        errorStyle: const TextStyle(
          color: CinearaColours.error,
          fontSize: CinearaFontSizes.labelMedium,
        ),
        prefixIconColor: CinearaColours.lightTextSecondary,
        suffixIconColor: CinearaColours.lightTextSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CinearaRadii.md),
          borderSide: const BorderSide(color: CinearaColours.lightOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CinearaRadii.md),
          borderSide: const BorderSide(color: CinearaColours.lightOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CinearaRadii.md),
          borderSide: const BorderSide(
            color: CinearaColours.brand600,
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
          borderSide: const BorderSide(color: CinearaColours.neutral200),
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
              return CinearaColours.neutral200;
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
              return CinearaColours.lightTextDisabled;
            }

            return CinearaColours.onPrimary;
          }),
          overlayColor: WidgetStatePropertyAll<Color>(
            CinearaColours.neutral0.withValues(alpha: 0.10),
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
              return CinearaColours.lightTextDisabled;
            }

            return CinearaColours.brand700;
          }),
          side: WidgetStateProperty.resolveWith<BorderSide>((
            Set<WidgetState> states,
          ) {
            if (states.contains(WidgetState.disabled)) {
              return const BorderSide(color: CinearaColours.neutral200);
            }

            if (states.contains(WidgetState.pressed)) {
              return const BorderSide(color: CinearaColours.brand700);
            }

            return const BorderSide(color: CinearaColours.brand500);
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
              return CinearaColours.lightTextDisabled;
            }

            return CinearaColours.brand700;
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
              return CinearaColours.lightTextDisabled;
            }

            if (states.contains(WidgetState.selected)) {
              return CinearaColours.brand700;
            }

            return CinearaColours.lightTextSecondary;
          }),
          overlayColor: WidgetStatePropertyAll<Color>(
            CinearaColours.brand500.withValues(alpha: 0.08),
          ),
        ),
      ),

      // -----------------------------------------------------------------------
      // Chips
      // -----------------------------------------------------------------------
      chipTheme: ChipThemeData(
        backgroundColor: CinearaColours.lightSurfaceElevated,
        selectedColor: CinearaColours.brand50,
        disabledColor: CinearaColours.neutral100,
        side: const BorderSide(color: CinearaColours.lightOutline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CinearaRadii.pill),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: CinearaSpacing.sm,
          vertical: CinearaSpacing.xxs,
        ),
        labelStyle: const TextStyle(
          color: CinearaColours.lightTextPrimary,
          fontSize: CinearaFontSizes.bodySmall,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: const TextStyle(
          color: CinearaColours.brand700,
          fontSize: CinearaFontSizes.bodySmall,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(
          color: CinearaColours.lightTextSecondary,
          size: 18,
        ),
        checkmarkColor: CinearaColours.brand700,
      ),

      // -----------------------------------------------------------------------
      // List tiles
      // -----------------------------------------------------------------------
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        selectedTileColor: CinearaColours.brand50,
        textColor: CinearaColours.lightTextPrimary,
        selectedColor: CinearaColours.brand700,
        iconColor: CinearaColours.lightTextSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CinearaRadii.md),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: CinearaSpacing.md,
          vertical: CinearaSpacing.xxs,
        ),
        titleTextStyle: const TextStyle(
          color: CinearaColours.lightTextPrimary,
          fontSize: CinearaFontSizes.bodyMedium,
          fontWeight: FontWeight.w500,
        ),
        subtitleTextStyle: const TextStyle(
          color: CinearaColours.lightTextSecondary,
          fontSize: CinearaFontSizes.bodySmall,
          fontWeight: FontWeight.w400,
        ),
      ),

      // -----------------------------------------------------------------------
      // Dividers
      // -----------------------------------------------------------------------
      dividerTheme: const DividerThemeData(
        color: CinearaColours.lightOutline,
        thickness: 1,
        space: 1,
      ),

      // -----------------------------------------------------------------------
      // Progress indicators
      // -----------------------------------------------------------------------
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: CinearaColours.brand600,
        linearTrackColor: CinearaColours.lightOutline,
        circularTrackColor: CinearaColours.lightOutline,
      ),

      // -----------------------------------------------------------------------
      // Sliders
      // -----------------------------------------------------------------------
      sliderTheme: SliderThemeData(
        activeTrackColor: CinearaColours.brand600,
        inactiveTrackColor: CinearaColours.lightOutline,
        thumbColor: CinearaColours.brand500,
        overlayColor: CinearaColours.brand500.withValues(alpha: 0.12),
        valueIndicatorColor: CinearaColours.darkSurface,
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
            return CinearaColours.lightTextDisabled;
          }

          if (states.contains(WidgetState.selected)) {
            return CinearaColours.neutral0;
          }

          return CinearaColours.lightTextSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.disabled)) {
            return CinearaColours.neutral200;
          }

          if (states.contains(WidgetState.selected)) {
            return CinearaColours.brand600;
          }

          return CinearaColours.lightOutline;
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
            return CinearaColours.neutral200;
          }

          if (states.contains(WidgetState.selected)) {
            return CinearaColours.primary;
          }

          return Colors.transparent;
        }),
        checkColor: const WidgetStatePropertyAll<Color>(
          CinearaColours.onPrimary,
        ),
        side: const BorderSide(color: CinearaColours.lightTextSecondary),
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
            return CinearaColours.lightTextDisabled;
          }

          if (states.contains(WidgetState.selected)) {
            return CinearaColours.brand600;
          }

          return CinearaColours.lightTextSecondary;
        }),
      ),

      // -----------------------------------------------------------------------
      // Dialogs
      // -----------------------------------------------------------------------
      dialogTheme: DialogThemeData(
        backgroundColor: CinearaColours.lightSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CinearaRadii.xl),
        ),
        titleTextStyle: const TextStyle(
          color: CinearaColours.lightTextPrimary,
          fontSize: CinearaFontSizes.titleSmall,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        contentTextStyle: const TextStyle(
          color: CinearaColours.lightTextSecondary,
          fontSize: CinearaFontSizes.bodyMedium,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
      ),

      // -----------------------------------------------------------------------
      // Bottom sheets
      // -----------------------------------------------------------------------
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: CinearaColours.lightSurface,
        modalBackgroundColor: CinearaColours.lightSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        modalElevation: 8,
        showDragHandle: true,
        dragHandleColor: CinearaColours.lightTextDisabled,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(CinearaRadii.xl),
          ),
        ),
      ),

      // -----------------------------------------------------------------------
      // Snack bars
      //
      // Snack bars intentionally use an inverse dark surface in light mode
      // so they remain visually distinct from the application background.
      // -----------------------------------------------------------------------
      snackBarTheme: SnackBarThemeData(
        backgroundColor: CinearaColours.neutral900,
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
      //
      // Like snack bars, tooltips use an inverse dark surface to maintain
      // strong contrast over the light application UI.
      // -----------------------------------------------------------------------
      tooltipTheme: TooltipThemeData(
        padding: const EdgeInsets.symmetric(
          horizontal: CinearaSpacing.sm,
          vertical: CinearaSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: CinearaColours.neutral900,
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
        cursorColor: CinearaColours.brand600,
        selectionColor: CinearaColours.brand300.withValues(alpha: 0.30),
        selectionHandleColor: CinearaColours.brand600,
      ),

      // -----------------------------------------------------------------------
      // Cineara-specific semantic colours
      // -----------------------------------------------------------------------
      extensions: const <ThemeExtension<dynamic>>[
        CinearaThemeExtension(
          heroOverlay: CinearaColours.heroOverlay,
          skeletonBase: CinearaColours.neutral100,
          skeletonHighlight: CinearaColours.neutral50,
          progressTrack: CinearaColours.lightOutline,
          posterPlaceholder: CinearaColours.lightSurfaceElevated,
        ),
      ],
    );
  }

  // ===========================================================================
  // Material colour scheme
  // ===========================================================================

  static const ColorScheme _colorScheme = ColorScheme(
    brightness: Brightness.light,

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
    // Cineara's blue logo accent remains the secondary brand accent.
    // -------------------------------------------------------------------------
    secondary: CinearaColours.logoBlue,
    onSecondary: CinearaColours.neutral0,
    secondaryContainer: CinearaColours.brand50,
    onSecondaryContainer: CinearaColours.brand900,

    // -------------------------------------------------------------------------
    // Tertiary
    //
    // Cineara's pink logo accent remains the tertiary brand accent.
    // -------------------------------------------------------------------------
    tertiary: CinearaColours.logoPink,
    onTertiary: CinearaColours.neutral950,
    tertiaryContainer: CinearaColours.brand100,
    onTertiaryContainer: CinearaColours.brand900,

    // -------------------------------------------------------------------------
    // Error
    // -------------------------------------------------------------------------
    error: CinearaColours.error,
    onError: CinearaColours.neutral950,

    // -------------------------------------------------------------------------
    // Surface hierarchy
    //
    // In a light theme:
    //
    // lowest  → brightest / least visually raised
    // highest → stronger neutral separation
    // -------------------------------------------------------------------------
    surface: CinearaColours.lightSurface,
    onSurface: CinearaColours.lightTextPrimary,
    onSurfaceVariant: CinearaColours.lightTextSecondary,

    surfaceDim: CinearaColours.neutral100,
    surfaceBright: CinearaColours.neutral0,

    surfaceContainerLowest: CinearaColours.neutral0,
    surfaceContainerLow: CinearaColours.lightBackground,
    surfaceContainer: CinearaColours.lightSurfaceElevated,
    surfaceContainerHigh: CinearaColours.neutral100,
    surfaceContainerHighest: CinearaColours.neutral200,

    // -------------------------------------------------------------------------
    // Borders
    // -------------------------------------------------------------------------
    outline: CinearaColours.lightOutline,
    outlineVariant: CinearaColours.neutral200,

    // -------------------------------------------------------------------------
    // Inverse surfaces
    // -------------------------------------------------------------------------
    inverseSurface: CinearaColours.darkSurface,
    onInverseSurface: CinearaColours.darkTextPrimary,
    inversePrimary: CinearaColours.brand300,

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

  /// Light-theme typography.
  ///
  /// The light and dark themes intentionally use the same type scale, weights,
  /// line heights and letter spacing. Only semantic text colours differ.
  ///
  /// Cineara defines fewer font-size tokens than Material's [TextTheme]
  /// contains roles. Related Material roles therefore intentionally share
  /// Cineara font-size tokens.
  static const TextTheme _textTheme = TextTheme(
    // -------------------------------------------------------------------------
    // Display
    // -------------------------------------------------------------------------
    displayLarge: TextStyle(
      color: CinearaColours.lightTextPrimary,
      fontSize: CinearaFontSizes.display,
      fontWeight: FontWeight.w700,
      height: 1.10,
      letterSpacing: -0.8,
    ),
    displayMedium: TextStyle(
      color: CinearaColours.lightTextPrimary,
      fontSize: CinearaFontSizes.display,
      fontWeight: FontWeight.w600,
      height: 1.10,
      letterSpacing: -0.6,
    ),
    displaySmall: TextStyle(
      color: CinearaColours.lightTextPrimary,
      fontSize: CinearaFontSizes.titleLarge,
      fontWeight: FontWeight.w700,
      height: 1.15,
      letterSpacing: -0.4,
    ),

    // -------------------------------------------------------------------------
    // Headlines
    // -------------------------------------------------------------------------
    headlineLarge: TextStyle(
      color: CinearaColours.lightTextPrimary,
      fontSize: CinearaFontSizes.titleLarge,
      fontWeight: FontWeight.w700,
      height: 1.20,
    ),
    headlineMedium: TextStyle(
      color: CinearaColours.lightTextPrimary,
      fontSize: CinearaFontSizes.titleMedium,
      fontWeight: FontWeight.w600,
      height: 1.20,
    ),
    headlineSmall: TextStyle(
      color: CinearaColours.lightTextPrimary,
      fontSize: CinearaFontSizes.titleSmall,
      fontWeight: FontWeight.w600,
      height: 1.25,
    ),

    // -------------------------------------------------------------------------
    // Titles
    // -------------------------------------------------------------------------
    titleLarge: TextStyle(
      color: CinearaColours.lightTextPrimary,
      fontSize: CinearaFontSizes.titleMedium,
      fontWeight: FontWeight.w600,
      height: 1.25,
    ),
    titleMedium: TextStyle(
      color: CinearaColours.lightTextPrimary,
      fontSize: CinearaFontSizes.titleSmall,
      fontWeight: FontWeight.w600,
      height: 1.30,
    ),
    titleSmall: TextStyle(
      color: CinearaColours.lightTextPrimary,
      fontSize: CinearaFontSizes.bodyLarge,
      fontWeight: FontWeight.w600,
      height: 1.30,
    ),

    // -------------------------------------------------------------------------
    // Body
    // -------------------------------------------------------------------------
    bodyLarge: TextStyle(
      color: CinearaColours.lightTextPrimary,
      fontSize: CinearaFontSizes.bodyLarge,
      fontWeight: FontWeight.w400,
      height: 1.50,
    ),
    bodyMedium: TextStyle(
      color: CinearaColours.lightTextSecondary,
      fontSize: CinearaFontSizes.bodyMedium,
      fontWeight: FontWeight.w400,
      height: 1.50,
    ),
    bodySmall: TextStyle(
      color: CinearaColours.lightTextSecondary,
      fontSize: CinearaFontSizes.bodySmall,
      fontWeight: FontWeight.w400,
      height: 1.45,
    ),

    // -------------------------------------------------------------------------
    // Labels
    // -------------------------------------------------------------------------
    labelLarge: TextStyle(
      color: CinearaColours.lightTextPrimary,
      fontSize: CinearaFontSizes.bodySmall,
      fontWeight: FontWeight.w600,
      height: 1.30,
    ),
    labelMedium: TextStyle(
      color: CinearaColours.lightTextSecondary,
      fontSize: CinearaFontSizes.labelMedium,
      fontWeight: FontWeight.w600,
      height: 1.30,
    ),
    labelSmall: TextStyle(
      color: CinearaColours.lightTextSecondary,
      fontSize: CinearaFontSizes.labelSmall,
      fontWeight: FontWeight.w500,
      height: 1.30,
    ),
  );
}
