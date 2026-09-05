import 'package:flutter/material.dart';

/// Primitive colours used by the Cineara design system.
///
/// Application widgets should normally use `Theme.of(context).colorScheme`.
///
/// Direct access is appropriate for brand artwork, gradients, media statuses,
/// ratings, and theme construction.
abstract final class CinearaColours {
  // Brand

  static const Color brand50 = Color(0xFFFAF7FC);
  static const Color brand100 = Color(0xFFF4EDF8);
  static const Color brand200 = Color(0xFFE9DCF1);
  static const Color brand300 = Color(0xFFD8C3E5);
  static const Color brand400 = Color(0xFFC29FD4);
  static const Color brand500 = Color(0xFFA87ABB);
  static const Color brand600 = Color(0xFF8C5D9E);
  static const Color brand700 = Color(0xFF6F497D);
  static const Color brand800 = Color(0xFF54385F);
  static const Color brand900 = Color(0xFF3D2A46);
  static const Color brand950 = Color(0xFF251A2B);

  // Neutrals

  static const Color neutral0 = Color(0xFFFFFFFF);
  static const Color neutral25 = Color(0xFFFCFBFD);
  static const Color neutral50 = Color(0xFFF8F7FA);
  static const Color neutral100 = Color(0xFFF2F0F4);
  static const Color neutral200 = Color(0xFFE7E4EA);
  static const Color neutral300 = Color(0xFFD4D0D9);
  static const Color neutral400 = Color(0xFFB4AFBA);
  static const Color neutral500 = Color(0xFF8A8590);
  static const Color neutral600 = Color(0xFF69646E);
  static const Color neutral700 = Color(0xFF4C4952);
  static const Color neutral800 = Color(0xFF302F38);
  static const Color neutral850 = Color(0xFF252630);
  static const Color neutral900 = Color(0xFF191A23);
  static const Color neutral925 = Color(0xFF11121A);
  static const Color neutral950 = Color(0xFF0B0C12);

  // Blue

  static const Color blue100 = Color(0xFFEAF2FF);
  static const Color blue300 = Color(0xFF91B8F4);
  static const Color blue500 = Color(0xFF5B8DEF);
  static const Color blue600 = Color(0xFF4676D7);
  static const Color blue700 = Color(0xFF355DB3);

  // Cyan

  static const Color cyan50 = Color(0xFFF3FAFB);
  static const Color cyan100 = Color(0xFFE5F4F6);
  static const Color cyan300 = Color(0xFF9FCFD5);
  static const Color cyan500 = Color(0xFF5FA4AE);
  static const Color cyan700 = Color(0xFF397580);

  // Pink

  static const Color pink100 = Color(0xFFFFEDF6);
  static const Color pink300 = Color(0xFFF3A7CD);
  static const Color pink500 = Color(0xFFD968A4);
  static const Color pink700 = Color(0xFFA94379);

  // Orange

  static const Color orange50 = Color(0xFFFFF8F2);
  static const Color orange100 = Color(0xFFFDEFE4);
  static const Color orange300 = Color(0xFFF2B98F);
  static const Color orange500 = Color(0xFFD98250);
  static const Color orange700 = Color(0xFFA85731);

  // Green

  static const Color green100 = Color(0xFFEAF8F0);
  static const Color green300 = Color(0xFF8ED1AA);
  static const Color green500 = Color(0xFF55B77A);
  static const Color green700 = Color(0xFF388558);

  // Amber

  static const Color amber100 = Color(0xFFFFF5DF);
  static const Color amber300 = Color(0xFFF2C56D);
  static const Color amber500 = Color(0xFFD99A32);
  static const Color amber700 = Color(0xFFA66E1E);

  // Red

  static const Color red100 = Color(0xFFFFECEF);
  static const Color red300 = Color(0xFFF09AA5);
  static const Color red500 = Color(0xFFD95C6B);
  static const Color red700 = Color(0xFFA93F4D);

  // Teal

  static const Color teal500 = Color(0xFF49A7A0);

  // Artwork

  static const Color artworkOverlay = Color(0xB8000000);
  static const Color artworkOutline = Color(0x47FFFFFF);

  // Brand decoration

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      CinearaColours.pink500,
      CinearaColours.brand500,
      CinearaColours.blue500,
    ],
    stops: <double>[0.0, 0.52, 1.0],
  );
}

/// Stable colours used for application feedback.
abstract final class CinearaFeedbackColours {
  static const Color success = CinearaColours.green500;
  static const Color warning = CinearaColours.amber500;
  static const Color error = CinearaColours.red500;
  static const Color information = CinearaColours.blue500;
}

/// Stable accent colours representing media tracking states.
abstract final class CinearaStatusColours {
  static const Color statusWatching = CinearaColours.blue500;
  static const Color statusCaughtUp = CinearaColours.green500;
  static const Color statusCompleted = CinearaColours.green700;
  static const Color statusRewatching = CinearaColours.brand500;
  static const Color statusOnHold = CinearaColours.amber500;
  static const Color statusDropped = CinearaColours.red500;
  static const Color watchlist = Color(0xFF3EAFCB);
  static const Color favourite = Color(0xFFE65D78);
  static const Color collection = Color(0xFF9569EB);
  static const Color rating = Color(0xFFE2A638);
}

/// Colours used by rating indicators.
abstract final class CinearaRatingColours {
  static const Color user = CinearaColours.amber500;
  static const Color external = CinearaColours.blue500;
}

/// Colour utilities used by the Cineara design system.
abstract final class CinearaColourUtils {
  /// Returns a readable foreground colour for content displayed over
  /// [background].
  static Color foregroundFor(Color background) {
    return background.computeLuminance() >= 0.47
        ? CinearaColours.neutral950
        : CinearaColours.neutral0;
  }
}
