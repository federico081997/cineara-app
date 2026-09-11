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
  /// All currently active, enabled indicators remain fully visible.
  permanent,

  /// Shows one full-size anchor plus one smaller semantic satellite at rest.
  ///
  /// The same compact visual language is used on both axes.
  ///
  /// Horizontal/List mode keeps the satellite in the same perched position as
  /// the ordinary compact dock at rest: above and partially overlapping the
  /// anchor. On reveal it drops to the common bottom baseline, becomes a
  /// full-size second node, then the chain continues horizontally.
  compact,
}

/// Axis used to compose active personal-state indicators.
enum CinearaStatusDockLayout {
  /// Vertical chain designed primarily for poster overlays.
  vertical,

  /// Horizontal chain designed for list rows and other wide layouts.
  ///
  /// The anchor stays fixed at [CinearaStatusDock.side].
  ///
  /// In Compact mode, entry 1 rests above the anchor as the same real-state
  /// satellite used by the vertical presentation. It then drops onto the
  /// baseline and the full chain expands horizontally away from the anchor.
  /// With [CinearaStatusDockSide.start] this grows toward logical end (right in
  /// LTR), which is the intended Search/List configuration.
  horizontal,
}

/// Logical side to which the dock is visually anchored.
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

  final String dock;
  final String favorite;
  final String collection;
  final String watchlist;
  final String personalRating;
}

// =============================================================================
// Controller
// =============================================================================

/// Imperative presentation controller for [CinearaStatusDock].
///
/// Application state remains outside the design-system component.
///
/// [reveal] is presentation-only. Use it for explicit dock inspection and
/// Settings previews.
///
/// [revealChanges] reacts to actual media-state mutations after the parent has
/// rebuilt with the final state and is visible again.
final class CinearaStatusDockController {
  _CinearaStatusDockState? _state;

  bool get attached => _state != null;

  Future<void> reveal() async {
    await _state?._revealFromController();
  }

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
/// The dock represents Favorite, Collection, Watchlist, and personal Rating.
///
/// Active visible entries use one canonical bottom-to-top hierarchy:
///
/// ```text
/// Rating
/// → Watchlist
/// → Favorite
/// → Collection
/// ```
///
/// In compact rest:
///
/// - entry 0 is the full-size anchor;
/// - entry 1 is the smaller satellite;
/// - entry 2+ are hidden.
///
/// The compact satellite intentionally overlaps the anchor at rest. This is the
/// **only** intentional badge overlap in the component.
///
/// ## Motion invariant
///
/// Full-size nodes never pass through or overlap one another. Structural
/// mutations always create a vacant slot before another node enters it.
///
/// ## Compact reveal
///
/// The satellite separates into its full chain slot first. Hidden active nodes
/// then magnetically attach into their own already-vacant full-size slots.
///
/// Collapse is the reverse: hidden presentation nodes magnetically retract
/// first, then the satellite settles back onto the anchor.
///
/// ## Real additions
///
/// Every visible real addition uses the same choreography:
///
/// ```text
/// compact
/// → expand the hierarchy
/// → immediately begin the structural mutation
/// → reflow retained nodes to create the new vacant slot
/// → magnetically attach the new full-size node
/// → pulse
/// → hold
/// → collapse using the NEW hierarchy
/// ```
///
/// Permanent mode performs the same reflow + magnetic attachment but remains
/// expanded.
///
/// ## Real removals
///
/// Every structural removal is shown explicitly.
///
/// In Compact mode the OLD hierarchy expands first, even when the removed state
/// was the resting satellite or a normally hidden state:
///
/// ```text
/// compact hierarchy
/// → expand hierarchy
/// → immediately begin the structural mutation
/// → magnetically detach the removed full-size node
/// → leave a vacant slot
/// → reflow retained nodes
/// → short confirmation hold
/// → collapse using the NEW hierarchy
/// ```
///
/// This means the compact satellite never silently swaps to another state after
/// a real removal. Any new satellite appears only as the natural result of the
/// final collapse.
///
/// Permanent mode uses the same magnetic detach + vacancy + reflow language but
/// stays expanded.
///
/// The single-node case cannot reveal a longer chain, so the node simply
/// magnetically detaches from its existing full-size slot.
///
/// ## Rating changes
///
/// Existing numerical Rating changes animate only the number. `null → value`
/// and `value → null` are structural addition/removal transitions.
///
/// ## Search/List presentation
///
/// For Search list rows, prefer:
///
/// ```dart
/// CinearaStatusDock(
///   labels: labels,
///   favorite: favorite,
///   collection: collection,
///   watchlist: watchlist,
///   personalRating: personalRating,
///   mode: CinearaStatusDockMode.compact,
///   layout: CinearaStatusDockLayout.horizontal,
///   variant: CinearaStatusDockVariant.surface,
///   density: CinearaStatusDockDensity.compact,
///   side: CinearaStatusDockSide.start,
/// )
/// ```
///
/// Compact horizontal rest uses the same anchor + real-state satellite as the
/// vertical dock, rotated onto the inline axis. With `side: start`, the chain
/// expands toward logical end (left-to-right in LTR and right-to-left in RTL).
///
/// Permanent mode keeps the complete horizontal chain visible. Compact mode
/// reveals the complete chain on tap and may auto-collapse back to the
/// anchor + satellite presentation.
///
/// ## Settings previews
///
/// Settings are presentation changes rather than media-state mutations. Rebuild
/// the preview, wait for the end of frame, then call [CinearaStatusDockController.reveal].
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
    this.layout = CinearaStatusDockLayout.vertical,
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

  final CinearaStatusDockController? controller;
  final CinearaStatusDockLabels labels;

  final bool favorite;
  final bool collection;
  final bool watchlist;

  final double? personalRating;
  final String? personalRatingLabel;
  final double ratingMax;

  final Set<CinearaStatusDockIndicator> visibleIndicators;

  final CinearaStatusDockMode mode;
  final CinearaStatusDockVariant variant;
  final CinearaStatusDockDensity density;

  /// Composition axis.
  ///
  /// Keep [CinearaStatusDockLayout.vertical] for poster overlays.
  /// Use [CinearaStatusDockLayout.horizontal] for Search/List rows.
  final CinearaStatusDockLayout layout;

  final CinearaStatusDockSide side;

  final bool tapToExpand;
  final bool autoCollapse;
  final Duration autoCollapseDelay;
  final bool animate;

  final Color? favoriteAccent;
  final Color? collectionAccent;
  final Color? watchlistAccent;
  final Color? ratingAccent;

  final String? semanticLabel;
  final String? semanticValue;
  final bool excludeFromSemantics;

  @override
  State<CinearaStatusDock> createState() => _CinearaStatusDockState();
}

// =============================================================================
// State
// =============================================================================

final class _CinearaStatusDockState extends State<CinearaStatusDock>
    with TickerProviderStateMixin {
  static const Duration _inheritedOpenCollapseDelay = Duration(
    milliseconds: 700,
  );

  /// How long a completed removal remains visible before Compact collapses.
  ///
  /// Additions keep using [CinearaStatusDock.autoCollapseDelay], because their
  /// celebratory pulse benefits from a longer hold.
  static const Duration _removalConfirmationDelay = Duration(milliseconds: 850);

  late final AnimationController _expansionController;
  late final AnimationController _mutationController;
  late final AnimationController _pulseController;
  late final AnimationController _settleController;
  late final AnimationController _ratingController;

  bool _reduceMotion = false;

  double? _ratingAnimationFrom;
  double? _ratingAnimationTo;
  bool _ratingAnimationActive = false;

  List<_StatusDockEntry>? _pendingStructureBefore;
  List<_StatusDockEntry>? _pendingStructureAfter;

  _DockMutationTransition? _activeExpandedMutation;

  /// Keeps the pre-mutation hierarchy visible while Compact opens before the
  /// real structural mutation is animated.
  List<_StatusDockEntry>? _visualEntriesOverride;

  CinearaStatusDockIndicator? _pulseIndicator;

  int _sequenceGeneration = 0;

  @override
  void initState() {
    super.initState();

    assert(
      widget.autoCollapseDelay.inMicroseconds >= 0,
      'autoCollapseDelay must not be negative.',
    );

    _expansionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
      reverseDuration: const Duration(milliseconds: 360),
      value: widget.mode == CinearaStatusDockMode.permanent ? 1 : 0,
    );

    _mutationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
      value: 1,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
      value: 1,
    );

    _settleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
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

    if (!identical(oldWidget.controller, widget.controller)) {
      oldWidget.controller?._detach(this);
      widget.controller?._attach(this);
    }

    final bool presentationStructureChanged =
        oldWidget.mode != widget.mode ||
        oldWidget.density != widget.density ||
        oldWidget.layout != widget.layout ||
        oldWidget.side != widget.side ||
        !_sameIndicatorSet(
          oldWidget.visibleIndicators,
          widget.visibleIndicators,
        );

    if (presentationStructureChanged) {
      _discardPendingStructureChange();
    }

    if (!presentationStructureChanged &&
        _mediaStructureChanged(oldWidget, widget)) {
      _pendingStructureBefore ??= _entriesForWidget(oldWidget);
      _pendingStructureAfter = _entriesForWidget(widget);
    }

    if (oldWidget.mode != widget.mode || oldWidget.layout != widget.layout) {
      _cancelCurrentSequence();

      _expansionController.value =
          widget.mode == CinearaStatusDockMode.permanent ? 1 : 0;
    }

    if (!widget.animate && oldWidget.animate) {
      _finishDecorativeAnimationsImmediately();
    }

    if (oldWidget.personalRating != widget.personalRating) {
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
    _mutationController.dispose();
    _pulseController.dispose();
    _settleController.dispose();
    _ratingController.dispose();

    super.dispose();
  }

  bool get _animationsEnabled => widget.animate && !_reduceMotion;

  List<_StatusDockEntry> get _activeEntries => _entriesForWidget(widget);

  List<_StatusDockEntry> _entriesForWidget(CinearaStatusDock source) {
    final List<_StatusDockEntry> entries = <_StatusDockEntry>[];

    if (source.visibleIndicators.contains(CinearaStatusDockIndicator.rating) &&
        source.personalRating != null) {
      entries.add(
        _StatusDockEntry(
          indicator: CinearaStatusDockIndicator.rating,
          semanticLabel: source.labels.personalRating,
          accent: source.ratingAccent ?? CinearaStatusColours.rating,
          icon: Icons.star_rounded,
          value: _ratingTextForWidget(source),
        ),
      );
    }

    if (source.visibleIndicators.contains(
          CinearaStatusDockIndicator.watchlist,
        ) &&
        source.watchlist) {
      entries.add(
        _StatusDockEntry(
          indicator: CinearaStatusDockIndicator.watchlist,
          semanticLabel: source.labels.watchlist,
          accent: source.watchlistAccent ?? CinearaStatusColours.watchlist,
          icon: Icons.bookmark_rounded,
        ),
      );
    }

    if (source.visibleIndicators.contains(
          CinearaStatusDockIndicator.favorite,
        ) &&
        source.favorite) {
      entries.add(
        _StatusDockEntry(
          indicator: CinearaStatusDockIndicator.favorite,
          semanticLabel: source.labels.favorite,
          accent: source.favoriteAccent ?? CinearaStatusColours.favourite,
          icon: Icons.favorite_rounded,
        ),
      );
    }

    if (source.visibleIndicators.contains(
          CinearaStatusDockIndicator.collection,
        ) &&
        source.collection) {
      entries.add(
        _StatusDockEntry(
          indicator: CinearaStatusDockIndicator.collection,
          semanticLabel: source.labels.collection,
          accent: source.collectionAccent ?? CinearaStatusColours.collection,
          icon: Icons.layers_rounded,
        ),
      );
    }

    return entries;
  }

  String _ratingTextForWidget(CinearaStatusDock source) {
    final String? explicit = source.personalRatingLabel?.trim();

    if (explicit != null && explicit.isNotEmpty) {
      return explicit;
    }

    final double? rating = source.personalRating;

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

  bool get _hasNumericalRatingTransition {
    final double? from = _ratingAnimationFrom;
    final double? to = _ratingAnimationTo;

    return from != null && to != null && from != to;
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

  void _discardPendingStructureChange() {
    _pendingStructureBefore = null;
    _pendingStructureAfter = null;
  }

  _DockMutationTransition? _consumePendingMutation() {
    final List<_StatusDockEntry>? before = _pendingStructureBefore;
    final List<_StatusDockEntry>? after = _pendingStructureAfter;

    _discardPendingStructureChange();

    if (before == null || after == null) {
      return null;
    }

    final _DockMutationTransition transition = _DockMutationTransition(
      before: List<_StatusDockEntry>.unmodifiable(before),
      after: List<_StatusDockEntry>.unmodifiable(after),
    );

    return transition.hasStructuralChange ? transition : null;
  }

  Future<void> _revealFromController() async {
    _discardPendingStructureChange();

    if (widget.mode != CinearaStatusDockMode.compact) {
      return;
    }

    final List<_StatusDockEntry> entries = _activeEntries;

    if (entries.length <= 1) {
      return;
    }

    final int generation = _beginSequence(
      visualEntriesOverride: null,
      expandedMutation: null,
      pulseIndicator: null,
    );

    await _expand(generation);

    if (!_sequenceIsCurrent(generation)) {
      return;
    }

    if (widget.autoCollapse) {
      await _wait(widget.autoCollapseDelay, generation);

      if (!_sequenceIsCurrent(generation)) {
        return;
      }

      await _collapse(generation);
    }

    _clearSequencePresentation(generation);
  }

  Future<void> _revealChanges(
    Set<CinearaStatusDockIndicator> changedIndicators,
  ) async {
    final Set<CinearaStatusDockIndicator> relevantChanges = changedIndicators
        .where(widget.visibleIndicators.contains)
        .toSet();

    final _DockMutationTransition? transition = _consumePendingMutation();

    final bool numericalRatingChange =
        relevantChanges.contains(CinearaStatusDockIndicator.rating) &&
        _hasNumericalRatingTransition;

    if (transition == null &&
        relevantChanges.isEmpty &&
        !numericalRatingChange) {
      return;
    }

    await _runChangeSequence(
      transition: transition,
      numericalRatingChange: numericalRatingChange,
    );
  }

  Future<void> _collapseFromController() async {
    if (widget.mode != CinearaStatusDockMode.compact) {
      return;
    }

    final int generation = _beginSequence(
      visualEntriesOverride: null,
      expandedMutation: null,
      pulseIndicator: null,
    );

    await _collapse(generation);

    _clearSequencePresentation(generation);
  }

  void _handleCompactTap() {
    final List<_StatusDockEntry> entries = _activeEntries;

    if (widget.mode != CinearaStatusDockMode.compact ||
        !widget.tapToExpand ||
        entries.length <= 1) {
      return;
    }

    if (_expansionController.value > 0.55) {
      unawaited(_collapseFromController());
      return;
    }

    unawaited(_revealFromController());
  }

  Future<void> _runChangeSequence({
    required _DockMutationTransition? transition,
    required bool numericalRatingChange,
  }) async {
    final bool compact = widget.mode == CinearaStatusDockMode.compact;

    final double inheritedExpansion = _expansionController.value;

    final bool dockWasFullyExpanded = compact && inheritedExpansion >= 0.999;

    if (!_animationsEnabled) {
      _cancelCurrentSequence();
      _discardPendingStructureChange();

      _expansionController.value =
          widget.mode == CinearaStatusDockMode.permanent ? 1 : 0;

      return;
    }

    // -----------------------------------------------------------------------
    // Numerical-only Rating update
    // -----------------------------------------------------------------------

    if (transition == null) {
      final int generation = _beginSequence(
        visualEntriesOverride: null,
        expandedMutation: null,
        pulseIndicator: null,
      );

      if (numericalRatingChange) {
        _prepareRatingAnimation(generation);
        await _runRatingChange(generation);

        if (!_sequenceIsCurrent(generation)) {
          return;
        }
      }

      if (compact && dockWasFullyExpanded && widget.autoCollapse) {
        await _wait(_inheritedOpenCollapseDelay, generation);

        if (!_sequenceIsCurrent(generation)) {
          return;
        }

        await _collapse(generation);
      }

      _clearSequencePresentation(generation);
      return;
    }

    // -----------------------------------------------------------------------
    // Structural mutation
    //
    // Every real structural change uses one shared magnetic vocabulary:
    //
    // ADD:
    //   old chain → vacancy/reflow → full-size magnetic attach
    //
    // REMOVE:
    //   old chain → magnetic detach → vacancy → retained reflow
    //
    // Compact always shows the OLD hierarchy first. This includes removals of
    // the resting satellite and normally hidden states. There is deliberately
    // no direct compact satellite swap for a real mutation.
    //
    // Once the old hierarchy is fully expanded, removals detach immediately
    // at mutation t=0. Additions either begin retained-node reflow at t=0 or,
    // when no reflow is needed, begin magnetic attachment at t=0.
    // -----------------------------------------------------------------------

    final CinearaStatusDockIndicator? pulseIndicator =
        transition.addedIndicators.isNotEmpty
        ? _firstIndicatorInCanonicalOrder(transition.addedIndicators)
        : null;

    final int generation = _beginSequence(
      visualEntriesOverride: transition.before,
      expandedMutation: null,
      pulseIndicator: pulseIndicator,
    );

    if (compact && !dockWasFullyExpanded) {
      // With 0/1 old entries there is no chain to unfold. Move directly to
      // expanded geometry so the structural mutation can start immediately.
      if (transition.before.length <= 1) {
        _expansionController.value = 1;
      } else {
        await _expand(generation);

        if (!_sequenceIsCurrent(generation)) {
          return;
        }
      }
    }

    // There is deliberately no post-expansion delay and no end-of-frame
    // handoff. The mutation starts immediately after Compact expansion reaches
    // its completed state.
    _activateExpandedMutation(generation, transition);

    if (!_sequenceIsCurrent(generation)) {
      return;
    }

    final List<Future<void>> feedback = <Future<void>>[
      _runExpandedMutation(generation, transition),
    ];

    if (numericalRatingChange) {
      _prepareRatingAnimation(generation);
      feedback.add(_runRatingChange(generation));
    }

    await Future.wait(feedback);

    if (!_sequenceIsCurrent(generation)) {
      return;
    }

    _deactivateExpandedMutation(generation);

    if (!_sequenceIsCurrent(generation)) {
      return;
    }

    if (transition.addedIndicators.isNotEmpty && transition.after.length > 1) {
      await _runPulse(generation);

      if (!_sequenceIsCurrent(generation)) {
        return;
      }
    }

    if (compact && widget.autoCollapse) {
      // If the mutation leaves the dock empty there is nothing to collapse.
      if (transition.after.isNotEmpty) {
        final Duration hold = transition.addedIndicators.isNotEmpty
            ? widget.autoCollapseDelay
            : _removalConfirmationDelay;

        await _wait(hold, generation);

        if (!_sequenceIsCurrent(generation)) {
          return;
        }

        await _collapse(generation);

        if (!_sequenceIsCurrent(generation)) {
          return;
        }
      } else {
        _expansionController.value = 0;
      }
    }

    _clearSequencePresentation(generation);
  }

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

    try {
      await _settleController.forward(from: 0).orCancel;
    } on TickerCanceled {
      return;
    }
  }

  void _activateExpandedMutation(
    int generation,
    _DockMutationTransition transition,
  ) {
    if (!_sequenceIsCurrent(generation)) {
      return;
    }

    _mutationController
      ..stop()
      ..value = 0
      ..duration = transition.mutationDuration;

    if (mounted) {
      setState(() {
        _visualEntriesOverride = null;
        _activeExpandedMutation = transition;
      });
    }
  }

  void _deactivateExpandedMutation(int generation) {
    if (!_sequenceIsCurrent(generation) || !mounted) {
      return;
    }

    setState(() {
      _activeExpandedMutation = null;
      _visualEntriesOverride = null;
    });
  }

  Future<void> _runExpandedMutation(
    int generation,
    _DockMutationTransition transition,
  ) async {
    if (!_sequenceIsCurrent(generation)) {
      return;
    }

    if (!_animationsEnabled) {
      _mutationController.value = 1;
      return;
    }

    try {
      await _mutationController.forward().orCancel;
    } on TickerCanceled {
      return;
    }
  }

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

    if (from == null || to == null || from == to) {
      _finishRatingAnimation(generation);
      return;
    }

    if (!_animationsEnabled) {
      _finishRatingAnimation(generation);
      return;
    }

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

  int _beginSequence({
    required List<_StatusDockEntry>? visualEntriesOverride,
    required _DockMutationTransition? expandedMutation,
    required CinearaStatusDockIndicator? pulseIndicator,
  }) {
    _sequenceGeneration++;

    _expansionController.stop();
    _mutationController.stop();
    _pulseController.stop();
    _settleController.stop();
    _ratingController.stop();

    _mutationController.value = expandedMutation == null ? 1 : 0;
    _pulseController.value = 1;
    _settleController.value = 1;
    _ratingController.value = 1;

    _ratingAnimationActive = false;

    if (mounted) {
      setState(() {
        _visualEntriesOverride = visualEntriesOverride;
        _activeExpandedMutation = expandedMutation;
        _pulseIndicator = pulseIndicator;
      });
    }

    return _sequenceGeneration;
  }

  void _cancelCurrentSequence() {
    _sequenceGeneration++;

    _expansionController.stop();
    _mutationController.stop();
    _pulseController.stop();
    _settleController.stop();
    _ratingController.stop();

    _mutationController.value = 1;
    _pulseController.value = 1;
    _settleController.value = 1;
    _ratingController.value = 1;

    _activeExpandedMutation = null;
    _visualEntriesOverride = null;
    _pulseIndicator = null;
    _ratingAnimationActive = false;
  }

  void _clearSequencePresentation(int generation) {
    if (!_sequenceIsCurrent(generation) || !mounted) {
      return;
    }

    setState(() {
      _activeExpandedMutation = null;
      _visualEntriesOverride = null;
      _pulseIndicator = null;
      _ratingAnimationActive = false;
    });
  }

  bool _sequenceIsCurrent(int generation) {
    return mounted && generation == _sequenceGeneration;
  }

  Future<void> _wait(Duration duration, int generation) async {
    if (duration.inMicroseconds <= 0 || !_sequenceIsCurrent(generation)) {
      return;
    }

    await Future<void>.delayed(duration);
  }

  void _finishDecorativeAnimationsImmediately() {
    _mutationController
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

    _activeExpandedMutation = null;
    _visualEntriesOverride = null;
    _pulseIndicator = null;
    _ratingAnimationActive = false;

    _expansionController
      ..stop()
      ..value = widget.mode == CinearaStatusDockMode.permanent ? 1 : 0;
  }

  CinearaStatusDockIndicator? _firstIndicatorInCanonicalOrder(
    Set<CinearaStatusDockIndicator> indicators,
  ) {
    const List<CinearaStatusDockIndicator> priority =
        <CinearaStatusDockIndicator>[
          CinearaStatusDockIndicator.rating,
          CinearaStatusDockIndicator.watchlist,
          CinearaStatusDockIndicator.favorite,
          CinearaStatusDockIndicator.collection,
        ];

    for (final CinearaStatusDockIndicator indicator in priority) {
      if (indicators.contains(indicator)) {
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

  @override
  Widget build(BuildContext context) {
    final List<_StatusDockEntry> activeEntries = _activeEntries;

    final List<_StatusDockEntry>? pendingOverride =
        _pendingStructureBefore != null &&
            _activeExpandedMutation == null &&
            _visualEntriesOverride == null
        ? _pendingStructureBefore
        : null;

    final List<_StatusDockEntry> visualEntries =
        _visualEntriesOverride ?? pendingOverride ?? activeEntries;

    final bool hasVisualContent =
        visualEntries.isNotEmpty || _activeExpandedMutation != null;

    if (!hasVisualContent) {
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

    final Widget visual = _StatusDockVisual(
      visualEntries: visualEntries,
      mode: widget.mode,
      variant: widget.variant,
      layout: widget.layout,
      side: widget.side,
      metrics: metrics,
      highContrast: highContrast,
      railPalette: railPalette,
      expansionAnimation: _expansionController,
      mutationAnimation: _mutationController,
      pulseAnimation: _pulseController,
      settleAnimation: _settleController,
      pulseAccent: _pulseAccent(activeEntries),
      expandedMutation: _activeExpandedMutation,
      ratingAnimation: _ratingController,
      ratingAnimationActive: _ratingAnimationActive,
      ratingAnimationFrom: _ratingAnimationFrom,
      ratingAnimationTo: _ratingAnimationTo,
    );

    final bool canTapToReveal =
        widget.mode == CinearaStatusDockMode.compact &&
        widget.tapToExpand &&
        activeEntries.length > 1;

    final Widget interactionChild;

    if (canTapToReveal) {
      const double minimumTapTarget = 48;

      final List<_StatusDockEntry> targetEntries = visualEntries.isEmpty
          ? activeEntries
          : visualEntries;

      final double restingWidth =
          widget.layout == CinearaStatusDockLayout.horizontal
          ? metrics.horizontalCompactRestWidthFor(targetEntries)
          : metrics.maximumWidthFor(targetEntries);

      final double restingHeight =
          widget.layout == CinearaStatusDockLayout.horizontal
          ? metrics.horizontalCompactRestHeightFor(targetEntries.length)
          : metrics.compactRestHeightFor(targetEntries.length);

      final double minimumWidth = math
          .max(minimumTapTarget, restingWidth + 8)
          .toDouble();

      final double minimumHeight = math
          .max(minimumTapTarget, restingHeight + 8)
          .toDouble();

      final AlignmentGeometry alignment = switch ((
        widget.layout,
        widget.side,
      )) {
        (CinearaStatusDockLayout.horizontal, CinearaStatusDockSide.end) =>
          AlignmentDirectional.centerEnd,
        (CinearaStatusDockLayout.horizontal, CinearaStatusDockSide.start) =>
          AlignmentDirectional.centerStart,
        (CinearaStatusDockLayout.vertical, CinearaStatusDockSide.end) =>
          AlignmentDirectional.bottomEnd,
        (CinearaStatusDockLayout.vertical, CinearaStatusDockSide.start) =>
          AlignmentDirectional.bottomStart,
      };

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

    if (widget.excludeFromSemantics || activeEntries.isEmpty) {
      return semanticChild;
    }

    return Semantics(
      container: true,
      label: _resolvedSemanticLabel,
      value: _resolveSemanticValue(activeEntries),
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
    required this.visualEntries,
    required this.mode,
    required this.variant,
    required this.layout,
    required this.side,
    required this.metrics,
    required this.highContrast,
    required this.railPalette,
    required this.expansionAnimation,
    required this.mutationAnimation,
    required this.pulseAnimation,
    required this.settleAnimation,
    required this.pulseAccent,
    required this.expandedMutation,
    required this.ratingAnimation,
    required this.ratingAnimationActive,
    required this.ratingAnimationFrom,
    required this.ratingAnimationTo,
  });

  final List<_StatusDockEntry> visualEntries;

  final CinearaStatusDockMode mode;
  final CinearaStatusDockVariant variant;
  final CinearaStatusDockLayout layout;
  final CinearaStatusDockSide side;

  final _StatusDockMetrics metrics;
  final bool highContrast;
  final _StatusDockRailPalette railPalette;

  final Animation<double> expansionAnimation;
  final Animation<double> mutationAnimation;
  final Animation<double> pulseAnimation;
  final Animation<double> settleAnimation;

  final Color pulseAccent;

  final _DockMutationTransition? expandedMutation;

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
      animation: Listenable.merge(<Listenable>[
        resolvedExpansion,
        mutationAnimation,
        pulseAnimation,
        settleAnimation,
        ratingAnimation,
      ]),
      builder: (BuildContext context, Widget? child) {
        final double expansion = resolvedExpansion.value
            .clamp(0.0, 1.0)
            .toDouble();

        if (expandedMutation != null &&
            (mode == CinearaStatusDockMode.permanent || expansion >= 0.999)) {
          if (layout == CinearaStatusDockLayout.horizontal) {
            return _buildHorizontalExpandedMutation(
              context: context,
              transition: expandedMutation!,
              progress: mutationAnimation.value.clamp(0.0, 1.0).toDouble(),
            );
          }

          return _buildVerticalExpandedMutation(
            context: context,
            transition: expandedMutation!,
            progress: mutationAnimation.value.clamp(0.0, 1.0).toDouble(),
          );
        }

        if (layout == CinearaStatusDockLayout.horizontal) {
          return _buildHorizontalNormalDock(
            context: context,
            dockEntries: visualEntries,
            expansion: expansion,
          );
        }

        return _buildVerticalNormalDock(
          context: context,
          dockEntries: visualEntries,
          expansion: expansion,
        );
      },
    );
  }

  Widget _buildVerticalNormalDock({
    required BuildContext context,
    required List<_StatusDockEntry> dockEntries,
    required double expansion,
  }) {
    if (dockEntries.isEmpty) {
      return const SizedBox.shrink();
    }

    final double easedExpansion = Curves.easeInOutCubic.transform(expansion);

    final _StatusDockEntry anchor = dockEntries.first;

    final double collapsedWidth = metrics.widthFor(anchor);
    final double expandedWidth = metrics.maximumWidthFor(dockEntries);

    final double collapsedHeight = metrics.compactRestHeightFor(
      dockEntries.length,
    );
    final double expandedHeight = metrics.heightFor(dockEntries.length);

    final double currentWidth = mode == CinearaStatusDockMode.permanent
        ? expandedWidth
        : _lerp(collapsedWidth, expandedWidth, easedExpansion);

    final double currentHeight = mode == CinearaStatusDockMode.permanent
        ? expandedHeight
        : _lerp(collapsedHeight, expandedHeight, easedExpansion);

    final List<_RailNodeSnapshot> railNodes = <_RailNodeSnapshot>[
      _RailNodeSnapshot(
        bottom: 0,
        diameter: metrics.outerDiameter,
        presence: 1,
      ),
    ];

    final List<Widget> hiddenNodes = <Widget>[];

    // -----------------------------------------------------------------------
    // Satellite
    //
    // It is the only node permitted to overlap the anchor, and only around
    // Compact rest. Hidden nodes never emerge from the satellite position.
    // They always magnetically attach directly into their own vacant slots.
    // -----------------------------------------------------------------------

    _DockNodePose? satellitePose;
    double satelliteMagneticDx = 0;

    if (dockEntries.length > 1) {
      final double satelliteProgress = mode == CinearaStatusDockMode.permanent
          ? 1
          : Curves.easeInOutCubic.transform(
              _intervalProgress(expansion, start: 0.00, end: 0.30),
            );

      satellitePose = _lerpPose(
        _compactSatellitePose(metrics),
        _expandedSlotPose(metrics, 1),
        satelliteProgress,
      );

      // The compact satellite retains its compressed size until it has begun
      // physically separating, then grows into the ordinary full-size link.
      satellitePose = _DockNodePose(
        edgeOffset: satellitePose.edgeOffset,
        bottom: satellitePose.bottom,
        scale: _lerp(
          metrics.satelliteScale,
          1,
          Curves.easeOutCubic.transform(satelliteProgress),
        ),
      );

      final double satelliteRailPresence = _intervalProgress(
        satelliteProgress,
        start: 0.78,
        end: 1,
      );

      railNodes.add(
        _RailNodeSnapshot(
          bottom: satellitePose.bottom,
          diameter: metrics.outerDiameter * satellitePose.scale,
          presence: satelliteRailPresence,
        ),
      );
    }

    // -----------------------------------------------------------------------
    // Hidden presentation nodes
    //
    // Every hidden node occupies its final vertical slot from the first frame
    // in which it is rendered. It approaches only horizontally. Therefore it
    // can never pass through another badge during reveal/collapse.
    // -----------------------------------------------------------------------

    if (dockEntries.length > 2) {
      final int hiddenCount = dockEntries.length - 2;

      for (int index = dockEntries.length - 1; index >= 2; index--) {
        final int hiddenOrdinal = index - 2;

        final double attachProgress = mode == CinearaStatusDockMode.permanent
            ? 1
            : _presentationHiddenAttachProgress(
                expansion,
                ordinal: hiddenOrdinal,
                count: hiddenCount,
              );

        if (attachProgress <= 0.001) {
          continue;
        }

        final double easedAttach = Curves.easeOutCubic.transform(
          attachProgress,
        );

        final double magneticDx = _magneticDx(
          context: context,
          side: side,
          travel: metrics.attachmentTravel * (1 - easedAttach),
        );

        final _DockNodePose pose = _expandedSlotPose(metrics, index);

        railNodes.add(
          _RailNodeSnapshot(
            bottom: pose.bottom,
            diameter: metrics.outerDiameter,
            presence: _intervalProgress(attachProgress, start: 0.68, end: 1),
          ),
        );

        hiddenNodes.add(
          _positionNode(
            entry: dockEntries[index],
            pose: pose,
            physicalDx: magneticDx,
          ),
        );
      }
    }

    return SizedBox(
      width: currentWidth,
      height: currentHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned.fill(
            child: CustomPaint(
              painter: _PhysicalDockRailPainter(
                nodes: railNodes,
                side: side,
                metrics: metrics,
                railColor: railPalette.rail,
                pulseColor: pulseAccent,
                pulse: pulseAnimation,
              ),
            ),
          ),

          ...hiddenNodes,

          _positionNode(
            entry: anchor,
            pose: _DockNodePose.anchor(),
            isAnchor: true,
          ),

          if (satellitePose != null)
            _positionNode(
              entry: dockEntries[1],
              pose: satellitePose,
              physicalDx: satelliteMagneticDx,
            ),
        ],
      ),
    );
  }

  Widget _buildVerticalExpandedMutation({
    required BuildContext context,
    required _DockMutationTransition transition,
    required double progress,
  }) {
    final _MutationTiming timing = _MutationTiming.resolve(transition);

    final int maximumCount = math
        .max(transition.before.length, transition.after.length)
        .toInt();

    final double width = metrics.maximumWidthFor(<_StatusDockEntry>[
      ...transition.before,
      ...transition.after,
    ]);

    final double height = metrics.heightFor(maximumCount);

    final List<_RailNodeSnapshot> railNodes = <_RailNodeSnapshot>[];
    final List<Widget> renderedNodes = <Widget>[];

    final List<CinearaStatusDockIndicator> addedOrdered = transition.after
        .where(
          (_StatusDockEntry entry) =>
              transition.addedIndicators.contains(entry.indicator),
        )
        .map((_StatusDockEntry entry) => entry.indicator)
        .toList(growable: false);

    final List<CinearaStatusDockIndicator> removedOrdered = transition.before
        .where(
          (_StatusDockEntry entry) =>
              transition.removedIndicators.contains(entry.indicator),
        )
        .map((_StatusDockEntry entry) => entry.indicator)
        .toList(growable: false);

    // -----------------------------------------------------------------------
    // Removed nodes detach first.
    //
    // Retained nodes do not move until every removed node has vacated its slot.
    // -----------------------------------------------------------------------

    for (int oldIndex = 0; oldIndex < transition.before.length; oldIndex++) {
      final _StatusDockEntry oldEntry = transition.before[oldIndex];

      if (!transition.removedIndicators.contains(oldEntry.indicator)) {
        continue;
      }

      final int ordinal = removedOrdered.indexOf(oldEntry.indicator);

      final double detachProgress = timing.detachProgress(
        progress,
        ordinal: ordinal,
        count: removedOrdered.length,
      );

      if (detachProgress >= 0.999) {
        continue;
      }

      final double easedDetach = Curves.easeInCubic.transform(detachProgress);

      final _DockNodePose pose = _expandedSlotPose(metrics, oldIndex);

      renderedNodes.add(
        _positionNode(
          entry: oldEntry,
          pose: pose,
          physicalDx: _magneticDx(
            context: context,
            side: side,
            travel: metrics.attachmentTravel * easedDetach,
          ),
        ),
      );

      railNodes.add(
        _RailNodeSnapshot(
          bottom: pose.bottom,
          diameter: metrics.outerDiameter,
          presence: 1 - easedDetach,
        ),
      );
    }

    // -----------------------------------------------------------------------
    // Retained nodes reflow only after removals are clear.
    //
    // Since canonical ordering is preserved, linearly interpolating slot
    // positions cannot make neighboring retained nodes cross one another.
    // -----------------------------------------------------------------------

    final double reflowProgress = Curves.easeInOutCubic.transform(
      timing.reflowProgress(progress),
    );

    for (int oldIndex = 0; oldIndex < transition.before.length; oldIndex++) {
      final _StatusDockEntry oldEntry = transition.before[oldIndex];

      if (!transition.retainedIndicators.contains(oldEntry.indicator)) {
        continue;
      }

      final int newIndex = transition.after.indexWhere(
        (_StatusDockEntry entry) => entry.indicator == oldEntry.indicator,
      );

      if (newIndex < 0) {
        continue;
      }

      final _StatusDockEntry newEntry = transition.after[newIndex];

      final _DockNodePose pose = _lerpPose(
        _expandedSlotPose(metrics, oldIndex),
        _expandedSlotPose(metrics, newIndex),
        reflowProgress,
      );

      renderedNodes.add(
        _positionNode(
          entry: newEntry,
          pose: pose,
          isAnchor: newIndex == 0 && reflowProgress >= 0.999,
        ),
      );

      railNodes.add(
        _RailNodeSnapshot(
          bottom: pose.bottom,
          diameter: metrics.outerDiameter,
          presence: 1,
        ),
      );
    }

    // -----------------------------------------------------------------------
    // New nodes attach only after their final slots are vacant.
    //
    // They are full size from their first visible frame and travel only a few
    // logical pixels horizontally into the rail.
    // -----------------------------------------------------------------------

    for (int newIndex = 0; newIndex < transition.after.length; newIndex++) {
      final _StatusDockEntry newEntry = transition.after[newIndex];

      if (!transition.addedIndicators.contains(newEntry.indicator)) {
        continue;
      }

      final int ordinal = addedOrdered.indexOf(newEntry.indicator);

      final double attachProgress = timing.attachProgress(
        progress,
        ordinal: ordinal,
        count: addedOrdered.length,
      );

      if (attachProgress <= 0.001) {
        continue;
      }

      final double easedAttach = Curves.easeOutCubic.transform(attachProgress);

      final _DockNodePose pose = _expandedSlotPose(metrics, newIndex);

      renderedNodes.add(
        _positionNode(
          entry: newEntry,
          pose: pose,
          physicalDx: _magneticDx(
            context: context,
            side: side,
            travel: metrics.attachmentTravel * (1 - easedAttach),
          ),
          isAnchor: newIndex == 0 && attachProgress >= 0.999,
        ),
      );

      railNodes.add(
        _RailNodeSnapshot(
          bottom: pose.bottom,
          diameter: metrics.outerDiameter,
          presence: _intervalProgress(attachProgress, start: 0.68, end: 1),
        ),
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned.fill(
            child: CustomPaint(
              painter: _PhysicalDockRailPainter(
                nodes: railNodes,
                side: side,
                metrics: metrics,
                railColor: railPalette.rail,
                pulseColor: pulseAccent,
                pulse: const AlwaysStoppedAnimation<double>(1),
              ),
            ),
          ),
          ...renderedNodes,
        ],
      ),
    );
  }

  CinearaStatusDockSide get _horizontalNodeSignalSide {
    // `side` describes which logical edge the horizontal chain is anchored to.
    // Node internals face the opposite way so the semantic signal (the star on
    // the Rating pill) sits on the expansion edge.
    //
    // side=start  -> chain grows toward end  -> Rating is [9.2 ★]
    // side=end    -> chain grows toward start -> Rating is [★ 9.2]
    return side == CinearaStatusDockSide.start
        ? CinearaStatusDockSide.end
        : CinearaStatusDockSide.start;
  }

  // =========================================================================
  // Horizontal list presentation
  // =========================================================================

  /// List-oriented presentation.
  ///
  /// Compact rest deliberately uses the same perched satellite silhouette as
  /// the vertical dock. For a Rating anchor, the star stays on the expansion
  /// edge and the real second-state satellite perches over that star:
  ///
  /// ```text
  ///          ◉
  /// [ 9.2 ★ ]
  /// ```
  ///
  /// The satellite is the real second active state. It is not a count.
  ///
  /// With [CinearaStatusDockSide.start], reveal proceeds down and then toward
  /// logical end — right in LTR. The Rating node therefore places its star on
  /// its logical end, so the chain visually grows *from the star*:
  ///
  /// ```text
  ///          ◉
  /// [ 9.2 ★ ]
  ///       ↓
  /// [ 9.2 ★ ]─[bookmark]
  ///       ↓
  /// [ 9.2 ★ ]─[bookmark]─[favorite]─[collection]
  /// ```
  ///
  /// The satellite first drops to the bottom baseline while growing to its
  /// ordinary full size and moving into canonical horizontal slot 1. Entry 2+
  /// then descend directly into their own already-vacant slots to the right.
  ///
  /// Permanent mode skips the compact satellite and stays as the complete
  /// horizontal chain. Vertical behavior is intentionally untouched.
  Widget _buildHorizontalNormalDock({
    required BuildContext context,
    required List<_StatusDockEntry> dockEntries,
    required double expansion,
  }) {
    if (dockEntries.isEmpty) {
      return const SizedBox.shrink();
    }

    final _StatusDockEntry anchor = dockEntries.first;
    final double easedExpansion = Curves.easeInOutCubic.transform(expansion);

    final double collapsedWidth = metrics.horizontalCompactRestWidthFor(
      dockEntries,
    );
    final double expandedWidth = metrics.horizontalWidthFor(dockEntries);

    final double currentWidth = mode == CinearaStatusDockMode.permanent
        ? expandedWidth
        : _lerp(collapsedWidth, expandedWidth, easedExpansion);

    // Keep a stable vertical box for Compact throughout reveal/collapse so the
    // anchor stays fixed on the bottom baseline while the satellite descends.
    final double currentHeight = mode == CinearaStatusDockMode.permanent
        ? metrics.outerDiameter
        : metrics.horizontalCompactRestHeightFor(dockEntries.length);

    final List<_HorizontalRailNodeSnapshot> railNodes =
        <_HorizontalRailNodeSnapshot>[
          _HorizontalRailNodeSnapshot(
            edgeOffset: 0,
            width: metrics.widthFor(anchor),
            presence: 1,
          ),
        ];

    final List<Widget> hiddenNodes = <Widget>[];

    // -----------------------------------------------------------------------
    // Perched satellite
    //
    // At rest it occupies the same upper-corner position as the compact
    // vertical dock. During reveal it moves down to bottom = 0 and outward
    // toward horizontal slot 1.
    // -----------------------------------------------------------------------

    _DockNodePose? satellitePose;

    if (dockEntries.length > 1) {
      final double satelliteProgress = mode == CinearaStatusDockMode.permanent
          ? 1
          : Curves.easeInOutCubic.transform(
              _intervalProgress(expansion, start: 0.00, end: 0.34),
            );

      satellitePose = _lerpPose(
        _horizontalPerchedSatellitePose(metrics, anchor),
        _horizontalSlotPose(metrics, dockEntries, 1),
        satelliteProgress,
      );

      satellitePose = _DockNodePose(
        edgeOffset: satellitePose.edgeOffset,
        bottom: satellitePose.bottom,
        scale: _lerp(
          metrics.satelliteScale,
          1,
          Curves.easeOutCubic.transform(satelliteProgress),
        ),
      );

      final double scaledDiameter = metrics.outerDiameter * satellitePose.scale;
      final double scaledInset = (metrics.outerDiameter - scaledDiameter) / 2;

      // The connector should not appear while the satellite is visibly perched.
      // It establishes only as the node finishes landing on the baseline.
      railNodes.add(
        _HorizontalRailNodeSnapshot(
          edgeOffset: satellitePose.edgeOffset + scaledInset,
          width: scaledDiameter,
          presence: _intervalProgress(satelliteProgress, start: 0.84, end: 1),
        ),
      );
    }

    // -----------------------------------------------------------------------
    // Hidden nodes
    //
    // Entry 2+ wait until the satellite has nearly landed, then descend from
    // above into their final horizontal slots. In LTR + side=start this builds
    // the chain from the rating/star anchor toward the right.
    // -----------------------------------------------------------------------

    if (dockEntries.length > 2) {
      final int hiddenCount = dockEntries.length - 2;

      for (int index = dockEntries.length - 1; index >= 2; index--) {
        final int hiddenOrdinal = index - 2;

        final double attachProgress = mode == CinearaStatusDockMode.permanent
            ? 1
            : _horizontalHiddenAttachProgress(
                expansion,
                ordinal: hiddenOrdinal,
                count: hiddenCount,
              );

        if (attachProgress <= 0.001) {
          continue;
        }

        final double easedAttach = Curves.easeOutCubic.transform(
          attachProgress,
        );

        final _DockNodePose pose = _horizontalSlotPose(
          metrics,
          dockEntries,
          index,
        );

        railNodes.add(
          _HorizontalRailNodeSnapshot(
            edgeOffset: pose.edgeOffset,
            width: metrics.widthFor(dockEntries[index]),
            presence: _intervalProgress(attachProgress, start: 0.72, end: 1),
          ),
        );

        hiddenNodes.add(
          _positionNode(
            entry: dockEntries[index],
            pose: pose,

            // Negative Y starts above the baseline; returning to 0 makes the
            // node travel downward into the row.
            physicalDy: -metrics.horizontalAttachmentLift * (1 - easedAttach),
            opacity: easedAttach,

            nodeSide: _horizontalNodeSignalSide,
          ),
        );
      }
    }

    return SizedBox(
      width: currentWidth,
      height: currentHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned.fill(
            child: CustomPaint(
              painter: _HorizontalPhysicalDockRailPainter(
                nodes: railNodes,
                side: side,
                direction: Directionality.of(context),
                metrics: metrics,
                railColor: railPalette.rail,
                pulseColor: pulseAccent,
                pulse: pulseAnimation,
              ),
            ),
          ),

          ...hiddenNodes,

          _positionNode(
            entry: anchor,
            pose: _horizontalSlotPose(metrics, dockEntries, 0),
            isAnchor: true,

            nodeSide: _horizontalNodeSignalSide,
          ),

          if (satellitePose != null)
            _positionNode(
              entry: dockEntries[1],
              pose: satellitePose,

              nodeSide: _horizontalNodeSignalSide,
            ),
        ],
      ),
    );
  }

  /// Horizontal structural-mutation choreography.
  ///
  /// This preserves the same invariant as the vertical chain:
  ///
  /// - removals detach before retained nodes reflow;
  /// - retained nodes never cross one another;
  /// - additions enter only after their final slot is vacant;
  /// - Compact expands the old hierarchy first and collapses using the new one.
  ///
  /// Movement that introduces/removes a node is perpendicular to the chain so
  /// full-size badges never slide through neighboring badges.
  Widget _buildHorizontalExpandedMutation({
    required BuildContext context,
    required _DockMutationTransition transition,
    required double progress,
  }) {
    final _MutationTiming timing = _MutationTiming.resolve(transition);

    final List<_StatusDockEntry> widthEntries =
        metrics.horizontalWidthFor(transition.before) >=
            metrics.horizontalWidthFor(transition.after)
        ? transition.before
        : transition.after;

    final double width = metrics.horizontalWidthFor(widthEntries);

    final List<_HorizontalRailNodeSnapshot> railNodes =
        <_HorizontalRailNodeSnapshot>[];
    final List<Widget> renderedNodes = <Widget>[];

    final List<CinearaStatusDockIndicator> addedOrdered = transition.after
        .where(
          (_StatusDockEntry entry) =>
              transition.addedIndicators.contains(entry.indicator),
        )
        .map((_StatusDockEntry entry) => entry.indicator)
        .toList(growable: false);

    final List<CinearaStatusDockIndicator> removedOrdered = transition.before
        .where(
          (_StatusDockEntry entry) =>
              transition.removedIndicators.contains(entry.indicator),
        )
        .map((_StatusDockEntry entry) => entry.indicator)
        .toList(growable: false);

    // Removed nodes leave perpendicular to the horizontal chain first.
    for (int oldIndex = 0; oldIndex < transition.before.length; oldIndex++) {
      final _StatusDockEntry oldEntry = transition.before[oldIndex];

      if (!transition.removedIndicators.contains(oldEntry.indicator)) {
        continue;
      }

      final int ordinal = removedOrdered.indexOf(oldEntry.indicator);

      final double detachProgress = timing.detachProgress(
        progress,
        ordinal: ordinal,
        count: removedOrdered.length,
      );

      if (detachProgress >= 0.999) {
        continue;
      }

      final double easedDetach = Curves.easeInCubic.transform(detachProgress);

      final _DockNodePose pose = _horizontalSlotPose(
        metrics,
        transition.before,
        oldIndex,
      );

      renderedNodes.add(
        _positionNode(
          entry: oldEntry,
          pose: pose,
          physicalDy: -metrics.horizontalAttachmentLift * easedDetach,
          opacity: 1 - easedDetach,

          nodeSide: _horizontalNodeSignalSide,
        ),
      );

      railNodes.add(
        _HorizontalRailNodeSnapshot(
          edgeOffset: pose.edgeOffset,
          width: metrics.widthFor(oldEntry),
          presence: 1 - easedDetach,
        ),
      );
    }

    // Retained nodes reflow horizontally only after removed slots are clear.
    final double reflowProgress = Curves.easeInOutCubic.transform(
      timing.reflowProgress(progress),
    );

    for (int oldIndex = 0; oldIndex < transition.before.length; oldIndex++) {
      final _StatusDockEntry oldEntry = transition.before[oldIndex];

      if (!transition.retainedIndicators.contains(oldEntry.indicator)) {
        continue;
      }

      final int newIndex = transition.after.indexWhere(
        (_StatusDockEntry entry) => entry.indicator == oldEntry.indicator,
      );

      if (newIndex < 0) {
        continue;
      }

      final _StatusDockEntry newEntry = transition.after[newIndex];

      final _DockNodePose pose = _lerpPose(
        _horizontalSlotPose(metrics, transition.before, oldIndex),
        _horizontalSlotPose(metrics, transition.after, newIndex),
        reflowProgress,
      );

      renderedNodes.add(
        _positionNode(
          entry: newEntry,
          pose: pose,
          isAnchor: newIndex == 0 && reflowProgress >= 0.999,

          nodeSide: _horizontalNodeSignalSide,
        ),
      );

      railNodes.add(
        _HorizontalRailNodeSnapshot(
          edgeOffset: pose.edgeOffset,
          width: metrics.widthFor(newEntry),
          presence: 1,
        ),
      );
    }

    // New nodes settle into their already-vacant final slots.
    for (int newIndex = 0; newIndex < transition.after.length; newIndex++) {
      final _StatusDockEntry newEntry = transition.after[newIndex];

      if (!transition.addedIndicators.contains(newEntry.indicator)) {
        continue;
      }

      final int ordinal = addedOrdered.indexOf(newEntry.indicator);

      final double attachProgress = timing.attachProgress(
        progress,
        ordinal: ordinal,
        count: addedOrdered.length,
      );

      if (attachProgress <= 0.001) {
        continue;
      }

      final double easedAttach = Curves.easeOutCubic.transform(attachProgress);

      final _DockNodePose pose = _horizontalSlotPose(
        metrics,
        transition.after,
        newIndex,
      );

      renderedNodes.add(
        _positionNode(
          entry: newEntry,
          pose: pose,
          physicalDy: -metrics.horizontalAttachmentLift * (1 - easedAttach),
          opacity: easedAttach,
          isAnchor: newIndex == 0 && attachProgress >= 0.999,

          nodeSide: _horizontalNodeSignalSide,
        ),
      );

      railNodes.add(
        _HorizontalRailNodeSnapshot(
          edgeOffset: pose.edgeOffset,
          width: metrics.widthFor(newEntry),
          presence: _intervalProgress(attachProgress, start: 0.68, end: 1),
        ),
      );
    }

    final int maximumCount = math
        .max(transition.before.length, transition.after.length)
        .toInt();

    final double mutationHeight = mode == CinearaStatusDockMode.compact
        ? metrics.horizontalCompactRestHeightFor(maximumCount)
        : metrics.outerDiameter;

    return SizedBox(
      width: width,
      height: mutationHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned.fill(
            child: CustomPaint(
              painter: _HorizontalPhysicalDockRailPainter(
                nodes: railNodes,
                side: side,
                direction: Directionality.of(context),
                metrics: metrics,
                railColor: railPalette.rail,
                pulseColor: pulseAccent,
                pulse: const AlwaysStoppedAnimation<double>(1),
              ),
            ),
          ),
          ...renderedNodes,
        ],
      ),
    );
  }

  Widget _positionNode({
    required _StatusDockEntry entry,
    required _DockNodePose pose,
    double physicalDx = 0,
    double physicalDy = 0,
    double opacity = 1,
    bool isAnchor = false,
    CinearaStatusDockSide? nodeSide,
  }) {
    Widget child = _StatusDockNode(
      entry: entry,
      variant: variant,
      side: nodeSide ?? side,
      metrics: metrics,
      highContrast: highContrast,
      ratingAnimation: ratingAnimation,
      ratingAnimationActive: ratingAnimationActive,
      ratingAnimationFrom: ratingAnimationFrom,
      ratingAnimationTo: ratingAnimationTo,
    );

    if (isAnchor) {
      child = _StatusDockAnchorSettle(animation: settleAnimation, child: child);
    }

    if (pose.scale != 1) {
      child = Transform.scale(scale: pose.scale, child: child);
    }

    if (physicalDx != 0 || physicalDy != 0) {
      child = Transform.translate(
        offset: Offset(physicalDx, physicalDy),
        child: child,
      );
    }

    if (opacity < 0.999) {
      child = Opacity(
        opacity: opacity.clamp(0.0, 1.0).toDouble(),
        child: child,
      );
    }

    if (side == CinearaStatusDockSide.end) {
      return PositionedDirectional(
        end: pose.edgeOffset,
        bottom: pose.bottom,
        child: child,
      );
    }

    return PositionedDirectional(
      start: pose.edgeOffset,
      bottom: pose.bottom,
      child: child,
    );
  }
}

// =============================================================================
// Dynamic node
// =============================================================================

final class _StatusDockNode extends StatelessWidget {
  const _StatusDockNode({
    required this.entry,
    required this.variant,
    required this.side,
    required this.metrics,
    required this.highContrast,
    required this.ratingAnimation,
    required this.ratingAnimationActive,
    required this.ratingAnimationFrom,
    required this.ratingAnimationTo,
  });

  final _StatusDockEntry entry;
  final CinearaStatusDockVariant variant;
  final CinearaStatusDockSide side;
  final _StatusDockMetrics metrics;
  final bool highContrast;

  final Animation<double> ratingAnimation;
  final bool ratingAnimationActive;
  final double? ratingAnimationFrom;
  final double? ratingAnimationTo;

  @override
  Widget build(BuildContext context) {
    if (entry.indicator == CinearaStatusDockIndicator.rating) {
      return _StatusDockRatingNode(
        entry: entry,
        variant: variant,
        side: side,
        metrics: metrics,
        highContrast: highContrast,
        animation: ratingAnimation,
        animationActive: ratingAnimationActive,
        animationFrom: ratingAnimationFrom,
        animationTo: ratingAnimationTo,
      );
    }

    return _StatusDockBinaryNode(
      entry: entry,
      variant: variant,
      metrics: metrics,
      highContrast: highContrast,
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

        return Transform.scale(
          scale: _anchorSettleScale(progress),
          child: child,
        );
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

    return _formatAnimatedRating(_lerp(from, to, progress));
  }
}

// =============================================================================
// Physical rail
// =============================================================================

@immutable
final class _RailNodeSnapshot {
  const _RailNodeSnapshot({
    required this.bottom,
    required this.diameter,
    required this.presence,
  });

  final double bottom;
  final double diameter;
  final double presence;
}

/// Draws only physically valid shell-to-shell rail segments.
///
/// A segment is never drawn across an empty structural slot. This prevents an
/// orphan line from appearing before a newly added badge reaches the chain.
final class _PhysicalDockRailPainter extends CustomPainter {
  _PhysicalDockRailPainter({
    required this.nodes,
    required this.side,
    required this.metrics,
    required this.railColor,
    required this.pulseColor,
    required this.pulse,
  }) : super(repaint: pulse);

  final List<_RailNodeSnapshot> nodes;
  final CinearaStatusDockSide side;
  final _StatusDockMetrics metrics;

  final Color railColor;
  final Color pulseColor;
  final Animation<double> pulse;

  @override
  void paint(Canvas canvas, Size size) {
    if (nodes.length <= 1) {
      return;
    }

    final List<_RailNodeSnapshot> ordered = <_RailNodeSnapshot>[...nodes]
      ..sort(
        (_RailNodeSnapshot a, _RailNodeSnapshot b) =>
            a.bottom.compareTo(b.bottom),
      );

    final double railX = side == CinearaStatusDockSide.end
        ? size.width - metrics.outerDiameter / 2
        : metrics.outerDiameter / 2;

    final Paint railPaint = Paint()
      ..color = railColor
      ..strokeWidth = metrics.railWidth
      ..strokeCap = StrokeCap.round;

    for (int index = 0; index < ordered.length - 1; index++) {
      final _RailNodeSnapshot lower = ordered[index];
      final _RailNodeSnapshot upper = ordered[index + 1];

      final double presence = math
          .min(lower.presence, upper.presence)
          .clamp(0.0, 1.0)
          .toDouble();

      if (presence <= 0.001) {
        continue;
      }

      final double lowerCenterY =
          size.height - lower.bottom - metrics.outerDiameter / 2;
      final double upperCenterY =
          size.height - upper.bottom - metrics.outerDiameter / 2;

      final double centerDistance = lowerCenterY - upperCenterY;

      // Never bridge a deliberately vacant chain slot.
      if (centerDistance > metrics.nodeExtent * 1.45) {
        continue;
      }

      final double startY = lowerCenterY - lower.diameter / 2;
      final double targetEndY = upperCenterY + upper.diameter / 2;

      if (startY <= targetEndY) {
        continue;
      }

      final double endY = _lerp(
        startY,
        targetEndY,
        Curves.easeOutCubic.transform(presence),
      );

      canvas.drawLine(Offset(railX, startY), Offset(railX, endY), railPaint);
    }

    final double pulseProgress = pulse.value.clamp(0.0, 1.0).toDouble();
    final double pulseOpacity = math.sin(math.pi * pulseProgress);

    if (pulseOpacity <= 0.001) {
      return;
    }

    final List<_RailNodeSnapshot> established = ordered
        .where((_RailNodeSnapshot node) => node.presence >= 0.98)
        .toList(growable: false);

    if (established.length <= 1) {
      return;
    }

    final _RailNodeSnapshot lowest = established.first;
    final _RailNodeSnapshot highest = established.last;

    final double lowestCenterY =
        size.height - lowest.bottom - metrics.outerDiameter / 2;
    final double highestCenterY =
        size.height - highest.bottom - metrics.outerDiameter / 2;

    final double startY = lowestCenterY - lowest.diameter / 2;
    final double endY = highestCenterY + highest.diameter / 2;

    if (startY <= endY) {
      return;
    }

    final double pulseCenterY = _lerp(startY, endY, pulseProgress);

    final double halfLength = metrics.pulseLength / 2;

    final Paint pulsePaint = Paint()
      ..color = pulseColor.withValues(
        alpha: pulseOpacity.clamp(0.0, 1.0).toDouble(),
      )
      ..strokeWidth = metrics.pulseWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(railX, math.min(startY, pulseCenterY + halfLength)),
      Offset(railX, math.max(endY, pulseCenterY - halfLength)),
      pulsePaint,
    );
  }

  @override
  bool shouldRepaint(_PhysicalDockRailPainter oldDelegate) {
    return oldDelegate.nodes != nodes ||
        oldDelegate.side != side ||
        oldDelegate.metrics != metrics ||
        oldDelegate.railColor != railColor ||
        oldDelegate.pulseColor != pulseColor ||
        oldDelegate.pulse != pulse;
  }
}

// =============================================================================
// Horizontal physical rail
// =============================================================================

@immutable
final class _HorizontalRailNodeSnapshot {
  const _HorizontalRailNodeSnapshot({
    required this.edgeOffset,
    required this.width,
    required this.presence,
  });

  /// Logical distance from the dock's anchored side.
  final double edgeOffset;

  /// Visible shell width. Rating nodes are wider than circular nodes and the
  /// Compact satellite uses its scaled visible diameter here.
  final double width;

  final double presence;
}

/// Inline-axis counterpart of [_PhysicalDockRailPainter].
///
/// It draws only shell-to-shell segments between physically adjacent visible
/// nodes. The rail therefore never bridges an intentionally vacant slot during
/// a structural mutation.
final class _HorizontalPhysicalDockRailPainter extends CustomPainter {
  _HorizontalPhysicalDockRailPainter({
    required this.nodes,
    required this.side,
    required this.direction,
    required this.metrics,
    required this.railColor,
    required this.pulseColor,
    required this.pulse,
  }) : super(repaint: pulse);

  final List<_HorizontalRailNodeSnapshot> nodes;
  final CinearaStatusDockSide side;
  final TextDirection direction;
  final _StatusDockMetrics metrics;

  final Color railColor;
  final Color pulseColor;
  final Animation<double> pulse;

  bool get _anchoredOnPhysicalLeft {
    return (side == CinearaStatusDockSide.start &&
            direction == TextDirection.ltr) ||
        (side == CinearaStatusDockSide.end && direction == TextDirection.rtl);
  }

  double _physicalLeft(_HorizontalRailNodeSnapshot node, double totalWidth) {
    if (_anchoredOnPhysicalLeft) {
      return node.edgeOffset;
    }

    return totalWidth - node.edgeOffset - node.width;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (nodes.length <= 1) {
      return;
    }

    final List<_HorizontalRailNodeSnapshot> ordered =
        <_HorizontalRailNodeSnapshot>[...nodes]..sort(
          (_HorizontalRailNodeSnapshot a, _HorizontalRailNodeSnapshot b) =>
              a.edgeOffset.compareTo(b.edgeOffset),
        );

    final double railY = size.height - (metrics.outerDiameter / 2);

    final Paint railPaint = Paint()
      ..color = railColor
      ..strokeWidth = metrics.railWidth
      ..strokeCap = StrokeCap.round;

    for (int index = 0; index < ordered.length - 1; index++) {
      final _HorizontalRailNodeSnapshot near = ordered[index];
      final _HorizontalRailNodeSnapshot far = ordered[index + 1];

      final double presence = math
          .min(near.presence, far.presence)
          .clamp(0.0, 1.0)
          .toDouble();

      if (presence <= 0.001) {
        continue;
      }

      final double nearLeft = _physicalLeft(near, size.width);
      final double farLeft = _physicalLeft(far, size.width);

      final double startX = _anchoredOnPhysicalLeft
          ? nearLeft + near.width
          : nearLeft;

      final double targetEndX = _anchoredOnPhysicalLeft
          ? farLeft
          : farLeft + far.width;

      final double shellGap = (targetEndX - startX).abs();

      // Do not bridge a vacant canonical slot during reflow/mutation.
      if (shellGap > math.max(8, metrics.horizontalNodeGap * 1.8)) {
        continue;
      }

      if (shellGap <= 0.001) {
        continue;
      }

      final double endX = _lerp(
        startX,
        targetEndX,
        Curves.easeOutCubic.transform(presence),
      );

      canvas.drawLine(Offset(startX, railY), Offset(endX, railY), railPaint);
    }

    final double pulseProgress = pulse.value.clamp(0.0, 1.0).toDouble();
    final double pulseOpacity = math.sin(math.pi * pulseProgress);

    if (pulseOpacity <= 0.001) {
      return;
    }

    final List<_HorizontalRailNodeSnapshot> established = ordered
        .where((_HorizontalRailNodeSnapshot node) => node.presence >= 0.98)
        .toList(growable: false);

    if (established.length <= 1) {
      return;
    }

    final _HorizontalRailNodeSnapshot first = established.first;
    final _HorizontalRailNodeSnapshot last = established.last;

    final double firstLeft = _physicalLeft(first, size.width);
    final double lastLeft = _physicalLeft(last, size.width);

    final double chainStartX = _anchoredOnPhysicalLeft
        ? firstLeft + first.width
        : firstLeft;

    final double chainEndX = _anchoredOnPhysicalLeft
        ? lastLeft
        : lastLeft + last.width;

    if ((chainEndX - chainStartX).abs() <= 0.001) {
      return;
    }

    final double normalizedHalfLength =
        (metrics.pulseLength / (chainEndX - chainStartX).abs()) / 2;

    final double startT = (pulseProgress - normalizedHalfLength)
        .clamp(0.0, 1.0)
        .toDouble();
    final double endT = (pulseProgress + normalizedHalfLength)
        .clamp(0.0, 1.0)
        .toDouble();

    final Paint pulsePaint = Paint()
      ..color = pulseColor.withValues(
        alpha: pulseOpacity.clamp(0.0, 1.0).toDouble(),
      )
      ..strokeWidth = metrics.pulseWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(_lerp(chainStartX, chainEndX, startT), railY),
      Offset(_lerp(chainStartX, chainEndX, endT), railY),
      pulsePaint,
    );
  }

  @override
  bool shouldRepaint(_HorizontalPhysicalDockRailPainter oldDelegate) {
    return oldDelegate.nodes != nodes ||
        oldDelegate.side != side ||
        oldDelegate.direction != direction ||
        oldDelegate.metrics != metrics ||
        oldDelegate.railColor != railColor ||
        oldDelegate.pulseColor != pulseColor ||
        oldDelegate.pulse != pulse;
  }
}

// =============================================================================
// Mutation model
// =============================================================================

@immutable
final class _DockMutationTransition {
  const _DockMutationTransition({required this.before, required this.after});

  final List<_StatusDockEntry> before;
  final List<_StatusDockEntry> after;

  Set<CinearaStatusDockIndicator> get beforeIndicators =>
      before.map((_StatusDockEntry entry) => entry.indicator).toSet();

  Set<CinearaStatusDockIndicator> get afterIndicators =>
      after.map((_StatusDockEntry entry) => entry.indicator).toSet();

  Set<CinearaStatusDockIndicator> get addedIndicators =>
      afterIndicators.difference(beforeIndicators);

  Set<CinearaStatusDockIndicator> get removedIndicators =>
      beforeIndicators.difference(afterIndicators);

  Set<CinearaStatusDockIndicator> get retainedIndicators =>
      beforeIndicators.intersection(afterIndicators);

  bool get hasStructuralChange =>
      addedIndicators.isNotEmpty || removedIndicators.isNotEmpty;

  bool get requiresRetainedReflow {
    for (final CinearaStatusDockIndicator indicator in retainedIndicators) {
      final int oldIndex = before.indexWhere(
        (_StatusDockEntry entry) => entry.indicator == indicator,
      );
      final int newIndex = after.indexWhere(
        (_StatusDockEntry entry) => entry.indicator == indicator,
      );

      if (oldIndex != newIndex) {
        return true;
      }
    }

    return false;
  }

  Duration get mutationDuration {
    final bool hasAdds = addedIndicators.isNotEmpty;
    final bool hasRemovals = removedIndicators.isNotEmpty;

    if (hasAdds && hasRemovals) {
      return const Duration(milliseconds: 640);
    }

    if (hasAdds) {
      return const Duration(milliseconds: 540);
    }

    return const Duration(milliseconds: 480);
  }
}

@immutable
final class _MutationTiming {
  const _MutationTiming({
    required this.detachStart,
    required this.detachEnd,
    required this.reflowStart,
    required this.reflowEnd,
    required this.attachStart,
    required this.attachEnd,
  });

  final double detachStart;
  final double detachEnd;

  final double reflowStart;
  final double reflowEnd;

  final double attachStart;
  final double attachEnd;

  factory _MutationTiming.resolve(_DockMutationTransition transition) {
    final bool hasAdds = transition.addedIndicators.isNotEmpty;
    final bool hasRemovals = transition.removedIndicators.isNotEmpty;

    if (hasAdds && hasRemovals) {
      return const _MutationTiming(
        detachStart: 0.00,
        detachEnd: 0.28,
        reflowStart: 0.28,
        reflowEnd: 0.58,
        attachStart: 0.58,
        attachEnd: 0.94,
      );
    }

    if (hasRemovals) {
      if (!transition.requiresRetainedReflow) {
        return const _MutationTiming(
          detachStart: 0.00,
          detachEnd: 0.46,
          reflowStart: 1.00,
          reflowEnd: 1.00,
          attachStart: 1.00,
          attachEnd: 1.00,
        );
      }

      return const _MutationTiming(
        detachStart: 0.00,
        detachEnd: 0.36,
        reflowStart: 0.36,
        reflowEnd: 0.86,
        attachStart: 1.00,
        attachEnd: 1.00,
      );
    }

    if (!transition.requiresRetainedReflow) {
      return const _MutationTiming(
        detachStart: 0.00,
        detachEnd: 0.00,
        reflowStart: 0.00,
        reflowEnd: 0.00,
        attachStart: 0.00,
        attachEnd: 0.72,
      );
    }

    return const _MutationTiming(
      detachStart: 0.00,
      detachEnd: 0.00,
      reflowStart: 0.00,
      reflowEnd: 0.44,
      attachStart: 0.44,
      attachEnd: 0.88,
    );
  }

  double detachProgress(
    double progress, {
    required int ordinal,
    required int count,
  }) {
    if (detachEnd <= detachStart || count <= 0) {
      return 1;
    }

    final double stagger = count <= 1 ? 0 : ordinal * 0.035;

    return _intervalProgress(
      progress,
      start: (detachStart + stagger).clamp(0.0, detachEnd - 0.04).toDouble(),
      end: detachEnd,
    );
  }

  double reflowProgress(double progress) {
    if (reflowEnd <= reflowStart) {
      return 1;
    }

    return _intervalProgress(progress, start: reflowStart, end: reflowEnd);
  }

  double attachProgress(
    double progress, {
    required int ordinal,
    required int count,
  }) {
    if (attachEnd <= attachStart || count <= 0) {
      return 0;
    }

    final double stagger = count <= 1 ? 0 : ordinal * 0.055;

    return _intervalProgress(
      progress,
      start: (attachStart + stagger)
          .clamp(attachStart, attachEnd - 0.06)
          .toDouble(),
      end: attachEnd,
    );
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
// Node pose
// =============================================================================

@immutable
final class _DockNodePose {
  const _DockNodePose({
    required this.edgeOffset,
    required this.bottom,
    required this.scale,
  });

  factory _DockNodePose.anchor() {
    return const _DockNodePose(edgeOffset: 0, bottom: 0, scale: 1);
  }

  final double edgeOffset;
  final double bottom;
  final double scale;
}

_DockNodePose _expandedSlotPose(_StatusDockMetrics metrics, int index) {
  return _DockNodePose(
    edgeOffset: 0,
    bottom: index * metrics.nodeExtent,
    scale: 1,
  );
}

_DockNodePose _compactSatellitePose(_StatusDockMetrics metrics) {
  return _DockNodePose(
    edgeOffset: -metrics.satelliteHorizontalShift,
    bottom: metrics.satelliteVerticalShift,
    scale: metrics.satelliteScale,
  );
}

_DockNodePose _horizontalSlotPose(
  _StatusDockMetrics metrics,
  List<_StatusDockEntry> entries,
  int index,
) {
  return _DockNodePose(
    edgeOffset: metrics.horizontalOffsetFor(entries, index),
    bottom: 0,
    scale: 1,
  );
}

_DockNodePose _horizontalPerchedSatellitePose(
  _StatusDockMetrics metrics,
  _StatusDockEntry anchor,
) {
  return _DockNodePose(
    edgeOffset: metrics.horizontalPerchedSatelliteOffsetFor(anchor),
    bottom: metrics.satelliteVerticalShift,
    scale: metrics.satelliteScale,
  );
}

_DockNodePose _lerpPose(
  _DockNodePose start,
  _DockNodePose end,
  double progress,
) {
  return _DockNodePose(
    edgeOffset: _lerp(start.edgeOffset, end.edgeOffset, progress),
    bottom: _lerp(start.bottom, end.bottom, progress),
    scale: _lerp(start.scale, end.scale, progress),
  );
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

  final double outerDiameter;
  final double innerDiameter;

  final double ratingWidth;

  final double iconSize;
  final double ratingFontSize;

  final double ratingTextPadding;
  final double ratingTextVerticalOffset;
  final double ratingSignalGap;
  final double ratingIconVerticalOffset;

  final double nodeGap;

  final double railWidth;
  final double pulseWidth;
  final double pulseLength;

  final double attachmentTravel;
  final double highContrastOuterBorderWidth;

  double get innerInset => (outerDiameter - innerDiameter) / 2;

  double get nodeExtent => outerDiameter + nodeGap;

  // ---------------------------------------------------------------------------
  // Horizontal list geometry
  // ---------------------------------------------------------------------------

  /// Horizontal full-chain spacing deliberately matches the vertical chain's
  /// shell-to-shell gap so both layouts feel like the same component.
  double get horizontalNodeGap => nodeGap;

  /// Small perpendicular travel used when hidden list nodes attach/detach.
  double get horizontalAttachmentLift => attachmentTravel * 0.72;

  /// Horizontal Compact reuses the vertical satellite scale and lift. Only
  /// the inline offset changes so it perches over the anchor's trailing corner.
  double horizontalOffsetFor(List<_StatusDockEntry> entries, int index) {
    if (index <= 0) {
      return 0;
    }

    double offset = 0;

    for (int current = 0; current < index; current++) {
      offset += widthFor(entries[current]);
      offset += horizontalNodeGap;
    }

    return offset;
  }

  double horizontalWidthFor(List<_StatusDockEntry> entries) {
    if (entries.isEmpty) {
      return 0;
    }

    double width = 0;

    for (int index = 0; index < entries.length; index++) {
      if (index > 0) {
        width += horizontalNodeGap;
      }

      width += widthFor(entries[index]);
    }

    return width;
  }

  /// Layout-box offset for the perched Horizontal Compact satellite.
  ///
  /// In the normal LTR Search/List configuration (`side: start`) this places
  /// the small satellite over the upper-right corner of the expansion-facing
  /// signal. For a Rating anchor that signal is the star at the right end of
  /// `[9.2 ★]`, matching the vertical Compact dock's rest composition.
  double horizontalPerchedSatelliteOffsetFor(_StatusDockEntry anchor) {
    return widthFor(anchor) - outerDiameter + satelliteHorizontalShift;
  }

  double horizontalCompactRestWidthFor(List<_StatusDockEntry> entries) {
    if (entries.isEmpty) {
      return 0;
    }

    final double anchorWidth = widthFor(entries.first);

    if (entries.length == 1) {
      return anchorWidth;
    }

    final double satelliteOffset = horizontalPerchedSatelliteOffsetFor(
      entries.first,
    );
    final double scaledDiameter = outerDiameter * satelliteScale;
    final double scaledInset = (outerDiameter - scaledDiameter) / 2;

    final double satelliteVisualEnd =
        satelliteOffset + scaledInset + scaledDiameter;

    return math.max(anchorWidth, satelliteVisualEnd).toDouble();
  }

  /// Vertical extent needed by Horizontal Compact while its satellite is
  /// perched above the anchor. This intentionally matches the ordinary compact
  /// dock's resting silhouette.
  double horizontalCompactRestHeightFor(int count) {
    return compactRestHeightFor(count);
  }

  // ---------------------------------------------------------------------------
  // Compact satellite geometry
  // ---------------------------------------------------------------------------

  /// Resting satellite size relative to an ordinary circular node.
  double get satelliteScale => 0.60;

  /// Pushes the resting satellite toward the trailing corner so the semantic
  /// cores remain readable while the outer shells still feel connected.
  double get satelliteHorizontalShift => outerDiameter * 0.45;

  /// Raises the satellite enough to produce the deliberate compact overlap.
  double get satelliteVerticalShift => outerDiameter * 0.40;

  double compactRestHeightFor(int count) {
    if (count <= 1) {
      return outerDiameter;
    }

    final double satelliteVisualTop =
        satelliteVerticalShift +
        outerDiameter / 2 +
        outerDiameter * satelliteScale / 2;

    return math.max(outerDiameter, satelliteVisualTop).toDouble();
  }

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

bool _mediaStructureChanged(CinearaStatusDock before, CinearaStatusDock after) {
  return before.favorite != after.favorite ||
      before.collection != after.collection ||
      before.watchlist != after.watchlist ||
      (before.personalRating == null) != (after.personalRating == null);
}

bool _sameIndicatorSet(
  Set<CinearaStatusDockIndicator> first,
  Set<CinearaStatusDockIndicator> second,
) {
  return first.length == second.length && first.containsAll(second);
}

double _physicalInwardSign({
  required CinearaStatusDockSide side,
  required TextDirection direction,
}) {
  final bool railOnPhysicalRight =
      (side == CinearaStatusDockSide.end && direction == TextDirection.ltr) ||
      (side == CinearaStatusDockSide.start && direction == TextDirection.rtl);

  return railOnPhysicalRight ? -1 : 1;
}

double _magneticDx({
  required BuildContext context,
  required CinearaStatusDockSide side,
  required double travel,
}) {
  return _physicalInwardSign(
        side: side,
        direction: Directionality.of(context),
      ) *
      travel;
}

double _horizontalHiddenAttachProgress(
  double expansion, {
  required int ordinal,
  required int count,
}) {
  if (count <= 0) {
    return 0;
  }

  // The real satellite drops to the baseline first. Entry 2+ then descend
  // into their own already-vacant horizontal slots to continue the chain.
  final double start = (0.38 + ordinal * 0.10).clamp(0.38, 0.66).toDouble();
  final double end = (0.72 + ordinal * 0.09).clamp(0.72, 0.96).toDouble();

  return _intervalProgress(expansion, start: start, end: end);
}

double _presentationHiddenAttachProgress(
  double expansion, {
  required int ordinal,
  required int count,
}) {
  if (count <= 0) {
    return 0;
  }

  final double start = (0.32 + ordinal * 0.10).clamp(0.32, 0.62).toDouble();

  final double end = (0.68 + ordinal * 0.10).clamp(0.68, 0.94).toDouble();

  return _intervalProgress(expansion, start: start, end: end);
}

double _lerp(double start, double end, double progress) {
  return start + ((end - start) * progress);
}

String _formatRating(double value) {
  return value.toStringAsFixed(1);
}

String _formatAnimatedRating(double value) {
  final double stepped = (value * 10).round() / 10;
  return _formatRating(stepped);
}

double _intervalProgress(
  double progress, {
  required double start,
  required double end,
}) {
  if (end <= start) {
    return progress >= end ? 1 : 0;
  }

  if (progress <= start) {
    return 0;
  }

  if (progress >= end) {
    return 1;
  }

  return ((progress - start) / (end - start)).clamp(0.0, 1.0).toDouble();
}

/// Tiny mechanical settle at the end of Compact collapse.
///
/// This is intentionally restrained. The dock should feel magnetic, not
/// spring-loaded.
double _anchorSettleScale(double progress) {
  final double t = progress.clamp(0.0, 1.0).toDouble();

  if (t <= 0.42) {
    final double local = (t / 0.42).clamp(0.0, 1.0).toDouble();

    return _lerp(1, 0.975, Curves.easeOutCubic.transform(local));
  }

  final double local = ((t - 0.42) / 0.58).clamp(0.0, 1.0).toDouble();

  return _lerp(0.975, 1, Curves.easeOutCubic.transform(local));
}
