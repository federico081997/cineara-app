import 'package:cineara_design_system/cineara_design_system.dart';
import 'package:flutter/material.dart';

/// Broad result category used by [SearchContentView].
///
/// Global search intentionally models only the top-level entities that users
/// can filter directly:
///
/// - movies;
/// - series;
/// - people.
///
/// More specific catalogue classifications such as anime, K-drama, C-drama,
/// country, language, genre, decade and mood belong to Cineara's Discover
/// experience rather than the global search taxonomy.
///
/// Richer classifications can still be communicated through
/// [CinearaSearchResult.typeLabel]. For example, a result whose [type] is
/// [CinearaSearchResultType.series] may have a type label such as
/// `Series • Anime` or `Series • K-drama`.
enum CinearaSearchResultType { movie, series, person }

/// Primary filter available while a search query is active.
///
/// Global search deliberately exposes only broad entity/media filters.
///
/// More specific catalogue exploration belongs to Discover.
enum CinearaSearchFilter { all, movies, series, people }

/// Localized copy used by [SearchContentView].
///
/// All user-visible strings are supplied by the application localization layer
/// so the component remains usable across Cineara's supported locales,
/// directions and accessibility settings.
@immutable
class SearchContentLabels {
  const SearchContentLabels({
    required this.recentSearches,
    required this.clearRecentSearches,
    required this.suggestedForYou,
    required this.all,
    required this.movies,
    required this.series,
    required this.people,
    required this.loading,
    required this.noResultsTitle,
    required this.noResultsMessage,
    required this.errorTitle,
    required this.retry,
    required this.resultsFor,
  });

  /// Heading displayed above recent-search chips.
  final String recentSearches;

  /// Action used to clear the complete recent-search history.
  final String clearRecentSearches;

  /// Heading displayed above idle-state recommendations.
  final String suggestedForYou;

  /// Label for the unfiltered result view.
  final String all;

  /// Label for movie results.
  final String movies;

  /// Label for series results.
  final String series;

  /// Label for person results.
  final String people;

  /// Loading-state accessibility and supporting copy.
  final String loading;

  /// Heading displayed when the active query has no results.
  final String noResultsTitle;

  /// Builds localized explanatory copy for a query with no results.
  final String Function(String query) noResultsMessage;

  /// Heading displayed when search fails.
  final String errorTitle;

  /// Retry action label.
  final String retry;

  /// Builds the localized search-result heading for [query].
  final String Function(String query) resultsFor;

  /// Returns the localized label associated with [filter].
  String filterLabel(CinearaSearchFilter filter) {
    return switch (filter) {
      CinearaSearchFilter.all => all,
      CinearaSearchFilter.movies => movies,
      CinearaSearchFilter.series => series,
      CinearaSearchFilter.people => people,
    };
  }
}

/// Presentation data for one Cineara Search result.
///
/// Search rows use three logical lines:
///
/// ```text
/// Title
/// Format · optional classification · optional genres
/// Year / person department
/// ```
///
/// Examples:
///
/// ```text
/// Frieren: Beyond Journey's End
/// Series · Anime · Fantasy
/// 2023
///
/// When the Devil Calls Your Name
/// Series · K-Drama · Comedy
/// 2019
/// ```
@immutable
class CinearaSearchResult {
  const CinearaSearchResult({
    required this.id,
    required this.title,
    required this.metadata,
    required this.typeLabel,
    required this.type,
    this.imageProvider,
    this.semanticLabel,
  });

  /// Stable result identifier.
  ///
  /// The application layer may namespace backend IDs by media type:
  ///
  /// movie:372058
  /// tv:90699
  /// person:123
  final String id;

  /// Primary result title.
  final String title;

  /// Supporting third-line metadata.
  ///
  /// Media examples:
  ///
  /// 2016
  /// 2024
  ///
  /// Person examples:
  ///
  /// Acting
  /// Directing
  final String metadata;

  /// Main descriptive second line.
  ///
  /// Examples:
  ///
  /// Movie · Animation · Romance
  /// Series · Anime · Fantasy
  /// Series · K-Drama · Comedy
  /// Series · Comedy · Crime
  /// Series
  /// Person
  final String typeLabel;

  /// Broad Search category.
  final CinearaSearchResultType type;

  /// Optional poster/profile artwork.
  final ImageProvider<Object>? imageProvider;

  /// Optional accessibility description.
  ///
  /// When null, the result tile derives one from the visible fields.
  final String? semanticLabel;
}

/// Production body used inside [CinearaGlobalSearchPage].
///
/// The view intentionally separates two states.
///
/// ## Idle search
///
/// When [query] is empty, the view may show:
///
/// - recent-search chips;
/// - an optional clear-history action;
/// - suggested results.
///
/// ## Active search
///
/// When [query] contains text, the view may show:
///
/// - All / Movies / Series / People filters;
/// - loading state;
/// - error and retry state;
/// - no-results state;
/// - matching media/person rows.
///
/// The component owns presentation only. Search debouncing, network requests,
/// result pagination, recent-search persistence and navigation remain the
/// responsibility of the search/application layer.
///
/// The supplied [results] should already represent [selectedFilter]. The widget
/// deliberately does not locally filter a paginated result set because doing so
/// could produce misleading result counts or incomplete pages.
///
/// The layout is built for localization and accessibility:
///
/// - all horizontal layout uses directional APIs;
/// - translated headings and actions can wrap when necessary;
/// - the four primary filters scroll horizontally rather than being compressed;
/// - result line budgets expand at large text sizes;
/// - artwork scales more slowly than text;
/// - scrolling dismisses the keyboard;
/// - RTL is handled automatically;
/// - no hard-coded light/dark colours are used.
///
/// Example:
///
/// ```dart
/// SearchContentView(
///   query: state.query,
///   labels: SearchContentLabels(
///     recentSearches: labels.recentSearches,
///     clearRecentSearches: labels.clearRecentSearches,
///     suggestedForYou: labels.suggestedForYou,
///     all: labels.all,
///     movies: labels.movies,
///     series: labels.series,
///     people: labels.people,
///     loading: labels.loading,
///     noResultsTitle: labels.noResults,
///     noResultsMessage: labels.noResultsFor,
///     errorTitle: labels.searchError,
///     retry: labels.retry,
///     resultsFor: labels.resultsFor,
///   ),
///   recentSearches: state.recentSearches,
///   suggestions: state.suggestions,
///   results: state.results,
///   selectedFilter: state.filter,
///   isLoading: state.isLoading,
///   errorMessage: state.errorMessage,
///   onRecentSearchPressed: controller.searchRecent,
///   onClearRecentSearches: controller.clearRecentSearches,
///   onFilterChanged: controller.setFilter,
///   onResultPressed: controller.openResult,
///   onRetry: controller.retry,
/// )
/// ```
class SearchContentView extends StatelessWidget {
  const SearchContentView({
    required this.query,
    required this.labels,
    required this.onResultPressed,
    super.key,
    this.recentSearches = const <String>[],
    this.suggestions = const <CinearaSearchResult>[],
    this.results = const <CinearaSearchResult>[],
    this.selectedFilter = CinearaSearchFilter.all,
    this.isLoading = false,
    this.errorMessage,
    this.onRecentSearchPressed,
    this.onClearRecentSearches,
    this.onFilterChanged,
    this.onRetry,
    this.showFilters = true,
    this.maxSuggestedItems = 5,
  }) : assert(maxSuggestedItems > 0);

  /// Current search query.
  ///
  /// Whitespace is trimmed internally when deciding whether Search is in its
  /// idle or active state.
  final String query;

  /// Localized copy used throughout the view.
  final SearchContentLabels labels;

  /// Recent-search terms ordered from most recent to least recent.
  final List<String> recentSearches;

  /// Results suggested before the user enters a query.
  final List<CinearaSearchResult> suggestions;

  /// Search results supplied by the search/application layer.
  ///
  /// These should already correspond to [selectedFilter].
  final List<CinearaSearchResult> results;

  /// Currently selected broad result filter.
  ///
  /// Search intentionally limits this to:
  ///
  /// - All;
  /// - Movies;
  /// - Series;
  /// - People.
  final CinearaSearchFilter selectedFilter;

  /// Whether the active query is currently loading.
  final bool isLoading;

  /// Optional localized or user-appropriate error detail.
  ///
  /// When non-null and [isLoading] is false, the error state takes precedence
  /// over results and the no-results state.
  final String? errorMessage;

  /// Called when a recent-search chip is selected.
  final ValueChanged<String>? onRecentSearchPressed;

  /// Called when the user clears all recent-search history.
  final VoidCallback? onClearRecentSearches;

  /// Called when the user selects All, Movies, Series or People.
  ///
  /// More specific filtering belongs to Discover.
  final ValueChanged<CinearaSearchFilter>? onFilterChanged;

  /// Called when a search result is selected.
  final ValueChanged<CinearaSearchResult> onResultPressed;

  /// Called when the user retries a failed search.
  final VoidCallback? onRetry;

  /// Whether the All / Movies / Series / People filter strip is displayed.
  final bool showFilters;

  /// Maximum number of idle-state suggestions displayed.
  final int maxSuggestedItems;

  bool get _isIdle => query.trim().isEmpty;

  bool get _hasError => errorMessage != null && errorMessage!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (_isIdle) {
      return _SearchIdleContent(
        labels: labels,
        recentSearches: recentSearches,
        suggestions: suggestions
            .take(maxSuggestedItems)
            .toList(growable: false),
        onRecentSearchPressed: onRecentSearchPressed,
        onClearRecentSearches: onClearRecentSearches,
        onResultPressed: onResultPressed,
      );
    }

    return _SearchActiveContent(
      query: query.trim(),
      labels: labels,
      results: results,
      selectedFilter: selectedFilter,
      isLoading: isLoading,
      errorMessage: _hasError ? errorMessage!.trim() : null,
      showFilters: showFilters,
      onFilterChanged: onFilterChanged,
      onResultPressed: onResultPressed,
      onRetry: onRetry,
    );
  }
}

/// Idle Search content.
///
/// Recent searches appear first when available, followed by optional suggested
/// results.
class _SearchIdleContent extends StatelessWidget {
  const _SearchIdleContent({
    required this.labels,
    required this.recentSearches,
    required this.suggestions,
    required this.onRecentSearchPressed,
    required this.onClearRecentSearches,
    required this.onResultPressed,
  });

  final SearchContentLabels labels;
  final List<String> recentSearches;
  final List<CinearaSearchResult> suggestions;

  final ValueChanged<String>? onRecentSearchPressed;
  final VoidCallback? onClearRecentSearches;
  final ValueChanged<CinearaSearchResult> onResultPressed;

  @override
  Widget build(BuildContext context) {
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsetsDirectional.fromSTEB(
        CinearaSpacing.md,
        CinearaSpacing.lg,
        CinearaSpacing.md,
        CinearaSpacing.xxl,
      ),
      children: <Widget>[
        if (recentSearches.isNotEmpty) ...<Widget>[
          _SearchSectionHeader(
            title: labels.recentSearches,
            actionLabel: onClearRecentSearches == null
                ? null
                : labels.clearRecentSearches,
            onActionPressed: onClearRecentSearches,
          ),
          const SizedBox(height: CinearaSpacing.sm),
          _RecentSearchesWrap(
            searches: recentSearches,
            onPressed: onRecentSearchPressed,
          ),
          const SizedBox(height: CinearaSpacing.xl),
        ],
        if (suggestions.isNotEmpty) ...<Widget>[
          _SearchSectionHeader(title: labels.suggestedForYou),
          const SizedBox(height: CinearaSpacing.xs),
          for (final CinearaSearchResult result in suggestions)
            _SearchResultTile(
              result: result,
              onPressed: () => onResultPressed(result),
            ),
        ],
      ],
    );
  }
}

/// Active-query content.
///
/// The broad filter strip remains independent from the loading/error/result
/// state so the user can switch result categories without leaving Search.
class _SearchActiveContent extends StatelessWidget {
  const _SearchActiveContent({
    required this.query,
    required this.labels,
    required this.results,
    required this.selectedFilter,
    required this.isLoading,
    required this.errorMessage,
    required this.showFilters,
    required this.onFilterChanged,
    required this.onResultPressed,
    required this.onRetry,
  });

  final String query;
  final SearchContentLabels labels;
  final List<CinearaSearchResult> results;
  final CinearaSearchFilter selectedFilter;
  final bool isLoading;
  final String? errorMessage;
  final bool showFilters;

  final ValueChanged<CinearaSearchFilter>? onFilterChanged;
  final ValueChanged<CinearaSearchResult> onResultPressed;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final Widget body;

    if (isLoading) {
      body = _SearchLoadingState(label: labels.loading);
    } else if (errorMessage != null) {
      body = _SearchErrorState(
        title: labels.errorTitle,
        message: errorMessage!,
        retryLabel: labels.retry,
        onRetry: onRetry,
      );
    } else if (results.isEmpty) {
      body = _SearchEmptyState(
        title: labels.noResultsTitle,
        message: labels.noResultsMessage(query),
      );
    } else {
      body = _SearchResultsList(
        heading: labels.resultsFor(query),
        results: results,
        onResultPressed: onResultPressed,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (showFilters) ...<Widget>[
          _SearchFilterStrip(
            labels: labels,
            selectedFilter: selectedFilter,
            onFilterChanged: onFilterChanged,
          ),
          const _SearchHorizontalDivider(),
        ],
        Expanded(child: body),
      ],
    );
  }
}

/// Search section heading with an optional trailing text action.
///
/// The heading and action remain on the same logical row. The heading receives
/// the available flexible space while the action stays compact at the trailing
/// edge.
///
/// This is particularly appropriate for lightweight section actions such as
/// clearing recent searches:
///
/// ```text
/// Recent searches                              Clear
/// ```
///
/// Directional layout automatically mirrors the arrangement in RTL.
class _SearchSectionHeader extends StatelessWidget {
  const _SearchSectionHeader({
    required this.title,
    this.actionLabel,
    this.onActionPressed,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final TextScaler scaler = MediaQuery.textScalerOf(context);

    final double textScale = (scaler.scale(16) / 16).clamp(1.0, 3.0).toDouble();

    final bool hasAction = actionLabel != null && onActionPressed != null;

    final Widget titleWidget = Text(
      title,
      maxLines: textScale >= 1.6 ? 2 : 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.start,
      style: theme.textTheme.titleSmall?.copyWith(
        color: colors.onSurface,
        fontWeight: FontWeight.w700,
      ),
    );

    if (!hasAction) {
      return titleWidget;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(child: titleWidget),
        const SizedBox(width: CinearaSpacing.sm),
        TextButton(
          onPressed: onActionPressed,
          style: TextButton.styleFrom(
            foregroundColor: colors.primary,
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: CinearaSpacing.xs,
              vertical: CinearaSpacing.xxs,
            ),
            minimumSize: const Size(0, 40),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            actionLabel!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

/// Recent-search chips.
///
/// Chips wrap naturally instead of forming a horizontal scroll rail. This keeps
/// recent searches visible at a glance and remains robust when search terms or
/// accessibility text become larger.
class _RecentSearchesWrap extends StatelessWidget {
  const _RecentSearchesWrap({required this.searches, required this.onPressed});

  final List<String> searches;
  final ValueChanged<String>? onPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Wrap(
          spacing: CinearaSpacing.xs,
          runSpacing: CinearaSpacing.xs,
          children: searches
              .map((String search) {
                return ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                  child: ActionChip(
                    avatar: Icon(
                      Icons.history_rounded,
                      size: 17,
                      color: colors.onSurfaceVariant,
                    ),
                    label: Text(
                      search,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onPressed: onPressed == null
                        ? null
                        : () => onPressed!(search),
                    side: BorderSide(
                      color: colors.outlineVariant.withValues(alpha: 0.72),
                      width: 0.75,
                    ),
                    backgroundColor: colors.surfaceContainerLow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(CinearaRadii.pill),
                    ),
                    labelStyle: theme.textTheme.labelMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              })
              .toList(growable: false),
        );
      },
    );
  }
}

/// Horizontally scrollable primary search filter strip.
///
/// Global Search intentionally exposes only:
///
/// ```text
/// All • Movies • Series • People
/// ```
///
/// Catalogue exploration dimensions such as anime, K-drama, country, region,
/// language, genre, mood and decade belong to Discover.
///
/// Horizontal scrolling is preferable to compressing translated labels into
/// unreadable widths on compact phones or at large accessibility text sizes.
class _SearchFilterStrip extends StatelessWidget {
  const _SearchFilterStrip({
    required this.labels,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final SearchContentLabels labels;
  final CinearaSearchFilter selectedFilter;
  final ValueChanged<CinearaSearchFilter>? onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsetsDirectional.fromSTEB(
        CinearaSpacing.md,
        CinearaSpacing.sm,
        CinearaSpacing.md,
        CinearaSpacing.sm,
      ),
      child: Row(
        children: <Widget>[
          for (
            int index = 0;
            index < CinearaSearchFilter.values.length;
            index++
          ) ...<Widget>[
            if (index > 0) const SizedBox(width: CinearaSpacing.xs),
            _SearchFilterChip(
              label: labels.filterLabel(CinearaSearchFilter.values[index]),
              selected: selectedFilter == CinearaSearchFilter.values[index],
              onSelected: onFilterChanged == null
                  ? null
                  : () {
                      final CinearaSearchFilter filter =
                          CinearaSearchFilter.values[index];

                      if (selectedFilter != filter) {
                        onFilterChanged!(filter);
                      }
                    },
            ),
          ],
        ],
      ),
    );
  }
}

/// Individual broad Search filter.
///
/// The selected state uses a restrained branded surface rather than a saturated
/// filled button so the filter strip does not compete visually with results.
class _SearchFilterChip extends StatelessWidget {
  const _SearchFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback? onSelected;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final bool highContrast = MediaQuery.highContrastOf(context);

    return ChoiceChip(
      label: Text(label, maxLines: 1, softWrap: false),
      selected: selected,
      showCheckmark: false,
      onSelected: onSelected == null
          ? null
          : (bool value) {
              if (value) {
                onSelected!();
              }
            },
      backgroundColor: colors.surfaceContainerLow,
      selectedColor: colors.primaryContainer,
      side: BorderSide(
        color: selected
            ? colors.primary.withValues(alpha: highContrast ? 1 : 0.44)
            : colors.outlineVariant.withValues(alpha: highContrast ? 1 : 0.70),
        width: highContrast ? 1.5 : 0.75,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(CinearaRadii.pill),
      ),
      labelStyle: theme.textTheme.labelMedium?.copyWith(
        color: selected ? colors.onPrimaryContainer : colors.onSurfaceVariant,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
      ),
    );
  }
}

/// Divider between Search filtering and result content.
class _SearchHorizontalDivider extends StatelessWidget {
  const _SearchHorizontalDivider();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Divider(
      height: 1,
      thickness: 0.75,
      color: colors.outlineVariant.withValues(alpha: 0.62),
    );
  }
}

/// Scrollable list of active-query Search results.
class _SearchResultsList extends StatelessWidget {
  const _SearchResultsList({
    required this.heading,
    required this.results,
    required this.onResultPressed,
  });

  final String heading;
  final List<CinearaSearchResult> results;
  final ValueChanged<CinearaSearchResult> onResultPressed;

  @override
  Widget build(BuildContext context) {
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsetsDirectional.fromSTEB(
        CinearaSpacing.md,
        CinearaSpacing.lg,
        CinearaSpacing.md,
        CinearaSpacing.xxl,
      ),
      children: <Widget>[
        _SearchSectionHeader(title: heading),
        const SizedBox(height: CinearaSpacing.xs),
        for (final CinearaSearchResult result in results)
          _SearchResultTile(
            result: result,
            onPressed: () => onResultPressed(result),
          ),
      ],
    );
  }
}

/// Compact media/person Search result.
///
/// Real poster/profile artwork is preferred. If artwork is unavailable or fails
/// to load, Cineara renders a restrained themed fallback.
///
/// The complete row owns interaction. The trailing chevron is passive and
/// follows the current text direction.
///
/// At larger text scales:
///
/// - titles can use two lines;
/// - metadata can use two lines;
/// - descriptive type labels can use two lines;
/// - artwork grows only modestly so text retains most of the available width.
class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({required this.result, required this.onPressed});

  final CinearaSearchResult result;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final TextScaler scaler = MediaQuery.textScalerOf(context);
    final bool highContrast = MediaQuery.highContrastOf(context);

    final double textScale = (scaler.scale(16) / 16).clamp(1.0, 3.0).toDouble();

    final double artworkScale = (1 + ((textScale - 1) * 0.18))
        .clamp(1.0, 1.18)
        .toDouble();

    final double artworkWidth = result.type == CinearaSearchResultType.person
        ? 52 * artworkScale
        : 48 * artworkScale;

    final double artworkHeight = result.type == CinearaSearchResultType.person
        ? 58 * artworkScale
        : 68 * artworkScale;

    final int titleLines = textScale >= 1.5 ? 2 : 1;
    final int metadataLines = textScale >= 1.8 ? 2 : 1;
    final int typeLines = textScale >= 2.0 ? 2 : 1;

    final String semanticLabel =
        result.semanticLabel ??
        <String>[
          result.title,
          result.typeLabel,
          if (result.metadata.trim().isNotEmpty) result.metadata,
        ].join(', ');

    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: CinearaSpacing.xs),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(CinearaRadii.md),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(CinearaRadii.md),
            overlayColor: WidgetStateProperty.resolveWith<Color?>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.pressed)) {
                return colors.primary.withValues(
                  alpha: highContrast ? 0.13 : 0.07,
                );
              }

              if (states.contains(WidgetState.hovered)) {
                return colors.primary.withValues(alpha: 0.035);
              }

              if (states.contains(WidgetState.focused)) {
                return colors.primary.withValues(
                  alpha: highContrast ? 0.10 : 0.05,
                );
              }

              return null;
            }),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                CinearaSpacing.xs,
                CinearaSpacing.xs,
                CinearaSpacing.xs,
                CinearaSpacing.xs,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _SearchResultArtwork(
                    result: result,
                    width: artworkWidth,
                    height: artworkHeight,
                  ),
                  const SizedBox(width: CinearaSpacing.sm),
                  Expanded(
                    child: _SearchResultText(
                      result: result,
                      titleLines: titleLines,
                      metadataLines: metadataLines,
                      typeLines: typeLines,
                    ),
                  ),
                  const SizedBox(width: CinearaSpacing.xs),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: colors.onSurfaceVariant.withValues(alpha: 0.68),
                    textDirection: Directionality.of(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Text content displayed within one Search result row.
///
/// Visual hierarchy:
///
/// 1. title;
/// 2. format / classification / genres;
/// 3. year or person department.
class _SearchResultText extends StatelessWidget {
  const _SearchResultText({
    required this.result,
    required this.titleLines,
    required this.metadataLines,
    required this.typeLines,
  });

  final CinearaSearchResult result;

  final int titleLines;
  final int metadataLines;
  final int typeLines;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final ColorScheme colors = theme.colorScheme;

    final bool hasMetadata = result.metadata.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          result.title,
          maxLines: titleLines,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.start,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
            height: 1.22,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          result.typeLabel,
          maxLines: typeLines,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.start,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            height: 1.22,
          ),
        ),

        if (hasMetadata) ...<Widget>[
          const SizedBox(height: 4),

          Text(
            result.metadata,
            maxLines: metadataLines,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.start,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
              height: 1.18,
            ),
          ),
        ],
      ],
    );
  }
}

/// Poster/profile artwork used by one Search result.
class _SearchResultArtwork extends StatelessWidget {
  const _SearchResultArtwork({
    required this.result,
    required this.width,
    required this.height,
  });

  final CinearaSearchResult result;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final bool highContrast = MediaQuery.highContrastOf(context);

    final BorderRadius radius = BorderRadius.circular(CinearaRadii.sm);

    final Widget fallback = DecoratedBox(
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          colors.primaryContainer.withValues(
            alpha: theme.brightness == Brightness.dark ? 0.28 : 0.52,
          ),
          colors.surfaceContainerLow,
        ),
      ),
      child: Center(
        child: Icon(
          _fallbackIcon(result.type),
          size: 21,
          color: colors.primary,
        ),
      ),
    );

    final Widget artwork = result.imageProvider == null
        ? fallback
        : Image(
            image: result.imageProvider!,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
            errorBuilder:
                (BuildContext context, Object error, StackTrace? stackTrace) {
                  return fallback;
                },
          );

    return ExcludeSemantics(
      child: SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: colors.outlineVariant.withValues(
                alpha: highContrast ? 1 : 0.66,
              ),
              width: highContrast ? 1.5 : 0.75,
            ),
          ),
          child: ClipRRect(borderRadius: radius, child: artwork),
        ),
      ),
    );
  }

  IconData _fallbackIcon(CinearaSearchResultType type) {
    return switch (type) {
      CinearaSearchResultType.movie => Icons.movie_outlined,
      CinearaSearchResultType.series => Icons.live_tv_rounded,
      CinearaSearchResultType.person => Icons.person_outline_rounded,
    };
  }
}

/// Active Search loading state.
///
/// A restrained progress indicator communicates active work while static
/// skeleton rows preserve the expected result geometry.
///
/// The skeleton deliberately does not shimmer so reduced-motion users do not
/// receive unnecessary animation.
class _SearchLoadingState extends StatelessWidget {
  const _SearchLoadingState({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsetsDirectional.fromSTEB(
        CinearaSpacing.md,
        CinearaSpacing.lg,
        CinearaSpacing.md,
        CinearaSpacing.xxl,
      ),
      children: <Widget>[
        Semantics(
          liveRegion: true,
          label: label,
          child: ExcludeSemantics(
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
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: CinearaSpacing.lg),
        const _SearchSkeletonRow(),
        const _SearchSkeletonRow(),
        const _SearchSkeletonRow(),
        const _SearchSkeletonRow(),
      ],
    );
  }
}

/// Static loading placeholder for one Search result.
class _SearchSkeletonRow extends StatelessWidget {
  const _SearchSkeletonRow();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextScaler scaler = MediaQuery.textScalerOf(context);

    final double textScale = (scaler.scale(16) / 16).clamp(1.0, 3.0).toDouble();

    final double artworkScale = (1 + ((textScale - 1) * 0.18))
        .clamp(1.0, 1.18)
        .toDouble();

    Widget block({
      required double height,
      double? width,
      BorderRadius? borderRadius,
    }) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: borderRadius ?? BorderRadius.circular(CinearaRadii.xs),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        CinearaSpacing.xs,
        CinearaSpacing.xs,
        CinearaSpacing.xs,
        CinearaSpacing.sm,
      ),
      child: Row(
        children: <Widget>[
          block(
            width: 48 * artworkScale,
            height: 68 * artworkScale,
            borderRadius: BorderRadius.circular(CinearaRadii.sm),
          ),
          const SizedBox(width: CinearaSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                FractionallySizedBox(
                  widthFactor: 0.66,
                  alignment: AlignmentDirectional.centerStart,
                  child: block(height: 13),
                ),
                const SizedBox(height: 8),
                FractionallySizedBox(
                  widthFactor: 0.42,
                  alignment: AlignmentDirectional.centerStart,
                  child: block(height: 11),
                ),
                const SizedBox(height: 8),
                FractionallySizedBox(
                  widthFactor: 0.28,
                  alignment: AlignmentDirectional.centerStart,
                  child: block(height: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty state displayed when the current query/filter returns no matches.
class _SearchEmptyState extends StatelessWidget {
  const _SearchEmptyState({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return _SearchMessageState(
      icon: Icons.search_off_rounded,
      title: title,
      message: message,
    );
  }
}

/// Error state displayed when Search cannot load results.
class _SearchErrorState extends StatelessWidget {
  const _SearchErrorState({
    required this.title,
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String title;
  final String message;
  final String retryLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return _SearchMessageState(
      icon: Icons.cloud_off_rounded,
      title: title,
      message: message,
      actionLabel: onRetry == null ? null : retryLabel,
      onActionPressed: onRetry,
    );
  }
}

/// Shared scroll-safe Search message state.
///
/// [CustomScrollView] with [SliverFillRemaining] keeps short content visually
/// centred while still allowing large accessibility text or long translations
/// to scroll instead of overflowing.
class _SearchMessageState extends StatelessWidget {
  const _SearchMessageState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onActionPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: <Widget>[
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                CinearaSpacing.xl,
                CinearaSpacing.xl,
                CinearaSpacing.xl,
                CinearaSpacing.xxl,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      icon,
                      size: 38,
                      color: colors.onSurfaceVariant.withValues(alpha: 0.70),
                    ),
                    const SizedBox(height: CinearaSpacing.sm),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: CinearaSpacing.xs),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                    if (actionLabel != null &&
                        onActionPressed != null) ...<Widget>[
                      const SizedBox(height: CinearaSpacing.md),
                      FilledButton.tonalIcon(
                        onPressed: onActionPressed,
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(actionLabel!),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
