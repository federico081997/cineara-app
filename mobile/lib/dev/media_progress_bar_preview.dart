import 'package:cineara_design_system/cineara_design_system.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CinearaMediaProgressIndicatorPreviewApp());
}

/// Standalone development preview for [CinearaMediaProgressIndicator].
///
/// Run with:
///
/// ```text
/// flutter run -t lib/debug/media_progress_indicator_preview.dart
/// ```
///
/// This preview intentionally avoids Cineara's normal application shell,
/// routing, repositories, and feature state so the shared progress primitive
/// can be evaluated in isolation.
final class CinearaMediaProgressIndicatorPreviewApp extends StatefulWidget {
  const CinearaMediaProgressIndicatorPreviewApp({super.key});

  @override
  State<CinearaMediaProgressIndicatorPreviewApp> createState() =>
      _CinearaMediaProgressIndicatorPreviewAppState();
}

final class _CinearaMediaProgressIndicatorPreviewAppState
    extends State<CinearaMediaProgressIndicatorPreviewApp> {
  ThemeMode _themeMode = ThemeMode.dark;
  bool _highContrast = false;
  bool _disableAnimations = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cineara Media Progress Preview',
      themeMode: _themeMode,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      home: Builder(
        builder: (context) {
          final MediaQueryData mediaQuery = MediaQuery.of(context);

          return MediaQuery(
            data: mediaQuery.copyWith(
              highContrast: _highContrast,
              disableAnimations: _disableAnimations,
            ),
            child: _PreviewPage(
              themeMode: _themeMode,
              highContrast: _highContrast,
              disableAnimations: _disableAnimations,
              onThemeModeChanged: (themeMode) {
                setState(() {
                  _themeMode = themeMode;
                });
              },
              onHighContrastChanged: (highContrast) {
                setState(() {
                  _highContrast = highContrast;
                });
              },
              onDisableAnimationsChanged: (disableAnimations) {
                setState(() {
                  _disableAnimations = disableAnimations;
                });
              },
            ),
          );
        },
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF7757F6),
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: brightness == Brightness.dark
          ? colorScheme.surfaceContainerLowest
          : colorScheme.surfaceContainerLow,
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
    required this.onThemeModeChanged,
    required this.onHighContrastChanged,
    required this.onDisableAnimationsChanged,
  });

  final ThemeMode themeMode;
  final bool highContrast;
  final bool disableAnimations;

  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<bool> onHighContrastChanged;
  final ValueChanged<bool> onDisableAnimationsChanged;

  @override
  State<_PreviewPage> createState() => _PreviewPageState();
}

final class _PreviewPageState extends State<_PreviewPage> {
  double _progress = 0.42;

  int get _watchedEpisodes => (_progress * 24).round();

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
                  _PreviewHeader(
                    themeMode: widget.themeMode,
                    highContrast: widget.highContrast,
                    disableAnimations: widget.disableAnimations,
                    onThemeModeChanged: widget.onThemeModeChanged,
                    onHighContrastChanged: widget.onHighContrastChanged,
                    onDisableAnimationsChanged:
                        widget.onDisableAnimationsChanged,
                  ),

                  const SizedBox(height: 48),

                  // ===========================================================
                  // Interactive preview
                  // ===========================================================
                  const _SectionHeader(
                    title: 'Interactive progress',
                    description:
                        'Change the value repeatedly to inspect the transition '
                        'between the filled and remaining portions.',
                  ),

                  const SizedBox(height: 24),

                  _InteractivePreview(
                    progress: _progress,
                    onProgressChanged: (value) {
                      setState(() {
                        _progress = value;
                      });
                    },
                  ),

                  const SizedBox(height: 56),

                  // ===========================================================
                  // Variant comparison
                  // ===========================================================
                  const _SectionHeader(
                    title: 'Variant comparison',
                    description:
                        'The same progress value rendered for artwork edges, '
                        'dense list rows, and larger card surfaces.',
                  ),

                  const SizedBox(height: 24),

                  _VariantComparison(progress: _progress),

                  const SizedBox(height: 56),

                  // ===========================================================
                  // Poster context
                  // ===========================================================
                  const _SectionHeader(
                    title: 'Poster edge',
                    description:
                        'The thin variant becomes part of the artwork '
                        'silhouette rather than appearing as a separate pill.',
                  ),

                  const SizedBox(height: 24),

                  Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    children: <Widget>[
                      _PosterExample(
                        title: 'Frieren',
                        subtitle: 'TV series · Anime',
                        progress: _progress,
                      ),
                      const _PosterExample(
                        title: 'Completed',
                        subtitle: 'Movie',
                        progress: 1,
                      ),
                      const _PosterExample(
                        title: 'Not started',
                        subtitle: 'TV series',
                        progress: 0,
                      ),
                      const _PosterExample(
                        title: 'Unknown',
                        subtitle: 'Progress unavailable',
                        progress: null,
                      ),
                    ],
                  ),

                  const SizedBox(height: 56),

                  // ===========================================================
                  // List context
                  // ===========================================================
                  const _SectionHeader(
                    title: 'List mode',
                    description:
                        'In list layouts the artwork can remain clean while '
                        'the progress indicator sits independently inside the '
                        'content area.',
                  ),

                  const SizedBox(height: 24),

                  _ListContextExample(
                    watchedEpisodes: _watchedEpisodes,
                    totalEpisodes: 24,
                  ),

                  const SizedBox(height: 56),

                  // ===========================================================
                  // Card context
                  // ===========================================================
                  const _SectionHeader(
                    title: 'Continue Watching',
                    description:
                        'The standard variant has slightly more visual weight '
                        'when progress is an important part of the surface.',
                  ),

                  const SizedBox(height: 24),

                  _ContinueWatchingExample(progress: _progress),

                  const SizedBox(height: 56),

                  // ===========================================================
                  // State comparison
                  // ===========================================================
                  const _SectionHeader(
                    title: 'State comparison',
                    description:
                        'Zero, partial, complete, unknown, and disabled states '
                        'must remain visibly distinct.',
                  ),

                  const SizedBox(height: 24),

                  const _StateComparison(),

                  const SizedBox(height: 56),

                  // ===========================================================
                  // Count-driven API
                  // ===========================================================
                  const _SectionHeader(
                    title: 'Watched / total API',
                    description:
                        'The component can calculate progress directly from '
                        'completed and total units without knowing what those '
                        'units represent.',
                  ),

                  const SizedBox(height: 24),

                  _CountExample(watched: _watchedEpisodes, total: 24),

                  const SizedBox(height: 56),

                  // ===========================================================
                  // Width testing
                  // ===========================================================
                  const _SectionHeader(
                    title: 'Responsive widths',
                    description:
                        'Check that the standalone progress treatment remains '
                        'clear at narrow, medium, and wide sizes.',
                  ),

                  const SizedBox(height: 24),

                  _WidthExamples(progress: _progress),

                  const SizedBox(height: 56),

                  // ===========================================================
                  // Notes
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
                          'Visual checks',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const _CheckItem(
                          text:
                              'Filled and remaining progress are immediately '
                              'distinguishable.',
                        ),
                        const _CheckItem(
                          text:
                              'Poster-edge progress feels integrated with '
                              'artwork rather than floating above it.',
                        ),
                        const _CheckItem(
                          text:
                              'Standalone bars remain visible without '
                              'becoming visually dominant.',
                        ),
                        const _CheckItem(
                          text:
                              'Unknown progress does not look equivalent to '
                              'zero progress.',
                        ),
                        const _CheckItem(
                          text:
                              'Animation communicates a changed value without '
                              'looking like buffering.',
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
    required this.onThemeModeChanged,
    required this.onHighContrastChanged,
    required this.onDisableAnimationsChanged,
  });

  final ThemeMode themeMode;
  final bool highContrast;
  final bool disableAnimations;

  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<bool> onHighContrastChanged;
  final ValueChanged<bool> onDisableAnimationsChanged;

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
          'Media Progress Indicator',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Isolated preview for poster-edge progress, standalone bars, '
          'motion, contrast, and progress states.',
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
              onSelectionChanged: (selection) {
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
// Interactive preview
// =============================================================================

final class _InteractivePreview extends StatelessWidget {
  const _InteractivePreview({
    required this.progress,
    required this.onProgressChanged,
  });

  final double progress;
  final ValueChanged<double> onProgressChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    final int percentage = (progress * 100).round();

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
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Viewing progress',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '$percentage%',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          CinearaMediaProgressIndicator(
            value: progress,
            variant: CinearaMediaProgressVariant.standard,
            semanticLabel: 'Viewing progress',
            semanticValue: '$percentage percent',
          ),

          const SizedBox(height: 20),

          Slider(value: progress, onChanged: onProgressChanged),

          const SizedBox(height: 8),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _ProgressPresetButton(
                label: '0%',
                onPressed: () => onProgressChanged(0),
              ),
              _ProgressPresetButton(
                label: '25%',
                onPressed: () => onProgressChanged(0.25),
              ),
              _ProgressPresetButton(
                label: '50%',
                onPressed: () => onProgressChanged(0.5),
              ),
              _ProgressPresetButton(
                label: '75%',
                onPressed: () => onProgressChanged(0.75),
              ),
              _ProgressPresetButton(
                label: '100%',
                onPressed: () => onProgressChanged(1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

final class _ProgressPresetButton extends StatelessWidget {
  const _ProgressPresetButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ActionChip(label: Text(label), onPressed: onPressed);
  }
}

// =============================================================================
// Variant comparison
// =============================================================================

final class _VariantComparison extends StatelessWidget {
  const _VariantComparison({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _VariantRow(
          name: 'Poster edge',
          description: '3.5 dp · artwork-integrated',
          child: CinearaMediaProgressIndicator(
            value: progress,
            variant: CinearaMediaProgressVariant.posterEdge,
            semanticLabel: 'Poster progress',
          ),
        ),
        const SizedBox(height: 24),
        _VariantRow(
          name: 'Compact',
          description: '5 dp · list and dense cards',
          child: CinearaMediaProgressIndicator(
            value: progress,
            variant: CinearaMediaProgressVariant.compact,
            semanticLabel: 'Compact viewing progress',
          ),
        ),
        const SizedBox(height: 24),
        _VariantRow(
          name: 'Standard',
          description: '7 dp · prominent content surfaces',
          child: CinearaMediaProgressIndicator(
            value: progress,
            variant: CinearaMediaProgressVariant.standard,
            semanticLabel: 'Viewing progress',
          ),
        ),
      ],
    );
  }
}

final class _VariantRow extends StatelessWidget {
  const _VariantRow({
    required this.name,
    required this.description,
    required this.child,
  });

  final String name;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
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
            name,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// =============================================================================
// Poster context
// =============================================================================

final class _PosterExample extends StatelessWidget {
  const _PosterExample({
    required this.title,
    required this.subtitle,
    required this.progress,
  });

  final String title;
  final String subtitle;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return SizedBox(
      width: 138,
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
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[
                          colors.primaryContainer,
                          colors.secondaryContainer,
                          colors.surfaceContainerHighest,
                        ],
                      ),
                    ),
                  ),

                  Center(
                    child: Icon(
                      Icons.movie_outlined,
                      size: 40,
                      color: colors.onPrimaryContainer.withValues(alpha: 0.76),
                    ),
                  ),

                  PositionedDirectional(
                    start: 0,
                    end: 0,
                    bottom: 0,
                    child: CinearaMediaProgressIndicator(
                      value: progress,
                      variant: CinearaMediaProgressVariant.posterEdge,
                      semanticLabel: '$title viewing progress',
                      unknownSemanticValue: 'Progress unavailable',
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
// List context
// =============================================================================

final class _ListContextExample extends StatelessWidget {
  const _ListContextExample({
    required this.watchedEpisodes,
    required this.totalEpisodes,
  });

  final int watchedEpisodes;
  final int totalEpisodes;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    final int percentage = totalEpisodes == 0
        ? 0
        : ((watchedEpisodes / totalEpisodes) * 100).round();

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
            width: 72,
            height: 108,
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

                const SizedBox(height: 18),

                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        '$watchedEpisodes / $totalEpisodes episodes',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '$percentage%',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                CinearaMediaProgressIndicator(
                  watched: watchedEpisodes,
                  total: totalEpisodes,
                  variant: CinearaMediaProgressVariant.compact,
                  semanticLabel: 'Episode progress',
                  semanticValue:
                      '$watchedEpisodes of $totalEpisodes episodes, '
                      '$percentage percent',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Continue Watching
// =============================================================================

final class _ContinueWatchingExample extends StatelessWidget {
  const _ContinueWatchingExample({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Container(
      constraints: const BoxConstraints(maxWidth: 620),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.38),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.play_arrow_rounded,
                  size: 34,
                  color: colors.onPrimaryContainer,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Continue watching',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Example series',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Season 1 · Episode 8',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right_rounded),
            ],
          ),

          const SizedBox(height: 20),

          CinearaMediaProgressIndicator(
            value: progress,
            variant: CinearaMediaProgressVariant.standard,
            semanticLabel: 'Viewing progress',
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// State comparison
// =============================================================================

final class _StateComparison extends StatelessWidget {
  const _StateComparison();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: const <Widget>[
        _ProgressStateCard(title: 'Not started', subtitle: '0%', value: 0),
        _ProgressStateCard(title: 'In progress', subtitle: '42%', value: 0.42),
        _ProgressStateCard(title: 'Almost done', subtitle: '88%', value: 0.88),
        _ProgressStateCard(title: 'Completed', subtitle: '100%', value: 1),
        _ProgressStateCard(
          title: 'Unknown',
          subtitle: 'No denominator',
          value: null,
        ),
        _ProgressStateCard(
          title: 'Disabled',
          subtitle: 'Temporarily unavailable',
          value: 0.58,
          enabled: false,
        ),
      ],
    );
  }
}

final class _ProgressStateCard extends StatelessWidget {
  const _ProgressStateCard({
    required this.title,
    required this.subtitle,
    required this.value,
    this.enabled = true,
  });

  final String title;
  final String subtitle;
  final double? value;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return SizedBox(
      width: 210,
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
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            CinearaMediaProgressIndicator(
              value: value,
              enabled: enabled,
              variant: CinearaMediaProgressVariant.compact,
              semanticLabel: title,
              unknownSemanticValue: 'Progress unavailable',
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Count-driven example
// =============================================================================

final class _CountExample extends StatelessWidget {
  const _CountExample({required this.watched, required this.total});

  final int watched;
  final int total;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Container(
      constraints: const BoxConstraints(maxWidth: 560),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.38),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Episode progress',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '$watched / $total',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          CinearaMediaProgressIndicator(
            watched: watched,
            total: total,
            variant: CinearaMediaProgressVariant.standard,
            semanticLabel: 'Episode progress',
            semanticValue: '$watched of $total episodes',
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Width examples
// =============================================================================

final class _WidthExamples extends StatelessWidget {
  const _WidthExamples({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _WidthExample(label: '120 dp', width: 120, progress: progress),
        const SizedBox(height: 20),
        _WidthExample(label: '240 dp', width: 240, progress: progress),
        const SizedBox(height: 20),
        _WidthExample(label: '420 dp', width: 420, progress: progress),
      ],
    );
  }
}

final class _WidthExample extends StatelessWidget {
  const _WidthExample({
    required this.label,
    required this.width,
    required this.progress,
  });

  final String label;
  final double width;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: width,
          child: CinearaMediaProgressIndicator(
            value: progress,
            variant: CinearaMediaProgressVariant.compact,
            semanticLabel: 'Viewing progress',
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Check item
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
