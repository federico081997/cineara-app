// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Cineara';

  @override
  String get routeErrorTitle => 'Page unavailable';

  @override
  String get routeErrorMessage =>
      'We couldn\'t open this page. Return to Home and try again.';

  @override
  String get routeErrorGoHome => 'Go to Home';

  @override
  String get navigationHome => 'Home';

  @override
  String get navigationDiscover => 'Discover';

  @override
  String get navigationLibrary => 'Library';

  @override
  String get navigationProfile => 'Profile';

  @override
  String get topBarSearch => 'Search';

  @override
  String get topBarNotifications => 'Notifications';

  @override
  String get topBarOpenProfileMenu => 'Open profile menu';
}
