import 'package:flutter/material.dart';

import '../shapes/cineara_shapes.dart';
import '../tokens/colour.dart';
import '../tokens/elevation.dart';
import '../tokens/geometry.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'theme_extensions.dart';

/// Builds the shared Material 3 configuration used by Cineara themes.
///
/// Individual themes provide their own [ColorScheme]. Shared component styling
/// is defined here so every Cineara theme follows the same visual language,
/// interaction model, and accessibility behaviour.
///
/// Cineara's visual language combines:
///
/// - restrained Material 3 foundations;
/// - semantic colour and typography;
/// - soft continuous geometry for substantial interface surfaces;
/// - conventional rounded geometry for controls and artwork;
/// - capsule geometry for filters and selected-state indicators;
/// - circular geometry for inherently round controls and identity elements;
/// - restrained elevation;
/// - strengthened boundaries in high-contrast themes.
///
/// Cineara's more distinctive continuous geometry is intentionally reserved for
/// substantial surfaces such as cards, dialogs, and major content panels.
/// Controls, artwork, chips, inputs, and navigation use simpler geometry so the
/// interface remains familiar, balanced, and visually calm.
///
/// When [highContrast] is enabled, boundaries, focus states, selection states,
/// and other important visual distinctions are strengthened without changing
/// the fundamental structure of the design system.
abstract final class CinearaThemeBuilder {
  /// Builds a Cineara [ThemeData] from [colorScheme].
  ///
  /// [extension] may be supplied by a theme when it requires custom
  /// Cineara-specific semantic colours. Otherwise a suitable extension is
  /// derived automatically from [colorScheme].
  static ThemeData build({
    required ColorScheme colorScheme,
    CinearaThemeExtension? extension,
    bool highContrast = false,
  }) {
    final isDark = colorScheme.brightness == Brightness.dark;

    // -------------------------------------------------------------------------
    // Borders
    // -------------------------------------------------------------------------

    final borderWidth = highContrast ? 1.25 : 1.0;
    final strongBorderWidth = highContrast ? 1.5 : 1.0;
    final focusBorderWidth = highContrast ? 2.0 : 1.5;
    final dividerThickness = highContrast ? 1.5 : 1.0;

    // -------------------------------------------------------------------------
    // Surfaces
    // -------------------------------------------------------------------------

    final pageBackground = isDark
        ? colorScheme.surfaceContainerLowest
        : colorScheme.surfaceContainerLow;

    final cardBackground = isDark
        ? colorScheme.surfaceContainerLow
        : colorScheme.surface;

    final inputBackground = isDark
        ? colorScheme.surfaceContainer
        : colorScheme.surface;

    // -------------------------------------------------------------------------
    // Disabled content
    // -------------------------------------------------------------------------

    final disabledForeground = colorScheme.onSurface.withValues(
      alpha: highContrast ? 0.52 : 0.38,
    );

    final disabledOutline = colorScheme.outlineVariant.withValues(
      alpha: highContrast ? 0.80 : 0.55,
    );

    // -------------------------------------------------------------------------
    // Cineara-specific colours
    // -------------------------------------------------------------------------

    final cinearaExtension =
        extension ?? _buildExtension(colorScheme, highContrast: highContrast);

    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      applyElevationOverlayColor: false,

      // -----------------------------------------------------------------------
      // Accessibility
      // -----------------------------------------------------------------------
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,

      // -----------------------------------------------------------------------
      // Global
      // -----------------------------------------------------------------------
      scaffoldBackgroundColor: pageBackground,
      canvasColor: pageBackground,
      cardColor: cardBackground,
      dividerColor: highContrast
          ? colorScheme.outline
          : colorScheme.outlineVariant,
      disabledColor: disabledForeground,

      // -----------------------------------------------------------------------
      // Interaction
      // -----------------------------------------------------------------------
      focusColor: colorScheme.primary.withValues(
        alpha: _focusOpacity(isDark: isDark, highContrast: highContrast),
      ),
      hoverColor: colorScheme.primary.withValues(
        alpha: _hoverOpacity(isDark: isDark, highContrast: highContrast),
      ),
      highlightColor: colorScheme.primary.withValues(
        alpha: _highlightOpacity(isDark: isDark, highContrast: highContrast),
      ),
      splashColor: colorScheme.primary.withValues(
        alpha: _splashOpacity(isDark: isDark, highContrast: highContrast),
      ),

      // -----------------------------------------------------------------------
      // Typography
      // -----------------------------------------------------------------------
      textTheme: _textTheme(colorScheme),

      // -----------------------------------------------------------------------
      // Icons
      // -----------------------------------------------------------------------
      iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant, size: 24),

      // -----------------------------------------------------------------------
      // App bar
      //
      // Root-page branding and application-specific layout are controlled by
      // CinearaTopAppBar. This theme provides coherent Material defaults for
      // contextual and secondary app bars.
      // -----------------------------------------------------------------------
      appBarTheme: AppBarThemeData(
        backgroundColor: isDark
            ? colorScheme.surfaceContainerLowest
            : colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: CinearaElevation.none,
        scrolledUnderElevation: CinearaElevation.none,
        centerTitle: false,
        iconTheme: IconThemeData(color: colorScheme.onSurface, size: 24),
        actionsIconTheme: IconThemeData(color: colorScheme.onSurface, size: 24),
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: CinearaFontSizes.titleSmall,
          fontWeight: FontWeight.w700,
          height: 1.20,
          letterSpacing: -0.1,
        ),
      ),

      // -----------------------------------------------------------------------
      // Cards
      //
      // Standard cards use Cineara's soft continuous geometry while relying
      // primarily on surface contrast and borders rather than strong shadows.
      // -----------------------------------------------------------------------
      cardTheme: CardThemeData(
        color: cardBackground,
        surfaceTintColor: Colors.transparent,
        shadowColor: _shadowColor(
          colorScheme,
          isDark: isDark,
          highContrast: highContrast,
          lightOpacity: 0.06,
          darkOpacity: 0.24,
        ),
        elevation: highContrast ? CinearaElevation.none : CinearaElevation.card,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: CinearaShapes.card(
          side: BorderSide(
            color: highContrast
                ? colorScheme.outline
                : colorScheme.outlineVariant.withValues(
                    alpha: isDark ? 0.75 : 0.70,
                  ),
            width: highContrast ? borderWidth : 0.75,
          ),
        ),
      ),

      // -----------------------------------------------------------------------
      // Material navigation bar
      //
      // Cineara's primary shell provide its own navigation component.
      // These defaults keep standard Material NavigationBar instances visually
      // consistent wherever they are used.
      // -----------------------------------------------------------------------
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: CinearaElevation.none,
        backgroundColor: cardBackground,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        indicatorColor: colorScheme.primaryContainer,
        indicatorShape: CinearaShapes.navigationIndicator(
          side: highContrast
              ? BorderSide(color: colorScheme.primary, width: borderWidth)
              : BorderSide.none,
        ),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
          final selected = states.contains(WidgetState.selected);

          return IconThemeData(
            color: selected
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
            size: 24,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
          final selected = states.contains(WidgetState.selected);

          return TextStyle(
            color: selected
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
            fontSize: CinearaFontSizes.labelMedium,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
      ),

      // -----------------------------------------------------------------------
      // Navigation rail
      // -----------------------------------------------------------------------
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: cardBackground,
        elevation: CinearaElevation.none,
        useIndicator: true,
        indicatorColor: colorScheme.primaryContainer,
        indicatorShape: CinearaShapes.navigationIndicator(
          side: highContrast
              ? BorderSide(color: colorScheme.primary, width: borderWidth)
              : BorderSide.none,
        ),
        minWidth: 80,
        minExtendedWidth: 220,
        selectedIconTheme: IconThemeData(color: colorScheme.primary, size: 24),
        unselectedIconTheme: IconThemeData(
          color: colorScheme.onSurfaceVariant,
          size: 24,
        ),
        selectedLabelTextStyle: TextStyle(
          color: colorScheme.primary,
          fontSize: CinearaFontSizes.labelLarge,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: CinearaFontSizes.labelLarge,
          fontWeight: FontWeight.w500,
        ),
      ),

      // -----------------------------------------------------------------------
      // Tabs
      //
      // Tabs remain visually quiet. Their underline already communicates
      // selection clearly, so additional surface geometry is unnecessary.
      // -----------------------------------------------------------------------
      tabBarTheme: TabBarThemeData(
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: highContrast ? 3 : 2,
          ),
        ),
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: highContrast
            ? colorScheme.outline
            : colorScheme.outlineVariant,
        labelColor: colorScheme.onSurface,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        labelPadding: const EdgeInsets.symmetric(horizontal: CinearaSpacing.md),
        splashBorderRadius: BorderRadius.circular(
          CinearaGeometry.controlRadius,
        ),
        overlayColor: WidgetStatePropertyAll(
          colorScheme.primary.withValues(alpha: highContrast ? 0.12 : 0.07),
        ),
        labelStyle: const TextStyle(
          fontSize: CinearaFontSizes.labelLarge,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: CinearaFontSizes.labelLarge,
          fontWeight: FontWeight.w500,
        ),
      ),

      // -----------------------------------------------------------------------
      // Inputs
      //
      // Text-entry surfaces intentionally retain familiar rounded geometry.
      // -----------------------------------------------------------------------
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: inputBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: CinearaSpacing.md,
          vertical: CinearaSpacing.sm,
        ),
        hintStyle: TextStyle(
          color: highContrast
              ? colorScheme.onSurfaceVariant
              : colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
          fontSize: CinearaFontSizes.bodySmall,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: CinearaFontSizes.bodySmall,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: TextStyle(
          color: colorScheme.primary,
          fontSize: CinearaFontSizes.bodySmall,
          fontWeight: highContrast ? FontWeight.w700 : FontWeight.w600,
        ),
        helperStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: CinearaFontSizes.labelMedium,
        ),
        errorStyle: TextStyle(
          color: colorScheme.error,
          fontSize: CinearaFontSizes.labelMedium,
          fontWeight: highContrast ? FontWeight.w600 : FontWeight.w500,
        ),
        prefixIconColor: colorScheme.onSurfaceVariant,
        suffixIconColor: colorScheme.onSurfaceVariant,
        border: _inputBorder(colorScheme.outlineVariant, width: borderWidth),
        enabledBorder: _inputBorder(
          highContrast ? colorScheme.outline : colorScheme.outlineVariant,
          width: borderWidth,
        ),
        focusedBorder: _inputBorder(
          colorScheme.primary,
          width: focusBorderWidth,
        ),
        errorBorder: _inputBorder(
          colorScheme.error,
          width: highContrast ? strongBorderWidth : borderWidth,
        ),
        focusedErrorBorder: _inputBorder(
          colorScheme.error,
          width: focusBorderWidth,
        ),
        disabledBorder: _inputBorder(disabledOutline, width: borderWidth),
      ),

      // -----------------------------------------------------------------------
      // Filled buttons
      // -----------------------------------------------------------------------
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: CinearaSpacing.lg,
            vertical: CinearaSpacing.sm,
          ),
          textStyle: const TextStyle(
            fontSize: CinearaFontSizes.labelLarge,
            fontWeight: FontWeight.w700,
          ),
          shape: CinearaShapes.control(),
        ),
      ),

      // -----------------------------------------------------------------------
      // Outlined buttons
      // -----------------------------------------------------------------------
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(
              horizontal: CinearaSpacing.lg,
              vertical: CinearaSpacing.sm,
            ),
          ),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.disabled)) {
              return disabledForeground;
            }

            return colorScheme.primary;
          }),
          side: WidgetStateProperty.resolveWith<BorderSide>((states) {
            if (states.contains(WidgetState.disabled)) {
              return BorderSide(color: disabledOutline, width: borderWidth);
            }

            if (states.contains(WidgetState.focused)) {
              return BorderSide(
                color: colorScheme.primary,
                width: focusBorderWidth,
              );
            }

            if (states.contains(WidgetState.pressed)) {
              return BorderSide(
                color: colorScheme.primary,
                width: strongBorderWidth,
              );
            }

            return BorderSide(
              color: highContrast
                  ? colorScheme.outline
                  : colorScheme.outlineVariant,
              width: borderWidth,
            );
          }),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(
              fontSize: CinearaFontSizes.labelLarge,
              fontWeight: FontWeight.w700,
            ),
          ),
          shape: WidgetStatePropertyAll(CinearaShapes.control()),
        ),
      ),

      // -----------------------------------------------------------------------
      // Text buttons
      //
      // Text buttons use the same semantic control geometry as the rest of the
      // button family while retaining their lower visual weight.
      // -----------------------------------------------------------------------
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: CinearaSpacing.sm,
            vertical: CinearaSpacing.xs,
          ),
          textStyle: const TextStyle(
            fontSize: CinearaFontSizes.labelLarge,
            fontWeight: FontWeight.w700,
          ),
          shape: CinearaShapes.control(),
        ),
      ),

      // -----------------------------------------------------------------------
      // Material badges
      //
      // Poster and media-state indicators should use dedicated Cineara
      // components. This theme configures Flutter's built-in Badge only.
      // -----------------------------------------------------------------------
      badgeTheme: BadgeThemeData(
        backgroundColor: colorScheme.primary,
        textColor: colorScheme.onPrimary,
        smallSize: 7,
        largeSize: 18,
        textStyle: TextStyle(
          color: colorScheme.onPrimary,
          fontSize: CinearaFontSizes.labelSmall,
          fontWeight: FontWeight.w800,
        ),
      ),

      // -----------------------------------------------------------------------
      // Chips
      //
      // Chips use true capsule geometry because the shape has clear semantic
      // meaning for filters, metadata, and compact selection.
      // -----------------------------------------------------------------------
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        selectedColor: colorScheme.primaryContainer,
        disabledColor: colorScheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        selectedShadowColor: Colors.transparent,
        elevation: CinearaElevation.none,
        pressElevation: CinearaElevation.none,
        side: WidgetStateBorderSide.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return BorderSide(color: disabledOutline, width: borderWidth);
          }

          if (states.contains(WidgetState.focused)) {
            return BorderSide(
              color: colorScheme.primary,
              width: focusBorderWidth,
            );
          }

          if (states.contains(WidgetState.selected)) {
            return BorderSide(
              color: colorScheme.primary,
              width: highContrast ? strongBorderWidth : borderWidth,
            );
          }

          if (states.contains(WidgetState.pressed)) {
            return BorderSide(
              color: highContrast
                  ? colorScheme.outline
                  : colorScheme.outlineVariant,
              width: strongBorderWidth,
            );
          }

          return BorderSide(
            color: highContrast
                ? colorScheme.outline
                : colorScheme.outlineVariant,
            width: borderWidth,
          );
        }),
        shape: CinearaShapes.capsule(),
        padding: const EdgeInsets.symmetric(
          horizontal: CinearaSpacing.sm,
          vertical: CinearaSpacing.xxs,
        ),
        labelStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: CinearaFontSizes.labelLarge,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: TextStyle(
          color: colorScheme.primary,
          fontSize: CinearaFontSizes.labelLarge,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant, size: 18),
        checkmarkColor: colorScheme.primary,
      ),

      // -----------------------------------------------------------------------
      // List tiles
      //
      // List tiles remain structurally quiet. Rounded geometry is available for
      // selected and grouped states without turning every row into a card.
      // -----------------------------------------------------------------------
      listTileTheme: ListTileThemeData(
        selectedTileColor: colorScheme.primaryContainer,
        textColor: colorScheme.onSurface,
        selectedColor: colorScheme.primary,
        iconColor: colorScheme.onSurfaceVariant,
        shape: CinearaShapes.control(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: CinearaSpacing.md,
          vertical: CinearaSpacing.xxs,
        ),
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: CinearaFontSizes.bodyMedium,
          fontWeight: FontWeight.w600,
        ),
        subtitleTextStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: CinearaFontSizes.bodySmall,
          fontWeight: FontWeight.w400,
        ),
      ),

      // -----------------------------------------------------------------------
      // Dividers
      // -----------------------------------------------------------------------
      dividerTheme: DividerThemeData(
        color: highContrast ? colorScheme.outline : colorScheme.outlineVariant,
        thickness: dividerThickness,
        space: dividerThickness,
      ),

      // -----------------------------------------------------------------------
      // Progress
      // -----------------------------------------------------------------------
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: highContrast
            ? colorScheme.outlineVariant
            : colorScheme.surfaceContainerHigh,
        circularTrackColor: highContrast
            ? colorScheme.outlineVariant
            : colorScheme.surfaceContainerHigh,
      ),

      // -----------------------------------------------------------------------
      // Dialogs
      //
      // Dialogs use Cineara's prominent continuous surface geometry. Modal
      // positioning already provides strong hierarchy, so additional
      // decorative geometry is unnecessary.
      // -----------------------------------------------------------------------
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        elevation: highContrast
            ? CinearaElevation.none
            : CinearaElevation.dialog,
        shadowColor: _shadowColor(
          colorScheme,
          isDark: isDark,
          highContrast: highContrast,
          lightOpacity: 0.10,
          darkOpacity: 0.32,
        ),
        shape: CinearaShapes.dialog(
          side: BorderSide(
            color: highContrast
                ? colorScheme.outline
                : colorScheme.outlineVariant,
            width: highContrast ? strongBorderWidth : 0.75,
          ),
        ),
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: CinearaFontSizes.titleSmall,
          fontWeight: FontWeight.w700,
          height: 1.25,
        ),
        contentTextStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: CinearaFontSizes.bodyMedium,
          fontWeight: FontWeight.w400,
          height: 1.50,
        ),
      ),

      // -----------------------------------------------------------------------
      // Bottom sheets
      //
      // Bottom sheets retain conventional rounded top corners because their
      // connection to the screen edge already provides a strong spatial cue.
      // -----------------------------------------------------------------------
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        modalBackgroundColor: colorScheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        elevation: highContrast
            ? CinearaElevation.none
            : CinearaElevation.modal,
        modalElevation: highContrast
            ? CinearaElevation.none
            : CinearaElevation.modal,
        showDragHandle: true,
        dragHandleColor: highContrast
            ? colorScheme.onSurfaceVariant
            : colorScheme.outline,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(CinearaGeometry.prominentSurfaceRadius),
          ),
          side: highContrast
              ? BorderSide(color: colorScheme.outline, width: borderWidth)
              : BorderSide.none,
        ),
      ),

      // -----------------------------------------------------------------------
      // Popup menus
      // -----------------------------------------------------------------------
      popupMenuTheme: PopupMenuThemeData(
        color: colorScheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        elevation: highContrast ? CinearaElevation.none : CinearaElevation.menu,
        shadowColor: _shadowColor(
          colorScheme,
          isDark: isDark,
          highContrast: highContrast,
          lightOpacity: 0.10,
          darkOpacity: 0.28,
        ),
        shape: CinearaShapes.menu(
          side: BorderSide(
            color: highContrast
                ? colorScheme.outline
                : colorScheme.outlineVariant,
            width: highContrast ? strongBorderWidth : 0.75,
          ),
        ),
        textStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: CinearaFontSizes.labelLarge,
          fontWeight: FontWeight.w500,
        ),
      ),

      // -----------------------------------------------------------------------
      // Material menus
      // -----------------------------------------------------------------------
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(
            colorScheme.surfaceContainerLow,
          ),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          elevation: WidgetStatePropertyAll(
            highContrast ? CinearaElevation.none : CinearaElevation.menu,
          ),
          shadowColor: WidgetStatePropertyAll(
            _shadowColor(
              colorScheme,
              isDark: isDark,
              highContrast: highContrast,
              lightOpacity: 0.10,
              darkOpacity: 0.28,
            ),
          ),
          shape: WidgetStatePropertyAll(
            CinearaShapes.menu(
              side: BorderSide(
                color: highContrast
                    ? colorScheme.outline
                    : colorScheme.outlineVariant,
                width: highContrast ? strongBorderWidth : 0.75,
              ),
            ),
          ),
        ),
      ),

      // -----------------------------------------------------------------------
      // Snack bars
      // -----------------------------------------------------------------------
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(
          color: colorScheme.onInverseSurface,
          fontSize: CinearaFontSizes.bodySmall,
          fontWeight: FontWeight.w500,
        ),
        actionTextColor: colorScheme.inversePrimary,
        elevation: highContrast
            ? CinearaElevation.none
            : CinearaElevation.snackbar,
        behavior: SnackBarBehavior.floating,
        insetPadding: const EdgeInsets.all(CinearaSpacing.md),
        shape: CinearaShapes.snackbar(
          side: highContrast
              ? BorderSide(
                  color: colorScheme.onInverseSurface,
                  width: borderWidth,
                )
              : BorderSide.none,
        ),
      ),

      // -----------------------------------------------------------------------
      // Tooltips
      //
      // Tooltips are compact utility surfaces and therefore use conventional
      // rounded geometry rather than larger continuous-surface geometry.
      // -----------------------------------------------------------------------
      tooltipTheme: TooltipThemeData(
        padding: const EdgeInsets.symmetric(
          horizontal: CinearaSpacing.sm,
          vertical: CinearaSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: colorScheme.inverseSurface,
          borderRadius: BorderRadius.circular(CinearaGeometry.badgeRadius),
          border: highContrast
              ? Border.all(
                  color: colorScheme.onInverseSurface,
                  width: borderWidth,
                )
              : null,
        ),
        textStyle: TextStyle(
          color: colorScheme.onInverseSurface,
          fontSize: CinearaFontSizes.labelMedium,
          fontWeight: FontWeight.w500,
        ),
      ),

      // -----------------------------------------------------------------------
      // Text selection
      // -----------------------------------------------------------------------
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colorScheme.primary,
        selectionColor: colorScheme.primary.withValues(
          alpha: highContrast ? 0.34 : 0.24,
        ),
        selectionHandleColor: colorScheme.primary,
      ),

      // -----------------------------------------------------------------------
      // Cineara extensions
      // -----------------------------------------------------------------------
      extensions: <ThemeExtension<dynamic>>[cinearaExtension],
    );
  }

  // ===========================================================================
  // Cineara theme extension
  // ===========================================================================

  /// Builds the default Cineara-specific theme extension.
  static CinearaThemeExtension _buildExtension(
    ColorScheme colors, {
    required bool highContrast,
  }) {
    final isDark = colors.brightness == Brightness.dark;

    final actionSurface = isDark ? colors.surfaceContainer : colors.surface;

    return CinearaThemeExtension(
      // Artwork
      heroOverlay: CinearaColours.artworkOverlay,
      artworkOverlaySurface: CinearaColours.artworkOverlay,
      artworkOverlayOutline: highContrast
          ? CinearaColours.neutral0.withValues(alpha: 0.72)
          : CinearaColours.artworkOutline,

      // Loading and media
      skeletonBase: highContrast
          ? colors.surfaceContainerHighest
          : colors.surfaceContainerHigh,
      skeletonHighlight: highContrast
          ? isDark
                ? colors.surfaceBright
                : colors.surfaceContainerLowest
          : isDark
          ? colors.surfaceContainerHighest
          : colors.surfaceContainerLowest,
      progressTrack: highContrast
          ? colors.outlineVariant
          : colors.surfaceContainerHigh,
      posterPlaceholder: highContrast
          ? colors.surfaceContainerHigh
          : colors.surfaceContainer,

      // Actions
      actionSurface: actionSurface,
      actionSurfacePressed: Color.alphaBlend(
        colors.primary.withValues(
          alpha: highContrast
              ? isDark
                    ? 0.22
                    : 0.16
              : isDark
              ? 0.14
              : 0.08,
        ),
        actionSurface,
      ),
      actionOutline: highContrast ? colors.outline : colors.outlineVariant,
    );
  }

  // ===========================================================================
  // Input geometry
  // ===========================================================================

  /// Builds Cineara's standard rounded text-input border.
  ///
  /// Input borders remain specialised [OutlineInputBorder] instances because
  /// Flutter's text-field infrastructure requires input-specific border
  /// behaviour rather than a general-purpose [ShapeBorder].
  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(CinearaGeometry.controlRadius),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  // ===========================================================================
  // Shadows
  // ===========================================================================

  /// Resolves a restrained Material shadow colour.
  ///
  /// High-contrast themes suppress decorative shadows and communicate
  /// boundaries through explicit outlines instead.
  static Color _shadowColor(
    ColorScheme colors, {
    required bool isDark,
    required bool highContrast,
    required double lightOpacity,
    required double darkOpacity,
  }) {
    if (highContrast) {
      return Colors.transparent;
    }

    return colors.shadow.withValues(alpha: isDark ? darkOpacity : lightOpacity);
  }

  // ===========================================================================
  // Interaction opacity
  // ===========================================================================

  static double _focusOpacity({
    required bool isDark,
    required bool highContrast,
  }) {
    if (highContrast) {
      return isDark ? 0.20 : 0.16;
    }

    return isDark ? 0.14 : 0.10;
  }

  static double _hoverOpacity({
    required bool isDark,
    required bool highContrast,
  }) {
    if (highContrast) {
      return isDark ? 0.12 : 0.10;
    }

    return isDark ? 0.08 : 0.06;
  }

  static double _highlightOpacity({
    required bool isDark,
    required bool highContrast,
  }) {
    if (highContrast) {
      return isDark ? 0.12 : 0.10;
    }

    return isDark ? 0.08 : 0.06;
  }

  static double _splashOpacity({
    required bool isDark,
    required bool highContrast,
  }) {
    if (highContrast) {
      return isDark ? 0.18 : 0.14;
    }

    return isDark ? 0.12 : 0.08;
  }

  // ===========================================================================
  // Typography
  // ===========================================================================

  /// Builds Cineara's shared Material typography hierarchy.
  ///
  /// Font families are supplied globally elsewhere. This method defines the
  /// semantic scale, weights, spacing, line heights, and theme-aware colours.
  static TextTheme _textTheme(ColorScheme colors) {
    return TextTheme(
      // -----------------------------------------------------------------------
      // Display
      // -----------------------------------------------------------------------
      displayLarge: TextStyle(
        color: colors.onSurface,
        fontSize: CinearaFontSizes.display,
        fontWeight: FontWeight.w700,
        height: 1.08,
        letterSpacing: -0.8,
      ),
      displayMedium: TextStyle(
        color: colors.onSurface,
        fontSize: CinearaFontSizes.display,
        fontWeight: FontWeight.w600,
        height: 1.10,
        letterSpacing: -0.6,
      ),
      displaySmall: TextStyle(
        color: colors.onSurface,
        fontSize: CinearaFontSizes.titleLarge,
        fontWeight: FontWeight.w700,
        height: 1.15,
        letterSpacing: -0.4,
      ),

      // -----------------------------------------------------------------------
      // Headlines
      // -----------------------------------------------------------------------
      headlineLarge: TextStyle(
        color: colors.onSurface,
        fontSize: CinearaFontSizes.titleLarge,
        fontWeight: FontWeight.w700,
        height: 1.18,
        letterSpacing: -0.2,
      ),
      headlineMedium: TextStyle(
        color: colors.onSurface,
        fontSize: CinearaFontSizes.titleMedium,
        fontWeight: FontWeight.w700,
        height: 1.20,
        letterSpacing: -0.15,
      ),
      headlineSmall: TextStyle(
        color: colors.onSurface,
        fontSize: CinearaFontSizes.titleSmall,
        fontWeight: FontWeight.w700,
        height: 1.24,
        letterSpacing: -0.1,
      ),

      // -----------------------------------------------------------------------
      // Titles
      // -----------------------------------------------------------------------
      titleLarge: TextStyle(
        color: colors.onSurface,
        fontSize: CinearaFontSizes.titleMedium,
        fontWeight: FontWeight.w700,
        height: 1.24,
      ),
      titleMedium: TextStyle(
        color: colors.onSurface,
        fontSize: CinearaFontSizes.titleSmall,
        fontWeight: FontWeight.w600,
        height: 1.28,
      ),
      titleSmall: TextStyle(
        color: colors.onSurface,
        fontSize: CinearaFontSizes.bodyLarge,
        fontWeight: FontWeight.w600,
        height: 1.30,
      ),

      // -----------------------------------------------------------------------
      // Body
      // -----------------------------------------------------------------------
      bodyLarge: TextStyle(
        color: colors.onSurface,
        fontSize: CinearaFontSizes.bodyLarge,
        fontWeight: FontWeight.w400,
        height: 1.48,
      ),
      bodyMedium: TextStyle(
        color: colors.onSurface,
        fontSize: CinearaFontSizes.bodyMedium,
        fontWeight: FontWeight.w400,
        height: 1.48,
      ),
      bodySmall: TextStyle(
        color: colors.onSurfaceVariant,
        fontSize: CinearaFontSizes.bodySmall,
        fontWeight: FontWeight.w400,
        height: 1.44,
      ),

      // -----------------------------------------------------------------------
      // Labels
      // -----------------------------------------------------------------------
      labelLarge: TextStyle(
        color: colors.onSurface,
        fontSize: CinearaFontSizes.labelLarge,
        fontWeight: FontWeight.w700,
        height: 1.28,
      ),
      labelMedium: TextStyle(
        color: colors.onSurfaceVariant,
        fontSize: CinearaFontSizes.labelMedium,
        fontWeight: FontWeight.w600,
        height: 1.28,
      ),
      labelSmall: TextStyle(
        color: colors.onSurfaceVariant,
        fontSize: CinearaFontSizes.labelSmall,
        fontWeight: FontWeight.w500,
        height: 1.28,
      ),
    );
  }
}
