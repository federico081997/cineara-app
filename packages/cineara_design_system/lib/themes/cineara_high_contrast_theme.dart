import 'package:flutter/material.dart';

import '../tokens/colour_tokens.dart';
import '../tokens/radius_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';
import 'theme_extensions.dart';

/// High-contrast Material 3 theme for Cineara.
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
/// The high-contrast theme preserves Cineara's component dimensions, spacing,
/// radii and typography while deliberately increasing luminance separation,
/// border visibility and state differentiation. It uses a near-black blue
/// foundation with bright Cineara accents and explicit component boundaries.
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
abstract final class CinearaHighContrastTheme {
  // ===========================================================================
  // High-contrast semantic palette
  //
  // This theme uses a very dark blue-black foundation with deliberately large
  // luminance steps between surfaces. Outlines and text are substantially
  // brighter than in the standard dark theme so component boundaries remain
  // clear even when elevation/shadows are difficult to perceive.
  // ===========================================================================

  // Near-black blue foundation. Avoiding pure black keeps Cineara's night-time
  // identity while still providing extremely high text contrast.
  static const Color _background = Color(0xFF020713);
  static const Color _surface = Color(0xFF091529);
  static const Color _surfaceElevated = Color(0xFF10213A);
  static const Color _surfaceHigh = Color(0xFF18304F);
  static const Color _surfaceHighest = Color(0xFF244469);

  // High-visibility blue outlines. The strong outline approaches text-level
  // contrast and is used where a boundary is an important interaction cue.
  static const Color _outline = Color(0xFF8FB4E8);
  static const Color _outlineStrong = Color(0xFFD8E7FF);

  static const Color _textPrimary = Color(0xFFFFFFFF);
  static const Color _textSecondary = Color(0xFFDCE8FF);
  static const Color _textDisabled = Color(0xFFA5B4CC);

  // Artwork overlays are intentionally stronger than in standard themes.
  // They sit on unpredictable poster imagery, so the high-contrast variant
  // uses an almost-opaque black surface and a near-white outline.
  static const Color _artworkOverlaySurface = Color(0xF2000000);
  static const Color _artworkOverlayOutline = Color(0xE6FFFFFF);

  // Cineara primary purple is deliberately light in this theme so branded
  // controls and focus states are unambiguous against the dark foundation.
  static const Color _primary = CinearaColours.brand200;
  static const Color _primaryMid = CinearaColours.brand300;
  static const Color _primaryStrong = CinearaColours.brand100;
  static const Color _onPrimary = CinearaColours.brand900;

  static const Color _primaryContainer = Color(0xFF432A5A);
  static const Color _onPrimaryContainer = Color(0xFFF8E9FF);

  // Secondary/tertiary accents are explicit high-contrast variants rather than
  // relying on lower-contrast logo colors.
  static const Color _secondary = Color(0xFF80D8FF);
  static const Color _onSecondary = Color(0xFF051A24);
  static const Color _secondaryContainer = Color(0xFF123448);
  static const Color _onSecondaryContainer = Color(0xFFEAF8FF);

  static const Color _tertiary = Color(0xFFFF9FD2);
  static const Color _onTertiary = Color(0xFF2A071D);
  static const Color _tertiaryContainer = Color(0xFF4A1735);
  static const Color _onTertiaryContainer = Color(0xFFFFF0F8);

  // High-contrast error pair.
  static const Color _error = Color(0xFFFF8A96);
  static const Color _onError = Color(0xFF2B0005);

  // Inverse UI remains light so snack bars, tooltips and value indicators
  // cannot disappear into the high-contrast application surface.
  static const Color _inverseSurface = Color(0xFFF8FBFF);
  static const Color _onInverseSurface = Color(0xFF07101E);
  static const Color _inverseDisabled = Color(0xFF536276);

  // Stronger semantic overlay for text placed directly over hero imagery.
  static const Color _heroOverlay = Color(0xD9000000);

  /// Complete high-contrast theme used by Cineara.
  static ThemeData get theme {
    final ColorScheme colorScheme = _colorScheme;

    return ThemeData(
      // -----------------------------------------------------------------------
      // Material configuration
      // -----------------------------------------------------------------------
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,

      // Cineara explicitly defines its own surface hierarchy.
      applyElevationOverlayColor: false,

      // -----------------------------------------------------------------------
      // Application surfaces
      // -----------------------------------------------------------------------
      scaffoldBackgroundColor: _background,
      canvasColor: _background,
      cardColor: _surface,
      dividerColor: _outline,
      disabledColor: _textDisabled,

      // -----------------------------------------------------------------------
      // Typography
      // -----------------------------------------------------------------------
      textTheme: _textTheme,

      // -----------------------------------------------------------------------
      // Icons
      // -----------------------------------------------------------------------
      iconTheme: const IconThemeData(color: _textSecondary, size: 24),

      // -----------------------------------------------------------------------
      // App bar
      // -----------------------------------------------------------------------
      appBarTheme: const AppBarThemeData(
        backgroundColor: _background,
        foregroundColor: _textPrimary,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: _textPrimary, size: 24),
        actionsIconTheme: IconThemeData(color: _textPrimary, size: 24),
        titleTextStyle: TextStyle(
          color: _textPrimary,
          fontSize: CinearaFontSizes.titleSmall,
          fontWeight: FontWeight.w600,
          height: 1.25,
        ),
      ),

      // -----------------------------------------------------------------------
      // Cards
      // -----------------------------------------------------------------------
      cardTheme: CardThemeData(
        color: _surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.30),
        elevation: 1,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CinearaRadii.lg),
          side: const BorderSide(color: _outline, width: 1.25),
        ),
      ),

      // -----------------------------------------------------------------------
      // Bottom navigation
      // -----------------------------------------------------------------------
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: _surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: _primaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CinearaRadii.lg),
        ),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: _primaryStrong, size: 24);
          }

          return const IconThemeData(color: _textSecondary, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: _primaryStrong,
              fontSize: CinearaFontSizes.labelMedium,
              fontWeight: FontWeight.w700,
            );
          }

          return const TextStyle(
            color: _textSecondary,
            fontSize: CinearaFontSizes.labelMedium,
            fontWeight: FontWeight.w500,
          );
        }),
      ),

      // -----------------------------------------------------------------------
      // Tablet navigation rail
      // -----------------------------------------------------------------------
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: _surface,
        elevation: 0,
        useIndicator: true,
        indicatorColor: _primaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CinearaRadii.lg),
        ),
        minWidth: 80,
        minExtendedWidth: 220,
        selectedIconTheme: const IconThemeData(color: _primaryStrong, size: 24),
        unselectedIconTheme: const IconThemeData(
          color: _textSecondary,
          size: 24,
        ),
        selectedLabelTextStyle: const TextStyle(
          color: _primaryStrong,
          fontSize: CinearaFontSizes.bodySmall,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: const TextStyle(
          color: _textSecondary,
          fontSize: CinearaFontSizes.bodySmall,
          fontWeight: FontWeight.w500,
        ),
      ),

      // -----------------------------------------------------------------------
      // Internal tab bars
      // -----------------------------------------------------------------------
      tabBarTheme: TabBarThemeData(
        indicatorColor: _primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: _outline,
        labelColor: _textPrimary,
        unselectedLabelColor: _textSecondary,
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
        fillColor: _surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: CinearaSpacing.md,
          vertical: CinearaSpacing.sm,
        ),
        hintStyle: const TextStyle(
          color: _textDisabled,
          fontSize: CinearaFontSizes.bodySmall,
        ),
        labelStyle: const TextStyle(
          color: _textSecondary,
          fontSize: CinearaFontSizes.bodySmall,
        ),
        floatingLabelStyle: const TextStyle(
          color: _primaryStrong,
          fontSize: CinearaFontSizes.bodySmall,
          fontWeight: FontWeight.w500,
        ),
        helperStyle: const TextStyle(
          color: _textSecondary,
          fontSize: CinearaFontSizes.labelMedium,
        ),
        errorStyle: const TextStyle(
          color: _error,
          fontSize: CinearaFontSizes.labelMedium,
        ),
        prefixIconColor: _textSecondary,
        suffixIconColor: _textSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CinearaRadii.md),
          borderSide: const BorderSide(color: _outline, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CinearaRadii.md),
          borderSide: const BorderSide(color: _outline, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CinearaRadii.md),
          borderSide: const BorderSide(color: _primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CinearaRadii.md),
          borderSide: const BorderSide(color: _error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CinearaRadii.md),
          borderSide: const BorderSide(color: _error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CinearaRadii.md),
          borderSide: const BorderSide(color: _textDisabled, width: 1.5),
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
              return _surfaceHighest;
            }

            if (states.contains(WidgetState.pressed)) {
              return _primaryStrong;
            }

            return _primary;
          }),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>((
            Set<WidgetState> states,
          ) {
            if (states.contains(WidgetState.disabled)) {
              return _textDisabled;
            }

            return _onPrimary;
          }),
          overlayColor: WidgetStatePropertyAll<Color>(
            _onPrimary.withValues(alpha: 0.16),
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
              return _textDisabled;
            }

            return _primaryStrong;
          }),
          side: WidgetStateProperty.resolveWith<BorderSide>((
            Set<WidgetState> states,
          ) {
            if (states.contains(WidgetState.disabled)) {
              return const BorderSide(color: _textDisabled, width: 1.5);
            }

            if (states.contains(WidgetState.pressed)) {
              return const BorderSide(color: _primaryStrong, width: 2);
            }

            return const BorderSide(color: _primaryMid, width: 1.5);
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
              return _textDisabled;
            }

            return _primaryStrong;
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
              return _textDisabled;
            }

            if (states.contains(WidgetState.selected)) {
              return _primaryStrong;
            }

            return _textSecondary;
          }),
          overlayColor: WidgetStatePropertyAll<Color>(
            _primary.withValues(alpha: 0.18),
          ),
        ),
      ),

      // -----------------------------------------------------------------------
      // Chips
      // -----------------------------------------------------------------------
      chipTheme: ChipThemeData(
        backgroundColor: _surfaceElevated,
        selectedColor: _primaryContainer,
        disabledColor: _surfaceHigh,
        side: const BorderSide(color: _outline, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CinearaRadii.pill),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: CinearaSpacing.sm,
          vertical: CinearaSpacing.xxs,
        ),
        labelStyle: const TextStyle(
          color: _textPrimary,
          fontSize: CinearaFontSizes.bodySmall,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: const TextStyle(
          color: _primaryStrong,
          fontSize: CinearaFontSizes.bodySmall,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: _textSecondary, size: 18),
        checkmarkColor: _primaryStrong,
      ),

      // -----------------------------------------------------------------------
      // List tiles
      // -----------------------------------------------------------------------
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        selectedTileColor: _primaryContainer,
        textColor: _textPrimary,
        selectedColor: _primaryStrong,
        iconColor: _textSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CinearaRadii.md),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: CinearaSpacing.md,
          vertical: CinearaSpacing.xxs,
        ),
        titleTextStyle: const TextStyle(
          color: _textPrimary,
          fontSize: CinearaFontSizes.bodyMedium,
          fontWeight: FontWeight.w500,
        ),
        subtitleTextStyle: const TextStyle(
          color: _textSecondary,
          fontSize: CinearaFontSizes.bodySmall,
          fontWeight: FontWeight.w400,
        ),
      ),

      // -----------------------------------------------------------------------
      // Dividers
      // -----------------------------------------------------------------------
      dividerTheme: const DividerThemeData(
        color: _outline,
        thickness: 1,
        space: 1,
      ),

      // -----------------------------------------------------------------------
      // Progress indicators
      // -----------------------------------------------------------------------
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _primary,
        linearTrackColor: _outline,
        circularTrackColor: _outline,
      ),

      // -----------------------------------------------------------------------
      // Sliders
      // -----------------------------------------------------------------------
      sliderTheme: SliderThemeData(
        activeTrackColor: _primary,
        inactiveTrackColor: _outline,
        thumbColor: _primaryMid,
        overlayColor: _primary.withValues(alpha: 0.20),
        valueIndicatorColor: _inverseSurface,
        valueIndicatorTextStyle: const TextStyle(
          color: _onInverseSurface,
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
            return _textDisabled;
          }

          if (states.contains(WidgetState.selected)) {
            return _onPrimary;
          }

          // Dark thumb against the bright unselected track preserves the
          // switch boundary without relying on hue alone.
          return _background;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.disabled)) {
            return _surfaceHighest;
          }

          if (states.contains(WidgetState.selected)) {
            return _primary;
          }

          return _outlineStrong;
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
            return _surfaceHighest;
          }

          if (states.contains(WidgetState.selected)) {
            return _primary;
          }

          return Colors.transparent;
        }),
        checkColor: const WidgetStatePropertyAll<Color>(_onPrimary),
        side: const BorderSide(color: _textSecondary, width: 2),
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
            return _textDisabled;
          }

          if (states.contains(WidgetState.selected)) {
            return _primary;
          }

          return _textSecondary;
        }),
      ),

      // -----------------------------------------------------------------------
      // Dialogs
      // -----------------------------------------------------------------------
      dialogTheme: DialogThemeData(
        backgroundColor: _surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.36),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CinearaRadii.xl),
          side: const BorderSide(color: _outlineStrong, width: 1.5),
        ),
        titleTextStyle: const TextStyle(
          color: _textPrimary,
          fontSize: CinearaFontSizes.titleSmall,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        contentTextStyle: const TextStyle(
          color: _textSecondary,
          fontSize: CinearaFontSizes.bodyMedium,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
      ),

      // -----------------------------------------------------------------------
      // Bottom sheets
      // -----------------------------------------------------------------------
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: _surface,
        modalBackgroundColor: _surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        modalElevation: 8,
        showDragHandle: true,
        dragHandleColor: _textDisabled,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(CinearaRadii.xl),
          ),
          side: BorderSide(color: _outlineStrong, width: 1.5),
        ),
      ),

      // -----------------------------------------------------------------------
      // Snack bars
      //
      // Snack bars intentionally use an inverse light surface in high-contrast mode
      // so they remain visually distinct from the application background.
      // -----------------------------------------------------------------------
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _inverseSurface,
        contentTextStyle: const TextStyle(
          color: _onInverseSurface,
          fontSize: CinearaFontSizes.bodySmall,
        ),
        actionTextColor: CinearaColours.brand800,
        disabledActionTextColor: _inverseDisabled,
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
      // Like snack bars, tooltips use an inverse light surface to maintain
      // strong contrast over the high-contrast application UI.
      // -----------------------------------------------------------------------
      tooltipTheme: TooltipThemeData(
        padding: const EdgeInsets.symmetric(
          horizontal: CinearaSpacing.sm,
          vertical: CinearaSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: _inverseSurface,
          borderRadius: BorderRadius.circular(CinearaRadii.sm),
        ),
        textStyle: const TextStyle(
          color: _onInverseSurface,
          fontSize: CinearaFontSizes.labelMedium,
          fontWeight: FontWeight.w500,
        ),
      ),

      // -----------------------------------------------------------------------
      // Text selection
      // -----------------------------------------------------------------------
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: _primary,
        selectionColor: _primary.withValues(alpha: 0.42),
        selectionHandleColor: _primary,
      ),

      // -----------------------------------------------------------------------
      // Cineara-specific semantic colours
      // -----------------------------------------------------------------------
      extensions: const <ThemeExtension<dynamic>>[
        CinearaThemeExtension(
          heroOverlay: _heroOverlay,
          skeletonBase: _surfaceHigh,
          skeletonHighlight: _surface,
          progressTrack: _outline,
          posterPlaceholder: _surfaceElevated,
          artworkOverlaySurface: _artworkOverlaySurface,
          artworkOverlayOutline: _artworkOverlayOutline,
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
    primary: _primary,
    onPrimary: _onPrimary,
    primaryContainer: _primaryContainer,
    onPrimaryContainer: _onPrimaryContainer,

    // -------------------------------------------------------------------------
    // Secondary
    //
    // Bright cyan provides a clearly separated secondary accent.
    // -------------------------------------------------------------------------
    secondary: _secondary,
    onSecondary: _onSecondary,
    secondaryContainer: _secondaryContainer,
    onSecondaryContainer: _onSecondaryContainer,

    // -------------------------------------------------------------------------
    // Tertiary
    //
    // Bright pink provides a clearly separated tertiary accent.
    // -------------------------------------------------------------------------
    tertiary: _tertiary,
    onTertiary: _onTertiary,
    tertiaryContainer: _tertiaryContainer,
    onTertiaryContainer: _onTertiaryContainer,

    // -------------------------------------------------------------------------
    // Error
    // -------------------------------------------------------------------------
    error: _error,
    onError: _onError,

    // -------------------------------------------------------------------------
    // Surface hierarchy
    //
    // In the high-contrast dark theme:
    //
    // lowest  → darkest / visually closest to the background
    // highest → lighter blue surface / strongest elevation separation
    // -------------------------------------------------------------------------
    surface: _surface,
    onSurface: _textPrimary,
    onSurfaceVariant: _textSecondary,

    surfaceDim: _background,
    surfaceBright: _surfaceHighest,

    surfaceContainerLowest: _background,
    surfaceContainerLow: _surface,
    surfaceContainer: _surfaceElevated,
    surfaceContainerHigh: _surfaceHigh,
    surfaceContainerHighest: _surfaceHighest,

    // -------------------------------------------------------------------------
    // Borders
    // -------------------------------------------------------------------------
    outline: _outlineStrong,
    outlineVariant: _outline,

    // -------------------------------------------------------------------------
    // Inverse surfaces
    // -------------------------------------------------------------------------
    inverseSurface: _inverseSurface,
    onInverseSurface: _onInverseSurface,
    inversePrimary: CinearaColours.brand700,

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

  /// High-contrast-theme typography.
  ///
  /// The dark and light themes intentionally use the same type scale, weights,
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
      color: _textPrimary,
      fontSize: CinearaFontSizes.display,
      fontWeight: FontWeight.w700,
      height: 1.10,
      letterSpacing: -0.8,
    ),
    displayMedium: TextStyle(
      color: _textPrimary,
      fontSize: CinearaFontSizes.display,
      fontWeight: FontWeight.w600,
      height: 1.10,
      letterSpacing: -0.6,
    ),
    displaySmall: TextStyle(
      color: _textPrimary,
      fontSize: CinearaFontSizes.titleLarge,
      fontWeight: FontWeight.w700,
      height: 1.15,
      letterSpacing: -0.4,
    ),

    // -------------------------------------------------------------------------
    // Headlines
    // -------------------------------------------------------------------------
    headlineLarge: TextStyle(
      color: _textPrimary,
      fontSize: CinearaFontSizes.titleLarge,
      fontWeight: FontWeight.w700,
      height: 1.20,
    ),
    headlineMedium: TextStyle(
      color: _textPrimary,
      fontSize: CinearaFontSizes.titleMedium,
      fontWeight: FontWeight.w600,
      height: 1.20,
    ),
    headlineSmall: TextStyle(
      color: _textPrimary,
      fontSize: CinearaFontSizes.titleSmall,
      fontWeight: FontWeight.w600,
      height: 1.25,
    ),

    // -------------------------------------------------------------------------
    // Titles
    // -------------------------------------------------------------------------
    titleLarge: TextStyle(
      color: _textPrimary,
      fontSize: CinearaFontSizes.titleMedium,
      fontWeight: FontWeight.w600,
      height: 1.25,
    ),
    titleMedium: TextStyle(
      color: _textPrimary,
      fontSize: CinearaFontSizes.titleSmall,
      fontWeight: FontWeight.w600,
      height: 1.30,
    ),
    titleSmall: TextStyle(
      color: _textPrimary,
      fontSize: CinearaFontSizes.bodyLarge,
      fontWeight: FontWeight.w600,
      height: 1.30,
    ),

    // -------------------------------------------------------------------------
    // Body
    // -------------------------------------------------------------------------
    bodyLarge: TextStyle(
      color: _textPrimary,
      fontSize: CinearaFontSizes.bodyLarge,
      fontWeight: FontWeight.w400,
      height: 1.50,
    ),
    bodyMedium: TextStyle(
      color: _textSecondary,
      fontSize: CinearaFontSizes.bodyMedium,
      fontWeight: FontWeight.w400,
      height: 1.50,
    ),
    bodySmall: TextStyle(
      color: _textSecondary,
      fontSize: CinearaFontSizes.bodySmall,
      fontWeight: FontWeight.w400,
      height: 1.45,
    ),

    // -------------------------------------------------------------------------
    // Labels
    // -------------------------------------------------------------------------
    labelLarge: TextStyle(
      color: _textPrimary,
      fontSize: CinearaFontSizes.bodySmall,
      fontWeight: FontWeight.w600,
      height: 1.30,
    ),
    labelMedium: TextStyle(
      color: _textSecondary,
      fontSize: CinearaFontSizes.labelMedium,
      fontWeight: FontWeight.w600,
      height: 1.30,
    ),
    labelSmall: TextStyle(
      color: _textSecondary,
      fontSize: CinearaFontSizes.labelSmall,
      fontWeight: FontWeight.w500,
      height: 1.30,
    ),
  );

  /// Decorative Cineara gradient for small high-contrast accents.
  ///
  /// Keep this for branded details rather than generic surfaces.
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[_tertiary, _primary, _secondary],
  );
}
