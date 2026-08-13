import 'package:flutter/material.dart';

import '../tokens/colour_tokens.dart';
import '../tokens/radius_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';
import 'theme_extensions.dart';

/// Warm light Material 3 theme for Cineara.
///
/// Sunrise keeps the same component geometry, spacing, radii and typography as
/// the standard light theme, but replaces its cool lavender surface hierarchy
/// with a warm dawn-inspired palette:
///
/// - cream / blush application backgrounds;
/// - peach-tinted elevated surfaces;
/// - coral-rose primary actions;
/// - amber secondary accents;
/// - restrained Cineara violet as the tertiary accent.
///
/// Feature widgets should continue to read colours from:
///
/// ```dart
/// Theme.of(context).colorScheme
/// Theme.of(context).textTheme
/// ```
///
/// Cineara-specific semantic colours remain available through
/// [CinearaThemeExtension].
abstract final class CinearaSunriseTheme {
  // ===========================================================================
  // Sunrise palette
  //
  // A warm, luminous Cineara palette built around soft cream surfaces, sunrise
  // rose, peach and amber tones. The hierarchy is intentionally gentle and
  // inviting, with enough contrast for clear interaction states while avoiding
  // an overly saturated or orange appearance.
  //
  // Violet remains available only as a restrained Cineara signature accent, while
  // the overall atmosphere stays warm, soft and distinct from the default Light
  // and Dark themes.
  // ===========================================================================

  static const Color _background = Color(0xFFFFF5EE);
  static const Color _surface = Color(0xFFFFFBF8);
  static const Color _surfaceElevated = Color(0xFFFFEDE4);
  static const Color _surfaceHigh = Color(0xFFF9DED3);
  static const Color _surfaceHighest = Color(0xFFF4D2C5);

  static const Color _outline = Color(0xFFDFC2B8);
  static const Color _outlineStrong = Color(0xFFCDA99D);

  static const Color _textPrimary = Color(0xFF2B1B22);
  static const Color _textSecondary = Color(0xFF6F5860);
  static const Color _textDisabled = Color(0xFFA58E94);

  static const Color _artworkOverlaySurface = Color(0xB8000000);
  static const Color _artworkOverlayOutline = Color(0x47FFFFFF);

  // Dark enough to keep white text comfortably readable.
  static const Color _primary = Color(0xFFB53B58);
  static const Color _primaryPressed = Color(0xFF963047);
  static const Color _onPrimary = Color(0xFFFFFFFF);
  static const Color _primaryContainer = Color(0xFFFFD9D6);
  static const Color _onPrimaryContainer = Color(0xFF4C1021);

  static const Color _secondary = Color(0xFFD5743C);
  static const Color _onSecondary = Color(0xFF351808);
  static const Color _secondaryContainer = Color(0xFFFFE6C7);
  static const Color _onSecondaryContainer = Color(0xFF4A270A);

  // Keeps Cineara's existing purple identity visible inside the warm theme.
  static const Color _tertiary = CinearaColours.logoViolet;
  static const Color _onTertiary = Color(0xFFFFFFFF);
  static const Color _tertiaryContainer = Color(0xFFEADFFF);
  static const Color _onTertiaryContainer = Color(0xFF2C175A);

  static const Color _sunrisePeach = Color(0xFFFF9D7A);
  static const Color _sunriseGold = Color(0xFFF0A34A);
  static const Color _sunriseRose = Color(0xFFE86368);

  static const Color _inverseSurface = Color(0xFF35232A);
  static const Color _onInverseSurface = Color(0xFFFFF5F0);

  /// Complete Sunrise theme used by Cineara.
  static ThemeData get theme {
    final ColorScheme colorScheme = _colorScheme;

    return ThemeData(
      // -----------------------------------------------------------------------
      // Material configuration
      // -----------------------------------------------------------------------
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
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
        shadowColor: const Color(0x262F1520),
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
        indicatorColor: _primaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CinearaRadii.lg),
        ),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: _primary, size: 24);
          }

          return const IconThemeData(color: _textSecondary, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: _primary,
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
        indicatorColor: _primaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CinearaRadii.lg),
        ),
        minWidth: 80,
        minExtendedWidth: 220,
        selectedIconTheme: const IconThemeData(color: _primary, size: 24),
        unselectedIconTheme: const IconThemeData(
          color: _textSecondary,
          size: 24,
        ),
        selectedLabelTextStyle: const TextStyle(
          color: _primary,
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
          color: _primary,
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
              return _primaryPressed;
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
            Colors.white.withValues(alpha: 0.10),
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

            return _primary;
          }),
          side: WidgetStateProperty.resolveWith<BorderSide>((
            Set<WidgetState> states,
          ) {
            if (states.contains(WidgetState.disabled)) {
              return const BorderSide(color: _surfaceHighest);
            }

            if (states.contains(WidgetState.pressed)) {
              return const BorderSide(color: _primaryPressed);
            }

            return const BorderSide(color: _primary);
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

            return _primary;
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
              return _primary;
            }

            return _textSecondary;
          }),
          overlayColor: WidgetStatePropertyAll<Color>(
            _primary.withValues(alpha: 0.08),
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
          color: _primary,
          fontSize: CinearaFontSizes.bodySmall,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: _textSecondary, size: 18),
        checkmarkColor: _primary,
      ),

      // -----------------------------------------------------------------------
      // List tiles
      // -----------------------------------------------------------------------
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        selectedTileColor: _primaryContainer,
        textColor: _textPrimary,
        selectedColor: _primary,
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
        linearTrackColor: _surfaceHigh,
        circularTrackColor: _surfaceHigh,
      ),

      // -----------------------------------------------------------------------
      // Sliders
      // -----------------------------------------------------------------------
      sliderTheme: SliderThemeData(
        activeTrackColor: _primary,
        inactiveTrackColor: _surfaceHigh,
        thumbColor: _sunriseRose,
        overlayColor: _sunriseRose.withValues(alpha: 0.14),
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
            return Colors.white;
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
        shadowColor: const Color(0x332F1520),
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
      // -----------------------------------------------------------------------
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _inverseSurface,
        contentTextStyle: const TextStyle(
          color: _onInverseSurface,
          fontSize: CinearaFontSizes.bodySmall,
        ),
        actionTextColor: const Color(0xFFFFC2AF),
        disabledActionTextColor: _textDisabled,
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
        selectionColor: _sunriseRose.withValues(alpha: 0.24),
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
    brightness: Brightness.light,

    // Primary: sunrise rose.
    primary: _primary,
    onPrimary: _onPrimary,
    primaryContainer: _primaryContainer,
    onPrimaryContainer: _onPrimaryContainer,

    // Secondary: warm amber.
    secondary: _secondary,
    onSecondary: _onSecondary,
    secondaryContainer: _secondaryContainer,
    onSecondaryContainer: _onSecondaryContainer,

    // Tertiary: Cineara violet.
    tertiary: _tertiary,
    onTertiary: _onTertiary,
    tertiaryContainer: _tertiaryContainer,
    onTertiaryContainer: _onTertiaryContainer,

    // Error.
    error: CinearaColours.error,
    onError: Colors.white,

    // Warm surface hierarchy.
    surface: _surface,
    onSurface: _textPrimary,
    onSurfaceVariant: _textSecondary,

    surfaceDim: _surfaceHigh,
    surfaceBright: _surface,

    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: _background,
    surfaceContainer: _surfaceElevated,
    surfaceContainerHigh: _surfaceHigh,
    surfaceContainerHighest: _surfaceHighest,

    // Borders.
    outline: _outlineStrong,
    outlineVariant: _outline,

    // Inverse surfaces.
    inverseSurface: _inverseSurface,
    onInverseSurface: _onInverseSurface,
    inversePrimary: Color(0xFFFFB3B9),

    // Miscellaneous.
    shadow: Colors.black,
    scrim: Colors.black,
    surfaceTint: Colors.transparent,
  );

  // ===========================================================================
  // Typography
  // ===========================================================================

  /// Sunrise uses the same type scale and weights as the other Cineara themes.
  ///
  /// Only semantic text colours change.
  static const TextTheme _textTheme = TextTheme(
    // Display
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

    // Headlines
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

    // Titles
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

    // Body
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

    // Labels
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

  /// Optional decorative gradient for Sunrise-specific surfaces.
  ///
  /// Do not use this as a generic card background. It is intended for hero
  /// accents, selected theme previews and small branded details.
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      _sunrisePeach,
      _sunriseRose,
      CinearaColours.logoViolet,
      _sunriseGold,
    ],
    stops: <double>[0.0, 0.38, 0.72, 1.0],
  );
}
