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
  String get posterStatusNotStarted => 'Not started';

  @override
  String get posterStatusWatching => 'Watching';

  @override
  String get posterStatusCaughtUp => 'Caught up';

  @override
  String get posterStatusCompleted => 'Completed';

  @override
  String get posterStatusRewatching => 'Rewatching';

  @override
  String get posterStatusOnHold => 'On hold';

  @override
  String get posterStatusDropped => 'Dropped';

  @override
  String get posterFavourite => 'Favourite';

  @override
  String get posterWatchlist => 'In watchlist';

  @override
  String posterUserRating(String rating) {
    return 'Your rating: $rating';
  }

  @override
  String posterCollectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'In $count collections',
      one: 'In one collection',
    );
    return '$_temp0';
  }

  @override
  String posterProgress(int percentage) {
    return '$percentage% watched';
  }

  @override
  String posterNewEpisodeBadge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count NEW',
      one: 'NEW',
    );
    return '$_temp0';
  }

  @override
  String get posterNewContent => 'NEW';

  @override
  String get posterNewRelease => 'New release';

  @override
  String get posterNewEpisodesAvailable => 'New episodes available';

  @override
  String posterNewEpisodeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new episodes available',
      one: 'One new episode available',
    );
    return '$_temp0';
  }

  @override
  String posterAddToWatchlist(String title) {
    return 'Add $title to watchlist';
  }

  @override
  String posterRemoveFromWatchlist(String title) {
    return 'Remove $title from watchlist';
  }

  @override
  String posterAddToFavourites(String title) {
    return 'Add $title to favourites';
  }

  @override
  String posterRemoveFromFavourites(String title) {
    return 'Remove $title from favourites';
  }

  @override
  String posterMarkAsWatched(String title) {
    return 'Mark $title as watched';
  }

  @override
  String posterMarkAsUnwatched(String title) {
    return 'Mark $title as unwatched';
  }
}
