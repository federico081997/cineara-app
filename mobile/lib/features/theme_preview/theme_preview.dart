import 'package:cineara_design_system/cineara_design_system.dart';
import 'package:flutter/material.dart';

import '../../features/home/presentation/cards/home_shortcut_card.dart';

/// Development-only preview for comparing Cineara application themes.
///
/// The active theme changes immediately without restarting or hot reloading the
/// application. Keep this screen out of production navigation.
class CinearaThemePreviewScreen extends StatefulWidget {
  const CinearaThemePreviewScreen({super.key});

  @override
  State<CinearaThemePreviewScreen> createState() =>
      _CinearaThemePreviewScreenState();
}

class _CinearaThemePreviewScreenState extends State<CinearaThemePreviewScreen> {
  _PreviewTheme _selectedTheme = _PreviewTheme.light;

  bool _switchValue = true;
  bool _checkboxValue = true;
  double _sliderValue = 0.62;

  @override
  Widget build(BuildContext context) {
    final ThemeData selectedTheme = _selectedTheme.theme;

    return AnimatedTheme(
      data: selectedTheme,
      duration: CinearaMotion.standard,
      curve: Curves.easeOutCubic,
      child: Builder(
        builder: (BuildContext context) {
          final ThemeData theme = Theme.of(context);

          return Scaffold(
            appBar: AppBar(
              title: const Text('Cineara Theme Preview'),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: CinearaSpacing.md),
                  child: Center(
                    child: _BrightnessPill(brightness: theme.brightness),
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      CinearaSpacing.md,
                      CinearaSpacing.sm,
                      CinearaSpacing.md,
                      CinearaSpacing.xxl,
                    ),
                    sliver: SliverList.list(
                      children: <Widget>[
                        _ThemeSelector(
                          selectedTheme: _selectedTheme,
                          onChanged: (_PreviewTheme value) {
                            setState(() {
                              _selectedTheme = value;
                            });
                          },
                        ),

                        const SizedBox(height: CinearaSpacing.xl),

                        _SectionHeader(
                          title: _selectedTheme.label,
                          description: _selectedTheme.description,
                        ),

                        const SizedBox(height: CinearaSpacing.md),

                        const _ThemePalettePreview(),

                        const SizedBox(height: CinearaSpacing.xl),

                        const _SectionHeader(
                          title: 'Home shortcuts',
                          description:
                              'Real HomeShortcutCard instances using the '
                              'active ColorScheme.',
                        ),

                        const SizedBox(height: CinearaSpacing.md),

                        _ShortcutGrid(),

                        const SizedBox(height: CinearaSpacing.xl),

                        const _SectionHeader(
                          title: 'Media surface',
                          description:
                              'Poster-style artwork and metadata for checking '
                              'surface contrast around media.',
                        ),

                        const SizedBox(height: CinearaSpacing.md),

                        const _MediaPreview(),

                        const SizedBox(height: CinearaSpacing.xl),

                        const _SectionHeader(
                          title: 'Material controls',
                          description:
                              'Buttons, fields, chips and interactive states.',
                        ),

                        const SizedBox(height: CinearaSpacing.md),

                        _ControlsPreview(
                          switchValue: _switchValue,
                          checkboxValue: _checkboxValue,
                          sliderValue: _sliderValue,
                          onSwitchChanged: (bool value) {
                            setState(() {
                              _switchValue = value;
                            });
                          },
                          onCheckboxChanged: (bool? value) {
                            setState(() {
                              _checkboxValue = value ?? false;
                            });
                          },
                          onSliderChanged: (double value) {
                            setState(() {
                              _sliderValue = value;
                            });
                          },
                        ),

                        const SizedBox(height: CinearaSpacing.xl),

                        const _SectionHeader(
                          title: 'Surface hierarchy',
                          description:
                              'Every Material surface level shown together.',
                        ),

                        const SizedBox(height: CinearaSpacing.md),

                        const _SurfaceHierarchyPreview(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Themes currently available to the preview.
///
/// This enum is intentionally local to the developer preview. It is not the
/// production application theme preference model.
enum _PreviewTheme {
  light,
  dark,
  sunrise,
  aurora,
  highContrast,
  polar;

  String get label => switch (this) {
    _PreviewTheme.light => 'Light',
    _PreviewTheme.dark => 'Dark',
    _PreviewTheme.sunrise => 'Sunrise',
    _PreviewTheme.aurora => 'Aurora',
    _PreviewTheme.highContrast => 'High Contrast',
    _PreviewTheme.polar => 'Polar',
  };

  String get description => switch (this) {
    _PreviewTheme.light =>
      'Canonical Cineara light theme with a soft lavender atmosphere.',
    _PreviewTheme.dark =>
      'Cinematic blue-black surfaces with luminous Cineara accents.',
    _PreviewTheme.sunrise =>
      'Warm cream, rose and amber with restrained Cineara violet.',
    _PreviewTheme.aurora =>
      'Deep navy with a vivid violet, cyan and magenta spectrum.',
    _PreviewTheme.highContrast =>
      'Accessibility-first dark theme with stronger boundaries and contrast.',
    _PreviewTheme.polar =>
      'Icy blue light theme with cobalt, cyan and restrained periwinkle.',
  };

  ThemeData get theme => switch (this) {
    _PreviewTheme.light => CinearaLightTheme.theme,
    _PreviewTheme.dark => CinearaDarkTheme.theme,
    _PreviewTheme.sunrise => CinearaSunriseTheme.theme,
    _PreviewTheme.aurora => CinearaAuroraTheme.theme,
    _PreviewTheme.highContrast => CinearaHighContrastTheme.theme,
    _PreviewTheme.polar => CinearaPolarTheme.theme,
  };
}

/// Horizontally scrollable live theme selector.
class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector({required this.selectedTheme, required this.onChanged});

  final _PreviewTheme selectedTheme;
  final ValueChanged<_PreviewTheme> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(CinearaRadii.xl),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(CinearaSpacing.xs),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: <Widget>[
              for (final _PreviewTheme option
                  in _PreviewTheme.values) ...<Widget>[
                _ThemeChoice(
                  label: option.label,
                  selected: option == selectedTheme,
                  onTap: () => onChanged(option),
                ),
                if (option != _PreviewTheme.values.last)
                  const SizedBox(width: CinearaSpacing.xs),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeChoice extends StatelessWidget {
  const _ThemeChoice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Material(
      color: selected
          ? theme.colorScheme.primary
          : theme.colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(CinearaRadii.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(CinearaRadii.pill),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: CinearaSpacing.md,
            vertical: CinearaSpacing.sm,
          ),
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: selected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _BrightnessPill extends StatelessWidget {
  const _BrightnessPill({required this.brightness});

  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final bool isDark = brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CinearaSpacing.sm,
        vertical: CinearaSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(CinearaRadii.pill),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            size: 14,
          ),
          const SizedBox(width: CinearaSpacing.xxs),
          Text(
            isDark ? 'Dark' : 'Light',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
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
        const SizedBox(height: CinearaSpacing.xxs),
        Text(
          description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Shows the active Material semantic palette.
class _ThemePalettePreview extends StatelessWidget {
  const _ThemePalettePreview();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    final List<({String label, Color color, Color foreground})> swatches =
        <({String label, Color color, Color foreground})>[
          (
            label: 'Primary',
            color: colors.primary,
            foreground: colors.onPrimary,
          ),
          (
            label: 'Secondary',
            color: colors.secondary,
            foreground: colors.onSecondary,
          ),
          (
            label: 'Tertiary',
            color: colors.tertiary,
            foreground: colors.onTertiary,
          ),
          (
            label: 'Container',
            color: colors.primaryContainer,
            foreground: colors.onPrimaryContainer,
          ),
        ];

    return Wrap(
      spacing: CinearaSpacing.sm,
      runSpacing: CinearaSpacing.sm,
      children: <Widget>[
        for (final swatch in swatches)
          _ColourSwatch(
            label: swatch.label,
            color: swatch.color,
            foreground: swatch.foreground,
          ),
      ],
    );
  }
}

class _ColourSwatch extends StatelessWidget {
  const _ColourSwatch({
    required this.label,
    required this.color,
    required this.foreground,
  });

  final String label;
  final Color color;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      height: 70,
      padding: const EdgeInsets.all(CinearaSpacing.sm),
      alignment: Alignment.bottomLeft,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(CinearaRadii.md),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Uses real HomeShortcutCard widgets so theme changes exercise the component.
class _ShortcutGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int columns = constraints.maxWidth >= 720
            ? 4
            : constraints.maxWidth >= 480
            ? 3
            : 2;

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: CinearaSpacing.sm,
          mainAxisSpacing: CinearaSpacing.sm,
          mainAxisExtent: columns == 3 ? 150 : 170,
          children: <Widget>[
            HomeShortcutCard(
              icon: Icons.shuffle_rounded,
              label: 'Random Picker',
              description: 'Choose something for tonight',
              onTap: () {},
            ),
            HomeShortcutCard(
              icon: Icons.public_rounded,
              label: 'Spin the Globe',
              description: 'Discover cinema somewhere new',
              badgeLabel: 'NEW',
              onTap: () {},
            ),
            HomeShortcutCard(
              icon: Icons.workspace_premium_rounded,
              label: 'Achievements',
              description: 'See what you have unlocked',
              badgeLabel: '12',
              onTap: () {},
            ),
            const HomeShortcutCard(
              icon: Icons.upcoming_rounded,
              label: 'Coming later',
              description: 'Future Cineara shortcut',
            ),
          ],
        );
      },
    );
  }
}

/// Poster-like preview that intentionally uses only semantic theme roles.
class _MediaPreview extends StatelessWidget {
  const _MediaPreview();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(CinearaSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(CinearaRadii.lg),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 112,
            height: 168,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(CinearaRadii.lg),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  theme.colorScheme.surfaceContainerHighest,
                  theme.colorScheme.primary.withValues(alpha: 0.82),
                  theme.colorScheme.secondary.withValues(alpha: 0.72),
                ],
              ),
            ),
            child: Stack(
              children: <Widget>[
                Center(
                  child: Icon(
                    Icons.movie_filter_rounded,
                    size: 42,
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.88),
                  ),
                ),
                Positioned(
                  top: CinearaSpacing.xs,
                  left: CinearaSpacing.xs,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: CinearaSpacing.xs,
                      vertical: CinearaSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(CinearaRadii.pill),
                    ),
                    child: Text(
                      'JP',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: CinearaSpacing.xs,
                  bottom: CinearaSpacing.xs,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.onPrimary.withValues(
                          alpha: 0.30,
                        ),
                      ),
                    ),
                    child: Icon(
                      Icons.bookmark_rounded,
                      size: 17,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: CinearaSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Perfect Days',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: CinearaSpacing.xxs),
                Text('2023 · Japan · Drama', style: theme.textTheme.bodySmall),
                const SizedBox(height: CinearaSpacing.md),
                Text(
                  'Use this block to check how media artwork sits against '
                  'the current surface hierarchy.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: CinearaSpacing.md),
                LinearProgressIndicator(
                  value: 0.64,
                  borderRadius: BorderRadius.circular(CinearaRadii.pill),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlsPreview extends StatelessWidget {
  const _ControlsPreview({
    required this.switchValue,
    required this.checkboxValue,
    required this.sliderValue,
    required this.onSwitchChanged,
    required this.onCheckboxChanged,
    required this.onSliderChanged,
  });

  final bool switchValue;
  final bool checkboxValue;
  final double sliderValue;
  final ValueChanged<bool> onSwitchChanged;
  final ValueChanged<bool?> onCheckboxChanged;
  final ValueChanged<double> onSliderChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(CinearaSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(CinearaRadii.lg),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Wrap(
            spacing: CinearaSpacing.sm,
            runSpacing: CinearaSpacing.sm,
            children: <Widget>[
              FilledButton(onPressed: () {}, child: const Text('Primary')),
              OutlinedButton(onPressed: () {}, child: const Text('Secondary')),
              TextButton(onPressed: () {}, child: const Text('Text action')),
              const FilledButton(onPressed: null, child: Text('Disabled')),
            ],
          ),

          const SizedBox(height: CinearaSpacing.lg),

          const TextField(
            decoration: InputDecoration(
              labelText: 'Search Cineara',
              hintText: 'Movies, series, people…',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),

          const SizedBox(height: CinearaSpacing.lg),

          Wrap(
            spacing: CinearaSpacing.xs,
            runSpacing: CinearaSpacing.xs,
            children: const <Widget>[
              Chip(label: Text('Anime')),
              Chip(label: Text('K-Drama')),
              Chip(label: Text('World Cinema')),
            ],
          ),

          const SizedBox(height: CinearaSpacing.md),

          Row(
            children: <Widget>[
              Switch(value: switchValue, onChanged: onSwitchChanged),
              const SizedBox(width: CinearaSpacing.sm),
              Text('Switch', style: theme.textTheme.bodyMedium),
              const SizedBox(width: CinearaSpacing.lg),
              Checkbox(value: checkboxValue, onChanged: onCheckboxChanged),
              Text('Checkbox', style: theme.textTheme.bodyMedium),
            ],
          ),

          Slider(value: sliderValue, onChanged: onSliderChanged),

          const SizedBox(height: CinearaSpacing.sm),

          LinearProgressIndicator(
            value: sliderValue,
            borderRadius: BorderRadius.circular(CinearaRadii.pill),
          ),
        ],
      ),
    );
  }
}

class _SurfaceHierarchyPreview extends StatelessWidget {
  const _SurfaceHierarchyPreview();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final List<({String label, Color color})> surfaces =
        <({String label, Color color})>[
          (label: 'Lowest', color: colors.surfaceContainerLowest),
          (label: 'Low', color: colors.surfaceContainerLow),
          (label: 'Container', color: colors.surfaceContainer),
          (label: 'High', color: colors.surfaceContainerHigh),
          (label: 'Highest', color: colors.surfaceContainerHighest),
        ];

    return Column(
      children: <Widget>[
        for (final surface in surfaces)
          _SurfaceRow(label: surface.label, color: surface.color),
      ],
    );
  }
}

class _SurfaceRow extends StatelessWidget {
  const _SurfaceRow({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: CinearaSpacing.xs),
      padding: const EdgeInsets.all(CinearaSpacing.md),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(CinearaRadii.md),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
