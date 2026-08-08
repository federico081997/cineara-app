import 'package:flutter/material.dart';

/// Central colour palette for the Cineara design system.
///
/// The palette is derived from Cineara's visual identity:
/// - near-black cinematic backgrounds;
/// - deep violet interface elements;
/// - magenta-to-blue branding gradients;
/// - cool neutral text and surface colours.
abstract final class CinearaColours {
  // ---------------------------------------------------------------------------
  // Brand palette
  // ---------------------------------------------------------------------------

  static const Color brand50 = Color(0xFFFBF3FF);
  static const Color brand100 = Color(0xFFF3DDFF);
  static const Color brand200 = Color(0xFFE6B6FC);
  static const Color brand300 = Color(0xFFD285F1);
  static const Color brand400 = Color(0xFFB85DDF);
  static const Color brand500 = Color(0xFF9142CF);
  static const Color brand600 = Color(0xFF6E38B8);
  static const Color brand700 = Color(0xFF542D93);
  static const Color brand800 = Color(0xFF3B216D);
  static const Color brand900 = Color(0xFF28184B);

  /// Primary solid colour for buttons, navigation and selected elements.
  static const Color primary = brand600;

  /// Colour for text and icons placed over [primary].
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Soft selected-state and prominent-button background.
  static const Color primaryContainer = Color(0xFFD6C0FF);

  /// Text and icon colour placed over [primaryContainer].
  static const Color onPrimaryContainer = Color(0xFF32145E);

  /// Colour for the hero overlay.
  static const Color heroOverlay = Color(0xB8000000);

  // ---------------------------------------------------------------------------
  // Logo and decorative accent colours
  // ---------------------------------------------------------------------------

  /// Pink used at the upper portion of the Cineara film-strip logo.
  static const Color logoPink = Color(0xFFEA77F1);

  /// Central violet used in the Cineara film-strip logo.
  static const Color logoViolet = Color(0xFF9B43D5);

  /// Blue used at the lower portion of the Cineara film-strip logo.
  static const Color logoBlue = Color(0xFF3F61E2);

  /// Main Cineara branding gradient.
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[logoPink, logoViolet, logoBlue],
  );

  // ---------------------------------------------------------------------------
  // Neutral palette
  // ---------------------------------------------------------------------------

  static const Color neutral0 = Color(0xFFFFFFFF);
  static const Color neutral50 = Color(0xFFF8F7FA);
  static const Color neutral100 = Color(0xFFEEEAF2);
  static const Color neutral200 = Color(0xFFD9D4DF);
  static const Color neutral300 = Color(0xFFC0BAC8);
  static const Color neutral400 = Color(0xFFA49EAD);
  static const Color neutral500 = Color(0xFF817B8B);
  static const Color neutral600 = Color(0xFF625D6C);
  static const Color neutral700 = Color(0xFF3A3744);
  static const Color neutral800 = Color(0xFF24222D);
  static const Color neutral900 = Color(0xFF171721);
  static const Color neutral950 = Color(0xFF0B0C11);

  // ---------------------------------------------------------------------------
  // Dark-theme semantic surfaces
  // ---------------------------------------------------------------------------

  /// Main application background.
  static const Color darkBackground = Color(0xFF293661);

  /// Standard card, dialog and navigation-bar surface.
  static const Color darkSurface = neutral900;

  /// Slightly raised surface used for elevated cards and menus.
  static const Color darkSurfaceElevated = Color(0xFF211F2B);

  /// Subtle purple-tinted surface for selected or branded cards.
  static const Color darkSurfaceBrand = Color(0xFF292243);

  /// Borders and dividers on dark surfaces.
  static const Color darkOutline = Color(0xFF35313F);

  /// Strong text and icons on dark backgrounds.
  static const Color darkTextPrimary = Color(0xFFF3F0F6);

  /// Supporting text on dark backgrounds.
  static const Color darkTextSecondary = Color(0xFFA9A3B0);

  /// Disabled text and icons on dark backgrounds.
  static const Color darkTextDisabled = Color(0xFF706A79);

  // ---------------------------------------------------------------------------
  // Light-theme semantic surfaces
  // ---------------------------------------------------------------------------

  static const Color lightBackground = Color(0xFFEEE5FB);
  static const Color lightSurface = neutral0;
  static const Color lightSurfaceElevated = Color(0xFFF2EEF7);
  static const Color lightOutline = Color(0xFFD8D1DF);
  static const Color lightTextPrimary = Color(0xFF1A1720);
  static const Color lightTextSecondary = Color(0xFF68616F);
  static const Color lightTextDisabled = Color(0xFFA39BAA);

  // ---------------------------------------------------------------------------
  // Feedback colours
  // ---------------------------------------------------------------------------

  static const Color success = Color(0xFF43C98B);
  static const Color warning = Color(0xFFF4B84A);
  static const Color error = Color(0xFFF06472);
  static const Color information = Color(0xFF5681F5);
}
