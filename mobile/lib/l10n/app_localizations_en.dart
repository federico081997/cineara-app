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

  @override
  String get searchPageTitle => 'Search';

  @override
  String get searchFieldLabel => 'Search Cineara';

  @override
  String get searchHint => 'Search Cineara';

  @override
  String get searchClearSearch => 'Clear search';

  @override
  String get searchRetry => 'Retry';

  @override
  String get searchSeeAll => 'See all';

  @override
  String get searchRecentSearches => 'Recent searches';

  @override
  String get searchRecommended => 'Recommended';

  @override
  String get searchClearRecent => 'Clear';

  @override
  String get searchRemoveRecentSearch => 'Remove recent search';

  @override
  String get searchSearching => 'Searching…';

  @override
  String get searchLoadingMore => 'Loading more…';

  @override
  String get searchLoadMore => 'Load more';

  @override
  String get searchTryAgain => 'Try again';

  @override
  String get searchNoResultsTitle => 'No results';

  @override
  String get searchNoResultsMessage =>
      'Try another title, person, collection, studio, or keyword.';

  @override
  String get searchErrorTitle => 'Search unavailable';

  @override
  String get searchErrorMessage =>
      'Something went wrong while searching. Please try again.';

  @override
  String get searchStartTitle => 'Find something to watch';

  @override
  String get searchStartMessage =>
      'Search across movies, TV series, people, collections, studios, and keywords.';

  @override
  String get searchGrid => 'Grid';

  @override
  String get searchList => 'List';

  @override
  String get searchCategoryAll => 'All';

  @override
  String get searchCategoryMovies => 'Movies';

  @override
  String get searchCategoryTvSeries => 'TV series';

  @override
  String get searchCategoryPeople => 'People';

  @override
  String get searchCategoryCollections => 'Collections';

  @override
  String get searchCategoryStudios => 'Studios';

  @override
  String get searchCategoryKeywords => 'Keywords';

  @override
  String get searchMovieDescriptor => 'Movie';

  @override
  String get searchTvSeriesDescriptor => 'TV series';

  @override
  String get searchViewingProgress => 'Viewing progress';

  @override
  String get searchOpenMedia => 'Open media details';

  @override
  String get searchOpenPerson => 'Open person details';

  @override
  String get searchOpenCollection => 'Open collection details';

  @override
  String get searchOpenStudio => 'Open studio details';

  @override
  String get searchOpenKeyword => 'Search this keyword';

  @override
  String get searchFocusShortcut => 'Focus search';

  @override
  String get searchControlShortcutLabel => 'Ctrl K';

  @override
  String get searchMetaShortcutLabel => '⌘K';

  @override
  String get searchCategoriesLabel => 'Search categories';

  @override
  String searchResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
      zero: 'No results',
    );
    return '$_temp0';
  }

  @override
  String searchRatingOutOfTen(String rating) {
    return '$rating out of 10';
  }

  @override
  String get searchStatusDock => 'Personal media status';

  @override
  String get searchFavorite => 'Favorite';

  @override
  String get searchInCollection => 'In collection';

  @override
  String get searchInWatchlist => 'In watchlist';

  @override
  String get searchPersonalRating => 'Personal rating';

  @override
  String get searchStatusWatching => 'Watching';

  @override
  String get searchStatusCaughtUp => 'Caught up';

  @override
  String get searchStatusCompleted => 'Completed';

  @override
  String get searchStatusRewatching => 'Rewatching';

  @override
  String get searchStatusOnHold => 'On hold';

  @override
  String get searchStatusDropped => 'Dropped';

  @override
  String get searchDetailsUnavailable =>
      'This type of detail page is not available yet.';
}
