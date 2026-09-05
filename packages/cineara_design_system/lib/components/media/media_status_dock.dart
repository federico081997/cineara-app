import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../tokens/colour.dart';

// =============================================================================
// Public API
// =============================================================================

/// Personal indicators that can be represented by [CinearaStatusDock].
enum CinearaStatusDockIndicator { favorite, collection, watchlist, rating }

/// Visual density used by [CinearaStatusDock].
enum CinearaStatusDockDensity {
  /// Compact treatment intended primarily for poster artwork.
  compact,

  /// Slightly larger treatment for larger cards and list layouts.
  standard,
}

/// Surface treatment used by [CinearaStatusDock].
enum CinearaStatusDockVariant {
  /// Predictable dark-glass treatment intended for arbitrary artwork.
  artwork,

  /// Theme-aware treatment intended for ordinary content surfaces.
  surface,
}

/// Presentation behaviour used by [CinearaStatusDock].
enum CinearaStatusDockMode {
  /// All currently active, enabled indicators remain visible.
  permanent,

  /// Only the first active, enabled indicator remains visible at rest.
  ///
  /// The complete chain can temporarily unfold and then collapse back into
  /// that first visible indicator.
  compact,
}

/// Logical side to which the dock is visually anchored.
///
/// This controls the internal alignment of nodes. Actual placement within a
/// poster or list row remains the responsibility of the parent.
enum CinearaStatusDockSide { start, end }

/// Localized accessibility labels used by [CinearaStatusDock].
@immutable
final class CinearaStatusDockLabels {
  const CinearaStatusDockLabels({
    required this.dock,
    required this.favorite,
    required this.collection,
    required this.watchlist,
    required this.personalRating,
  });

  /// Accessibility label for the complete personal-state dock.
  final String dock;

  /// Localized Favorite label.
  final String favorite;

  /// Localized Collection label.
  final String collection;

  /// Localized Watchlist label.
  final String watchlist;

  /// Localized personal-rating label.
  final String personalRating;
}

// =============================================================================
// Controller
// =============================================================================

/// Imperative presentation controller for [CinearaStatusDock].
///
/// Application state remains outside the design-system component.
///
/// Two controller operations intentionally have different semantics.
///
/// ## [reveal]
///
/// Explicitly reveals the complete current dock.
///
/// Use this when the user deliberately asks to inspect the dock, or when a
/// presentation preview should show the effect of a configuration change.
///
/// Typical uses:
///
/// ```text
/// user taps compact dock
///     ↓
/// controller.reveal()
///
/// settings preference changes
///     ↓
/// preview rebuilds
///     ↓
/// controller.reveal()
/// ```
///
/// ## [revealChanges]
///
/// Reacts to an actual media-state mutation.
///
/// Typical use:
///
/// ```text
/// long press card
///     ↓
/// quick-actions surface
///     ↓
/// user changes personal state
///     ↓
/// surface closes
///     ↓
/// application state updates
///     ↓
/// controller.revealChanges(...)
/// ```
///
/// State-change choreography:
///
/// ```text
/// added state
/// → reveal stack
/// → magnetic attachment
/// → rail pulse
///
/// removed state while collapsed
/// → remain collapsed
///
/// removed state while fully open
/// → show updated configuration briefly
/// → collapse
///
/// removed state while opening/collapsing
/// → immediately continue toward collapsed
///
/// existing rating changed
/// → animate rating number only
/// ```
///
/// A controller should normally belong to one media-card instance.
final class CinearaStatusDockController {
  _CinearaStatusDockState? _state;

  /// Whether this controller is currently attached to a mounted dock.
  bool get attached => _state != null;

  /// Explicitly reveals the complete current dock.
  ///
  /// In [CinearaStatusDockMode.compact], the chain unfolds from the current
  /// compact anchor and automatically collapses again when auto-collapse is
  /// enabled.
  ///
  /// In permanent mode the complete chain is already visible.
  Future<void> reveal() async {
    await _state?._revealFromController();
  }

  /// Plays presentation feedback for application state that just changed.
  ///
  /// Call this only once the corresponding card/poster is visible again, for
  /// example after a quick-actions sheet has closed.
  ///
  /// [changedIndicators] must describe what actually changed, rather than all
  /// indicators that are currently active.
  Future<void> revealChanges({
    required Set<CinearaStatusDockIndicator> changedIndicators,
  }) async {
    if (changedIndicators.isEmpty) {
      return;
    }

    await _state?._revealChanges(
      Set<CinearaStatusDockIndicator>.unmodifiable(changedIndicators),
    );
  }

  /// Collapses a temporarily expanded compact dock immediately.
  ///
  /// Permanent docks remain expanded.
  Future<void> collapse() async {
    await _state?._collapseFromController();
  }

  void _attach(_CinearaStatusDockState state) {
    assert(
      _state == null || identical(_state, state),
      'A CinearaStatusDockController can only control one mounted dock.',
    );

    _state = state;
  }

  void _detach(_CinearaStatusDockState state) {
    if (identical(_state, state)) {
      _state = null;
    }
  }
}

// =============================================================================
// Dock
// =============================================================================

/// Personal-state indicator attached to a Cineara media presentation.
///
/// The dock represents:
///
/// - Favorite
/// - Collection
/// - Watchlist
/// - Personal rating
///
/// It does not represent lifecycle/viewing state such as Watching, Completed,
/// Rewatching, On hold, or Dropped.
///
/// ## Visibility
///
/// [visibleIndicators] controls which categories are eligible to appear.
///
/// Visibility is presentation-only:
///
/// ```text
/// collection == true
/// +
/// collection omitted from visibleIndicators
///
/// => collection remains true in application state
/// => collection simply does not appear in the dock
/// ```
///
/// Only active indicators are rendered.
///
/// An entirely empty dock renders [SizedBox.shrink].
///
/// ## Canonical order
///
/// The dock is ordered from bottom to top:
///
/// ```text
/// Collection
///     │
/// Favorite
///     │
/// Watchlist
///     │
/// ★ Rating
/// ```
///
/// Rating therefore occupies the bottom position whenever it is active and
/// enabled for display.
///
/// The compact-anchor fallback priority is:
///
/// ```text
/// Rating
/// → Watchlist
/// → Favorite
/// → Collection
/// ```
///
/// ## Permanent mode
///
/// Every active visible indicator remains present.
///
/// ## Compact mode
///
/// The first active visible indicator becomes the compact anchor.
///
/// With all indicators active:
///
/// ```text
/// collapsed:
///
/// ★ 8.5
///
/// expanded:
///
/// Collection
///     │
/// Favorite
///     │
/// Watchlist
///     │
/// ★ 8.5       ← stable anchor
/// ```
///
/// During collapse, every non-anchor node returns into the current anchor.
///
/// ## Interaction
///
/// Permanent mode is presentation-only and lets pointer input pass to the
/// containing media card.
///
/// Compact mode can intercept a tap when multiple indicators exist:
///
/// ```text
/// tap dock
/// → explicitly reveal chain
/// → hold
/// → collapse automatically
/// ```
///
/// Card-level editing should still be handled by the parent:
///
/// ```text
/// tap card
/// → details
///
/// long press card
/// → media actions
/// ```
///
/// A larger poster-corner interaction region can be provided by the parent
/// overlay while setting [tapToExpand] to false and invoking
/// [CinearaStatusDockController.reveal] from that parent region.
///
/// ## Real state-change animation
///
/// The full change animation is intentionally not started automatically from
/// [State.didUpdateWidget].
///
/// Instead, after external state has changed and the poster is visible again,
/// invoke:
///
/// ```dart
/// controller.revealChanges(
///   changedIndicators: changed,
/// );
/// ```
///
/// Automatic state-change choreography follows these rules:
///
/// ```text
/// add Favorite / Collection / Watchlist
/// → reveal stack
/// → magnetically attach new node
/// → rail pulse
///
/// add Rating: null → value
/// → reveal stack
/// → magnetically attach Rating
/// → rail pulse
///
/// remove state while collapsed
/// → remain collapsed
///
/// remove state while fully expanded
/// → show updated configuration briefly
/// → collapse
///
/// remove state while opening or collapsing
/// → do not freeze the partial geometry
/// → immediately continue toward collapsed
///
/// change Rating: value → value while collapsed
/// → remain collapsed
/// → animate number toward target
///
/// change Rating while fully expanded
/// → animate number
/// → short hold
/// → collapse
///
/// change Rating while opening/collapsing
/// → animate number while continuing toward collapsed
/// ```
///
/// When an existing rating changes, the numerical animation decelerates toward
/// the final value.
///
/// ```text
/// 7.2 → 7.8 → 8.3 → 8.7 → 8.9 → 9
/// ```
///
/// A numerical rating change does not replay the badge's magnetic attachment.
///
/// ```text
/// null → 8.5
/// ```
///
/// remains a newly attached Rating indicator.
///
/// ```text
/// 8.5 → null
/// ```
///
/// removes the Rating indicator without counting down to zero.
///
/// ## Presentation previews
///
/// A settings/configuration preview should not call [revealChanges], because a
/// display preference is not a mutation of the media's personal state.
///
/// Instead:
///
/// ```text
/// update display preference
///     ↓
/// rebuild preview
///     ↓
/// controller.reveal()
/// ```
///
/// This lets the preview deliberately show the resulting dock configuration
/// without pretending that Favorite, Collection, Watchlist, or Rating changed.
final class CinearaStatusDock extends StatefulWidget {
  const CinearaStatusDock({
    required this.labels,
    super.key,
    this.controller,
    this.favorite = false,
    this.collection = false,
    this.watchlist = false,
    this.personalRating,
    this.personalRatingLabel,
    this.ratingMax = 10,
    this.visibleIndicators = const <CinearaStatusDockIndicator>{
      CinearaStatusDockIndicator.rating,
      CinearaStatusDockIndicator.watchlist,
      CinearaStatusDockIndicator.favorite,
      CinearaStatusDockIndicator.collection,
    },
    this.mode = CinearaStatusDockMode.permanent,
    this.variant = CinearaStatusDockVariant.artwork,
    this.density = CinearaStatusDockDensity.compact,
    this.side = CinearaStatusDockSide.end,
    this.tapToExpand = true,
    this.autoCollapse = true,
    this.autoCollapseDelay = const Duration(milliseconds: 1800),
    this.animate = true,
    this.favoriteAccent,
    this.collectionAccent,
    this.watchlistAccent,
    this.ratingAccent,
    this.semanticLabel,
    this.semanticValue,
    this.excludeFromSemantics = false,
  }) : assert(ratingMax > 0, 'ratingMax must be greater than zero.'),
       assert(
         personalRating == null ||
             (personalRating >= 0 && personalRating <= ratingMax),
         'personalRating must be between zero and ratingMax.',
       );

  /// Optional presentation controller.
  final CinearaStatusDockController? controller;

  /// Localized accessibility strings.
  final CinearaStatusDockLabels labels;

  /// Whether the title is marked as a favorite.
  final bool favorite;

  /// Whether the title belongs to the user's collection.
  final bool collection;

  /// Whether the title belongs to the user's watchlist.
  final bool watchlist;

  /// Current personal rating.
  ///
  /// A non-null value represents an active Rating indicator, including zero.
  final double? personalRating;

  /// Optional already-formatted final rating value.
  ///
  /// Use this for locale-aware decimal formatting.
  ///
  /// During an active numerical transition, intermediate values use the
  /// component's internal one-decimal formatter. Once the transition finishes,
  /// this explicit final label is restored.
  final String? personalRatingLabel;

  /// Maximum valid personal rating.
  final double ratingMax;

  /// Indicators the user has chosen to display.
  ///
  /// This never modifies actual media state.
  final Set<CinearaStatusDockIndicator> visibleIndicators;

  /// Permanent or compact presentation.
  final CinearaStatusDockMode mode;

  /// Artwork or ordinary-surface treatment.
  final CinearaStatusDockVariant variant;

  /// Physical visual density.
  final CinearaStatusDockDensity density;

  /// Logical card edge to which the dock is aligned.
  final CinearaStatusDockSide side;

  /// Whether the dock itself handles tap-to-reveal in compact mode.
  ///
  /// Set this to false when the parent poster overlay provides a larger
  /// interaction region and calls [CinearaStatusDockController.reveal].
  final bool tapToExpand;

  /// Whether a temporarily expanded compact dock collapses automatically.
  final bool autoCollapse;

  /// Time the fully revealed compact dock remains visible before collapsing.
  final Duration autoCollapseDelay;

  /// Whether decorative animation is enabled.
  ///
  /// System reduced-motion preferences always take precedence.
  final bool animate;

  /// Optional Favorite semantic-colour override.
  final Color? favoriteAccent;

  /// Optional Collection semantic-colour override.
  final Color? collectionAccent;

  /// Optional Watchlist semantic-colour override.
  final Color? watchlistAccent;

  /// Optional personal-rating semantic-colour override.
  final Color? ratingAccent;

  /// Optional accessibility label override.
  final String? semanticLabel;

  /// Optional accessibility value override.
  final String? semanticValue;

  /// Whether the dock should be removed from the semantics tree.
  final bool excludeFromSemantics;

  @override
  State<CinearaStatusDock> createState() => _CinearaStatusDockState();
}

// =============================================================================
// State
// =============================================================================

final class _CinearaStatusDockState extends State<CinearaStatusDock>
    with TickerProviderStateMixin {
  // ---------------------------------------------------------------------------
  // Timing
  // ---------------------------------------------------------------------------

  /// Brief hold after a change to a dock that was already fully expanded.
  ///
  /// A partially expanded/collapsing dock never receives this delay because
  /// freezing intermediate geometry would make nodes overlap visually.
  static const Duration _inheritedOpenCollapseDelay = Duration(
    milliseconds: 700,
  );

  // ---------------------------------------------------------------------------
  // Controllers
  // ---------------------------------------------------------------------------

  late final AnimationController _expansionController;
  late final AnimationController _attachmentController;
  late final AnimationController _pulseController;
  late final AnimationController _settleController;
  late final AnimationController _ratingController;

  // ---------------------------------------------------------------------------
  // Accessibility / motion
  // ---------------------------------------------------------------------------

  bool _reduceMotion = false;

  // ---------------------------------------------------------------------------
  // Current explicit reaction
  // ---------------------------------------------------------------------------

  Set<CinearaStatusDockIndicator> _reactingIndicators =
      const <CinearaStatusDockIndicator>{};

  CinearaStatusDockIndicator? _pulseIndicator;

  // ---------------------------------------------------------------------------
  // Deferred numerical-rating transition
  // ---------------------------------------------------------------------------

  /// Numerical rating before the latest external application-state update.
  double? _ratingAnimationFrom;

  /// Numerical rating after the latest external application-state update.
  double? _ratingAnimationTo;

  /// Whether the rating node should currently render its interpolated value.
  ///
  /// Merely changing [widget.personalRating] does not activate this. The
  /// animation is armed only when [CinearaStatusDockController.revealChanges]
  /// explicitly begins the visible feedback sequence.
  bool _ratingAnimationActive = false;

  // ---------------------------------------------------------------------------
  // Sequence invalidation
  // ---------------------------------------------------------------------------

  int _sequenceGeneration = 0;

  // ===========================================================================
  // Lifecycle
  // ===========================================================================

  @override
  void initState() {
    super.initState();

    assert(
      widget.autoCollapseDelay.inMicroseconds >= 0,
      'autoCollapseDelay must not be negative.',
    );

    _expansionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      reverseDuration: const Duration(milliseconds: 280),
      value: widget.mode == CinearaStatusDockMode.permanent ? 1 : 0,
    );

    _attachmentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
      value: 1,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
      value: 1,
    );

    _settleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      value: 1,
    );

    _ratingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
      value: 1,
    );

    widget.controller?._attach(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final MediaQueryData mediaQuery = MediaQuery.of(context);

    _reduceMotion =
        mediaQuery.disableAnimations || mediaQuery.accessibleNavigation;

    if (!_animationsEnabled) {
      _finishDecorativeAnimationsImmediately();
    }
  }

  @override
  void didUpdateWidget(CinearaStatusDock oldWidget) {
    super.didUpdateWidget(oldWidget);

    assert(
      widget.autoCollapseDelay.inMicroseconds >= 0,
      'autoCollapseDelay must not be negative.',
    );

    // -------------------------------------------------------------------------
    // Controller ownership
    // -------------------------------------------------------------------------

    if (!identical(oldWidget.controller, widget.controller)) {
      oldWidget.controller?._detach(this);

      widget.controller?._attach(this);
    }

    // -------------------------------------------------------------------------
    // Mode changes
    // -------------------------------------------------------------------------

    if (oldWidget.mode != widget.mode) {
      _cancelCurrentSequence();

      _expansionController.value =
          widget.mode == CinearaStatusDockMode.permanent ? 1 : 0;

      _settleController.value = 1;
    }

    // -------------------------------------------------------------------------
    // Motion changes
    // -------------------------------------------------------------------------

    if (!widget.animate && oldWidget.animate) {
      _finishDecorativeAnimationsImmediately();
    }

    // -------------------------------------------------------------------------
    // Rating transition capture
    // -------------------------------------------------------------------------

    if (oldWidget.personalRating != widget.personalRating) {
      // Capture the transition but deliberately do not animate it here.
      //
      // The parent may still be displaying a quick-actions surface. The count
      // animation should begin only after revealChanges() is explicitly called
      // once the media presentation is visible again.
      _ratingAnimationFrom = oldWidget.personalRating;

      _ratingAnimationTo = widget.personalRating;

      _ratingController
        ..stop()
        ..value = 1;

      _ratingAnimationActive = false;
    }
  }

  @override
  void dispose() {
    widget.controller?._detach(this);

    _expansionController.dispose();
    _attachmentController.dispose();
    _pulseController.dispose();
    _settleController.dispose();
    _ratingController.dispose();

    super.dispose();
  }

  // ===========================================================================
  // Derived state
  // ===========================================================================

  bool get _animationsEnabled => widget.animate && !_reduceMotion;

  /// Active visible entries in canonical bottom-to-top order.
  ///
  /// Because [entries.first] is also the compact anchor, this order naturally
  /// implements:
  ///
  /// ```text
  /// Rating
  /// → Watchlist
  /// → Favorite
  /// → Collection
  /// ```
  List<_StatusDockEntry> get _activeEntries {
    final List<_StatusDockEntry> entries = <_StatusDockEntry>[];

    // -------------------------------------------------------------------------
    // Rating — canonical bottom node
    // -------------------------------------------------------------------------

    if (widget.visibleIndicators.contains(CinearaStatusDockIndicator.rating) &&
        widget.personalRating != null) {
      entries.add(
        _StatusDockEntry(
          indicator: CinearaStatusDockIndicator.rating,
          semanticLabel: widget.labels.personalRating,
          accent: widget.ratingAccent ?? CinearaStatusColours.rating,
          icon: Icons.star_rounded,
          value: _ratingText,
        ),
      );
    }

    // -------------------------------------------------------------------------
    // Watchlist
    // -------------------------------------------------------------------------

    if (widget.visibleIndicators.contains(
          CinearaStatusDockIndicator.watchlist,
        ) &&
        widget.watchlist) {
      entries.add(
        _StatusDockEntry(
          indicator: CinearaStatusDockIndicator.watchlist,
          semanticLabel: widget.labels.watchlist,
          accent: widget.watchlistAccent ?? CinearaStatusColours.watchlist,
          icon: Icons.bookmark_rounded,
        ),
      );
    }

    // -------------------------------------------------------------------------
    // Favorite
    // -------------------------------------------------------------------------

    if (widget.visibleIndicators.contains(
          CinearaStatusDockIndicator.favorite,
        ) &&
        widget.favorite) {
      entries.add(
        _StatusDockEntry(
          indicator: CinearaStatusDockIndicator.favorite,
          semanticLabel: widget.labels.favorite,
          accent: widget.favoriteAccent ?? CinearaStatusColours.favourite,
          icon: Icons.favorite_rounded,
        ),
      );
    }

    // -------------------------------------------------------------------------
    // Collection — canonical top node
    // -------------------------------------------------------------------------

    if (widget.visibleIndicators.contains(
          CinearaStatusDockIndicator.collection,
        ) &&
        widget.collection) {
      entries.add(
        _StatusDockEntry(
          indicator: CinearaStatusDockIndicator.collection,
          semanticLabel: widget.labels.collection,
          accent: widget.collectionAccent ?? CinearaStatusColours.collection,
          icon: Icons.layers_rounded,
        ),
      );
    }

    return entries;
  }

  String get _ratingText {
    final String? explicit = widget.personalRatingLabel?.trim();

    if (explicit != null && explicit.isNotEmpty) {
      return explicit;
    }

    final double? rating = widget.personalRating;

    if (rating == null) {
      return '';
    }

    return _formatRating(rating);
  }

  String get _resolvedSemanticLabel {
    final String? explicit = widget.semanticLabel?.trim();

    if (explicit != null && explicit.isNotEmpty) {
      return explicit;
    }

    return widget.labels.dock;
  }

  String _resolveSemanticValue(List<_StatusDockEntry> entries) {
    final String? explicit = widget.semanticValue?.trim();

    if (explicit != null && explicit.isNotEmpty) {
      return explicit;
    }

    return entries
        .map((_StatusDockEntry entry) {
          if (entry.indicator == CinearaStatusDockIndicator.rating &&
              entry.value != null) {
            return '${entry.semanticLabel}: ${entry.value}';
          }

          return entry.semanticLabel;
        })
        .join(', ');
  }

  Color _accentForIndicator(CinearaStatusDockIndicator indicator) {
    return switch (indicator) {
      CinearaStatusDockIndicator.favorite =>
        widget.favoriteAccent ?? CinearaStatusColours.favourite,

      CinearaStatusDockIndicator.collection =>
        widget.collectionAccent ?? CinearaStatusColours.collection,

      CinearaStatusDockIndicator.watchlist =>
        widget.watchlistAccent ?? CinearaStatusColours.watchlist,

      CinearaStatusDockIndicator.rating =>
        widget.ratingAccent ?? CinearaStatusColours.rating,
    };
  }

  bool get _hasNumericalRatingTransition {
    final double? from = _ratingAnimationFrom;

    final double? to = _ratingAnimationTo;

    return from != null && to != null && from != to;
  }

  // ===========================================================================
  // Public-controller actions
  // ===========================================================================

  /// Explicit reveal.
  ///
  /// This is intentionally different from a state-change reaction. It is used
  /// for user inspection and presentation previews.
  Future<void> _revealFromController() async {
    await _runRevealSequence(
      changedIndicators: const <CinearaStatusDockIndicator>{},
      forceRevealStack: true,
    );
  }

  /// Reacts intelligently to actual media-state changes.
  Future<void> _revealChanges(
    Set<CinearaStatusDockIndicator> changedIndicators,
  ) async {
    final Set<CinearaStatusDockIndicator> relevantChanges = changedIndicators
        .where(widget.visibleIndicators.contains)
        .toSet();

    if (relevantChanges.isEmpty) {
      return;
    }

    await _runRevealSequence(
      changedIndicators: relevantChanges,
      forceRevealStack: false,
    );
  }

  Future<void> _collapseFromController() async {
    if (widget.mode != CinearaStatusDockMode.compact) {
      return;
    }

    final int generation = _beginSequence(
      reactingIndicators: const <CinearaStatusDockIndicator>{},
    );

    await _collapse(generation);

    _clearReactionState(generation);
  }

  // ===========================================================================
  // Tap behaviour
  // ===========================================================================

  void _handleCompactTap() {
    final List<_StatusDockEntry> entries = _activeEntries;

    if (widget.mode != CinearaStatusDockMode.compact ||
        !widget.tapToExpand ||
        entries.length <= 1) {
      return;
    }

    // A second tap while substantially open collapses immediately rather than
    // restarting the reveal/auto-collapse sequence.
    if (_expansionController.value > 0.55) {
      unawaited(_collapseFromController());

      return;
    }

    unawaited(_revealFromController());
  }

  // ===========================================================================
  // Complete reveal / state-change sequence
  // ===========================================================================

  Future<void> _runRevealSequence({
    required Set<CinearaStatusDockIndicator> changedIndicators,
    required bool forceRevealStack,
  }) async {
    final List<_StatusDockEntry> entries = _activeEntries;

    // If the dock became completely empty, reset its internal compact position.
    //
    // This matters especially when autoCollapse is disabled or when the final
    // active indicator disappears while another sequence was still in flight.
    if (entries.isEmpty) {
      _cancelCurrentSequence();

      _expansionController.value =
          widget.mode == CinearaStatusDockMode.permanent ? 1 : 0;

      return;
    }

    // =========================================================================
    // Preserve inherited expansion state
    // =========================================================================

    // Capture this before _beginSequence() stops the previous expansion
    // controller and invalidates that sequence's pending auto-collapse.
    final double inheritedExpansion = _expansionController.value;

    final AnimationStatus inheritedExpansionStatus =
        _expansionController.status;

    // The longer inherited-open delay is reserved strictly for a dock that was
    // already stably and completely expanded.
    //
    // A partial value must never receive this hold because doing so would freeze
    // nodes while they geometrically overlap.
    final bool dockWasFullyExpanded =
        widget.mode == CinearaStatusDockMode.compact &&
        inheritedExpansion >= 0.999 &&
        inheritedExpansionStatus == AnimationStatus.completed;

    // Any visible non-zero state that is not a stable completed expansion is
    // treated as a transition.
    //
    // This also covers an unusual stopped partial controller value safely.
    final bool dockWasMidTransition =
        widget.mode == CinearaStatusDockMode.compact &&
        inheritedExpansion > 0.001 &&
        !dockWasFullyExpanded;

    // =========================================================================
    // Change classification
    // =========================================================================

    final bool ratingChanged = changedIndicators.contains(
      CinearaStatusDockIndicator.rating,
    );

    final bool numericalRatingChange =
        ratingChanged && _hasNumericalRatingTransition;

    // -------------------------------------------------------------------------
    // Added indicators
    //
    // Boolean indicators:
    //
    // changed + active now
    // => false -> true
    //
    // Rating:
    //
    // null -> value
    // => newly added Rating indicator
    //
    // value -> value
    // => numerical update, not an addition
    //
    // value -> null
    // => removal
    // -------------------------------------------------------------------------

    final Set<CinearaStatusDockIndicator> addedIndicators = changedIndicators
        .where((CinearaStatusDockIndicator indicator) {
          if (!widget.visibleIndicators.contains(indicator)) {
            return false;
          }

          return switch (indicator) {
            CinearaStatusDockIndicator.rating =>
              _ratingAnimationFrom == null && _ratingAnimationTo != null,

            CinearaStatusDockIndicator.favorite => widget.favorite,

            CinearaStatusDockIndicator.collection => widget.collection,

            CinearaStatusDockIndicator.watchlist => widget.watchlist,
          };
        })
        .toSet();

    // =========================================================================
    // Reveal policy
    // =========================================================================

    // The complete chain opens automatically only when a new state joins it.
    //
    // Explicit reveal() also opens the complete compact chain because it
    // represents deliberate inspection, including Settings previews.
    //
    // Removal alone does not open a collapsed dock.
    //
    // Existing-rating numerical changes do not open a collapsed dock.
    final bool shouldRevealStack =
        forceRevealStack || addedIndicators.isNotEmpty;

    // Only newly added states receive magnetic attachment.
    final Set<CinearaStatusDockIndicator> attachmentIndicators =
        addedIndicators;

    final int generation = _beginSequence(
      reactingIndicators: attachmentIndicators,
      pulseIndicator: addedIndicators.isNotEmpty
          ? _firstChangedIndicator(addedIndicators)
          : null,
    );

    // =========================================================================
    // Prepare numerical rating transition
    // =========================================================================

    if (numericalRatingChange) {
      _prepareRatingAnimation(generation);
    }

    // =========================================================================
    // Compact reveal
    // =========================================================================

    bool revealedStackThisSequence = false;

    if (widget.mode == CinearaStatusDockMode.compact &&
        entries.length > 1 &&
        shouldRevealStack) {
      revealedStackThisSequence = true;

      await _expand(generation);

      if (!_sequenceIsCurrent(generation)) {
        return;
      }
    }

    // =========================================================================
    // Interrupted-transition policy
    //
    // If a non-reveal change arrives while the stack is opening/collapsing,
    // continue immediately toward compact state.
    //
    // Do not wait for the inherited-open delay.
    //
    // Examples:
    //
    // opening + remove
    // → reverse immediately
    //
    // collapsing + remove
    // → continue immediately
    //
    // collapsing + rating change
    // → continue collapsing while the rating number animates
    // =========================================================================

    final bool shouldCollapseTransitionImmediately =
        widget.autoCollapse && !shouldRevealStack && dockWasMidTransition;

    // =========================================================================
    // Primary feedback
    //
    // Newly added nodes magnetically attach.
    //
    // An existing Rating changing numerically counts toward the new target.
    //
    // An inherited partial expansion collapses concurrently rather than being
    // frozen while those feedback animations run.
    // =========================================================================

    final List<Future<void>> feedbackAnimations = <Future<void>>[];

    if (attachmentIndicators.isNotEmpty) {
      feedbackAnimations.add(_runAttachment(generation));
    }

    if (numericalRatingChange) {
      feedbackAnimations.add(_runRatingChange(generation));
    }

    if (shouldCollapseTransitionImmediately) {
      feedbackAnimations.add(_collapse(generation));
    }

    if (feedbackAnimations.isNotEmpty) {
      await Future.wait(feedbackAnimations);

      if (!_sequenceIsCurrent(generation)) {
        return;
      }
    }

    // =========================================================================
    // Rail pulse
    //
    // The full-chain rail pulse specifically communicates:
    //
    // "a new state joined this chain"
    //
    // It does not run for:
    //
    // - removals
    // - numerical Rating updates
    // - ordinary explicit reveal()
    // =========================================================================

    if (addedIndicators.isNotEmpty && entries.length > 1) {
      await _runPulse(generation);

      if (!_sequenceIsCurrent(generation)) {
        return;
      }
    }

    // =========================================================================
    // Permanent mode
    // =========================================================================

    if (widget.mode == CinearaStatusDockMode.permanent) {
      _clearReactionState(generation);

      return;
    }

    // =========================================================================
    // Compact return-to-rest policy
    //
    // 1. A stack deliberately revealed by this sequence receives the ordinary
    //    auto-collapse delay.
    //
    // 2. A stack inherited in a fully expanded, stable state receives the
    //    shorter inherited-open delay.
    //
    // 3. A stack inherited mid-transition has already been sent directly
    //    toward collapsed state above and therefore receives no delay here.
    // =========================================================================

    final bool shouldReturnToCollapsed =
        widget.autoCollapse &&
        !shouldCollapseTransitionImmediately &&
        (revealedStackThisSequence || dockWasFullyExpanded);

    if (shouldReturnToCollapsed) {
      final Duration collapseDelay = revealedStackThisSequence
          ? widget.autoCollapseDelay
          : _inheritedOpenCollapseDelay;

      await _wait(collapseDelay, generation);

      if (!_sequenceIsCurrent(generation)) {
        return;
      }

      await _collapse(generation);

      if (!_sequenceIsCurrent(generation)) {
        return;
      }
    }

    _clearReactionState(generation);
  }

  // ===========================================================================
  // Expansion
  // ===========================================================================

  Future<void> _expand(int generation) async {
    if (!_sequenceIsCurrent(generation)) {
      return;
    }

    if (widget.mode != CinearaStatusDockMode.compact) {
      _expansionController.value = 1;

      return;
    }

    if (!_animationsEnabled) {
      _expansionController.value = 1;

      return;
    }

    try {
      await _expansionController.forward().orCancel;
    } on TickerCanceled {
      return;
    }
  }

  // ===========================================================================
  // Collapse
  // ===========================================================================

  Future<void> _collapse(int generation) async {
    if (!_sequenceIsCurrent(generation)) {
      return;
    }

    if (widget.mode != CinearaStatusDockMode.compact) {
      _expansionController.value = 1;

      return;
    }

    if (!_animationsEnabled) {
      _expansionController.value = 0;
      _settleController.value = 1;

      return;
    }

    try {
      await _expansionController.reverse().orCancel;
    } on TickerCanceled {
      return;
    }

    if (!_sequenceIsCurrent(generation)) {
      return;
    }

    // Small final compression/overshoot makes the return of the non-anchor
    // indicators feel as though they have physically settled into the anchor.
    try {
      await _settleController.forward(from: 0).orCancel;
    } on TickerCanceled {
      return;
    }
  }

  // ===========================================================================
  // Changed-node magnetic attachment
  // ===========================================================================

  Future<void> _runAttachment(int generation) async {
    if (!_sequenceIsCurrent(generation)) {
      return;
    }

    if (!_animationsEnabled) {
      _attachmentController.value = 1;

      return;
    }

    try {
      await _attachmentController.forward(from: 0).orCancel;
    } on TickerCanceled {
      return;
    }
  }

  // ===========================================================================
  // Rail pulse
  // ===========================================================================

  Future<void> _runPulse(int generation) async {
    if (!_sequenceIsCurrent(generation)) {
      return;
    }

    if (!_animationsEnabled) {
      _pulseController.value = 1;

      return;
    }

    try {
      await _pulseController.forward(from: 0).orCancel;
    } on TickerCanceled {
      return;
    }
  }

  // ===========================================================================
  // Rating change
  // ===========================================================================

  void _prepareRatingAnimation(int generation) {
    if (!_sequenceIsCurrent(generation)) {
      return;
    }

    if (!_hasNumericalRatingTransition || !_animationsEnabled) {
      _ratingController
        ..stop()
        ..value = 1;

      _ratingAnimationActive = false;

      return;
    }

    _ratingController
      ..stop()
      ..value = 0;

    if (mounted) {
      setState(() {
        _ratingAnimationActive = true;
      });
    }
  }

  Future<void> _runRatingChange(int generation) async {
    if (!_sequenceIsCurrent(generation)) {
      return;
    }

    final double? from = _ratingAnimationFrom;

    final double? to = _ratingAnimationTo;

    // Only animate:
    //
    // existing numerical Rating
    //        ↓
    // another numerical Rating
    //
    // null -> value is an addition.
    //
    // value -> null is removal.
    if (from == null || to == null || from == to) {
      _finishRatingAnimation(generation);

      return;
    }

    if (!_animationsEnabled) {
      _finishRatingAnimation(generation);

      return;
    }

    // Larger changes receive more time while remaining bounded.
    //
    // Examples:
    //
    // 8.4 -> 8.5  ≈ 550 ms
    // 6.0 -> 8.5  ≈ 675 ms
    // 3.0 -> 9.5  ≈ 950 ms
    final double distance = (to - from).abs();

    final int rawDurationMs = (500 + (distance * 70)).round();

    final int durationMs = rawDurationMs.clamp(550, 950).toInt();

    _ratingController.duration = Duration(milliseconds: durationMs);

    try {
      await _ratingController.forward().orCancel;
    } on TickerCanceled {
      return;
    }

    _finishRatingAnimation(generation);
  }

  void _finishRatingAnimation(int generation) {
    if (!_sequenceIsCurrent(generation)) {
      return;
    }

    _ratingController
      ..stop()
      ..value = 1;

    if (mounted && _ratingAnimationActive) {
      setState(() {
        _ratingAnimationActive = false;
      });

      return;
    }

    _ratingAnimationActive = false;
  }

  // ===========================================================================
  // Sequence management
  // ===========================================================================

  int _beginSequence({
    required Set<CinearaStatusDockIndicator> reactingIndicators,
    CinearaStatusDockIndicator? pulseIndicator,
  }) {
    _sequenceGeneration++;

    // Preserve the current expansion value while stopping the previous
    // expansion/collapse animation.
    //
    // The new sequence decides whether to continue expanding or reverse toward
    // collapsed state from exactly the geometry currently on screen.
    _expansionController.stop();

    _attachmentController.stop();
    _pulseController.stop();
    _settleController.stop();
    _ratingController.stop();

    _attachmentController.value = 1;
    _pulseController.value = 1;
    _settleController.value = 1;
    _ratingController.value = 1;

    _ratingAnimationActive = false;

    if (mounted) {
      setState(() {
        _reactingIndicators = Set<CinearaStatusDockIndicator>.unmodifiable(
          reactingIndicators,
        );

        _pulseIndicator = pulseIndicator;
      });
    }

    return _sequenceGeneration;
  }

  void _cancelCurrentSequence() {
    _sequenceGeneration++;

    _expansionController.stop();
    _attachmentController.stop();
    _pulseController.stop();
    _settleController.stop();
    _ratingController.stop();

    _attachmentController.value = 1;
    _pulseController.value = 1;
    _settleController.value = 1;
    _ratingController.value = 1;

    _reactingIndicators = const <CinearaStatusDockIndicator>{};

    _pulseIndicator = null;

    _ratingAnimationActive = false;
  }

  void _clearReactionState(int generation) {
    if (!_sequenceIsCurrent(generation) || !mounted) {
      return;
    }

    setState(() {
      _reactingIndicators = const <CinearaStatusDockIndicator>{};

      _pulseIndicator = null;

      _ratingAnimationActive = false;
    });
  }

  bool _sequenceIsCurrent(int generation) {
    return mounted && generation == _sequenceGeneration;
  }

  Future<void> _wait(Duration duration, int generation) async {
    if (duration.inMicroseconds <= 0) {
      return;
    }

    await Future<void>.delayed(duration);

    if (!_sequenceIsCurrent(generation)) {
      return;
    }
  }

  // ===========================================================================
  // Animation cleanup
  // ===========================================================================

  void _finishDecorativeAnimationsImmediately() {
    _attachmentController
      ..stop()
      ..value = 1;

    _pulseController
      ..stop()
      ..value = 1;

    _settleController
      ..stop()
      ..value = 1;

    _ratingController
      ..stop()
      ..value = 1;

    _ratingAnimationActive = false;

    if (widget.mode == CinearaStatusDockMode.permanent) {
      _expansionController
        ..stop()
        ..value = 1;
    }
  }

  // ===========================================================================
  // Reaction helpers
  // ===========================================================================

  CinearaStatusDockIndicator? _firstChangedIndicator(
    Set<CinearaStatusDockIndicator> changedIndicators,
  ) {
    // Match the canonical bottom-to-top dock hierarchy.
    const List<CinearaStatusDockIndicator> priority =
        <CinearaStatusDockIndicator>[
          CinearaStatusDockIndicator.rating,
          CinearaStatusDockIndicator.watchlist,
          CinearaStatusDockIndicator.favorite,
          CinearaStatusDockIndicator.collection,
        ];

    for (final CinearaStatusDockIndicator indicator in priority) {
      if (changedIndicators.contains(indicator)) {
        return indicator;
      }
    }

    return null;
  }

  Color _pulseAccent(List<_StatusDockEntry> entries) {
    final CinearaStatusDockIndicator? indicator = _pulseIndicator;

    if (indicator != null) {
      return _accentForIndicator(indicator);
    }

    if (entries.isNotEmpty) {
      return entries.first.accent;
    }

    return Theme.of(context).colorScheme.primary;
  }

  // ===========================================================================
  // Build
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final List<_StatusDockEntry> entries = _activeEntries;

    // No dormant line, handle, node, rail, or other affordance.
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    final bool highContrast = MediaQuery.highContrastOf(context);

    final _StatusDockMetrics metrics = _StatusDockMetrics.resolve(
      context: context,
      density: widget.density,
    );

    final _StatusDockRailPalette railPalette = _StatusDockRailPalette.resolve(
      context: context,
      variant: widget.variant,
      highContrast: highContrast,
    );

    final List<CinearaStatusDockIndicator> activeReactingIndicators = entries
        .where(
          (_StatusDockEntry entry) =>
              _reactingIndicators.contains(entry.indicator),
        )
        .map((_StatusDockEntry entry) => entry.indicator)
        .toList(growable: false);

    final Widget visual = _StatusDockVisual(
      entries: entries,
      mode: widget.mode,
      variant: widget.variant,
      side: widget.side,
      metrics: metrics,
      highContrast: highContrast,
      railPalette: railPalette,
      expansionAnimation: _expansionController,
      attachmentAnimation: _attachmentController,
      settleAnimation: _settleController,
      pulseAnimation: _pulseController,
      pulseAccent: _pulseAccent(entries),
      reactingIndicators: activeReactingIndicators,
      ratingAnimation: _ratingController,
      ratingAnimationActive: _ratingAnimationActive,
      ratingAnimationFrom: _ratingAnimationFrom,
      ratingAnimationTo: _ratingAnimationTo,
    );

    final bool canTapToReveal =
        widget.mode == CinearaStatusDockMode.compact &&
        widget.tapToExpand &&
        entries.length > 1;

    final Widget interactionChild;

    if (canTapToReveal) {
      const double minimumTapTarget = 56;

      final double minimumWidth = math
          .max(minimumTapTarget, metrics.maximumWidthFor(entries) + 12)
          .toDouble();

      final double minimumHeight = math
          .max(minimumTapTarget, metrics.outerDiameter + 12)
          .toDouble();

      final AlignmentGeometry alignment =
          widget.side == CinearaStatusDockSide.end
          ? AlignmentDirectional.bottomEnd
          : AlignmentDirectional.bottomStart;

      interactionChild = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleCompactTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: minimumWidth,
            minHeight: minimumHeight,
          ),
          child: Align(alignment: alignment, child: visual),
        ),
      );
    } else {
      interactionChild = IgnorePointer(child: visual);
    }

    final Widget semanticChild = ExcludeSemantics(child: interactionChild);

    if (widget.excludeFromSemantics) {
      return semanticChild;
    }

    return Semantics(
      container: true,
      label: _resolvedSemanticLabel,
      value: _resolveSemanticValue(entries),
      button: canTapToReveal,
      onTap: canTapToReveal ? _handleCompactTap : null,
      child: semanticChild,
    );
  }
}

// =============================================================================
// Dock visual
// =============================================================================

final class _StatusDockVisual extends StatelessWidget {
  const _StatusDockVisual({
    required this.entries,
    required this.mode,
    required this.variant,
    required this.side,
    required this.metrics,
    required this.highContrast,
    required this.railPalette,
    required this.expansionAnimation,
    required this.attachmentAnimation,
    required this.settleAnimation,
    required this.pulseAnimation,
    required this.pulseAccent,
    required this.reactingIndicators,
    required this.ratingAnimation,
    required this.ratingAnimationActive,
    required this.ratingAnimationFrom,
    required this.ratingAnimationTo,
  });

  final List<_StatusDockEntry> entries;

  final CinearaStatusDockMode mode;
  final CinearaStatusDockVariant variant;
  final CinearaStatusDockSide side;

  final _StatusDockMetrics metrics;

  final bool highContrast;

  final _StatusDockRailPalette railPalette;

  final Animation<double> expansionAnimation;
  final Animation<double> attachmentAnimation;
  final Animation<double> settleAnimation;
  final Animation<double> pulseAnimation;

  final Color pulseAccent;

  final List<CinearaStatusDockIndicator> reactingIndicators;

  final Animation<double> ratingAnimation;

  final bool ratingAnimationActive;

  final double? ratingAnimationFrom;
  final double? ratingAnimationTo;

  @override
  Widget build(BuildContext context) {
    final Animation<double> resolvedExpansion =
        mode == CinearaStatusDockMode.permanent
        ? const AlwaysStoppedAnimation<double>(1)
        : expansionAnimation;

    return AnimatedBuilder(
      animation: resolvedExpansion,
      builder: (BuildContext context, Widget? child) {
        final double expansion = Curves.easeInOutCubic.transform(
          resolvedExpansion.value.clamp(0.0, 1.0).toDouble(),
        );

        final _StatusDockEntry anchor = entries.first;

        final double collapsedWidth = metrics.widthFor(anchor);

        final double expandedWidth = metrics.maximumWidthFor(entries);

        final double collapsedHeight = metrics.outerDiameter;

        final double expandedHeight = metrics.heightFor(entries.length);

        final double currentWidth = _lerp(
          collapsedWidth,
          expandedWidth,
          expansion,
        );

        final double currentHeight = _lerp(
          collapsedHeight,
          expandedHeight,
          expansion,
        );

        final List<_StatusDockEntry> nonAnchorEntries = entries
            .skip(1)
            .toList(growable: false);

        return SizedBox(
          width: currentWidth,
          height: currentHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              // ---------------------------------------------------------
              // Rail
              // ---------------------------------------------------------
              if (entries.length > 1)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _StatusDockRailPainter(
                      repaint: pulseAnimation,
                      count: entries.length,
                      side: side,
                      metrics: metrics,
                      railColor: railPalette.rail,
                      pulseColor: pulseAccent,
                      pulse: pulseAnimation,
                      expansionProgress: expansion,
                    ),
                  ),
                ),

              // ---------------------------------------------------------
              // Non-anchor nodes
              // ---------------------------------------------------------
              if (expansion > 0.001)
                for (
                  int index = nonAnchorEntries.length - 1;
                  index >= 0;
                  index--
                )
                  _positionedEntry(
                    entry: nonAnchorEntries[index],
                    fullIndex: index + 1,
                    expansion: expansion,
                    reactingIndicators: reactingIndicators,
                  ),

              // ---------------------------------------------------------
              // Stable anchor
              // ---------------------------------------------------------
              _positionedEntry(
                entry: anchor,
                fullIndex: 0,
                expansion: expansion,
                reactingIndicators: reactingIndicators,
                isAnchor: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _positionedEntry({
    required _StatusDockEntry entry,
    required int fullIndex,
    required double expansion,
    required List<CinearaStatusDockIndicator> reactingIndicators,
    bool isAnchor = false,
  }) {
    final double targetBottom = fullIndex * metrics.nodeExtent;

    final double animatedBottom = targetBottom * expansion;

    final int reactionIndex = reactingIndicators.indexOf(entry.indicator);

    final int reactionCount = reactingIndicators.length;

    final Widget slot = _StatusDockSlot(
      key: ValueKey<CinearaStatusDockIndicator>(entry.indicator),
      entry: entry,
      variant: variant,
      side: side,
      metrics: metrics,
      highContrast: highContrast,
      attachmentAnimation: attachmentAnimation,
      settleAnimation: settleAnimation,
      reactionIndex: reactionIndex,
      reactionCount: reactionCount,
      isAnchor: isAnchor,
      ratingAnimation: ratingAnimation,
      ratingAnimationActive: ratingAnimationActive,
      ratingAnimationFrom: ratingAnimationFrom,
      ratingAnimationTo: ratingAnimationTo,
    );

    if (side == CinearaStatusDockSide.end) {
      return PositionedDirectional(end: 0, bottom: animatedBottom, child: slot);
    }

    return PositionedDirectional(start: 0, bottom: animatedBottom, child: slot);
  }
}

// =============================================================================
// Dock slot
// =============================================================================

final class _StatusDockSlot extends StatelessWidget {
  const _StatusDockSlot({
    required this.entry,
    required this.variant,
    required this.side,
    required this.metrics,
    required this.highContrast,
    required this.attachmentAnimation,
    required this.settleAnimation,
    required this.reactionIndex,
    required this.reactionCount,
    required this.isAnchor,
    required this.ratingAnimation,
    required this.ratingAnimationActive,
    required this.ratingAnimationFrom,
    required this.ratingAnimationTo,
    super.key,
  });

  final _StatusDockEntry entry;

  final CinearaStatusDockVariant variant;
  final CinearaStatusDockSide side;

  final _StatusDockMetrics metrics;

  final bool highContrast;

  final Animation<double> attachmentAnimation;
  final Animation<double> settleAnimation;

  /// -1 means this node was not part of the magnetic attachment sequence.
  final int reactionIndex;

  final int reactionCount;

  final bool isAnchor;

  final Animation<double> ratingAnimation;

  final bool ratingAnimationActive;

  final double? ratingAnimationFrom;
  final double? ratingAnimationTo;

  @override
  Widget build(BuildContext context) {
    Widget node = entry.indicator == CinearaStatusDockIndicator.rating
        ? _StatusDockRatingNode(
            entry: entry,
            variant: variant,
            side: side,
            metrics: metrics,
            highContrast: highContrast,
            animation: ratingAnimation,
            animationActive: ratingAnimationActive,
            animationFrom: ratingAnimationFrom,
            animationTo: ratingAnimationTo,
          )
        : _StatusDockBinaryNode(
            entry: entry,
            variant: variant,
            metrics: metrics,
            highContrast: highContrast,
          );

    // Only newly added nodes receive magnetic attachment.
    //
    // There is deliberately no:
    //
    // - opacity animation
    // - FadeTransition
    // - AnimatedOpacity
    // - scale-in animation
    //
    // The badge is fully opaque and fully sized throughout attachment.
    if (reactionIndex >= 0) {
      node = _MagneticDockAttachment(
        side: side,
        animation: attachmentAnimation,
        staggerIndex: reactionIndex,
        staggerCount: reactionCount,
        travel: metrics.attachmentTravel,
        child: node,
      );
    }

    if (isAnchor) {
      node = _StatusDockAnchorSettle(animation: settleAnimation, child: node);
    }

    return node;
  }
}

// =============================================================================
// Magnetic attachment
// =============================================================================

final class _MagneticDockAttachment extends StatelessWidget {
  const _MagneticDockAttachment({
    required this.side,
    required this.animation,
    required this.staggerIndex,
    required this.staggerCount,
    required this.travel,
    required this.child,
  });

  final CinearaStatusDockSide side;

  final Animation<double> animation;

  final int staggerIndex;
  final int staggerCount;

  final double travel;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final TextDirection direction = Directionality.of(context);

    final double inwardSign = _physicalInwardSign(
      side: side,
      direction: direction,
    );

    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (BuildContext context, Widget? child) {
        final double progress = _staggeredProgress(
          animation.value,
          index: staggerIndex,
          count: staggerCount,
        );

        final double movement = _lerp(
          travel,
          0,
          Curves.easeOutCubic.transform(progress),
        );

        return Transform.translate(
          offset: Offset(movement * inwardSign, 0),
          child: child,
        );
      },
    );
  }
}

// =============================================================================
// Anchor settle
// =============================================================================

final class _StatusDockAnchorSettle extends StatelessWidget {
  const _StatusDockAnchorSettle({required this.animation, required this.child});

  final Animation<double> animation;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (BuildContext context, Widget? child) {
        final double progress = animation.value.clamp(0.0, 1.0).toDouble();

        final double scale = _anchorSettleScale(progress);

        return Transform.scale(scale: scale, child: child);
      },
    );
  }
}

// =============================================================================
// Binary node
// =============================================================================

final class _StatusDockBinaryNode extends StatelessWidget {
  const _StatusDockBinaryNode({
    required this.entry,
    required this.variant,
    required this.metrics,
    required this.highContrast,
  });

  final _StatusDockEntry entry;

  final CinearaStatusDockVariant variant;

  final _StatusDockMetrics metrics;

  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    final _StatusDockNodePalette palette = _StatusDockNodePalette.resolve(
      context: context,
      variant: variant,
      accent: entry.accent,
      highContrast: highContrast,
    );

    return SizedBox.square(
      dimension: metrics.outerDiameter,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: palette.outerSurface,
            ),
          ),

          Padding(
            padding: EdgeInsets.all(metrics.innerInset),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: palette.accent,
              ),
              child: Center(
                child: Icon(
                  entry.icon,
                  size: metrics.iconSize,
                  color: palette.onAccent,
                ),
              ),
            ),
          ),

          if (highContrast)
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: palette.outerOutline,
                    width: metrics.highContrastOuterBorderWidth,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// =============================================================================
// Rating node
// =============================================================================

final class _StatusDockRatingNode extends StatelessWidget {
  const _StatusDockRatingNode({
    required this.entry,
    required this.variant,
    required this.side,
    required this.metrics,
    required this.highContrast,
    required this.animation,
    required this.animationActive,
    required this.animationFrom,
    required this.animationTo,
  });

  final _StatusDockEntry entry;

  final CinearaStatusDockVariant variant;
  final CinearaStatusDockSide side;

  final _StatusDockMetrics metrics;

  final bool highContrast;

  final Animation<double> animation;

  final bool animationActive;

  final double? animationFrom;
  final double? animationTo;

  @override
  Widget build(BuildContext context) {
    final _StatusDockNodePalette palette = _StatusDockNodePalette.resolve(
      context: context,
      variant: variant,
      accent: entry.accent,
      highContrast: highContrast,
    );

    final String finalValue = entry.value ?? '';

    return SizedBox(
      width: metrics.ratingWidth,
      height: metrics.outerDiameter,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: palette.outerSurface,
                borderRadius: BorderRadius.circular(metrics.outerDiameter / 2),
              ),
            ),
          ),

          PositionedDirectional(
            start: side == CinearaStatusDockSide.start
                ? metrics.outerDiameter + metrics.ratingSignalGap
                : metrics.ratingTextPadding,
            end: side == CinearaStatusDockSide.end
                ? metrics.outerDiameter + metrics.ratingSignalGap
                : metrics.ratingTextPadding,
            top: 0,
            bottom: 0,
            child: Center(
              child: Transform.translate(
                offset: Offset(0, metrics.ratingTextVerticalOffset),
                child: AnimatedBuilder(
                  animation: animation,
                  builder: (BuildContext context, Widget? child) {
                    final String displayedValue = _resolveDisplayedRating(
                      finalValue: finalValue,
                    );

                    return Text(
                      displayedValue,
                      maxLines: 1,
                      softWrap: false,
                      textScaler: TextScaler.noScaling,
                      strutStyle: StrutStyle(
                        fontSize: metrics.ratingFontSize,
                        height: 1,
                        forceStrutHeight: true,
                      ),
                      style: TextStyle(
                        color: palette.foreground,
                        fontSize: metrics.ratingFontSize,
                        fontWeight: FontWeight.w800,
                        height: 1,
                        fontFeatures: const <FontFeature>[
                          FontFeature.tabularFigures(),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          PositionedDirectional(
            start: side == CinearaStatusDockSide.start
                ? metrics.innerInset
                : null,
            end: side == CinearaStatusDockSide.end ? metrics.innerInset : null,
            top: metrics.innerInset,
            width: metrics.innerDiameter,
            height: metrics.innerDiameter,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: palette.accent,
              ),
              child: Center(
                child: Transform.translate(
                  offset: Offset(0, metrics.ratingIconVerticalOffset),
                  child: Icon(
                    entry.icon,
                    size: metrics.iconSize,
                    color: palette.onAccent,
                  ),
                ),
              ),
            ),
          ),

          if (highContrast)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      metrics.outerDiameter / 2,
                    ),
                    border: Border.all(
                      color: palette.outerOutline,
                      width: metrics.highContrastOuterBorderWidth,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _resolveDisplayedRating({required String finalValue}) {
    final double? from = animationFrom;

    final double? to = animationTo;

    if (!animationActive || from == null || to == null || from == to) {
      return finalValue;
    }

    final double progress = Curves.easeOutCubic.transform(
      animation.value.clamp(0.0, 1.0).toDouble(),
    );

    final double current = _lerp(from, to, progress);

    return _formatAnimatedRating(current);
  }
}

// =============================================================================
// Rail painter
// =============================================================================

final class _StatusDockRailPainter extends CustomPainter {
  _StatusDockRailPainter({
    required Listenable repaint,
    required this.count,
    required this.side,
    required this.metrics,
    required this.railColor,
    required this.pulseColor,
    required this.pulse,
    required this.expansionProgress,
  }) : super(repaint: repaint);

  final int count;

  final CinearaStatusDockSide side;

  final _StatusDockMetrics metrics;

  final Color railColor;
  final Color pulseColor;

  final Animation<double> pulse;

  final double expansionProgress;

  @override
  void paint(Canvas canvas, Size size) {
    if (count <= 1 || expansionProgress <= 0.001) {
      return;
    }

    final double railX = side == CinearaStatusDockSide.end
        ? size.width - (metrics.outerDiameter / 2)
        : metrics.outerDiameter / 2;

    final double anchorY = size.height - (metrics.outerDiameter / 2);

    final double furthestY =
        anchorY - ((count - 1) * metrics.nodeExtent * expansionProgress);

    final Paint railPaint = Paint()
      ..color = railColor
      ..strokeWidth = metrics.railWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(railX, anchorY),
      Offset(railX, furthestY),
      railPaint,
    );

    final double pulseProgress = pulse.value.clamp(0.0, 1.0).toDouble();

    final double opacity = math.sin(math.pi * pulseProgress);

    if (opacity <= 0.001) {
      return;
    }

    final double pulseY = _lerp(anchorY, furthestY, pulseProgress);

    final double halfLength = metrics.pulseLength / 2;

    final double top = math.min(anchorY, furthestY);

    final double bottom = math.max(anchorY, furthestY);

    final double pulseStart = math.max(top, pulseY - halfLength);

    final double pulseEnd = math.min(bottom, pulseY + halfLength);

    final Paint pulsePaint = Paint()
      ..color = pulseColor.withValues(alpha: opacity.clamp(0.0, 1.0).toDouble())
      ..strokeWidth = metrics.pulseWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(railX, pulseStart),
      Offset(railX, pulseEnd),
      pulsePaint,
    );
  }

  @override
  bool shouldRepaint(_StatusDockRailPainter oldDelegate) {
    return oldDelegate.count != count ||
        oldDelegate.side != side ||
        oldDelegate.metrics != metrics ||
        oldDelegate.railColor != railColor ||
        oldDelegate.pulseColor != pulseColor ||
        oldDelegate.pulse != pulse ||
        oldDelegate.expansionProgress != expansionProgress;
  }
}

// =============================================================================
// Internal entry
// =============================================================================

@immutable
final class _StatusDockEntry {
  const _StatusDockEntry({
    required this.indicator,
    required this.semanticLabel,
    required this.accent,
    required this.icon,
    this.value,
  });

  final CinearaStatusDockIndicator indicator;

  final String semanticLabel;

  final Color accent;

  final IconData icon;

  final String? value;
}

// =============================================================================
// Metrics
// =============================================================================

@immutable
final class _StatusDockMetrics {
  const _StatusDockMetrics({
    required this.outerDiameter,
    required this.innerDiameter,
    required this.ratingWidth,
    required this.iconSize,
    required this.ratingFontSize,
    required this.ratingTextPadding,
    required this.ratingTextVerticalOffset,
    required this.ratingSignalGap,
    required this.ratingIconVerticalOffset,
    required this.nodeGap,
    required this.railWidth,
    required this.pulseWidth,
    required this.pulseLength,
    required this.attachmentTravel,
    required this.highContrastOuterBorderWidth,
  });

  /// Complete circular-node diameter.
  final double outerDiameter;

  /// Semantic inner-circle diameter.
  final double innerDiameter;

  /// Width of the personal-rating pill.
  final double ratingWidth;

  /// Glyph size inside semantic circles.
  final double iconSize;

  /// Personal-rating number size.
  final double ratingFontSize;

  /// Inward padding around rating text.
  final double ratingTextPadding;

  /// Optical vertical offset for rating text.
  final double ratingTextVerticalOffset;

  /// Horizontal space between rating number and semantic circle.
  final double ratingSignalGap;

  /// Optical vertical correction for the rating star.
  final double ratingIconVerticalOffset;

  /// Vertical space between expanded nodes.
  final double nodeGap;

  /// Resting rail width.
  final double railWidth;

  /// State-addition pulse width.
  final double pulseWidth;

  /// Travelling state-addition pulse length.
  final double pulseLength;

  /// Horizontal distance used by magnetic state attachment.
  final double attachmentTravel;

  /// Accessibility outline used only in high-contrast mode.
  final double highContrastOuterBorderWidth;

  /// Equal physical inset around the semantic circle.
  double get innerInset => (outerDiameter - innerDiameter) / 2;

  /// Distance from the centre of one expanded node to the next.
  double get nodeExtent => outerDiameter + nodeGap;

  double widthFor(_StatusDockEntry entry) {
    return entry.indicator == CinearaStatusDockIndicator.rating
        ? ratingWidth
        : outerDiameter;
  }

  double maximumWidthFor(List<_StatusDockEntry> entries) {
    double width = outerDiameter;

    for (final _StatusDockEntry entry in entries) {
      width = math.max(width, widthFor(entry)).toDouble();
    }

    return width;
  }

  double heightFor(int count) {
    if (count <= 0) {
      return 0;
    }

    return outerDiameter + ((count - 1) * nodeExtent);
  }

  factory _StatusDockMetrics.resolve({
    required BuildContext context,
    required CinearaStatusDockDensity density,
  }) {
    final TextScaler scaler = MediaQuery.textScalerOf(context);

    final double rawScale = scaler.scale(12) / 12;

    final double visualScale = (1 + ((rawScale - 1) * 0.18))
        .clamp(1.0, 1.12)
        .toDouble();

    final _StatusDockMetrics base = switch (density) {
      CinearaStatusDockDensity.compact => const _StatusDockMetrics(
        outerDiameter: 22,
        innerDiameter: 18,
        ratingWidth: 44,
        iconSize: 11.5,
        ratingFontSize: 9.5,
        ratingTextPadding: 5,
        ratingTextVerticalOffset: 0.5,
        ratingSignalGap: 1,
        ratingIconVerticalOffset: -0.6,
        nodeGap: 3,
        railWidth: 1,
        pulseWidth: 2,
        pulseLength: 10,
        attachmentTravel: 6,
        highContrastOuterBorderWidth: 0.65,
      ),

      CinearaStatusDockDensity.standard => const _StatusDockMetrics(
        outerDiameter: 26,
        innerDiameter: 22,
        ratingWidth: 51,
        iconSize: 13,
        ratingFontSize: 10.5,
        ratingTextPadding: 6,
        ratingTextVerticalOffset: 0.4,
        ratingSignalGap: 1.25,
        ratingIconVerticalOffset: -0.1,
        nodeGap: 4,
        railWidth: 1.25,
        pulseWidth: 2.25,
        pulseLength: 12,
        attachmentTravel: 7,
        highContrastOuterBorderWidth: 0.75,
      ),
    };

    return _StatusDockMetrics(
      outerDiameter: base.outerDiameter * visualScale,
      innerDiameter: base.innerDiameter * visualScale,
      ratingWidth: base.ratingWidth * visualScale,
      iconSize: base.iconSize * visualScale,
      ratingFontSize: base.ratingFontSize * visualScale,
      ratingTextPadding: base.ratingTextPadding * visualScale,
      ratingTextVerticalOffset: base.ratingTextVerticalOffset * visualScale,
      ratingSignalGap: base.ratingSignalGap * visualScale,
      ratingIconVerticalOffset: base.ratingIconVerticalOffset * visualScale,
      nodeGap: base.nodeGap * visualScale,
      railWidth: base.railWidth * visualScale,
      pulseWidth: base.pulseWidth * visualScale,
      pulseLength: base.pulseLength * visualScale,
      attachmentTravel: base.attachmentTravel * visualScale,
      highContrastOuterBorderWidth:
          base.highContrastOuterBorderWidth * visualScale,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _StatusDockMetrics &&
            other.outerDiameter == outerDiameter &&
            other.innerDiameter == innerDiameter &&
            other.ratingWidth == ratingWidth &&
            other.iconSize == iconSize &&
            other.ratingFontSize == ratingFontSize &&
            other.ratingTextPadding == ratingTextPadding &&
            other.ratingTextVerticalOffset == ratingTextVerticalOffset &&
            other.ratingSignalGap == ratingSignalGap &&
            other.ratingIconVerticalOffset == ratingIconVerticalOffset &&
            other.nodeGap == nodeGap &&
            other.railWidth == railWidth &&
            other.pulseWidth == pulseWidth &&
            other.pulseLength == pulseLength &&
            other.attachmentTravel == attachmentTravel &&
            other.highContrastOuterBorderWidth == highContrastOuterBorderWidth;
  }

  @override
  int get hashCode => Object.hash(
    outerDiameter,
    innerDiameter,
    ratingWidth,
    iconSize,
    ratingFontSize,
    ratingTextPadding,
    ratingTextVerticalOffset,
    ratingSignalGap,
    ratingIconVerticalOffset,
    nodeGap,
    railWidth,
    pulseWidth,
    pulseLength,
    attachmentTravel,
    highContrastOuterBorderWidth,
  );
}

// =============================================================================
// Node palette
// =============================================================================

@immutable
final class _StatusDockNodePalette {
  const _StatusDockNodePalette({
    required this.accent,
    required this.onAccent,
    required this.outerSurface,
    required this.outerOutline,
    required this.foreground,
  });

  final Color accent;

  final Color onAccent;

  final Color outerSurface;

  /// Used only when high-contrast mode requests an explicit outline.
  final Color outerOutline;

  final Color foreground;

  factory _StatusDockNodePalette.resolve({
    required BuildContext context,
    required CinearaStatusDockVariant variant,
    required Color accent,
    required bool highContrast,
  }) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final Color onAccent = CinearaColourUtils.foregroundFor(accent);

    return switch (variant) {
      CinearaStatusDockVariant.artwork => _StatusDockNodePalette(
        accent: accent,
        onAccent: onAccent,
        outerSurface: Color.alphaBlend(
          accent.withValues(alpha: highContrast ? 0.14 : 0.08),
          Colors.black.withValues(alpha: highContrast ? 0.95 : 0.82),
        ),
        outerOutline: accent.withValues(alpha: 0.78),
        foreground: Colors.white.withValues(alpha: highContrast ? 1 : 0.96),
      ),

      CinearaStatusDockVariant.surface => _StatusDockNodePalette(
        accent: accent,
        onAccent: onAccent,
        outerSurface: Color.alphaBlend(
          accent.withValues(alpha: highContrast ? 0.14 : 0.08),
          colors.surfaceContainerHigh,
        ),
        outerOutline: Color.alphaBlend(
          accent.withValues(alpha: 0.70),
          colors.outlineVariant,
        ),
        foreground: colors.onSurface,
      ),
    };
  }
}

// =============================================================================
// Rail palette
// =============================================================================

@immutable
final class _StatusDockRailPalette {
  const _StatusDockRailPalette({required this.rail});

  final Color rail;

  factory _StatusDockRailPalette.resolve({
    required BuildContext context,
    required CinearaStatusDockVariant variant,
    required bool highContrast,
  }) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return switch (variant) {
      CinearaStatusDockVariant.artwork => _StatusDockRailPalette(
        rail: Colors.white.withValues(alpha: highContrast ? 0.68 : 0.24),
      ),

      CinearaStatusDockVariant.surface => _StatusDockRailPalette(
        rail: colors.onSurfaceVariant.withValues(
          alpha: highContrast ? 0.68 : 0.30,
        ),
      ),
    };
  }
}

// =============================================================================
// Helpers
// =============================================================================

/// Returns the physical direction from the rail toward the interior of the
/// containing card.
double _physicalInwardSign({
  required CinearaStatusDockSide side,
  required TextDirection direction,
}) {
  final bool railOnPhysicalRight =
      (side == CinearaStatusDockSide.end && direction == TextDirection.ltr) ||
      (side == CinearaStatusDockSide.start && direction == TextDirection.rtl);

  return railOnPhysicalRight ? -1 : 1;
}

double _lerp(double start, double end, double progress) {
  return start + ((end - start) * progress);
}

/// Default final personal-rating formatter.
///
/// ```text
/// 8.0 -> 8
/// 8.5 -> 8.5
/// ```
String _formatRating(double value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }

  return value.toStringAsFixed(1);
}

/// Quantizes an in-flight numerical rating to one decimal place.
String _formatAnimatedRating(double value) {
  final double stepped = (value * 10).round() / 10;

  return _formatRating(stepped);
}

/// Converts one shared attachment controller into a small stagger for multiple
/// newly added nodes.
///
/// Existing nodes are never included, so they do not replay an entrance
/// animation when another indicator is added.
double _staggeredProgress(
  double progress, {
  required int index,
  required int count,
}) {
  if (count <= 1) {
    return progress.clamp(0.0, 1.0).toDouble();
  }

  final double start = (index * 0.10).clamp(0.0, 0.30).toDouble();

  final double end = math.min(1.0, start + 0.70).toDouble();

  if (progress <= start) {
    return 0;
  }

  if (progress >= end) {
    return 1;
  }

  return ((progress - start) / (end - start)).clamp(0.0, 1.0).toDouble();
}

/// Small mechanical compression/overshoot after non-anchor indicators return
/// into the compact anchor.
double _anchorSettleScale(double progress) {
  if (progress <= 0.32) {
    final double local = progress / 0.32;

    return _lerp(1, 0.94, Curves.easeOutCubic.transform(local));
  }

  if (progress <= 0.68) {
    final double local = (progress - 0.32) / 0.36;

    return _lerp(0.94, 1.035, Curves.easeOutCubic.transform(local));
  }

  final double local = (progress - 0.68) / 0.32;

  return _lerp(1.035, 1, Curves.easeOutCubic.transform(local));
}
