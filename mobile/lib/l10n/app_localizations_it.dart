// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Cineara';

  @override
  String get routeErrorTitle => 'Pagina non disponibile';

  @override
  String get routeErrorMessage =>
      'Non è stato possibile aprire questa pagina. Torna alla Home e riprova.';

  @override
  String get routeErrorGoHome => 'Torna alla Home';

  @override
  String get navigationHome => 'Home';

  @override
  String get navigationDiscover => 'Scopri';

  @override
  String get navigationLibrary => 'Libreria';

  @override
  String get navigationProfile => 'Profilo';

  @override
  String get topBarSearch => 'Cerca';

  @override
  String get topBarNotifications => 'Notifiche';

  @override
  String get topBarOpenProfileMenu => 'Apri il menu del profilo';
}
