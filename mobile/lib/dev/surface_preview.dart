// Adjust this import only if your surface.dart lives elsewhere.
import 'package:cineara_design_system/cineara_design_system.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CinearaSurfacePreviewApp());
}

/// Standalone development preview for [CinearaSurface].
///
/// Run with:
///
/// ```text
/// flutter run -t lib/debug/surface_preview.dart
/// ```
///
/// This preview deliberately does not depend on Cineara's application shell,
/// router, navigation, or feature modules. It exists only to validate the
/// design-system surface primitive in isolation.
final class CinearaSurfacePreviewApp extends StatefulWidget {
  const CinearaSurfacePreviewApp({super.key});

  @override
  State<CinearaSurfacePreviewApp> createState() =>
      _CinearaSurfacePreviewAppState();
}

final class _CinearaSurfacePreviewAppState
    extends State<CinearaSurfacePreviewApp> {
  ThemeMode _themeMode = ThemeMode.dark;
  bool _highContrast = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cineara Surface Preview',
      themeMode: _themeMode,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      home: Builder(
        builder: (context) {
          final mediaQuery = MediaQuery.of(context);

          return MediaQuery(
            data: mediaQuery.copyWith(highContrast: _highContrast),
            child: _SurfacePreviewPage(
              themeMode: _themeMode,
              highContrast: _highContrast,
              onThemeModeChanged: (value) {
                setState(() {
                  _themeMode = value;
                });
              },
              onHighContrastChanged: (value) {
                setState(() {
                  _highContrast = value;
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
      seedColor: const Color(0xFF7C5CFC),
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
    );
  }
}

/// Main surface preview screen.
final class _SurfacePreviewPage extends StatelessWidget {
  const _SurfacePreviewPage({
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
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 64),
              sliver: SliverList.list(
                children: [
                  _PreviewHeader(
                    themeMode: themeMode,
                    highContrast: highContrast,
                    onThemeModeChanged: onThemeModeChanged,
                    onHighContrastChanged: onHighContrastChanged,
                  ),
                  const SizedBox(height: 40),

                  const _SectionTitle(
                    title: 'Surface variants',
                    description:
                        'The five semantic surface treatments shown with '
                        'identical content.',
                  ),
                  const SizedBox(height: 20),

                  ...CinearaSurfaceVariant.values.map(
                    (variant) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _VariantPreview(variant: variant),
                    ),
                  ),

                  const SizedBox(height: 32),

                  const _SectionTitle(
                    title: 'Realistic cards',
                    description:
                        'Examples closer to how surfaces would appear inside '
                        'the actual Cineara interface.',
                  ),
                  const SizedBox(height: 20),

                  const _MediaSummaryPreview(),
                  const SizedBox(height: 16),

                  const _StatisticsPreview(),
                  const SizedBox(height: 16),

                  const _SettingsPreview(),

                  const SizedBox(height: 40),

                  const _SectionTitle(
                    title: 'Artwork overlay',
                    description:
                        'Checks translucency, clipping, border treatment, '
                        'and readability over imagery.',
                  ),
                  const SizedBox(height: 20),

                  const _ArtworkPreview(),

                  const SizedBox(height: 40),

                  const _SectionTitle(
                    title: 'Clipping',
                    description:
                        'Useful for checking that artwork and coloured content '
                        'respect the surface geometry.',
                  ),
                  const SizedBox(height: 20),

                  const _ClippingPreview(),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CINEARA',
          style: theme.textTheme.labelLarge?.copyWith(
            letterSpacing: 3,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Surface Preview',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Isolated development environment for testing surface hierarchy, '
          'borders, elevation, clipping, and theme behaviour.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
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

final class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.description});

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

final class _VariantPreview extends StatelessWidget {
  const _VariantPreview({required this.variant});

  final CinearaSurfaceVariant variant;

  @override
  Widget build(BuildContext context) {
    return CinearaSurface(
      variant: variant,
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _VariantIcon(variant: variant),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _titleFor(variant),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _descriptionFor(variant),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _titleFor(CinearaSurfaceVariant variant) {
    return switch (variant) {
      CinearaSurfaceVariant.subtle => 'Subtle',
      CinearaSurfaceVariant.standard => 'Standard',
      CinearaSurfaceVariant.elevated => 'Elevated',
      CinearaSurfaceVariant.prominent => 'Prominent',
      CinearaSurfaceVariant.artworkOverlay => 'Artwork overlay',
    };
  }

  String _descriptionFor(CinearaSurfaceVariant variant) {
    return switch (variant) {
      CinearaSurfaceVariant.subtle =>
        'Quiet grouping for secondary or supporting information.',
      CinearaSurfaceVariant.standard =>
        'Default treatment for ordinary cards and grouped content.',
      CinearaSurfaceVariant.elevated =>
        'Raised treatment for content requiring additional separation.',
      CinearaSurfaceVariant.prominent =>
        'Higher-emphasis treatment for featured or important content.',
      CinearaSurfaceVariant.artworkOverlay =>
        'Translucent treatment intended to sit over media artwork.',
    };
  }
}

final class _VariantIcon extends StatelessWidget {
  const _VariantIcon({required this.variant});

  final CinearaSurfaceVariant variant;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final icon = switch (variant) {
      CinearaSurfaceVariant.subtle => Icons.layers_outlined,
      CinearaSurfaceVariant.standard => Icons.crop_square_rounded,
      CinearaSurfaceVariant.elevated => Icons.filter_none_rounded,
      CinearaSurfaceVariant.prominent => Icons.auto_awesome_outlined,
      CinearaSurfaceVariant.artworkOverlay => Icons.image_outlined,
    };

    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.primaryContainer,
      ),
      child: Icon(icon, color: colors.onPrimaryContainer),
    );
  }
}

final class _MediaSummaryPreview extends StatelessWidget {
  const _MediaSummaryPreview();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return CinearaSurface(
      variant: CinearaSurfaceVariant.standard,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 108,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colors.primaryContainer, colors.tertiaryContainer],
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.movie_outlined,
              size: 30,
              color: colors.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Example Movie',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '2026  •  Science Fiction  •  2h 14m',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    _PreviewPill(icon: Icons.star_rounded, label: '8.4'),
                    _PreviewPill(
                      icon: Icons.bookmark_outline_rounded,
                      label: 'Watchlist',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final class _StatisticsPreview extends StatelessWidget {
  const _StatisticsPreview();

  @override
  Widget build(BuildContext context) {
    return CinearaSurface(
      variant: CinearaSurfaceVariant.prominent,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('This month', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: _Statistic(value: '18', label: 'Movies'),
              ),
              _divider(context),
              const Expanded(
                child: _Statistic(value: '42', label: 'Episodes'),
              ),
              _divider(context),
              const Expanded(
                child: _Statistic(value: '37h', label: 'Watched'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) {
    return Container(
      width: 1,
      height: 42,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}

final class _Statistic extends StatelessWidget {
  const _Statistic({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

final class _SettingsPreview extends StatelessWidget {
  const _SettingsPreview();

  @override
  Widget build(BuildContext context) {
    return CinearaSurface(
      variant: CinearaSurfaceVariant.subtle,
      child: Column(
        children: [
          const _SettingRow(
            icon: Icons.palette_outlined,
            title: 'Appearance',
            value: 'Dark',
          ),
          Divider(
            height: 1,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const _SettingRow(
            icon: Icons.view_module_outlined,
            title: 'Poster size',
            value: 'Standard',
          ),
          Divider(
            height: 1,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const _SettingRow(
            icon: Icons.visibility_outlined,
            title: 'Status indicators',
            value: 'Minimal',
          ),
        ],
      ),
    );
  }
}

final class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: colors.onSurfaceVariant),
          const SizedBox(width: 14),
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.bodyLarge),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(width: 6),
          Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
        ],
      ),
    );
  }
}

final class _ArtworkPreview extends StatelessWidget {
  const _ArtworkPreview();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [colors.primary, colors.tertiary, colors.surface],
                ),
              ),
            ),
            const Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: CinearaSurface(
                variant: CinearaSurfaceVariant.artworkOverlay,
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Continue watching',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: 4),
                          Text('Season 2 • Episode 7'),
                        ],
                      ),
                    ),
                    Icon(Icons.play_arrow_rounded, size: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _ClippingPreview extends StatelessWidget {
  const _ClippingPreview();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return CinearaSurface(
      variant: CinearaSurfaceVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.primary, colors.secondary],
              ),
            ),
            child: const Center(
              child: Icon(Icons.landscape_outlined, size: 44),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(18),
            child: Text(
              'The coloured region above should clip perfectly to the '
              'surface geometry without leaking beyond its corners.',
            ),
          ),
        ],
      ),
    );
  }
}

final class _PreviewPill extends StatelessWidget {
  const _PreviewPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: colors.onSurfaceVariant),
            const SizedBox(width: 5),
            Text(label, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}
