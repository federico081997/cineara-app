import 'dart:async';
import 'dart:collection';

import 'package:cineara_design_system/cineara_design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/shell/app_root_destination.dart';

// =============================================================================
// Search public contracts
// =============================================================================

/// User-facing Search destinations.
///
/// Keep this enum as the single source of truth for Search pills and the
/// sections shown by the All experience.
enum CinearaSearchCategory {
  all,
  movies,
  tvSeries,
  people,
  collections,
  studios,
  keywords;

  /// Sections shown by Search > All, in presentation order.
  static const List<CinearaSearchCategory> allSections =
      <CinearaSearchCategory>[
        movies,
        tvSeries,
        people,
        collections,
        studios,
        keywords,
      ];

  bool get supportsViewMode {
    return switch (this) {
      CinearaSearchCategory.movies ||
      CinearaSearchCategory.tvSeries ||
      CinearaSearchCategory.people ||
      CinearaSearchCategory.collections ||
      CinearaSearchCategory.studios => true,
      CinearaSearchCategory.all || CinearaSearchCategory.keywords => false,
    };
  }

  IconData get icon {
    return switch (this) {
      CinearaSearchCategory.all => Icons.apps_rounded,
      CinearaSearchCategory.movies => Icons.movie_rounded,
      CinearaSearchCategory.tvSeries => Icons.tv_rounded,
      CinearaSearchCategory.people => Icons.person_rounded,
      CinearaSearchCategory.collections => Icons.collections_bookmark_rounded,
      CinearaSearchCategory.studios => Icons.apartment_rounded,
      CinearaSearchCategory.keywords => Icons.tag_rounded,
    };
  }
}

/// Locale-owned copy consumed by [CinearaSearchPage].
///
/// This type intentionally contains no default language. The feature layer must
/// supply every visible string and every locale-sensitive formatter from the
/// app's localization system (for example generated ARB/localizations).
///
/// The page therefore never assumes English, never derives text direction from a
/// locale, and never formats localized numbers itself. Layout direction is taken
/// from the ambient [Directionality].
typedef CinearaSearchResultCountLabel = String Function(int count);
typedef CinearaSearchRatingFormatter = String Function(double rating);
typedef CinearaSearchRatingSemanticLabel = String Function(double rating);

@immutable
final class CinearaSearchLocalizations {
  const CinearaSearchLocalizations({
    required this.pageTitle,
    required this.searchFieldLabel,
    required this.searchHint,
    required this.clearSearch,
    required this.retry,
    required this.seeAll,
    required this.recentSearches,
    required this.recommended,
    required this.clearRecent,
    required this.removeRecentSearch,
    required this.searching,
    required this.loadingMore,
    required this.loadMore,
    required this.tryAgain,
    required this.noResultsTitle,
    required this.noResultsMessage,
    required this.searchErrorTitle,
    required this.searchErrorMessage,
    required this.startSearchingTitle,
    required this.startSearchingMessage,
    required this.gridLabel,
    required this.listLabel,
    required this.all,
    required this.movies,
    required this.tvSeries,
    required this.people,
    required this.collections,
    required this.studios,
    required this.keywords,
    required this.movieDescriptor,
    required this.tvSeriesDescriptor,
    required this.viewingProgress,
    required this.openMedia,
    required this.openPerson,
    required this.openCollection,
    required this.openStudio,
    required this.openKeyword,
    required this.focusSearchShortcut,
    required this.controlSearchShortcutLabel,
    required this.metaSearchShortcutLabel,
    required this.searchCategoriesLabel,
    required this.resultCountLabel,
    required this.formatRating,
    required this.ratingSemanticLabel,
  });

  final String pageTitle;
  final String searchFieldLabel;
  final String searchHint;
  final String clearSearch;

  final String retry;
  final String seeAll;

  final String recentSearches;
  final String recommended;
  final String clearRecent;
  final String removeRecentSearch;

  final String searching;
  final String loadingMore;
  final String loadMore;
  final String tryAgain;

  final String noResultsTitle;
  final String noResultsMessage;
  final String searchErrorTitle;
  final String searchErrorMessage;
  final String startSearchingTitle;
  final String startSearchingMessage;

  final String gridLabel;
  final String listLabel;

  final String all;
  final String movies;
  final String tvSeries;
  final String people;
  final String collections;
  final String studios;
  final String keywords;

  /// Localized fallback descriptor for a movie result.
  final String movieDescriptor;

  /// Localized fallback descriptor for a TV-series result.
  final String tvSeriesDescriptor;

  final String viewingProgress;

  final String openMedia;
  final String openPerson;
  final String openCollection;
  final String openStudio;
  final String openKeyword;

  final String focusSearchShortcut;

  /// Visual keyboard shortcut labels supplied by the localization layer.
  ///
  /// Keeping these injected avoids embedding platform key names in a language-
  /// specific way. Typical values are equivalent to Control+K and Command+K.
  final String controlSearchShortcutLabel;
  final String metaSearchShortcutLabel;

  final String searchCategoriesLabel;

  /// Locale-aware pluralized result-count label supplied by the app.
  ///
  /// Example implementations may use ICU plural rules rather than a binary
  /// singular/plural branch.
  final CinearaSearchResultCountLabel resultCountLabel;

  /// Locale-aware visual rating formatter supplied by the app.
  ///
  /// This is used for the rendered external-rating badge so decimal separators
  /// and digits may follow the active locale.
  final CinearaSearchRatingFormatter formatRating;

  /// Locale-aware accessibility phrase for an external rating.
  final CinearaSearchRatingSemanticLabel ratingSemanticLabel;

  String labelFor(CinearaSearchCategory category) {
    return switch (category) {
      CinearaSearchCategory.all => all,
      CinearaSearchCategory.movies => movies,
      CinearaSearchCategory.tvSeries => tvSeries,
      CinearaSearchCategory.people => people,
      CinearaSearchCategory.collections => collections,
      CinearaSearchCategory.studios => studios,
      CinearaSearchCategory.keywords => keywords,
    };
  }
}

/// Search request supplied to the application/repository layer.
///
/// The repository should map [category] to the backend's `type` argument and
/// fulfil this from `GET /api/v1/search`. The Search page intentionally does
/// not request Search enrichment.
@immutable
final class CinearaSearchRequest {
  const CinearaSearchRequest({
    required this.query,
    required this.category,
    required this.page,
  }) : assert(query != ''),
       assert(page >= 1);

  final String query;
  final CinearaSearchCategory category;
  final int page;
}

/// Loader contract used by [CinearaSearchPage].
///
/// Keeping transport outside the widget makes the page usable with the real
/// repository, mocks, fixtures, offline caches, and tests without embedding
/// HTTP concerns in presentation code.
typedef CinearaSearchLoader =
    Future<CinearaSearchResponse> Function(CinearaSearchRequest request);

typedef CinearaSearchViewModeChanged =
    void Function(CinearaSearchCategory category, CinearaViewMode mode);

/// One page returned by the Search loader.
@immutable
final class CinearaSearchResponse {
  const CinearaSearchResponse({
    required this.results,
    this.page = 1,
    this.totalPages = 1,
    this.totalResults,
  }) : assert(page >= 1),
       assert(totalPages >= 0),
       assert(totalResults == null || totalResults >= 0);

  final List<CinearaSearchResult> results;
  final int page;
  final int totalPages;
  final int? totalResults;

  bool get hasNextPage => page < totalPages;

  CinearaSearchResponse append(CinearaSearchResponse next) {
    final LinkedHashMap<String, CinearaSearchResult> deduplicated =
        LinkedHashMap<String, CinearaSearchResult>();

    for (final CinearaSearchResult result in results) {
      deduplicated[result.stableKey] = result;
    }

    for (final CinearaSearchResult result in next.results) {
      deduplicated[result.stableKey] = result;
    }

    return CinearaSearchResponse(
      results: List<CinearaSearchResult>.unmodifiable(deduplicated.values),
      page: next.page,
      totalPages: next.totalPages,
      totalResults: next.totalResults ?? totalResults,
    );
  }
}

/// Base presentation result consumed by Search.
@immutable
sealed class CinearaSearchResult {
  const CinearaSearchResult({required this.id, required this.title})
    : assert(id != ''),
      assert(title != '');

  final String id;
  final String title;

  String get stableKey;
}

enum CinearaSearchMediaKind { movie, tvSeries }

/// Search media result suitable for both Grid/rail and List presentation.
@immutable
final class CinearaSearchMediaResult extends CinearaSearchResult {
  const CinearaSearchMediaResult({
    required super.id,
    required super.title,
    required this.kind,
    required this.descriptor,
    this.poster,
    this.year,
    this.primaryGenre,
    this.externalRating,
    this.lifecycleStatus,
    this.favorite = false,
    this.watchlist = false,
    this.collection = false,
    this.personalRating,
    this.progress,
    this.heroTag,
  }) : assert(descriptor != ''),
       assert(
         externalRating == null ||
             (externalRating >= 0 && externalRating <= 10),
       ),
       assert(
         personalRating == null ||
             (personalRating >= 0 && personalRating <= 10),
       ),
       assert(progress == null || (progress >= 0 && progress <= 1));

  final CinearaSearchMediaKind kind;
  final String descriptor;

  final ImageProvider<Object>? poster;
  final int? year;
  final String? primaryGenre;

  final double? externalRating;
  final CinearaStatusBadgeType? lifecycleStatus;

  final bool favorite;
  final bool watchlist;
  final bool collection;
  final double? personalRating;
  final double? progress;

  final Object? heroTag;

  bool get hasPersonalState {
    return favorite || watchlist || collection || personalRating != null;
  }

  @override
  String get stableKey => 'media:${kind.name}:$id';
}

/// Search person result.
@immutable
final class CinearaSearchPersonResult extends CinearaSearchResult {
  const CinearaSearchPersonResult({
    required super.id,
    required super.title,
    this.portrait,
    this.knownForDepartment,
    this.knownFor = const <CinearaPersonKnownForItem>[],
    this.favorite = false,
    this.heroTag,
  });

  final ImageProvider<Object>? portrait;
  final String? knownForDepartment;
  final List<CinearaPersonKnownForItem> knownFor;
  final bool favorite;
  final Object? heroTag;

  @override
  String get stableKey => 'person:$id';
}

enum CinearaSearchEntityKind { collection, studio }

/// Collection or Studio Search result.
@immutable
final class CinearaSearchEntityResult extends CinearaSearchResult {
  const CinearaSearchEntityResult({
    required super.id,
    required super.title,
    required this.kind,
    this.artwork,
    this.favorite = false,
    this.heroTag,
  });

  final CinearaSearchEntityKind kind;
  final ImageProvider<Object>? artwork;
  final bool favorite;
  final Object? heroTag;

  CinearaEntityVisualVariant get visualVariant {
    return switch (kind) {
      CinearaSearchEntityKind.collection => CinearaEntityVisualVariant.poster,
      CinearaSearchEntityKind.studio => CinearaEntityVisualVariant.logo,
    };
  }

  @override
  String get stableKey => 'entity:${kind.name}:$id';
}

/// Text-only keyword Search result.
///
/// Keywords deliberately do not fabricate artwork.
@immutable
final class CinearaSearchKeywordResult extends CinearaSearchResult {
  const CinearaSearchKeywordResult({
    required super.id,
    required super.title,
    this.favorite = false,
  });

  final bool favorite;

  @override
  String get stableKey => 'keyword:$id';
}

// =============================================================================
// App-facing Search dependencies
// =============================================================================

typedef CinearaSearchLocalizationsResolver =
    CinearaSearchLocalizations Function(BuildContext context);

typedef CinearaSearchStatusDockLabelsResolver =
    CinearaStatusDockLabels Function(BuildContext context);

typedef CinearaSearchStatusLabelResolver =
    String Function(BuildContext context, CinearaStatusBadgeType type);

typedef CinearaSearchMediaNavigation =
    void Function(
      BuildContext context,
      AppRootDestination destination,
      CinearaSearchMediaResult result,
    );

typedef CinearaSearchPersonNavigation =
    void Function(
      BuildContext context,
      AppRootDestination destination,
      CinearaSearchPersonResult result,
    );

typedef CinearaSearchEntityNavigation =
    void Function(
      BuildContext context,
      AppRootDestination destination,
      CinearaSearchEntityResult result,
    );

typedef CinearaSearchKeywordNavigation =
    void Function(
      BuildContext context,
      AppRootDestination destination,
      CinearaSearchKeywordResult result,
    );

/// Shared state used by Cineara's shell-level Search field and the routed
/// Search results page.
///
/// The query field lives in [CinearaAppShell], while the actual search lifecycle
/// remains owned by [CinearaSearchPage]. This controller is the narrow bridge
/// between those two layers.
final class CinearaSearchChromeController extends ChangeNotifier {
  CinearaSearchChromeController();

  final TextEditingController queryController = TextEditingController();

  final FocusNode focusNode = FocusNode(debugLabel: 'CinearaSearchQuery');

  Object? _owner;

  ValueChanged<String>? _onChanged;
  ValueChanged<String>? _onSubmitted;
  VoidCallback? _onClear;

  bool _loading = false;

  bool get loading => _loading;

  void attach({
    required Object owner,
    required ValueChanged<String> onChanged,
    required ValueChanged<String> onSubmitted,
    required VoidCallback onClear,
  }) {
    _owner = owner;
    _onChanged = onChanged;
    _onSubmitted = onSubmitted;
    _onClear = onClear;
    notifyListeners();
  }

  void detach(Object owner, {bool clearQuery = false}) {
    if (!identical(_owner, owner)) {
      return;
    }

    _owner = null;
    _onChanged = null;
    _onSubmitted = null;
    _onClear = null;
    _loading = false;

    if (clearQuery) {
      focusNode.unfocus();
      queryController.clear();
    }

    notifyListeners();
  }

  /// Clears transient Search chrome when Search is left through root
  /// navigation rather than the Search page's own back action.
  void resetForNavigation() {
    focusNode.unfocus();
    queryController.clear();

    if (_loading) {
      _loading = false;
    }

    notifyListeners();
  }

  void setLoading({required Object owner, required bool value}) {
    if (!identical(_owner, owner) || _loading == value) {
      return;
    }

    _loading = value;
    notifyListeners();
  }

  void handleChanged(String value) {
    notifyListeners();

    final ValueChanged<String>? callback = _onChanged;

    if (callback == null) {
      if (kDebugMode) {
        debugPrint(
          '[SearchChrome] Query changed without an active SearchPage owner.',
        );
      }
      return;
    }

    callback(value);
  }

  void handleSubmitted(String value) {
    final ValueChanged<String>? callback = _onSubmitted;

    if (callback == null) {
      if (kDebugMode) {
        debugPrint(
          '[SearchChrome] Query submitted without an active SearchPage owner.',
        );
      }
      return;
    }

    callback(value);
  }

  void clearSearch() {
    _onClear?.call();
  }

  @override
  void dispose() {
    focusNode.dispose();
    queryController.dispose();
    super.dispose();
  }
}

/// App-level dependencies used by the thin [SearchPage] route entry.
///
/// This object deliberately keeps framework- or package-specific dependency
/// injection out of the Search UI. The application can build one instance from
/// its repository, generated localizations and navigation policy, then expose it
/// above the router with [CinearaSearchDependenciesScope].
@immutable
final class CinearaSearchDependencies {
  const CinearaSearchDependencies({
    required this.loader,
    required this.chromeController,
    required this.localizations,
    required this.statusDockLabels,
    required this.statusLabel,
    required this.onMediaTap,
    required this.onPersonTap,
    required this.onEntityTap,
    this.onKeywordTap,
    this.onMediaLongPress,
    this.onPersonLongPress,
    this.onEntityLongPress,
    this.onKeywordLongPress,
    this.initialRecentSearches = const <String>[],
    this.recommendedSearches = const <String>[],
    this.onRecentSearchesChanged,
    this.onViewModeChanged,
  });

  final CinearaSearchLoader loader;
  final CinearaSearchChromeController chromeController;

  final CinearaSearchLocalizationsResolver localizations;
  final CinearaSearchStatusDockLabelsResolver statusDockLabels;
  final CinearaSearchStatusLabelResolver statusLabel;

  final CinearaSearchMediaNavigation onMediaTap;
  final CinearaSearchPersonNavigation onPersonTap;
  final CinearaSearchEntityNavigation onEntityTap;
  final CinearaSearchKeywordNavigation? onKeywordTap;

  final CinearaSearchMediaNavigation? onMediaLongPress;
  final CinearaSearchPersonNavigation? onPersonLongPress;
  final CinearaSearchEntityNavigation? onEntityLongPress;
  final CinearaSearchKeywordNavigation? onKeywordLongPress;

  final List<String> initialRecentSearches;
  final List<String> recommendedSearches;

  final ValueChanged<List<String>>? onRecentSearchesChanged;
  final CinearaSearchViewModeChanged? onViewModeChanged;
}

/// Inherited bridge between Cineara's app composition and the Search feature.
///
/// Place this once above the router (or above the shell containing Search).
/// [SearchPage] then resolves its dependencies from the current [BuildContext],
/// which keeps `app_branch_routes.dart` limited to route composition.
final class CinearaSearchDependenciesScope extends InheritedWidget {
  const CinearaSearchDependenciesScope({
    required this.dependencies,
    required super.child,
    super.key,
  });

  final CinearaSearchDependencies dependencies;

  static CinearaSearchDependencies of(BuildContext context) {
    final CinearaSearchDependenciesScope? scope = context
        .dependOnInheritedWidgetOfExactType<CinearaSearchDependenciesScope>();

    assert(
      scope != null,
      'SearchPage requires CinearaSearchDependenciesScope above the router.',
    );

    if (scope == null) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('Search dependencies are unavailable.'),
        ErrorDescription(
          'SearchPage must be built below a CinearaSearchDependenciesScope.',
        ),
        ErrorHint(
          'Provide the application Search loader, localization resolvers and '
          'navigation callbacks once at app composition level.',
        ),
      ]);
    }

    return scope.dependencies;
  }

  @override
  bool updateShouldNotify(CinearaSearchDependenciesScope oldWidget) {
    return oldWidget.dependencies != dependencies;
  }
}

// =============================================================================
// Feature route entry
// =============================================================================

/// Thin application-facing page used by Cineara's shared branch routes.
///
/// The owning [destination] is retained only for branch-aware navigation.
/// Search UI, transport and localization remain centralized in the production
/// [CinearaSearchPage] implementation below.
///
/// Typical route usage:
///
/// ```dart
/// GoRoute(
///   path: AppRoutes.searchSegment,
///   builder: (context, state) {
///     return SearchPage(destination: destination);
///   },
/// )
/// ```
final class SearchPage extends StatelessWidget {
  const SearchPage({
    required this.destination,
    super.key,
    this.initialQuery = '',
    this.initialCategory = CinearaSearchCategory.all,
    this.initialViewModes = const <CinearaSearchCategory, CinearaViewMode>{},
    this.autofocus = true,
  });

  final AppRootDestination destination;

  final String initialQuery;
  final CinearaSearchCategory initialCategory;
  final Map<CinearaSearchCategory, CinearaViewMode> initialViewModes;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final CinearaSearchDependencies dependencies =
        CinearaSearchDependenciesScope.of(context);

    final CinearaSearchKeywordNavigation? keywordTap =
        dependencies.onKeywordTap;
    final CinearaSearchMediaNavigation? mediaLongPress =
        dependencies.onMediaLongPress;
    final CinearaSearchPersonNavigation? personLongPress =
        dependencies.onPersonLongPress;
    final CinearaSearchEntityNavigation? entityLongPress =
        dependencies.onEntityLongPress;
    final CinearaSearchKeywordNavigation? keywordLongPress =
        dependencies.onKeywordLongPress;

    return CinearaSearchPage(
      loader: dependencies.loader,
      chromeController: dependencies.chromeController,
      localizations: dependencies.localizations(context),
      statusDockLabels: dependencies.statusDockLabels(context),
      statusLabelBuilder: (CinearaStatusBadgeType type) {
        return dependencies.statusLabel(context, type);
      },
      onMediaTap: (CinearaSearchMediaResult result) {
        dependencies.onMediaTap(context, destination, result);
      },
      onPersonTap: (CinearaSearchPersonResult result) {
        dependencies.onPersonTap(context, destination, result);
      },
      onEntityTap: (CinearaSearchEntityResult result) {
        dependencies.onEntityTap(context, destination, result);
      },
      onKeywordTap: keywordTap == null
          ? null
          : (CinearaSearchKeywordResult result) {
              keywordTap(context, destination, result);
            },
      onMediaLongPress: mediaLongPress == null
          ? null
          : (CinearaSearchMediaResult result) {
              mediaLongPress(context, destination, result);
            },
      onPersonLongPress: personLongPress == null
          ? null
          : (CinearaSearchPersonResult result) {
              personLongPress(context, destination, result);
            },
      onEntityLongPress: entityLongPress == null
          ? null
          : (CinearaSearchEntityResult result) {
              entityLongPress(context, destination, result);
            },
      onKeywordLongPress: keywordLongPress == null
          ? null
          : (CinearaSearchKeywordResult result) {
              keywordLongPress(context, destination, result);
            },
      initialQuery: initialQuery,
      initialCategory: initialCategory,
      initialRecentSearches: dependencies.initialRecentSearches,
      recommendedSearches: dependencies.recommendedSearches,
      initialViewModes: initialViewModes,
      onRecentSearchesChanged: dependencies.onRecentSearchesChanged,
      onViewModeChanged: dependencies.onViewModeChanged,
      autofocus: autofocus,
    );
  }
}

// =============================================================================
// Search page
// =============================================================================

/// Production Search page that composes Cineara's existing result primitives.
///
/// Quality-of-life behaviour:
///
/// - live debounced searching with stale-response protection;
/// - explicit Search keyboard submission;
/// - Ctrl/Cmd + K focuses the field;
/// - Escape clears the query, then dismisses focus;
/// - stale async responses are ignored;
/// - up to ten recent searches are maintained;
/// - recommended and recent searches are one-tap reusable;
/// - All groups results into deterministic sections without gating content behind entrance animations;
/// - focused categories support Grid/List where meaningful;
/// - Keywords remain text-only/List-only;
/// - infinite pagination is triggered near the end of focused results;
/// - a manual pagination retry remains available if loading more fails;
/// - pull-to-refresh retries the active query;
/// - Search presentation never invokes enrichment;
/// - all user-facing copy and locale-sensitive formatting are injected;
/// - RTL/LTR follows the ambient Directionality without assuming a language;
/// - layouts reflow for large accessibility text instead of clipping controls.
final class CinearaSearchPage extends StatefulWidget {
  const CinearaSearchPage({
    required this.loader,
    required this.chromeController,
    required this.localizations,
    required this.statusDockLabels,
    required this.statusLabelBuilder,
    required this.onMediaTap,
    required this.onPersonTap,
    required this.onEntityTap,
    super.key,
    this.onKeywordTap,
    this.onMediaLongPress,
    this.onPersonLongPress,
    this.onEntityLongPress,
    this.onKeywordLongPress,
    this.initialQuery = '',
    this.initialCategory = CinearaSearchCategory.all,
    this.initialRecentSearches = const <String>[],
    this.recommendedSearches = const <String>[],
    this.initialViewModes = const <CinearaSearchCategory, CinearaViewMode>{},
    this.onRecentSearchesChanged,
    this.onViewModeChanged,
    this.debounceDuration = const Duration(milliseconds: 650),
    this.autofocus = true,
    this.maximumContentWidth = CinearaContentWidths.extraWide,
    this.allSectionItemLimit = 12,
    this.paginationTriggerDistance = 720,
  }) : assert(allSectionItemLimit > 0),
       assert(paginationTriggerDistance >= 0),
       assert(maximumContentWidth > 0);

  final CinearaSearchLoader loader;
  final CinearaSearchChromeController chromeController;

  final CinearaStatusDockLabels statusDockLabels;
  final String Function(CinearaStatusBadgeType type) statusLabelBuilder;

  final ValueChanged<CinearaSearchMediaResult> onMediaTap;
  final ValueChanged<CinearaSearchPersonResult> onPersonTap;
  final ValueChanged<CinearaSearchEntityResult> onEntityTap;
  final ValueChanged<CinearaSearchKeywordResult>? onKeywordTap;

  final ValueChanged<CinearaSearchMediaResult>? onMediaLongPress;
  final ValueChanged<CinearaSearchPersonResult>? onPersonLongPress;
  final ValueChanged<CinearaSearchEntityResult>? onEntityLongPress;
  final ValueChanged<CinearaSearchKeywordResult>? onKeywordLongPress;

  final CinearaSearchLocalizations localizations;

  final String initialQuery;
  final CinearaSearchCategory initialCategory;

  final List<String> initialRecentSearches;
  final List<String> recommendedSearches;

  final Map<CinearaSearchCategory, CinearaViewMode> initialViewModes;

  final ValueChanged<List<String>>? onRecentSearchesChanged;
  final CinearaSearchViewModeChanged? onViewModeChanged;

  final Duration debounceDuration;
  final bool autofocus;

  final double maximumContentWidth;
  final int allSectionItemLimit;
  final double paginationTriggerDistance;

  @override
  State<CinearaSearchPage> createState() => _CinearaSearchPageState();
}

final class _CinearaSearchPageState extends State<CinearaSearchPage> {
  static const int _maximumRecentSearches = 10;

  late final ScrollController _scrollController;

  CinearaSearchChromeController get _chromeController =>
      widget.chromeController;

  TextEditingController get _queryController =>
      _chromeController.queryController;

  FocusNode get _queryFocusNode => _chromeController.focusNode;

  Timer? _debounceTimer;

  late CinearaSearchCategory _category;
  late List<String> _recentSearches;
  late Map<CinearaSearchCategory, CinearaViewMode> _viewModes;

  CinearaSearchResponse? _response;

  String _activeQuery = '';

  Object? _initialError;
  Object? _paginationError;

  bool _initialLoading = false;
  bool _loadingMore = false;
  bool _requestInFlight = false;

  int _requestGeneration = 0;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController()..addListener(_handleScroll);

    _chromeController.attach(
      owner: this,
      onChanged: _handleQueryChanged,
      onSubmitted: _handleSubmitted,
      onClear: _clearSearch,
    );

    _queryController
      ..text = widget.initialQuery
      ..selection = TextSelection.collapsed(offset: widget.initialQuery.length);

    _category = widget.initialCategory;
    _recentSearches = _sanitizeSearchTerms(widget.initialRecentSearches);

    _viewModes = <CinearaSearchCategory, CinearaViewMode>{
      for (final CinearaSearchCategory category in CinearaSearchCategory.values)
        if (category.supportsViewMode)
          category: widget.initialViewModes[category] ?? CinearaViewMode.grid,
    };

    final String initialQuery = _normalizeQuery(widget.initialQuery);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      if (initialQuery.isNotEmpty) {
        unawaited(_search(query: initialQuery, reset: true));
      }

      if (widget.autofocus) {
        unawaited(_focusAfterShellExpansion());
      }
    });
  }

  @override
  void didUpdateWidget(CinearaSearchPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!identical(oldWidget.chromeController, widget.chromeController)) {
      oldWidget.chromeController.detach(this);

      widget.chromeController.attach(
        owner: this,
        onChanged: _handleQueryChanged,
        onSubmitted: _handleSubmitted,
        onClear: _clearSearch,
      );
    }

    if (!listEquals(
      oldWidget.initialRecentSearches,
      widget.initialRecentSearches,
    )) {
      _recentSearches = _sanitizeSearchTerms(widget.initialRecentSearches);
    }
  }

  @override
  void dispose() {
    _requestGeneration++;
    _requestInFlight = false;
    _debounceTimer?.cancel();

    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();

    _chromeController.detach(this, clearQuery: true);

    super.dispose();
  }

  /// Gives the shell-level Search surface time to expand before requesting
  /// keyboard focus so the field and IME enter as one continuous interaction.
  Future<void> _focusAfterShellExpansion() async {
    final Duration delay = _resolvedSearchMotionDuration(
      context,
      CinearaMotion.searchTransition,
    );

    if (delay != Duration.zero) {
      await Future<void>.delayed(delay);
    }

    if (!mounted || !_queryFocusNode.canRequestFocus) {
      return;
    }

    _queryFocusNode.requestFocus();
  }

  // ---------------------------------------------------------------------------
  // Query lifecycle
  // ---------------------------------------------------------------------------

  void _handleQueryChanged(String rawValue) {
    _debounceTimer?.cancel();

    final String query = _normalizeQuery(rawValue);

    // Any in-flight response now belongs to an older query and must not be
    // allowed to replace the next Search state.
    _requestGeneration++;
    _requestInFlight = false;

    if (query.isEmpty) {
      _clearResultState();
      return;
    }

    setState(() {
      _activeQuery = query;
      _response = null;
      _initialError = null;
      _paginationError = null;
      _initialLoading = true;
      _loadingMore = false;
    });

    _debounceTimer = Timer(widget.debounceDuration, () {
      if (!mounted || _activeQuery != query) {
        return;
      }

      unawaited(_search(query: query, reset: true, statePrepared: true));
    });
  }

  void _handleSubmitted(String rawValue) {
    final String query = _normalizeQuery(rawValue);

    if (query.isEmpty) {
      _debounceTimer?.cancel();
      _queryFocusNode.requestFocus();
      return;
    }

    _addRecentSearch(query);

    // Submitting the same query must not issue a second request when the
    // debounced request is already running or its successful results are
    // already on screen.
    if (_activeQuery == query) {
      if (_requestInFlight) {
        _debounceTimer?.cancel();
        return;
      }

      if (_response != null && _initialError == null) {
        _debounceTimer?.cancel();
        return;
      }
    }

    _debounceTimer?.cancel();

    final bool statePrepared =
        _initialLoading &&
        _response == null &&
        _initialError == null &&
        _activeQuery == query;

    unawaited(_search(query: query, reset: true, statePrepared: statePrepared));
  }

  void _clearSearch() {
    _debounceTimer?.cancel();

    _queryController.clear();
    _clearResultState();

    if (!_queryFocusNode.hasFocus) {
      _queryFocusNode.requestFocus();
    }
  }

  void _clearResultState() {
    _requestGeneration++;
    _requestInFlight = false;

    if (!mounted) {
      return;
    }

    setState(() {
      _activeQuery = '';
      _response = null;
      _initialError = null;
      _paginationError = null;
      _initialLoading = false;
      _loadingMore = false;
    });
  }

  Future<void> _search({
    required String query,
    required bool reset,
    int? page,
    bool statePrepared = false,
  }) async {
    final String normalized = _normalizeQuery(query);

    if (normalized.isEmpty) {
      _clearResultState();
      return;
    }

    if (!reset && (_initialLoading || _loadingMore || _requestInFlight)) {
      return;
    }

    final int requestPage = page ?? (reset ? 1 : ((_response?.page ?? 0) + 1));
    final int generation = ++_requestGeneration;

    if (reset) {
      final bool reusePreparedState =
          statePrepared &&
          _activeQuery == normalized &&
          _initialLoading &&
          _response == null;

      if (!reusePreparedState) {
        setState(() {
          _activeQuery = normalized;
          _response = null;
          _initialError = null;
          _paginationError = null;
          _initialLoading = true;
          _loadingMore = false;
        });
      }
    } else {
      setState(() {
        _paginationError = null;
        _loadingMore = true;
      });
    }

    _requestInFlight = true;

    if (kDebugMode) {
      debugPrint(
        '[Search] request query="$normalized" '
        'category=${_category.name} page=$requestPage',
      );
    }

    try {
      final CinearaSearchResponse next = await widget.loader(
        CinearaSearchRequest(
          query: normalized,
          category: _category,
          page: requestPage,
        ),
      );

      if (!mounted || generation != _requestGeneration) {
        return;
      }

      _requestInFlight = false;

      if (kDebugMode) {
        debugPrint(
          '[Search] response query="$normalized" '
          'category=${_category.name} page=${next.page} '
          'results=${next.results.length} total=${next.totalResults}',
        );
      }

      setState(() {
        _initialLoading = false;
        _loadingMore = false;
        _initialError = null;
        _paginationError = null;

        _response = reset || _response == null ? next : _response!.append(next);
      });
    } catch (error, stackTrace) {
      if (!mounted || generation != _requestGeneration) {
        return;
      }

      _requestInFlight = false;

      if (kDebugMode) {
        debugPrint(
          '[Search] failed query="$normalized" '
          'category=${_category.name}: $error',
        );
        debugPrintStack(stackTrace: stackTrace);
      }

      setState(() {
        _initialLoading = false;
        _loadingMore = false;

        if (reset) {
          _initialError = error;
          _response = null;
        } else {
          _paginationError = error;
        }
      });
    }
  }

  Future<void> _refresh() async {
    final String query = _normalizeQuery(_queryController.text);

    if (query.isEmpty) {
      return;
    }

    await _search(query: query, reset: true);
  }

  void _handleScroll() {
    if (_category == CinearaSearchCategory.all ||
        _initialLoading ||
        _loadingMore ||
        _paginationError != null) {
      return;
    }

    final CinearaSearchResponse? response = _response;

    if (response == null ||
        !response.hasNextPage ||
        !_scrollController.hasClients) {
      return;
    }

    if (_scrollController.position.extentAfter >
        widget.paginationTriggerDistance) {
      return;
    }

    unawaited(_search(query: _activeQuery, reset: false));
  }

  // ---------------------------------------------------------------------------
  // Category / view mode
  // ---------------------------------------------------------------------------

  void _selectCategory(CinearaSearchCategory next) {
    if (next == _category) {
      return;
    }

    _debounceTimer?.cancel();

    setState(() {
      _category = next;
      _initialError = null;
      _paginationError = null;
    });

    final String query = _normalizeQuery(_queryController.text);

    if (query.isNotEmpty) {
      unawaited(_search(query: query, reset: true));
    }

    _scrollToTop();
  }

  void _setViewMode(CinearaViewMode mode) {
    if (!_category.supportsViewMode || _viewModes[_category] == mode) {
      return;
    }

    setState(() {
      _viewModes[_category] = mode;
    });

    widget.onViewModeChanged?.call(_category, mode);
  }

  void _openAllSection(CinearaSearchCategory category) {
    final String query = _normalizeQuery(_queryController.text);

    if (query.isNotEmpty) {
      _addRecentSearch(query);
    }

    _selectCategory(category);
  }

  void _scrollToTop() {
    if (!_scrollController.hasClients) {
      return;
    }

    final Duration duration = _resolvedSearchMotionDuration(
      context,
      CinearaMotion.standard,
    );

    if (duration == Duration.zero) {
      _scrollController.jumpTo(0);
      return;
    }

    unawaited(
      _scrollController.animateTo(
        0,
        duration: duration,
        curve: CinearaMotion.standardCurve,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Recent/recommended search helpers
  // ---------------------------------------------------------------------------

  void _useSearchTerm(String term) {
    final String normalized = _normalizeQuery(term);

    if (normalized.isEmpty) {
      return;
    }

    _debounceTimer?.cancel();

    _queryController
      ..text = normalized
      ..selection = TextSelection.collapsed(offset: normalized.length);

    _addRecentSearch(normalized);
    _queryFocusNode.unfocus();

    unawaited(_search(query: normalized, reset: true));
  }

  void _addRecentSearch(String term) {
    final String normalized = _normalizeQuery(term);

    if (normalized.isEmpty) {
      return;
    }

    final List<String> next = <String>[
      normalized,
      for (final String existing in _recentSearches)
        if (existing != normalized) existing,
    ].take(_maximumRecentSearches).toList(growable: false);

    if (listEquals(next, _recentSearches)) {
      return;
    }

    setState(() {
      _recentSearches = next;
    });

    widget.onRecentSearchesChanged?.call(
      List<String>.unmodifiable(_recentSearches),
    );
  }

  void _removeRecentSearch(String term) {
    final List<String> next = _recentSearches
        .where((String item) => item != term)
        .toList(growable: false);

    setState(() {
      _recentSearches = next;
    });

    widget.onRecentSearchesChanged?.call(
      List<String>.unmodifiable(_recentSearches),
    );
  }

  void _clearRecentSearches() {
    if (_recentSearches.isEmpty) {
      return;
    }

    setState(() {
      _recentSearches = const <String>[];
    });

    widget.onRecentSearchesChanged?.call(const <String>[]);
  }

  List<String> _sanitizeSearchTerms(Iterable<String> values) {
    final LinkedHashMap<String, String> unique =
        LinkedHashMap<String, String>();

    for (final String value in values) {
      final String normalized = _normalizeQuery(value);

      if (normalized.isEmpty) {
        continue;
      }

      unique.putIfAbsent(normalized, () => normalized);

      if (unique.length == _maximumRecentSearches) {
        break;
      }
    }

    return List<String>.unmodifiable(unique.values);
  }

  String _normalizeQuery(String value) {
    return value.trim().replaceAll(RegExp(r'\s+', unicode: true), ' ');
  }

  // ---------------------------------------------------------------------------
  // Result navigation
  // ---------------------------------------------------------------------------

  void _handleMediaTap(CinearaSearchMediaResult result) {
    _recordCurrentQuery();
    widget.onMediaTap(result);
  }

  void _handlePersonTap(CinearaSearchPersonResult result) {
    _recordCurrentQuery();
    widget.onPersonTap(result);
  }

  void _handleEntityTap(CinearaSearchEntityResult result) {
    _recordCurrentQuery();
    widget.onEntityTap(result);
  }

  void _handleKeywordTap(CinearaSearchKeywordResult result) {
    _recordCurrentQuery();

    final ValueChanged<CinearaSearchKeywordResult>? callback =
        widget.onKeywordTap;

    if (callback != null) {
      callback(result);
      return;
    }

    _useSearchTerm(result.title);
  }

  void _recordCurrentQuery() {
    final String query = _normalizeQuery(_queryController.text);

    if (query.isNotEmpty) {
      _addRecentSearch(query);
    }
  }

  // ---------------------------------------------------------------------------
  // Keyboard quality-of-life
  // ---------------------------------------------------------------------------

  void _focusSearch() {
    _queryFocusNode.requestFocus();

    _queryController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _queryController.text.length,
    );
  }

  void _handleEscape() {
    if (_queryController.text.isNotEmpty) {
      _clearSearch();
      return;
    }

    _queryFocusNode.unfocus();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final Widget scrollable = RefreshIndicator(
      onRefresh: _refresh,
      child: CustomScrollView(
        controller: _scrollController,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: widget.maximumContentWidth,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      _horizontalPagePadding(context),
                      CinearaSpacing.md,
                      _horizontalPagePadding(context),
                      CinearaSpacing.xxxl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _buildControls(context),
                        const SizedBox(height: CinearaSpacing.xl),
                        _buildBody(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    final Widget shortcuts = Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.keyK, control: true):
            _FocusSearchIntent(),
        SingleActivator(LogicalKeyboardKey.keyK, meta: true):
            _FocusSearchIntent(),
        SingleActivator(LogicalKeyboardKey.escape): _DismissSearchIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _FocusSearchIntent: CallbackAction<_FocusSearchIntent>(
            onInvoke: (_FocusSearchIntent intent) {
              _focusSearch();
              return null;
            },
          ),
          _DismissSearchIntent: CallbackAction<_DismissSearchIntent>(
            onInvoke: (_DismissSearchIntent intent) {
              _handleEscape();
              return null;
            },
          ),
        },
        child: scrollable,
      ),
    );

    return SizedBox.expand(
      child: Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(top: false, child: shortcuts),
      ),
    );
  }

  Widget _buildControls(BuildContext context) {
    return _SearchCategoryPills(
      value: _category,
      localizations: widget.localizations,
      onChanged: _selectCategory,
    );
  }

  Widget _buildBody(BuildContext context) {
    final String query = _normalizeQuery(_queryController.text);

    return _buildBodyContent(context, query);
  }

  Widget _buildBodyContent(BuildContext context, String query) {
    if (query.isEmpty) {
      return _InitialSearchContent(
        recentSearches: _recentSearches,
        recommendedSearches: widget.recommendedSearches,
        localizations: widget.localizations,
        onSearch: _useSearchTerm,
        onRemoveRecent: _removeRecentSearch,
        onClearRecent: _clearRecentSearches,
      );
    }

    if (_initialLoading && _response == null) {
      return _SearchLoadingView(
        category: _category,
        localizations: widget.localizations,
      );
    }

    if (_initialError != null && _response == null) {
      return _SearchErrorView(
        error: _initialError,
        localizations: widget.localizations,
        onRetry: () {
          unawaited(_search(query: query, reset: true));
        },
      );
    }

    final CinearaSearchResponse? response = _response;

    if (response == null || response.results.isEmpty) {
      return _SearchEmptyView(localizations: widget.localizations);
    }

    if (_category == CinearaSearchCategory.all) {
      return _buildAllResults(context, response);
    }

    return _buildFocusedResults(response);
  }

  // ---------------------------------------------------------------------------
  // All results
  // ---------------------------------------------------------------------------

  Widget _buildAllResults(
    BuildContext context,
    CinearaSearchResponse response,
  ) {
    final List<Widget> sections = <Widget>[];

    for (final CinearaSearchCategory section
        in CinearaSearchCategory.allSections) {
      final List<CinearaSearchResult> results = _resultsForCategory(
        response.results,
        section,
      ).take(widget.allSectionItemLimit).toList(growable: false);

      if (results.isEmpty) {
        continue;
      }

      if (sections.isNotEmpty) {
        sections.add(const SizedBox(height: CinearaSpacing.xxl));
      }
    }

    if (sections.isEmpty) {
      return _SearchEmptyView(localizations: widget.localizations);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: sections,
    );
  }

  List<Widget> _buildRailItems(
    CinearaSearchCategory section,
    List<CinearaSearchResult> results,
  ) {
    final List<Widget> children = switch (section) {
      CinearaSearchCategory.movies || CinearaSearchCategory.tvSeries =>
        results
            .cast<CinearaSearchMediaResult>()
            .map<Widget>(_buildMediaGridItem)
            .toList(growable: false),

      CinearaSearchCategory.people =>
        results
            .cast<CinearaSearchPersonResult>()
            .map<Widget>(
              (CinearaSearchPersonResult result) =>
                  _buildPersonGridItem(result, showKnownFor: false),
            )
            .toList(growable: false),

      CinearaSearchCategory.collections || CinearaSearchCategory.studios =>
        results
            .cast<CinearaSearchEntityResult>()
            .map<Widget>(_buildEntityGridItem)
            .toList(growable: false),

      CinearaSearchCategory.all ||
      CinearaSearchCategory.keywords => const <Widget>[],
    };

    return children;
  }

  double _railItemWidth(double availableWidth) {
    const double spacing = CinearaSpacing.md;
    const double desiredNextItemPeek = 30;
    const double compactVisibleCards = 2.30;

    final double computed =
        (availableWidth - (spacing * 2) - desiredNextItemPeek) /
        compactVisibleCards;

    return computed.clamp(110.0, 136.0).toDouble();
  }

  // ---------------------------------------------------------------------------
  // Focused results
  // ---------------------------------------------------------------------------

  Widget _buildFocusedResults(CinearaSearchResponse response) {
    final List<CinearaSearchResult> results = _resultsForCategory(
      response.results,
      _category,
    );

    if (results.isEmpty) {
      return _SearchEmptyView(localizations: widget.localizations);
    }

    final CinearaViewMode mode = _viewModes[_category] ?? CinearaViewMode.list;
    final bool supportsViewMode = _category.supportsViewMode;

    final Widget resultsLayout =
        !supportsViewMode || mode == CinearaViewMode.list
        ? _buildFocusedList(results)
        : _buildFocusedGrid(results);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _FocusedResultsHeader(
          title: widget.localizations.labelFor(_category),
          resultCount: response.totalResults ?? results.length,
          localizations: widget.localizations,
          viewMode: supportsViewMode ? mode : null,
          onViewModeChanged: _setViewMode,
        ),
        const SizedBox(height: CinearaSpacing.lg),
        resultsLayout,
        if (_loadingMore || _paginationError != null || response.hasNextPage)
          Padding(
            padding: const EdgeInsets.only(top: CinearaSpacing.lg),
            child: _LoadMoreFooter(
              loading: _loadingMore,
              error: _paginationError != null,
              localizations: widget.localizations,
              onPressed: () {
                unawaited(_search(query: _activeQuery, reset: false));
              },
            ),
          ),
      ],
    );
  }

  Widget _buildFocusedGrid(List<CinearaSearchResult> results) {
    final List<Widget> children = switch (_category) {
      CinearaSearchCategory.movies || CinearaSearchCategory.tvSeries =>
        results
            .cast<CinearaSearchMediaResult>()
            .map<Widget>(_buildMediaGridItem)
            .toList(growable: false),

      CinearaSearchCategory.people =>
        results
            .cast<CinearaSearchPersonResult>()
            .map<Widget>(
              (CinearaSearchPersonResult result) =>
                  _buildPersonGridItem(result, showKnownFor: true),
            )
            .toList(growable: false),

      CinearaSearchCategory.collections || CinearaSearchCategory.studios =>
        results
            .cast<CinearaSearchEntityResult>()
            .map<Widget>(_buildEntityGridItem)
            .toList(growable: false),

      CinearaSearchCategory.all ||
      CinearaSearchCategory.keywords => const <Widget>[],
    };

    return CinearaResponsiveGrid(children: children);
  }

  Widget _buildFocusedList(List<CinearaSearchResult> results) {
    return switch (_category) {
      CinearaSearchCategory.movies ||
      CinearaSearchCategory.tvSeries => CinearaContentList(
        maximumWidth: double.infinity,
        separatorStartInset: CinearaMediaListItem.defaultMetadataRailInset,
        separatorEndInset: 0,
        separatorSpacing: CinearaSpacing.xs,
        children: results
            .cast<CinearaSearchMediaResult>()
            .map<Widget>(_buildMediaListItem)
            .toList(growable: false),
      ),

      CinearaSearchCategory.people => CinearaContentList(
        maximumWidth: double.infinity,
        separatorStartInset: CinearaPersonListItem.defaultMetadataRailInset,
        separatorEndInset: 0,
        separatorSpacing: CinearaSpacing.xs,
        children: results
            .cast<CinearaSearchPersonResult>()
            .map<Widget>(_buildPersonListItem)
            .toList(growable: false),
      ),

      CinearaSearchCategory.collections ||
      CinearaSearchCategory.studios => CinearaContentList(
        maximumWidth: double.infinity,
        separatorStartInset: CinearaEntityListItem.defaultMetadataRailInset,
        separatorEndInset: 0,
        separatorSpacing: CinearaSpacing.xs,
        children: results
            .cast<CinearaSearchEntityResult>()
            .map<Widget>(_buildEntityListItem)
            .toList(growable: false),
      ),

      CinearaSearchCategory.keywords => CinearaContentList(
        maximumWidth: double.infinity,
        separatorStartInset: CinearaEntityListItem.textOnlyMetadataRailInset,
        separatorEndInset: 0,
        separatorSpacing: CinearaSpacing.xs,
        children: results
            .cast<CinearaSearchKeywordResult>()
            .map<Widget>(_buildKeywordListItem)
            .toList(growable: false),
      ),

      CinearaSearchCategory.all => const SizedBox.shrink(),
    };
  }

  // ---------------------------------------------------------------------------
  // Production result adapters
  // ---------------------------------------------------------------------------

  String _localizedMediaDescriptor(CinearaSearchMediaResult result) {
    final String machineValue = result.descriptor
        .trim()
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');

    return switch (machineValue) {
      'movie' || 'movies' => widget.localizations.movieDescriptor,
      'tv' ||
      'tv_series' ||
      'tvseries' ||
      'series' ||
      'television' => widget.localizations.tvSeriesDescriptor,
      _ => result.descriptor,
    };
  }

  Widget _buildMediaGridItem(CinearaSearchMediaResult result) {
    return CinearaMediaGridItem(
      key: ValueKey<String>('search-grid-${result.stableKey}'),
      artwork: CinearaPosterImage(
        image: result.poster,
        constrainToPosterAspectRatio: false,
        excludeFromSemantics: true,
      ),
      title: result.title,
      descriptor: _localizedMediaDescriptor(result),
      year: result.year,
      semanticHint: widget.localizations.openMedia,
      heroTag: result.heroTag,
      onPosterTap: () {
        _handleMediaTap(result);
      },
      onPosterLongPress: widget.onMediaLongPress == null
          ? null
          : () {
              _recordCurrentQuery();
              widget.onMediaLongPress!(result);
            },
      statusBadge: _buildArtworkLifecycleBadge(result),
      externalRatingBadge: _buildArtworkRatingBadge(result.externalRating),
      statusDock: _buildArtworkPersonalDock(result),
      progressIndicator: result.progress == null
          ? null
          : CinearaMediaProgressIndicator(
              value: result.progress,
              variant: CinearaMediaProgressVariant.posterEdge,
              semanticLabel: widget.localizations.viewingProgress,
            ),
    );
  }

  Widget _buildMediaListItem(CinearaSearchMediaResult result) {
    return CinearaMediaListItem(
      key: ValueKey<String>('search-list-${result.stableKey}'),
      artwork: CinearaPosterImage(
        image: result.poster,
        constrainToPosterAspectRatio: false,
        excludeFromSemantics: true,
      ),
      title: result.title,
      descriptor: _localizedMediaDescriptor(result),
      year: result.year,
      primaryGenre: result.primaryGenre,
      semanticHint: widget.localizations.openMedia,
      externalRatingBadge: _buildArtworkRatingBadge(result.externalRating),
      progressIndicator: result.progress == null
          ? null
          : CinearaMediaProgressIndicator(
              value: result.progress,
              variant: CinearaMediaProgressVariant.posterEdge,
              semanticLabel: widget.localizations.viewingProgress,
            ),
      lifecycleStatus: _buildSurfaceLifecycleBadge(result),
      personalDock: _buildSurfacePersonalDock(result),
      onTap: () {
        _handleMediaTap(result);
      },
      onLongPress: widget.onMediaLongPress == null
          ? null
          : () {
              _recordCurrentQuery();
              widget.onMediaLongPress!(result);
            },
    );
  }

  CinearaStatusBadge? _buildArtworkLifecycleBadge(
    CinearaSearchMediaResult result,
  ) {
    final CinearaStatusBadgeType? status = result.lifecycleStatus;

    if (status == null) {
      return null;
    }

    return CinearaStatusBadge(
      type: status,
      label: widget.statusLabelBuilder(status),
      variant: CinearaStatusBadgeVariant.artwork,
      density: CinearaStatusBadgeDensity.compact,
      behavior: CinearaStatusBadgeBehavior.collapsible,
      revealOnMount: false,
      revealOnStatusChange: true,
      expandOnTap: true,
      autoCollapse: true,
    );
  }

  CinearaStatusBadge? _buildSurfaceLifecycleBadge(
    CinearaSearchMediaResult result,
  ) {
    final CinearaStatusBadgeType? status = result.lifecycleStatus;

    if (status == null) {
      return null;
    }

    return CinearaStatusBadge(
      type: status,
      label: widget.statusLabelBuilder(status),
      variant: CinearaStatusBadgeVariant.surface,
      density: CinearaStatusBadgeDensity.standard,
      behavior: CinearaStatusBadgeBehavior.persistent,
      revealOnMount: false,
      revealOnStatusChange: false,
      expandOnTap: false,
      autoCollapse: false,
    );
  }

  CinearaExternalRatingBadge? _buildArtworkRatingBadge(double? rating) {
    if (rating == null) {
      return null;
    }

    return CinearaExternalRatingBadge(
      value: widget.localizations.formatRating(rating),
      semanticLabel: widget.localizations.ratingSemanticLabel(rating),
      variant: CinearaExternalRatingBadgeVariant.artwork,
      density: CinearaExternalRatingBadgeDensity.compact,
    );
  }

  CinearaStatusDock? _buildArtworkPersonalDock(
    CinearaSearchMediaResult result,
  ) {
    if (!result.hasPersonalState) {
      return null;
    }

    return CinearaStatusDock(
      labels: widget.statusDockLabels,
      favorite: result.favorite,
      collection: result.collection,
      watchlist: result.watchlist,
      personalRating: result.personalRating,
      mode: CinearaStatusDockMode.compact,
      variant: CinearaStatusDockVariant.artwork,
      density: CinearaStatusDockDensity.compact,
      layout: CinearaStatusDockLayout.vertical,
      side: CinearaStatusDockSide.end,
      tapToExpand: true,
      autoCollapse: true,
    );
  }

  CinearaStatusDock? _buildSurfacePersonalDock(
    CinearaSearchMediaResult result,
  ) {
    if (!result.hasPersonalState) {
      return null;
    }

    return CinearaStatusDock(
      labels: widget.statusDockLabels,
      favorite: result.favorite,
      collection: result.collection,
      watchlist: result.watchlist,
      personalRating: result.personalRating,
      mode: CinearaStatusDockMode.compact,
      variant: CinearaStatusDockVariant.surface,
      density: CinearaStatusDockDensity.compact,
      layout: CinearaStatusDockLayout.horizontal,
      side: CinearaStatusDockSide.start,
      tapToExpand: true,
      autoCollapse: true,
    );
  }

  Widget _buildPersonGridItem(
    CinearaSearchPersonResult result, {
    required bool showKnownFor,
  }) {
    return CinearaPersonGridItem(
      key: ValueKey<String>('search-grid-${result.stableKey}'),
      name: result.title,
      image: result.portrait,
      knownForDepartment: result.knownForDepartment,
      knownFor: result.knownFor,
      favorite: result.favorite,
      statusDockLabels: widget.statusDockLabels,
      semanticLabel: result.title,
      semanticHint: widget.localizations.openPerson,
      heroTag: result.heroTag,
      showKnownFor: showKnownFor,
      onTap: () {
        _handlePersonTap(result);
      },
      onLongPress: widget.onPersonLongPress == null
          ? null
          : () {
              _recordCurrentQuery();
              widget.onPersonLongPress!(result);
            },
    );
  }

  Widget _buildPersonListItem(CinearaSearchPersonResult result) {
    return CinearaPersonListItem(
      key: ValueKey<String>('search-list-${result.stableKey}'),
      name: result.title,
      image: result.portrait,
      knownForDepartment: result.knownForDepartment,
      knownFor: result.knownFor,
      favorite: result.favorite,
      statusDockLabels: widget.statusDockLabels,
      semanticLabel: result.title,
      semanticHint: widget.localizations.openPerson,
      heroTag: result.heroTag,
      onTap: () {
        _handlePersonTap(result);
      },
      onLongPress: widget.onPersonLongPress == null
          ? null
          : () {
              _recordCurrentQuery();
              widget.onPersonLongPress!(result);
            },
    );
  }

  Widget _buildEntityGridItem(CinearaSearchEntityResult result) {
    return CinearaEntityGridItem(
      key: ValueKey<String>('search-grid-${result.stableKey}'),
      title: result.title,
      variant: result.visualVariant,
      image: result.artwork,
      favorite: result.favorite,
      showFavorite: true,
      statusDockLabels: widget.statusDockLabels,
      semanticLabel: result.title,
      semanticHint: result.kind == CinearaSearchEntityKind.collection
          ? widget.localizations.openCollection
          : widget.localizations.openStudio,
      heroTag: result.heroTag,
      // Studio fallback icon is intentionally owned centrally by the entity
      // component. Do not pass per-studio fallback glyphs here.
      fallbackIcon: null,
      onTap: () {
        _handleEntityTap(result);
      },
      onLongPress: widget.onEntityLongPress == null
          ? null
          : () {
              _recordCurrentQuery();
              widget.onEntityLongPress!(result);
            },
    );
  }

  Widget _buildEntityListItem(CinearaSearchEntityResult result) {
    return CinearaEntityListItem(
      key: ValueKey<String>('search-list-${result.stableKey}'),
      title: result.title,
      variant: result.visualVariant,
      image: result.artwork,
      favorite: result.favorite,
      showFavorite: true,
      statusDockLabels: widget.statusDockLabels,
      semanticLabel: result.title,
      semanticHint: result.kind == CinearaSearchEntityKind.collection
          ? widget.localizations.openCollection
          : widget.localizations.openStudio,
      heroTag: result.heroTag,
      fallbackIcon: null,
      onTap: () {
        _handleEntityTap(result);
      },
      onLongPress: widget.onEntityLongPress == null
          ? null
          : () {
              _recordCurrentQuery();
              widget.onEntityLongPress!(result);
            },
    );
  }

  Widget _buildKeywordListItem(CinearaSearchKeywordResult result) {
    return CinearaEntityListItem(
      key: ValueKey<String>('search-list-${result.stableKey}'),
      title: result.title,
      variant: null,
      favorite: result.favorite,
      showFavorite: true,
      statusDockLabels: widget.statusDockLabels,
      semanticLabel: result.title,
      semanticHint: widget.localizations.openKeyword,
      onTap: () {
        _handleKeywordTap(result);
      },
      onLongPress: widget.onKeywordLongPress == null
          ? null
          : () {
              _recordCurrentQuery();
              widget.onKeywordLongPress!(result);
            },
    );
  }

  Widget _buildKeywordWrap(List<CinearaSearchKeywordResult> results) {
    return Wrap(
      spacing: CinearaSpacing.xs,
      runSpacing: CinearaSpacing.xs,
      children: results
          .map<Widget>(
            (CinearaSearchKeywordResult result) => ActionChip(
              avatar: const ExcludeSemantics(
                child: Icon(Icons.tag_rounded, size: 18),
              ),
              label: Text(result.title),
              onPressed: () {
                _handleKeywordTap(result);
              },
            ),
          )
          .toList(growable: false),
    );
  }

  List<CinearaSearchResult> _resultsForCategory(
    List<CinearaSearchResult> results,
    CinearaSearchCategory category,
  ) {
    return switch (category) {
      CinearaSearchCategory.all => List<CinearaSearchResult>.of(results),

      CinearaSearchCategory.movies =>
        results
            .whereType<CinearaSearchMediaResult>()
            .where(
              (CinearaSearchMediaResult result) =>
                  result.kind == CinearaSearchMediaKind.movie,
            )
            .toList(growable: false),

      CinearaSearchCategory.tvSeries =>
        results
            .whereType<CinearaSearchMediaResult>()
            .where(
              (CinearaSearchMediaResult result) =>
                  result.kind == CinearaSearchMediaKind.tvSeries,
            )
            .toList(growable: false),

      CinearaSearchCategory.people =>
        results.whereType<CinearaSearchPersonResult>().toList(growable: false),

      CinearaSearchCategory.collections =>
        results
            .whereType<CinearaSearchEntityResult>()
            .where(
              (CinearaSearchEntityResult result) =>
                  result.kind == CinearaSearchEntityKind.collection,
            )
            .toList(growable: false),

      CinearaSearchCategory.studios =>
        results
            .whereType<CinearaSearchEntityResult>()
            .where(
              (CinearaSearchEntityResult result) =>
                  result.kind == CinearaSearchEntityKind.studio,
            )
            .toList(growable: false),

      CinearaSearchCategory.keywords =>
        results.whereType<CinearaSearchKeywordResult>().toList(growable: false),
    };
  }

  double _horizontalPagePadding(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;

    return switch (CinearaBreakpoints.fromWidth(width)) {
      CinearaWindowSize.compact => CinearaSpacing.md,
      CinearaWindowSize.medium => 20,
      CinearaWindowSize.expanded => CinearaSpacing.lg,
      CinearaWindowSize.large => CinearaSpacing.xl,
    };
  }
}

// =============================================================================
// Search controls
// =============================================================================

Duration _resolvedSearchMotionDuration(
  BuildContext context,
  Duration duration,
) {
  final MediaQueryData mediaQuery = MediaQuery.of(context);

  return CinearaMotion.resolve(
    duration,
    reduceMotion:
        mediaQuery.disableAnimations || mediaQuery.accessibleNavigation,
  );
}

/// Horizontally scrollable Search category selector.
///
/// Selection moves through a soft bubble treatment and the newly selected
/// category is kept visible when changes originate from another control such as
/// a Search > All section header.
final class _SearchCategoryPills extends StatefulWidget {
  const _SearchCategoryPills({
    required this.value,
    required this.localizations,
    required this.onChanged,
  });

  final CinearaSearchCategory value;
  final CinearaSearchLocalizations localizations;
  final ValueChanged<CinearaSearchCategory> onChanged;

  @override
  State<_SearchCategoryPills> createState() => _SearchCategoryPillsState();
}

final class _SearchCategoryPillsState extends State<_SearchCategoryPills> {
  late final Map<CinearaSearchCategory, GlobalKey> _categoryKeys =
      <CinearaSearchCategory, GlobalKey>{
        for (final CinearaSearchCategory category
            in CinearaSearchCategory.values)
          category: GlobalKey(),
      };

  @override
  void initState() {
    super.initState();
    _scheduleRevealSelection();
  }

  @override
  void didUpdateWidget(_SearchCategoryPills oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value) {
      _scheduleRevealSelection();
    }
  }

  void _scheduleRevealSelection() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final BuildContext? itemContext =
          _categoryKeys[widget.value]?.currentContext;

      if (itemContext == null) {
        return;
      }

      final Duration duration = _resolvedSearchMotionDuration(
        context,
        CinearaMotion.selectionTransition,
      );

      unawaited(
        Scrollable.ensureVisible(
          itemContext,
          alignment: 0.5,
          duration: duration,
          curve: CinearaMotion.bubbleCurve,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.localizations.searchCategoriesLabel,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: <Widget>[
            for (
              int index = 0;
              index < CinearaSearchCategory.values.length;
              index++
            ) ...<Widget>[
              if (index > 0) const SizedBox(width: CinearaSpacing.xs),
              _SearchCategoryPill(
                key: _categoryKeys[CinearaSearchCategory.values[index]],
                category: CinearaSearchCategory.values[index],
                selected: widget.value == CinearaSearchCategory.values[index],
                label: widget.localizations.labelFor(
                  CinearaSearchCategory.values[index],
                ),
                onPressed: () {
                  widget.onChanged(CinearaSearchCategory.values[index]);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// One category surface inside [_SearchCategoryPills].
///
/// The selected treatment animates colour, border, and scale together so the
/// category change reads as one continuous bubble movement.
final class _SearchCategoryPill extends StatelessWidget {
  const _SearchCategoryPill({
    required this.category,
    required this.selected,
    required this.label,
    required this.onPressed,
    super.key,
  });

  final CinearaSearchCategory category;
  final bool selected;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final Duration duration = _resolvedSearchMotionDuration(
      context,
      CinearaMotion.selectionTransition,
    );

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: selected ? 1 : 0),
      duration: duration,
      curve: CinearaMotion.bubbleCurve,
      builder: (BuildContext context, double progress, Widget? child) {
        final Color background =
            Color.lerp(
              colors.surfaceContainerHigh.withValues(alpha: 0.58),
              colors.primaryContainer,
              progress,
            ) ??
            colors.primaryContainer;

        final Color foreground =
            Color.lerp(
              colors.onSurfaceVariant,
              colors.onPrimaryContainer,
              progress,
            ) ??
            colors.onPrimaryContainer;

        final Color border =
            Color.lerp(
              colors.outlineVariant.withValues(alpha: 0.32),
              colors.primary.withValues(alpha: 0.38),
              progress,
            ) ??
            colors.primary;

        final double scale =
            1 + ((CinearaMotion.bubbleLiftScale - 1) * 0.55 * progress);

        return SizedBox(
          height: 48,
          child: Center(
            child: Transform.scale(
              scale: scale,
              child: Semantics(
                button: true,
                selected: selected,
                label: label,
                onTap: onPressed,
                child: ExcludeSemantics(
                  child: Material(
                    color: background,
                    shape: StadiumBorder(
                      side: BorderSide(
                        color: border,
                        width: selected ? 1 : 0.75,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: onPressed,
                      customBorder: const StadiumBorder(),
                      splashFactory: NoSplash.splashFactory,
                      overlayColor: WidgetStateProperty.resolveWith<Color?>((
                        Set<WidgetState> states,
                      ) {
                        if (states.contains(WidgetState.pressed) ||
                            states.contains(WidgetState.focused)) {
                          return colors.onSurface.withValues(alpha: 0.055);
                        }

                        if (states.contains(WidgetState.hovered)) {
                          return colors.onSurface.withValues(alpha: 0.03);
                        }

                        return Colors.transparent;
                      }),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          12,
                          8,
                          14,
                          8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(category.icon, size: 18, color: foreground),
                            const SizedBox(width: CinearaSpacing.xs),
                            Text(
                              label,
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: foreground,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// =============================================================================
// Initial state
// =============================================================================

final class _InitialSearchContent extends StatelessWidget {
  const _InitialSearchContent({
    required this.recentSearches,
    required this.recommendedSearches,
    required this.localizations,
    required this.onSearch,
    required this.onRemoveRecent,
    required this.onClearRecent,
  });

  final List<String> recentSearches;
  final List<String> recommendedSearches;
  final CinearaSearchLocalizations localizations;
  final ValueChanged<String> onSearch;
  final ValueChanged<String> onRemoveRecent;
  final VoidCallback onClearRecent;

  @override
  Widget build(BuildContext context) {
    final List<String> recommended = _sanitizeRecommended(recommendedSearches);

    if (recentSearches.isEmpty && recommended.isEmpty) {
      return CinearaStateView(
        icon: Icons.search_rounded,
        title: localizations.startSearchingTitle,
        message: localizations.startSearchingMessage,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (recentSearches.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _SearchSectionHeader(
                title: localizations.recentSearches,
                actionLabel: localizations.clearRecent,
                onAction: onClearRecent,
              ),
              const SizedBox(height: CinearaSpacing.sm),
              Wrap(
                spacing: CinearaSpacing.xs,
                runSpacing: CinearaSpacing.xs,
                children: recentSearches
                    .map<Widget>(
                      (String term) => InputChip(
                        avatar: const ExcludeSemantics(
                          child: Icon(Icons.history_rounded, size: 18),
                        ),
                        label: Text(term),
                        tooltip: term,
                        onPressed: () {
                          onSearch(term);
                        },
                        onDeleted: () {
                          onRemoveRecent(term);
                        },
                        deleteButtonTooltipMessage:
                            localizations.removeRecentSearch,
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
          ),
        if (recentSearches.isNotEmpty && recommended.isNotEmpty)
          const SizedBox(height: CinearaSpacing.xxl),
        if (recommended.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _SearchSectionHeader(title: localizations.recommended),
              const SizedBox(height: CinearaSpacing.sm),
              Wrap(
                spacing: CinearaSpacing.xs,
                runSpacing: CinearaSpacing.xs,
                children: recommended
                    .map<Widget>(
                      (String term) => ActionChip(
                        avatar: const ExcludeSemantics(
                          child: Icon(Icons.auto_awesome_rounded, size: 18),
                        ),
                        label: Text(term),
                        onPressed: () {
                          onSearch(term);
                        },
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
          ),
      ],
    );
  }

  List<String> _sanitizeRecommended(Iterable<String> values) {
    final LinkedHashMap<String, String> unique =
        LinkedHashMap<String, String>();

    for (final String value in values) {
      final String normalized = value.trim().replaceAll(
        RegExp(r'\s+', unicode: true),
        ' ',
      );

      if (normalized.isNotEmpty) {
        unique.putIfAbsent(normalized, () => normalized);
      }
    }

    return List<String>.unmodifiable(unique.values);
  }
}

// =============================================================================
// Result headers and states
// =============================================================================

final class _SearchSectionHeader extends StatelessWidget {
  const _SearchSectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double textScale = MediaQuery.textScalerOf(context).scale(1.0);

    final Widget heading = Semantics(
      header: true,
      child: Text(
        title,
        textAlign: TextAlign.start,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
    );

    final String? resolvedActionLabel = actionLabel;
    final VoidCallback? resolvedAction = onAction;

    if (resolvedActionLabel == null || resolvedAction == null) {
      return heading;
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool stack =
            textScale >= 1.45 ||
            (constraints.maxWidth.isFinite && constraints.maxWidth < 360);

        if (stack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              heading,
              const SizedBox(height: CinearaSpacing.xs),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: resolvedAction,
                  child: Text(resolvedActionLabel),
                ),
              ),
            ],
          );
        }

        return Row(
          children: <Widget>[
            Expanded(child: heading),
            const SizedBox(width: CinearaSpacing.sm),
            TextButton(
              onPressed: resolvedAction,
              child: Text(resolvedActionLabel),
            ),
          ],
        );
      },
    );
  }
}

final class _FocusedResultsHeader extends StatelessWidget {
  const _FocusedResultsHeader({
    required this.title,
    required this.resultCount,
    required this.localizations,
    required this.viewMode,
    required this.onViewModeChanged,
  });

  final String title;
  final int resultCount;
  final CinearaSearchLocalizations localizations;

  final CinearaViewMode? viewMode;
  final ValueChanged<CinearaViewMode> onViewModeChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final CinearaViewMode? mode = viewMode;
    final double textScale = MediaQuery.textScalerOf(context).scale(1.0);

    final Widget titleBlock = Semantics(
      header: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            textAlign: TextAlign.start,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: CinearaSpacing.xxs),
          Text(
            localizations.resultCountLabel(resultCount),
            textAlign: TextAlign.start,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );

    if (mode == null) {
      return titleBlock;
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool stack =
            textScale >= 1.35 ||
            (constraints.maxWidth.isFinite && constraints.maxWidth < 420);

        final Widget selector = CinearaViewModeSelector(
          value: mode,
          onChanged: onViewModeChanged,
          gridLabel: localizations.gridLabel,
          listLabel: localizations.listLabel,
        );

        if (stack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              titleBlock,
              const SizedBox(height: CinearaSpacing.sm),
              Align(alignment: AlignmentDirectional.centerEnd, child: selector),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(child: titleBlock),
            const SizedBox(width: CinearaSpacing.sm),
            selector,
          ],
        );
      },
    );
  }
}

final class _SearchLoadingView extends StatelessWidget {
  const _SearchLoadingView({
    required this.category,
    required this.localizations,
  });

  final CinearaSearchCategory category;
  final CinearaSearchLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    final Color loadingSurface = Color.alphaBlend(
      colors.primary.withValues(
        alpha: theme.brightness == Brightness.dark ? 0.10 : 0.055,
      ),
      colors.surfaceContainer,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Semantics(
          liveRegion: true,
          container: true,
          label: localizations.searching,
          child: ExcludeSemantics(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: loadingSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.16),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: CinearaSpacing.md,
                  vertical: CinearaSpacing.sm,
                ),
                child: Row(
                  children: <Widget>[
                    SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(width: CinearaSpacing.sm),
                    Expanded(
                      child: Text(
                        localizations.searching,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: CinearaSpacing.lg),
        _SearchSkeletonGrid(category: category),
      ],
    );
  }
}

final class _SearchSkeletonGrid extends StatelessWidget {
  const _SearchSkeletonGrid({required this.category});

  final CinearaSearchCategory category;

  @override
  Widget build(BuildContext context) {
    final bool people = category == CinearaSearchCategory.people;
    final bool studio = category == CinearaSearchCategory.studios;
    final Color color = Theme.of(context).colorScheme.surfaceContainerHighest;

    return ExcludeSemantics(
      child: CinearaResponsiveGrid(
        children: List<Widget>.generate(6, (int index) {
          if (people) {
            return Column(
              children: <Widget>[
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox.square(dimension: 88),
                ),
                const SizedBox(height: 10),
                FractionallySizedBox(
                  widthFactor: 0.68,
                  child: _SkeletonBar(color: color, height: 14),
                ),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              AspectRatio(
                aspectRatio: studio ? 3 / 2 : 2 / 3,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _SkeletonBar(color: color, height: 14),
              const SizedBox(height: 7),
              FractionallySizedBox(
                widthFactor: 0.62,
                child: _SkeletonBar(color: color, height: 11),
              ),
            ],
          );
        }),
      ),
    );
  }
}

final class _SkeletonBar extends StatelessWidget {
  const _SkeletonBar({required this.color, required this.height});

  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: SizedBox(height: height),
    );
  }
}

final class _SearchErrorView extends StatelessWidget {
  const _SearchErrorView({
    required this.error,
    required this.localizations,
    required this.onRetry,
  });

  final Object? error;
  final CinearaSearchLocalizations localizations;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: CinearaSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          CinearaStateView(
            icon: Icons.cloud_off_rounded,
            title: localizations.searchErrorTitle,
            message: localizations.searchErrorMessage,
            action: FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(localizations.retry),
            ),
          ),
          if (kDebugMode && error != null) ...<Widget>[
            const SizedBox(height: CinearaSpacing.lg),
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.45),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(CinearaSpacing.md),
                child: SelectableText(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

final class _SearchEmptyView extends StatelessWidget {
  const _SearchEmptyView({required this.localizations});

  final CinearaSearchLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: CinearaSpacing.xxl),
      child: CinearaStateView(
        icon: Icons.search_off_rounded,
        title: localizations.noResultsTitle,
        message: localizations.noResultsMessage,
      ),
    );
  }
}

final class _LoadMoreFooter extends StatelessWidget {
  const _LoadMoreFooter({
    required this.loading,
    required this.error,
    required this.localizations,
    required this.onPressed,
  });

  final bool loading;
  final bool error;
  final CinearaSearchLocalizations localizations;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Semantics(
        liveRegion: true,
        container: true,
        label: localizations.loadingMore,
        child: const ExcludeSemantics(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(CinearaSpacing.md),
              child: SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
        ),
      );
    }

    return Center(
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(error ? Icons.refresh_rounded : Icons.expand_more_rounded),
        label: Text(error ? localizations.tryAgain : localizations.loadMore),
      ),
    );
  }
}

// =============================================================================
// Keyboard intents
// =============================================================================

final class _FocusSearchIntent extends Intent {
  const _FocusSearchIntent();
}

final class _DismissSearchIntent extends Intent {
  const _DismissSearchIntent();
}
