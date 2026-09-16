import 'package:cineara_design_system/cineara_design_system.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CinearaViewModeSelectorPreviewApp());
}

/// Standalone development preview for [CinearaViewModeSelector].
///
/// Run with:
///
/// ```text
/// flutter run -t lib/debug/view_mode_selector_preview.dart
/// ```
///
/// This preview intentionally avoids Cineara's normal application shell,
/// routing, and feature modules so the selector can be evaluated in isolation.
final class CinearaViewModeSelectorPreviewApp extends StatefulWidget {
  const CinearaViewModeSelectorPreviewApp({super.key});

  @override
  State<CinearaViewModeSelectorPreviewApp> createState() =>
      _CinearaViewModeSelectorPreviewAppState();
}

final class _CinearaViewModeSelectorPreviewAppState
    extends State<CinearaViewModeSelectorPreviewApp> {
  ThemeMode _themeMode = ThemeMode.dark;
  bool _highContrast = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cineara View Mode Selector Preview',
      themeMode: _themeMode,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      home: Builder(
        builder: (context) {
          final mediaQuery = MediaQuery.of(context);

          return MediaQuery(
            data: mediaQuery.copyWith(highContrast: _highContrast),
            child: _PreviewPage(
              themeMode: _themeMode,
              highContrast: _highContrast,
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
            ),
          );
        },
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
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

final class _PreviewPage extends StatefulWidget {
  const _PreviewPage({
    required this.themeMode,
    required this.highContrast,
    required this.onThemeModeChanged,
    required this.onHighContrastChanged,
  });

  final ThemeMode themeMode;
  final bool highContrast;

  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<bool> onHighContrastChanged;

  @override
  State<_PreviewPage> createState() => _PreviewPageState();
}

final class _PreviewPageState extends State<_PreviewPage> {
  CinearaViewMode _viewMode = CinearaViewMode.grid;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 64),
              sliver: SliverList.list(
                children: [
                  _PreviewHeader(
                    themeMode: widget.themeMode,
                    highContrast: widget.highContrast,
                    onThemeModeChanged: widget.onThemeModeChanged,
                    onHighContrastChanged: widget.onHighContrastChanged,
                  ),
                  const SizedBox(height: 48),

                  const _SectionHeader(
                    title: 'Interactive preview',
                    description:
                        'Switch repeatedly between grid and list mode to inspect '
                        'the movement of the shared selection indicator.',
                  ),
                  const SizedBox(height: 24),

                  Center(
                    child: CinearaViewModeSelector(
                      value: _viewMode,
                      gridLabel: 'Grid view',
                      listLabel: 'List view',
                      onChanged: (mode) {
                        setState(() {
                          _viewMode = mode;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  Center(
                    child: Text(
                      _viewMode == CinearaViewMode.grid
                          ? 'Grid selected'
                          : 'List selected',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),

                  const SizedBox(height: 56),

                  const _SectionHeader(
                    title: 'In context',
                    description:
                        'The selector should behave as a quiet secondary '
                        'utility beside page controls rather than competing '
                        'with the content.',
                  ),
                  const SizedBox(height: 24),

                  _ContextExample(
                    viewMode: _viewMode,
                    onViewModeChanged: (mode) {
                      setState(() {
                        _viewMode = mode;
                      });
                    },
                  ),

                  const SizedBox(height: 56),

                  const _SectionHeader(
                    title: 'State comparison',
                    description:
                        'Compare enabled and disabled treatments side by side.',
                  ),
                  const SizedBox(height: 24),

                  Wrap(
                    spacing: 32,
                    runSpacing: 24,
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _StateExample(
                        title: 'Grid',
                        child: CinearaViewModeSelector(
                          value: CinearaViewMode.grid,
                          gridLabel: 'Grid view',
                          listLabel: 'List view',
                          onChanged: (_) {},
                        ),
                      ),
                      _StateExample(
                        title: 'List',
                        child: CinearaViewModeSelector(
                          value: CinearaViewMode.list,
                          gridLabel: 'Grid view',
                          listLabel: 'List view',
                          onChanged: (_) {},
                        ),
                      ),
                      _StateExample(
                        title: 'Disabled',
                        child: CinearaViewModeSelector(
                          value: CinearaViewMode.grid,
                          gridLabel: 'Grid view',
                          listLabel: 'List view',
                          enabled: false,
                          onChanged: (_) {},
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 56),

                  const _SectionHeader(
                    title: 'Content density',
                    description:
                        'The selector is shown beside realistic page actions '
                        'to check whether its size and visual prominence are '
                        'appropriately restrained.',
                  ),
                  const SizedBox(height: 24),

                  _ToolbarExample(
                    viewMode: _viewMode,
                    onChanged: (mode) {
                      setState(() {
                        _viewMode = mode;
                      });
                    },
                  ),

                  const SizedBox(height: 32),

                  _MockContent(viewMode: _viewMode),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _PreviewHeader extends StatelessWidget {
  const _PreviewHeader({
    required this.themeMode,
    required this.highContrast,
    required this.onThemeModeChanged,
    required this.onHighContrastChanged,
  });

  final ThemeMode themeMode;
  final bool highContrast;

  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<bool> onHighContrastChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          'View Mode Selector',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Isolated preview for motion, sizing, contrast, interaction, '
          'and visual hierarchy.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode_outlined),
                  label: Text('Light'),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode_outlined),
                  label: Text('Dark'),
                ),
              ],
              selected: {
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
          ],
        ),
      ],
    );
  }
}

final class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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

final class _ContextExample extends StatelessWidget {
  const _ContextExample({
    required this.viewMode,
    required this.onViewModeChanged,
  });

  final CinearaViewMode viewMode;
  final ValueChanged<CinearaViewMode> onViewModeChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Library',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '184 titles',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          CinearaViewModeSelector(
            value: viewMode,
            gridLabel: 'Grid view',
            listLabel: 'List view',
            onChanged: onViewModeChanged,
          ),
        ],
      ),
    );
  }
}

final class _StateExample extends StatelessWidget {
  const _StateExample({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

final class _ToolbarExample extends StatelessWidget {
  const _ToolbarExample({required this.viewMode, required this.onChanged});

  final CinearaViewMode viewMode;
  final ValueChanged<CinearaViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            'Popular',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        IconButton(
          tooltip: 'Sort',
          onPressed: () {},
          icon: const Icon(Icons.swap_vert_rounded),
        ),
        const SizedBox(width: 4),
        IconButton(
          tooltip: 'Filter',
          onPressed: () {},
          icon: const Icon(Icons.tune_rounded),
        ),
        const SizedBox(width: 8),
        CinearaViewModeSelector(
          value: viewMode,
          gridLabel: 'Grid view',
          listLabel: 'List view',
          onChanged: onChanged,
        ),
      ],
    );
  }
}

final class _MockContent extends StatelessWidget {
  const _MockContent({required this.viewMode});

  final CinearaViewMode viewMode;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: viewMode == CinearaViewMode.grid
          ? const _GridPreview(key: ValueKey('grid'))
          : const _ListPreview(key: ValueKey('list')),
    );
  }
}

final class _GridPreview extends StatelessWidget {
  const _GridPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 8,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2 / 3,
      ),
      itemBuilder: (context, index) {
        return _PosterPlaceholder(index: index);
      },
    );
  }
}

final class _ListPreview extends StatelessWidget {
  const _ListPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        5,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: index == 4 ? 0 : 12),
          child: _ListItemPlaceholder(index: index),
        ),
      ),
    );
  }
}

final class _PosterPlaceholder extends StatelessWidget {
  const _PosterPlaceholder({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: index.isEven
            ? colors.primaryContainer
            : colors.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.movie_outlined,
        color: index.isEven
            ? colors.onPrimaryContainer
            : colors.onSecondaryContainer,
      ),
    );
  }
}

final class _ListItemPlaceholder extends StatelessWidget {
  const _ListItemPlaceholder({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .35)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 72,
            decoration: BoxDecoration(
              color: index.isEven
                  ? colors.primaryContainer
                  : colors.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Example title ${index + 1}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '2026 • Movie',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
        ],
      ),
    );
  }
}
