import 'package:flutter/material.dart';

import '../tokens/colour_tokens.dart';
import '../tokens/radius_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';
import 'theme_extensions.dart';

/// Aurora Material 3 theme for Cineara.
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
/// The Aurora theme preserves the same component dimensions, spacing, radii
/// and typography as the other Cineara themes. Its visual identity combines a
/// deep teal-midnight surface hierarchy with luminous cyan, violet and pink
/// accents inspired by auroral light, while keeping strong contrast between
/// backgrounds, surfaces, controls and text.
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
abstract final class CinearaAuroraTheme {
  // ===========================================================================
  // Aurora semantic palette
  //
  // Aurora is intentionally a dark theme, but it is not a recoloured copy of
  // Cineara Dark. The base surfaces lean toward deep midnight teal, while
  // cyan, violet and pink provide the luminous brand accents. Surface steps
  // become progressively brighter so cards, fields and elevated containers
  // remain clearly distinguishable.
  // ===========================================================================

  static const Color _background = Color(0xFF061016);
  static const Color _surface = Color(0xFF0D1D26);
  static const Color _surfaceElevated = Color(0xFF152B37);
  static const Color _surfaceHigh = Color(0xFF1D3947);
  static const Color _surfaceHighest = Color(0xFF294A59);

  static const Color _outline = Color(0xFF315968);
  static const Color _outlineStrong = Color(0xFF4D7B89);

  static const Color _textPrimary = Color(0xFFF4FCFC);
  static const Color _textSecondary = Color(0xFFB8D4D8);
  static const Color _textDisabled = Color(0xFF76969C);

  // Artwork overlays depend on the image underneath rather than the app theme.
  // A dedicated high-contrast theme can override these extension values.
  static const Color _artworkOverlaySurface = Color(0xB8000000);
  static const Color _artworkOverlayOutline = Color(0x47FFFFFF);

  // Aurora's primary accent is luminous cyan. The darker foreground provides
  // strong contrast on filled controls, while the lighter strong variant keeps
  // selected navigation and focus states visible against dark surfaces.
  static const Color _primary = Color(0xFF63D9E2);
  static const Color _primaryMid = Color(0xFF3FC3CF);
  static const Color _primaryStrong = Color(0xFF9AEFF0);
  static const Color _onPrimary = Color(0xFF003238);

  static const Color _primaryContainer = Color(0xFF123A42);
  static const Color _primaryContainerSoft = Color(0xFF0B2A31);
  static const Color _onPrimaryContainer = Color(0xFFC5FAFA);

  // Violet and pink complete the aurora spectrum without competing with cyan
  // for primary actions. Each container has its own high-contrast foreground.
  static const Color _secondary = Color(0xFFB997FF);
  static const Color _onSecondary = Color(0xFF241137);
  static const Color _secondaryContainer = Color(0xFF33254B);
  static const Color _onSecondaryContainer = Color(0xFFEBDDFF);

  static const Color _tertiary = Color(0xFFFF91C7);
  static const Color _onTertiary = Color(0xFF3B1128);
  static const Color _tertiaryContainer = Color(0xFF49243B);
  static const Color _onTertiaryContainer = Color(0xFFFFE0EF);

  // Inverse surfaces are intentionally light so transient UI remains obvious
  // above the dark aurora hierarchy.
  static const Color _inverseSurface = Color(0xFFF4FCFC);
  static const Color _onInverseSurface = Color(0xFF122126);
  static const Color _inverseDisabled = Color(0xFF7D9297);
  static const Color _inversePrimary = Color(0xFF00666C);

  /// Complete Aurora theme used by Cineara.
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
        indicatorColor: _primaryContainerSoft,
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
              fontWeight: FontWeight.w600,
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
        indicatorColor: _primaryContainerSoft,
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
          color: CinearaColours.error,
          fontSize: CinearaFontSizes.labelMedium,
        ),
        prefixIconColor: _textSecondary,
        suffixIconColor: _textSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CinearaRadii.md),
          borderSide: const BorderSide(color: _outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CinearaRadii.md),
          borderSide: const BorderSide(color: _outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CinearaRadii.md),
          borderSide: const BorderSide(color: _primary, width: 1.5),
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
          borderSide: const BorderSide(color: _surfaceHighest),
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
              return _textDisabled;
            }

            return _primaryStrong;
          }),
          side: WidgetStateProperty.resolveWith<BorderSide>((
            Set<WidgetState> states,
          ) {
            if (states.contains(WidgetState.disabled)) {
              return const BorderSide(color: _surfaceHighest);
            }

            if (states.contains(WidgetState.pressed)) {
              return const BorderSide(color: _primaryStrong);
            }

            return const BorderSide(color: _primaryMid);
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
            _primaryMid.withValues(alpha: 0.08),
          ),
        ),
      ),

      // -----------------------------------------------------------------------
      // Chips
      // -----------------------------------------------------------------------
      chipTheme: ChipThemeData(
        backgroundColor: _surfaceElevated,
        selectedColor: _primaryContainerSoft,
        disabledColor: _surfaceHigh,
        side: const BorderSide(color: _outline),
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
        selectedTileColor: _primaryContainerSoft,
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
        overlayColor: _primaryMid.withValues(alpha: 0.12),
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
            return CinearaColours.neutral0;
          }

          return _textSecondary;
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

          return _outline;
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
        side: const BorderSide(color: _textSecondary),
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
        ),
      ),

      // -----------------------------------------------------------------------
      // Snack bars
      //
      // Snack bars intentionally use an inverse light surface in Aurora
      // so they remain visually distinct from the application background.
      // -----------------------------------------------------------------------
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _inverseSurface,
        contentTextStyle: const TextStyle(
          color: _onInverseSurface,
          fontSize: CinearaFontSizes.bodySmall,
        ),
        actionTextColor: _inversePrimary,
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
      // strong contrast over the Aurora application UI.
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
        selectionColor: _primary.withValues(alpha: 0.32),
        selectionHandleColor: _primary,
      ),

      // -----------------------------------------------------------------------
      // Cineara-specific semantic colours
      // -----------------------------------------------------------------------
      extensions: const <ThemeExtension<dynamic>>[
        CinearaThemeExtension(
          heroOverlay: CinearaColours.heroOverlay,
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
    // Violet provides Aurora's secondary spectral accent.
    // -------------------------------------------------------------------------
    secondary: _secondary,
    onSecondary: _onSecondary,
    secondaryContainer: _secondaryContainer,
    onSecondaryContainer: _onSecondaryContainer,

    // -------------------------------------------------------------------------
    // Tertiary
    //
    // Pink provides Aurora's tertiary spectral accent.
    // -------------------------------------------------------------------------
    tertiary: _tertiary,
    onTertiary: _onTertiary,
    tertiaryContainer: _tertiaryContainer,
    onTertiaryContainer: _onTertiaryContainer,

    // -------------------------------------------------------------------------
    // Error
    // -------------------------------------------------------------------------
    error: CinearaColours.error,
    onError: CinearaColours.neutral0,

    // -------------------------------------------------------------------------
    // Surface hierarchy
    //
    // In the Aurora dark theme:
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
    inversePrimary: _inversePrimary,

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

  /// Aurora-theme typography.
  ///
  /// Aurora and the other Cineara themes intentionally use the same type scale, weights,
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

  /// Decorative aurora gradient for small branded accents.
  ///
  /// Keep this for branded details rather than generic surfaces.
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[_tertiary, _secondary, _primary],
  );
}
