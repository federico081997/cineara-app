import 'package:cineara_design_system/cineara_design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;

import '../core/networking/api_client.dart';
import '../features/search/search.dart';
import '../l10n/app_localizations.dart';
import 'app.dart';
import 'config/app_config.dart';
import 'routing/app_router.dart';
import 'routing/app_routes.dart';
import 'shell/app_root_destination.dart';

/// Initializes Cineara's application infrastructure and starts the Flutter
/// application.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  final AppConfig config = AppConfig.fromEnvironment();

  final ApiClient apiClient = ApiClient(
    baseUri: config.apiBaseUri,
    enableDebugLogging: config.enableDebugLogging,
  );

  final CinearaSearchChromeController searchChromeController =
      CinearaSearchChromeController();

  final SearchRepository searchRepository = SearchRepository.fromAppConfig(
    config: config,
    getJson: apiClient.getJson,
    allStrategy: SearchAllStrategy.fanOut,
  );

  const AppRootDestination startDestination = AppRootDestination.home;

  const CinearaAppTheme appTheme = CinearaAppTheme.system;

  const Locale? locale = null;

  final GoRouter router = createAppRouter(startDestination: startDestination);

  final CinearaSearchDependencies searchDependencies =
      CinearaSearchDependencies(
        loader: searchRepository.search,
        chromeController: searchChromeController,
        localizations: _searchLocalizations,
        statusDockLabels: _searchStatusDockLabels,
        statusLabel: _searchStatusLabel,
        onMediaTap: _openSearchMedia,
        onPersonTap: _showUnavailablePersonDetails,
        onEntityTap: _showUnavailableEntityDetails,
        initialRecentSearches: const <String>[],
        recommendedSearches: const <String>[],
      );

  runApp(
    CinearaSearchDependenciesScope(
      dependencies: searchDependencies,
      child: CinearaApp(router: router, appTheme: appTheme, locale: locale),
    ),
  );
}

// =============================================================================
// Search localization
// =============================================================================

CinearaSearchLocalizations _searchLocalizations(BuildContext context) {
  final AppLocalizations l10n = _l10n(context);

  return CinearaSearchLocalizations(
    pageTitle: l10n.searchPageTitle,
    searchFieldLabel: l10n.searchFieldLabel,
    searchHint: l10n.searchHint,
    clearSearch: l10n.searchClearSearch,
    retry: l10n.searchRetry,
    seeAll: l10n.searchSeeAll,
    recentSearches: l10n.searchRecentSearches,
    recommended: l10n.searchRecommended,
    clearRecent: l10n.searchClearRecent,
    removeRecentSearch: l10n.searchRemoveRecentSearch,
    searching: l10n.searchSearching,
    loadingMore: l10n.searchLoadingMore,
    loadMore: l10n.searchLoadMore,
    tryAgain: l10n.searchTryAgain,
    noResultsTitle: l10n.searchNoResultsTitle,
    noResultsMessage: l10n.searchNoResultsMessage,
    searchErrorTitle: l10n.searchErrorTitle,
    searchErrorMessage: l10n.searchErrorMessage,
    startSearchingTitle: l10n.searchStartTitle,
    startSearchingMessage: l10n.searchStartMessage,
    gridLabel: l10n.searchGrid,
    listLabel: l10n.searchList,
    all: l10n.searchCategoryAll,
    movies: l10n.searchCategoryMovies,
    tvSeries: l10n.searchCategoryTvSeries,
    people: l10n.searchCategoryPeople,
    collections: l10n.searchCategoryCollections,
    studios: l10n.searchCategoryStudios,
    keywords: l10n.searchCategoryKeywords,
    movieDescriptor: l10n.searchMovieDescriptor,
    tvSeriesDescriptor: l10n.searchTvSeriesDescriptor,
    viewingProgress: l10n.searchViewingProgress,
    openMedia: l10n.searchOpenMedia,
    openPerson: l10n.searchOpenPerson,
    openCollection: l10n.searchOpenCollection,
    openStudio: l10n.searchOpenStudio,
    openKeyword: l10n.searchOpenKeyword,
    focusSearchShortcut: l10n.searchFocusShortcut,
    controlSearchShortcutLabel: l10n.searchControlShortcutLabel,
    metaSearchShortcutLabel: l10n.searchMetaShortcutLabel,
    searchCategoriesLabel: l10n.searchCategoriesLabel,
    resultCountLabel: l10n.searchResultCount,
    formatRating: (double rating) {
      return _formatRating(localeName: l10n.localeName, rating: rating);
    },
    ratingSemanticLabel: (double rating) {
      final String formatted = _formatRating(
        localeName: l10n.localeName,
        rating: rating,
      );

      return l10n.searchRatingOutOfTen(formatted);
    },
  );
}

CinearaStatusDockLabels _searchStatusDockLabels(BuildContext context) {
  final AppLocalizations l10n = _l10n(context);

  return CinearaStatusDockLabels(
    dock: l10n.searchStatusDock,
    favorite: l10n.searchFavorite,
    collection: l10n.searchInCollection,
    watchlist: l10n.searchInWatchlist,
    personalRating: l10n.searchPersonalRating,
  );
}

String _searchStatusLabel(BuildContext context, CinearaStatusBadgeType type) {
  final AppLocalizations l10n = _l10n(context);

  return switch (type) {
    CinearaStatusBadgeType.watching => l10n.searchStatusWatching,
    CinearaStatusBadgeType.caughtUp => l10n.searchStatusCaughtUp,
    CinearaStatusBadgeType.completed => l10n.searchStatusCompleted,
    CinearaStatusBadgeType.rewatching => l10n.searchStatusRewatching,
    CinearaStatusBadgeType.onHold => l10n.searchStatusOnHold,
    CinearaStatusBadgeType.dropped => l10n.searchStatusDropped,
  };
}

String _formatRating({required String localeName, required double rating}) {
  final intl.NumberFormat formatter =
      intl.NumberFormat.decimalPattern(localeName)
        ..minimumFractionDigits = 1
        ..maximumFractionDigits = 1;

  return formatter.format(rating);
}

// =============================================================================
// Search navigation
// =============================================================================

void _openSearchMedia(
  BuildContext context,
  AppRootDestination destination,
  CinearaSearchMediaResult result,
) {
  final int? mediaId = int.tryParse(result.id);

  if (mediaId == null || mediaId <= 0) {
    _showDetailsUnavailable(context);
    return;
  }

  final String mediaType = switch (result.kind) {
    CinearaSearchMediaKind.movie => 'movie',
    CinearaSearchMediaKind.tvSeries => 'tv',
  };

  context.push(AppRoutes.mediaFor(destination, mediaType, mediaId));
}

void _showUnavailablePersonDetails(
  BuildContext context,
  AppRootDestination destination,
  CinearaSearchPersonResult result,
) {
  _showDetailsUnavailable(context);
}

void _showUnavailableEntityDetails(
  BuildContext context,
  AppRootDestination destination,
  CinearaSearchEntityResult result,
) {
  _showDetailsUnavailable(context);
}

void _showDetailsUnavailable(BuildContext context) {
  final AppLocalizations l10n = _l10n(context);

  final ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(context);

  messenger
    ?..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(l10n.searchDetailsUnavailable)));
}

// =============================================================================
// Localization
// =============================================================================

AppLocalizations _l10n(BuildContext context) {
  final AppLocalizations? localizations = AppLocalizations.of(context);

  assert(
    localizations != null,
    'AppLocalizations must be available below MaterialApp.',
  );

  if (localizations == null) {
    throw FlutterError(
      'AppLocalizations are unavailable in the current BuildContext.',
    );
  }

  return localizations;
}
