import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it'),
  ];

  /// Accessibility label for media the user has not started.
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get posterStatusNotStarted;

  /// Accessibility label for media the user is currently watching.
  ///
  /// In en, this message translates to:
  /// **'Watching'**
  String get posterStatusWatching;

  /// Accessibility label for episodic media where all currently available episodes have been watched.
  ///
  /// In en, this message translates to:
  /// **'Caught up'**
  String get posterStatusCaughtUp;

  /// Accessibility label for media the user has completely watched.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get posterStatusCompleted;

  /// Accessibility label for media the user is currently rewatching.
  ///
  /// In en, this message translates to:
  /// **'Rewatching'**
  String get posterStatusRewatching;

  /// Accessibility label for media the user has temporarily paused.
  ///
  /// In en, this message translates to:
  /// **'On hold'**
  String get posterStatusOnHold;

  /// Accessibility label for media the user has stopped watching.
  ///
  /// In en, this message translates to:
  /// **'Dropped'**
  String get posterStatusDropped;

  /// Accessibility label indicating that the media is a favourite.
  ///
  /// In en, this message translates to:
  /// **'Favourite'**
  String get posterFavourite;

  /// Accessibility label indicating that the media is in the user's watchlist.
  ///
  /// In en, this message translates to:
  /// **'In watchlist'**
  String get posterWatchlist;

  /// Accessibility label for the user's personal rating of a media item.
  ///
  /// In en, this message translates to:
  /// **'Your rating: {rating}'**
  String posterUserRating(String rating);

  /// Accessibility label describing how many user collections contain the media.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{In one collection} other{In {count} collections}}'**
  String posterCollectionCount(int count);

  /// Accessibility label describing viewing progress as a percentage.
  ///
  /// In en, this message translates to:
  /// **'{percentage}% watched'**
  String posterProgress(int percentage);

  /// Short visual badge shown for newly available media or episodes.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get posterNewContent;

  /// Accessibility description for a newly released media item.
  ///
  /// In en, this message translates to:
  /// **'New release'**
  String get posterNewRelease;

  /// Accessibility description used when new episodes are available but their count is unknown.
  ///
  /// In en, this message translates to:
  /// **'New episodes available'**
  String get posterNewEpisodesAvailable;

  /// Accessibility description for the number of newly available episodes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{One new episode available} other{{count} new episodes available}}'**
  String posterNewEpisodeCount(int count);

  /// Accessibility label for the quick action that adds media to the watchlist.
  ///
  /// In en, this message translates to:
  /// **'Add {title} to watchlist'**
  String posterAddToWatchlist(String title);

  /// Accessibility label for the quick action that removes media from the watchlist.
  ///
  /// In en, this message translates to:
  /// **'Remove {title} from watchlist'**
  String posterRemoveFromWatchlist(String title);

  /// Accessibility label for the quick action that adds media to favourites.
  ///
  /// In en, this message translates to:
  /// **'Add {title} to favourites'**
  String posterAddToFavourites(String title);

  /// Accessibility label for the quick action that removes media from favourites.
  ///
  /// In en, this message translates to:
  /// **'Remove {title} from favourites'**
  String posterRemoveFromFavourites(String title);

  /// Accessibility label for the quick action that marks media as watched.
  ///
  /// In en, this message translates to:
  /// **'Mark {title} as watched'**
  String posterMarkAsWatched(String title);

  /// Accessibility label for the quick action that marks media as unwatched.
  ///
  /// In en, this message translates to:
  /// **'Mark {title} as unwatched'**
  String posterMarkAsUnwatched(String title);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
