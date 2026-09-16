import 'package:cineara_design_system/cineara_design_system.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CinearaStatusBadgePreviewApp());
}

/// Standalone development preview for [CinearaStatusBadge].
///
/// Run with:
///
/// ```text
/// flutter run -t lib/debug/status_badge_preview.dart
/// ```
///
/// This preview intentionally avoids Cineara's normal application shell,
/// routing, repositories, and feature state so the status badge can be
/// evaluated independently.
final class CinearaStatusBadgePreviewApp extends StatefulWidget {
  const CinearaStatusBadgePreviewApp({super.key});

  @override
  State<CinearaStatusBadgePreviewApp> createState() =>
      _CinearaStatusBadgePreviewAppState();
}

final class _CinearaStatusBadgePreviewAppState
    extends State<CinearaStatusBadgePreviewApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  bool _highContrast = false;
  bool _disableAnimations = false;
  bool _rtl = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cineara Status Badge Preview',
      themeMode: _themeMode,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      home: Builder(
        builder: (BuildContext context) {
          final MediaQueryData mediaQuery = MediaQuery.of(context);

          return MediaQuery(
            data: mediaQuery.copyWith(
              highContrast: _highContrast,
              disableAnimations: _disableAnimations,
            ),
            child: Directionality(
              textDirection: _rtl ? TextDirection.rtl : TextDirection.ltr,
              child: _PreviewPage(
                themeMode: _themeMode,
                highContrast: _highContrast,
                disableAnimations: _disableAnimations,
                rtl: _rtl,
                onThemeModeChanged: (ThemeMode value) {
                  setState(() {
                    _themeMode = value;
                  });
                },
                onHighContrastChanged: (bool value) {
                  setState(() {
                    _highContrast = value;
                  });
                },
                onDisableAnimationsChanged: (bool value) {
                  setState(() {
                    _disableAnimations = value;
                  });
                },
                onRtlChanged: (bool value) {
                  setState(() {
                    _rtl = value;
                  });
                },
              ),
            ),
          );
        },
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final ColorScheme colors = ColorScheme.fromSeed(
      seedColor: const Color(0xFF7757F6),
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colors,
      scaffoldBackgroundColor: brightness == Brightness.dark
          ? colors.surfaceContainerLowest
          : colors.surfaceContainerLow,
    );
  }
}

// =============================================================================
// Preview page
// =============================================================================

final class _PreviewPage extends StatefulWidget {
  const _PreviewPage({
    required this.themeMode,
    required this.highContrast,
    required this.disableAnimations,
    required this.rtl,
    required this.onThemeModeChanged,
    required this.onHighContrastChanged,
    required this.onDisableAnimationsChanged,
    required this.onRtlChanged,
  });

  final ThemeMode themeMode;

  final bool highContrast;
  final bool disableAnimations;
  final bool rtl;

  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<bool> onHighContrastChanged;
  final ValueChanged<bool> onDisableAnimationsChanged;
  final ValueChanged<bool> onRtlChanged;

  @override
  State<_PreviewPage> createState() => _PreviewPageState();
}

final class _PreviewPageState extends State<_PreviewPage> {
  CinearaStatusBadgeType _status = CinearaStatusBadgeType.watching;

  int _newBadgeGeneration = 0;
  int _longLabelGeneration = 0;

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 72),
              sliver: SliverList.list(
                children: <Widget>[
                  // ===========================================================
                  // Header
                  // ===========================================================
                  _PreviewHeader(
                    themeMode: widget.themeMode,
                    highContrast: widget.highContrast,
                    disableAnimations: widget.disableAnimations,
                    rtl: widget.rtl,
                    onThemeModeChanged: widget.onThemeModeChanged,
                    onHighContrastChanged: widget.onHighContrastChanged,
                    onDisableAnimationsChanged:
                        widget.onDisableAnimationsChanged,
                    onRtlChanged: widget.onRtlChanged,
                  ),

                  const SizedBox(height: 48),

                  // ===========================================================
                  // Interactive status change
                  // ===========================================================
                  const _SectionHeader(
                    title: 'Status transition',
                    description:
                        'Change status repeatedly. The icon slot should remain '
                        'perfectly anchored while the new label unfolds and '
                        'collapses automatically.',
                  ),

                  const SizedBox(height: 24),

                  _InteractiveStatusExample(
                    status: _status,
                    expanded: _expanded,
                    onExpandedChanged: (bool value) {
                      setState(() {
                        _expanded = value;
                      });
                    },
                    onStatusChanged: (CinearaStatusBadgeType value) {
                      setState(() {
                        _status = value;
                      });
                    },
                  ),

                  const SizedBox(height: 56),

                  // ===========================================================
                  // New badge entrance
                  // ===========================================================
                  const _SectionHeader(
                    title: 'Newly applied status',
                    description:
                        'This simulates the moment a user assigns a status for '
                        'the first time. The badge should pop in gently, reveal '
                        'its meaning, then settle into the compact icon state.',
                  ),

                  const SizedBox(height: 24),

                  _NewStatusExample(
                    generation: _newBadgeGeneration,
                    status: _status,
                    onReplay: () {
                      setState(() {
                        _newBadgeGeneration++;
                      });
                    },
                  ),

                  const SizedBox(height: 56),

                  // ===========================================================
                  // Tap to expand
                  // ===========================================================
                  const _SectionHeader(
                    title: 'Tap to reveal',
                    description:
                        'Once collapsed, tap the status signal. The icon stays '
                        'in place while the label unfolds toward inline-end.',
                  ),

                  const SizedBox(height: 24),

                  const _TapRevealExample(),

                  const SizedBox(height: 56),

                  // ===========================================================
                  // Long labels
                  // ===========================================================
                  const _SectionHeader(
                    title: 'Long localized labels',
                    description:
                        'Long text is never ellipsized. When it does not fit, '
                        'the label performs one restrained horizontal reveal '
                        'before collapsing.',
                  ),

                  const SizedBox(height: 24),

                  _LongLabelExample(
                    generation: _longLabelGeneration,
                    onReplay: () {
                      setState(() {
                        _longLabelGeneration++;
                      });
                    },
                  ),

                  const SizedBox(height: 56),

                  // ===========================================================
                  // Poster context
                  // ===========================================================
                  const _SectionHeader(
                    title: 'On poster artwork',
                    description:
                        'Collapsed status indicators keep the poster clean. '
                        'Tap any status icon to temporarily reveal its label.',
                  ),

                  const SizedBox(height: 24),

                  const _PosterGrid(),

                  const SizedBox(height: 56),

                  // ===========================================================
                  // Density
                  // ===========================================================
                  const _SectionHeader(
                    title: 'Density comparison',
                    description:
                        'Density controls physical sizing. Expansion is now a '
                        'separate state instead of an icon-only density.',
                  ),

                  const SizedBox(height: 24),

                  const _DensityComparison(),

                  const SizedBox(height: 56),

                  // ===========================================================
                  // List context
                  // ===========================================================
                  const _SectionHeader(
                    title: 'Persistent list-mode status',
                    description:
                        'List rows have more room, so the status can remain '
                        'expanded instead of behaving like a poster overlay.',
                  ),

                  const SizedBox(height: 24),

                  const _ListModeExample(),

                  const SizedBox(height: 56),

                  // ===========================================================
                  // Full poster composition
                  // ===========================================================
                  const _SectionHeader(
                    title: 'Complete poster composition',
                    description:
                        'Check the collapsed status alongside personal state, '
                        'an external rating, and poster-edge progress.',
                  ),

                  const SizedBox(height: 24),

                  const _PosterCompositionExample(),

                  const SizedBox(height: 56),

                  // ===========================================================
                  // All statuses
                  // ===========================================================
                  const _SectionHeader(
                    title: 'Status family',
                    description:
                        'Every status shares the same geometry while colour '
                        'and icon provide immediate semantic distinction.',
                  ),

                  const SizedBox(height: 24),

                  const _StatusFamily(),

                  const SizedBox(height: 56),

                  // ===========================================================
                  // Checklist
                  // ===========================================================
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainer,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colors.outlineVariant.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'What to inspect',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const _CheckItem(
                          text:
                              'The icon never shifts horizontally when status '
                              'or label width changes.',
                        ),
                        const _CheckItem(
                          text: 'Expansion grows only toward inline-end.',
                        ),
                        const _CheckItem(
                          text:
                              'The entrance pop is subtle rather than bouncy.',
                        ),
                        const _CheckItem(
                          text: 'Long labels scroll once and never loop.',
                        ),
                        const _CheckItem(
                          text:
                              'Collapsed badges remain visually quiet on '
                              'posters.',
                        ),
                        const _CheckItem(
                          text:
                              'Reduced motion removes pop and marquee motion.',
                        ),
                        const _CheckItem(
                          text:
                              'RTL reverses expansion and label movement '
                              'without changing semantic placement.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Header
// =============================================================================

final class _PreviewHeader extends StatelessWidget {
  const _PreviewHeader({
    required this.themeMode,
    required this.highContrast,
    required this.disableAnimations,
    required this.rtl,
    required this.onThemeModeChanged,
    required this.onHighContrastChanged,
    required this.onDisableAnimationsChanged,
    required this.onRtlChanged,
  });

  final ThemeMode themeMode;

  final bool highContrast;
  final bool disableAnimations;
  final bool rtl;

  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<bool> onHighContrastChanged;
  final ValueChanged<bool> onDisableAnimationsChanged;
  final ValueChanged<bool> onRtlChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'CINEARA',
          style: theme.textTheme.labelLarge?.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w800,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Status Badge',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Standalone preview for anchored transitions, reveal/collapse '
          'behaviour, long labels, artwork readability, and accessibility.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            SegmentedButton<ThemeMode>(
              segments: const <ButtonSegment<ThemeMode>>[
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode_outlined),
                  label: Text('Light'),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode_outlined),
                  label: Text('Dark'),
                ),
              ],
              selected: <ThemeMode>{
                themeMode == ThemeMode.light ? ThemeMode.light : ThemeMode.dark,
              },
              onSelectionChanged: (Set<ThemeMode> selection) {
                onThemeModeChanged(selection.first);
              },
            ),
            FilterChip(
              selected: highContrast,
              avatar: const Icon(Icons.contrast, size: 18),
              label: const Text('High contrast'),
              onSelected: onHighContrastChanged,
            ),
            FilterChip(
              selected: disableAnimations,
              avatar: const Icon(Icons.motion_photos_off_outlined, size: 18),
              label: const Text('Reduced motion'),
              onSelected: onDisableAnimationsChanged,
            ),
            FilterChip(
              selected: rtl,
              avatar: const Icon(
                Icons.format_textdirection_r_to_l_rounded,
                size: 18,
              ),
              label: const Text('RTL'),
              onSelected: onRtlChanged,
            ),
          ],
        ),
      ],
    );
  }
}

// =============================================================================
// Section header
// =============================================================================

final class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Interactive transition
// =============================================================================

final class _InteractiveStatusExample extends StatelessWidget {
  const _InteractiveStatusExample({
    required this.status,
    required this.expanded,
    required this.onStatusChanged,
    required this.onExpandedChanged,
  });

  final CinearaStatusBadgeType status;

  final bool expanded;

  final ValueChanged<CinearaStatusBadgeType> onStatusChanged;
  final ValueChanged<bool> onExpandedChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // This fixed-width field makes even tiny unintended icon movement
          // very easy to notice.
          Container(
            width: double.infinity,
            height: 126,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  colors.primaryContainer,
                  colors.tertiaryContainer,
                  colors.surfaceContainerHighest,
                ],
              ),
            ),
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: CinearaStatusBadge(
                type: status,
                label: _statusLabel(status),
                behavior: CinearaStatusBadgeBehavior.collapsible,
                revealOnStatusChange: true,
                autoCollapse: true,
                onExpandedChanged: onExpandedChanged,
              ),
            ),
          ),

          const SizedBox(height: 18),

          Text(
            expanded ? 'Label expanded' : 'Compact icon state',
            style: theme.textTheme.labelMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 18),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: CinearaStatusBadgeType.values.map((
              CinearaStatusBadgeType type,
            ) {
              return ChoiceChip(
                selected: type == status,
                label: Text(_statusLabel(type)),
                onSelected: (_) {
                  onStatusChanged(type);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Newly applied status
// =============================================================================

final class _NewStatusExample extends StatelessWidget {
  const _NewStatusExample({
    required this.generation,
    required this.status,
    required this.onReplay,
  });

  final int generation;
  final CinearaStatusBadgeType status;

  final VoidCallback onReplay;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 54,
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: CinearaStatusBadge(
                key: ValueKey<int>(generation),
                type: status,
                label: _statusLabel(status),
                behavior: CinearaStatusBadgeBehavior.collapsible,
                revealOnMount: true,
                autoCollapse: true,
              ),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.tonalIcon(
            onPressed: onReplay,
            icon: const Icon(Icons.replay_rounded),
            label: const Text('Replay new-status animation'),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Tap reveal
// =============================================================================

final class _TapRevealExample extends StatelessWidget {
  const _TapRevealExample();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const CinearaStatusBadge(
            type: CinearaStatusBadgeType.rewatching,
            label: 'Rewatching',
            behavior: CinearaStatusBadgeBehavior.collapsible,
            expandOnTap: true,
            autoCollapse: true,
          ),
          const SizedBox(height: 18),
          Text(
            'Tap the status icon above.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Long labels
// =============================================================================

final class _LongLabelExample extends StatelessWidget {
  const _LongLabelExample({required this.generation, required this.onReplay});

  final int generation;

  final VoidCallback onReplay;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CinearaStatusBadge(
            key: ValueKey<int>(generation),
            type: CinearaStatusBadgeType.rewatching,
            label: 'Currently rewatching this series',
            maxWidth: 128,
            behavior: CinearaStatusBadgeBehavior.collapsible,
            revealOnMount: true,
            marqueeLongLabels: true,
            autoCollapse: true,
          ),
          const SizedBox(height: 20),
          FilledButton.tonalIcon(
            onPressed: onReplay,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Replay long-label reveal'),
          ),
          const SizedBox(height: 10),
          Text(
            'Expected: pause → one horizontal reveal → pause → collapse.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Poster grid
// =============================================================================

final class _PosterGrid extends StatelessWidget {
  const _PosterGrid();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 18,
      runSpacing: 24,
      crossAxisAlignment: WrapCrossAlignment.start,
      children: CinearaStatusBadgeType.values.map((
        CinearaStatusBadgeType type,
      ) {
        return _PosterExample(status: type);
      }).toList(),
    );
  }
}

final class _PosterExample extends StatelessWidget {
  const _PosterExample({required this.status});

  final CinearaStatusBadgeType status;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 2 / 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: _posterGradient(context, status),
                    ),
                  ),
                  const _PosterDecoration(),
                  PositionedDirectional(
                    start: 6,
                    top: 6,
                    child: CinearaStatusBadge(
                      type: status,
                      label: _statusLabel(status),
                      behavior: CinearaStatusBadgeBehavior.collapsible,
                      variant: CinearaStatusBadgeVariant.artwork,
                      density: CinearaStatusBadgeDensity.compact,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 9),
          Text(
            _statusLabel(status),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Tap badge to reveal',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Density
// =============================================================================

final class _DensityComparison extends StatelessWidget {
  const _DensityComparison();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: const <Widget>[
        _DensityCard(
          title: 'Compact · collapsed',
          badge: CinearaStatusBadge(
            type: CinearaStatusBadgeType.watching,
            label: 'Watching',
            density: CinearaStatusBadgeDensity.compact,
            behavior: CinearaStatusBadgeBehavior.collapsible,
          ),
        ),
        _DensityCard(
          title: 'Compact · persistent',
          badge: CinearaStatusBadge(
            type: CinearaStatusBadgeType.watching,
            label: 'Watching',
            density: CinearaStatusBadgeDensity.compact,
            behavior: CinearaStatusBadgeBehavior.persistent,
            variant: CinearaStatusBadgeVariant.surface,
          ),
        ),
        _DensityCard(
          title: 'Standard · persistent',
          badge: CinearaStatusBadge(
            type: CinearaStatusBadgeType.watching,
            label: 'Watching',
            density: CinearaStatusBadgeDensity.standard,
            behavior: CinearaStatusBadgeBehavior.persistent,
            variant: CinearaStatusBadgeVariant.surface,
          ),
        ),
      ],
    );
  }
}

final class _DensityCard extends StatelessWidget {
  const _DensityCard({required this.title, required this.badge});

  final String title;
  final Widget badge;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return SizedBox(
      width: 220,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            badge,
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// List mode
// =============================================================================

final class _ListModeExample extends StatelessWidget {
  const _ListModeExample();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.38),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 70,
            height: 105,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  colors.primaryContainer,
                  colors.tertiaryContainer,
                ],
              ),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.movie_outlined, color: colors.onPrimaryContainer),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Frieren: Beyond Journey\'s End',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '2023 · Japan · Anime',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                const CinearaStatusBadge(
                  type: CinearaStatusBadgeType.watching,
                  label: 'Watching',
                  variant: CinearaStatusBadgeVariant.surface,
                  density: CinearaStatusBadgeDensity.standard,
                  behavior: CinearaStatusBadgeBehavior.persistent,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
        ],
      ),
    );
  }
}

// =============================================================================
// Full poster composition
// =============================================================================

final class _PosterCompositionExample extends StatelessWidget {
  const _PosterCompositionExample();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Center(
      child: SizedBox(
        width: 190,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 2 / 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: <Color>[
                            Color(0xFF242848),
                            Color(0xFF6A4DC7),
                            Color(0xFF151722),
                          ],
                        ),
                      ),
                    ),

                    const _PosterDecoration(),

                    const PositionedDirectional(
                      start: 7,
                      top: 7,
                      child: CinearaStatusBadge(
                        type: CinearaStatusBadgeType.rewatching,
                        label: 'Rewatching',
                        density: CinearaStatusBadgeDensity.compact,
                        behavior: CinearaStatusBadgeBehavior.collapsible,
                      ),
                    ),

                    PositionedDirectional(
                      top: 7,
                      end: 7,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          _MockArtworkBadge(
                            icon: Icons.star_rounded,
                            label: '9',
                            accent: colors.primary,
                          ),
                          const SizedBox(width: 3),
                          _MockArtworkBadge(
                            icon: Icons.favorite_rounded,
                            accent: colors.tertiary,
                          ),
                        ],
                      ),
                    ),

                    PositionedDirectional(
                      start: 7,
                      bottom: 8,
                      child: _MockArtworkBadge(
                        icon: Icons.star_rounded,
                        label: '8.4',
                        accent: colors.secondary,
                      ),
                    ),

                    const PositionedDirectional(
                      start: 0,
                      end: 0,
                      bottom: 0,
                      child: CinearaMediaProgressIndicator(
                        value: 0.57,
                        variant: CinearaMediaProgressVariant.posterEdge,
                        semanticLabel: 'Viewing progress',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Example series',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '2026 · TV series',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Status family
// =============================================================================

final class _StatusFamily extends StatelessWidget {
  const _StatusFamily();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: CinearaStatusBadgeType.values.map((
          CinearaStatusBadgeType type,
        ) {
          return CinearaStatusBadge(
            type: type,
            label: _statusLabel(type),
            variant: CinearaStatusBadgeVariant.surface,
            density: CinearaStatusBadgeDensity.standard,
            behavior: CinearaStatusBadgeBehavior.persistent,
          );
        }).toList(),
      ),
    );
  }
}

// =============================================================================
// Mock artwork
// =============================================================================

final class _PosterDecoration extends StatelessWidget {
  const _PosterDecoration();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          right: -24,
          top: 42,
          child: Transform.rotate(
            angle: 0.5,
            child: Container(
              width: 120,
              height: 36,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
        ),
        Positioned(
          left: 18,
          bottom: 52,
          child: Icon(
            Icons.movie_creation_outlined,
            size: 52,
            color: Colors.white.withValues(alpha: 0.30),
          ),
        ),
        Positioned(
          left: -24,
          bottom: 10,
          child: Container(
            width: 100,
            height: 82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.16),
            ),
          ),
        ),
      ],
    );
  }
}

LinearGradient _posterGradient(
  BuildContext context,
  CinearaStatusBadgeType status,
) {
  final ColorScheme colors = Theme.of(context).colorScheme;

  return switch (status) {
    CinearaStatusBadgeType.watching => const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Color(0xFF12233A), Color(0xFF416F9C), Color(0xFF10141B)],
    ),
    CinearaStatusBadgeType.caughtUp => const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Color(0xFF184646), Color(0xFF5AAFA7), Color(0xFF111C1C)],
    ),
    CinearaStatusBadgeType.completed => const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Color(0xFF214525), Color(0xFF69A96D), Color(0xFF111B12)],
    ),
    CinearaStatusBadgeType.rewatching => LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[
        colors.primaryContainer,
        const Color(0xFF7654D8),
        const Color(0xFF181322),
      ],
    ),
    CinearaStatusBadgeType.onHold => const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Color(0xFF7B431D), Color(0xFFE7A250), Color(0xFF221810)],
    ),
    CinearaStatusBadgeType.dropped => const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Color(0xFF5D1E23), Color(0xFFD25E61), Color(0xFF211012)],
    ),
  };
}

// =============================================================================
// Mock neighboring badge
// =============================================================================

final class _MockArtworkBadge extends StatelessWidget {
  const _MockArtworkBadge({
    required this.icon,
    required this.accent,
    this.label,
  });

  final IconData icon;
  final Color accent;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 23,
      padding: EdgeInsetsDirectional.only(
        start: label == null ? 5 : 4,
        end: label == null ? 5 : 6,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.24),
          width: 0.75,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 13, color: accent),
          if (label != null) ...<Widget>[
            const SizedBox(width: 2),
            Text(
              label!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// =============================================================================
// Checklist
// =============================================================================

final class _CheckItem extends StatelessWidget {
  const _CheckItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              Icons.check_circle_outline_rounded,
              size: 18,
              color: colors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Labels
// =============================================================================

String _statusLabel(CinearaStatusBadgeType type) {
  return switch (type) {
    CinearaStatusBadgeType.watching => 'Watching',
    CinearaStatusBadgeType.caughtUp => 'Caught up',
    CinearaStatusBadgeType.completed => 'Completed',
    CinearaStatusBadgeType.rewatching => 'Rewatching',
    CinearaStatusBadgeType.onHold => 'On hold',
    CinearaStatusBadgeType.dropped => 'Dropped',
  };
}
