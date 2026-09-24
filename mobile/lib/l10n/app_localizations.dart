import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_it.dart';
import 'app_localizations_zh.dart';

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
    Locale('ar'),
    Locale('en'),
    Locale('it'),
    Locale('zh'),
  ];

  /// Application title.
  ///
  /// In en, this message translates to:
  /// **'Cineara'**
  String get appTitle;

  /// Title shown when Cineara cannot open a requested route or page.
  ///
  /// In en, this message translates to:
  /// **'Page unavailable'**
  String get routeErrorTitle;

  /// Message shown when Cineara cannot open a requested route or page.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t open this page. Return to Home and try again.'**
  String get routeErrorMessage;

  /// Button label that navigates from the route error page back to Home.
  ///
  /// In en, this message translates to:
  /// **'Go to Home'**
  String get routeErrorGoHome;

  /// Label for the Home destination in the main bottom navigation.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navigationHome;

  /// Label for the Discover destination in the main bottom navigation.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get navigationDiscover;

  /// Label for the Library destination in the main bottom navigation.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navigationLibrary;

  /// Label for the Profile destination in the main bottom navigation.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navigationProfile;

  /// Accessibility label and tooltip for the global search action in the top application bar.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get topBarSearch;

  /// Accessibility label and tooltip for the global notifications action in the top application bar.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get topBarNotifications;

  /// Accessibility label and tooltip for the profile quick-action menu in the top application bar.
  ///
  /// In en, this message translates to:
  /// **'Open profile menu'**
  String get topBarOpenProfileMenu;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchPageTitle;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'Search Cineara'**
  String get searchFieldLabel;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'Search Cineara'**
  String get searchHint;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get searchClearSearch;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get searchRetry;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get searchSeeAll;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get searchRecentSearches;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get searchRecommended;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get searchClearRecent;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'Remove recent search'**
  String get searchRemoveRecentSearch;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'Searching…'**
  String get searchSearching;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'Loading more…'**
  String get searchLoadingMore;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get searchLoadMore;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get searchTryAgain;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get searchNoResultsTitle;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'Try another title, person, collection, studio, or keyword.'**
  String get searchNoResultsMessage;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'Search unavailable'**
  String get searchErrorTitle;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while searching. Please try again.'**
  String get searchErrorMessage;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'Find something to watch'**
  String get searchStartTitle;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'Search across movies, TV series, people, collections, studios, and keywords.'**
  String get searchStartMessage;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'Grid'**
  String get searchGrid;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get searchList;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get searchCategoryAll;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get searchCategoryMovies;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'TV series'**
  String get searchCategoryTvSeries;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get searchCategoryPeople;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get searchCategoryCollections;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'Studios'**
  String get searchCategoryStudios;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'Keywords'**
  String get searchCategoryKeywords;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'Movie'**
  String get searchMovieDescriptor;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'TV series'**
  String get searchTvSeriesDescriptor;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'Viewing progress'**
  String get searchViewingProgress;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'Open media details'**
  String get searchOpenMedia;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'Open person details'**
  String get searchOpenPerson;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'Open collection details'**
  String get searchOpenCollection;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'Open studio details'**
  String get searchOpenStudio;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'Search this keyword'**
  String get searchOpenKeyword;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'Focus search'**
  String get searchFocusShortcut;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'Ctrl K'**
  String get searchControlShortcutLabel;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'⌘K'**
  String get searchMetaShortcutLabel;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'Search categories'**
  String get searchCategoriesLabel;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No results} =1{1 result} other{{count} results}}'**
  String searchResultCount(int count);

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'{rating} out of 10'**
  String searchRatingOutOfTen(String rating);

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'Personal media status'**
  String get searchStatusDock;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get searchFavorite;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'In collection'**
  String get searchInCollection;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'In watchlist'**
  String get searchInWatchlist;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'Personal rating'**
  String get searchPersonalRating;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'Watching'**
  String get searchStatusWatching;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'Caught up'**
  String get searchStatusCaughtUp;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get searchStatusCompleted;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'Rewatching'**
  String get searchStatusRewatching;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'On hold'**
  String get searchStatusOnHold;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'Dropped'**
  String get searchStatusDropped;

  /// Search feature localized string.
  ///
  /// In en, this message translates to:
  /// **'This type of detail page is not available yet.'**
  String get searchDetailsUnavailable;
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
      <String>['ar', 'en', 'it', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
