import 'package:flutter/material.dart';

import '../home/presentation/cards/home_shortcut_card.dart';

/// Comprehensive manual preview for [HomeShortcutCard].
///
/// This screen is designed to be used directly as the `home` of Cineara's
/// existing [MaterialApp]. It does not create another [MaterialApp] and does
/// not define or override Cineara's themes.
///
/// Example:
///
/// ```dart
/// MaterialApp(
///   theme: CinearaLightTheme.theme,
///   darkTheme: CinearaDarkTheme.theme,
///   themeMode: ThemeMode.light,
///   home: const HomeShortcutCardPreviewScreen(),
/// )
/// ```
///
/// The preview deliberately covers:
///
/// - the real device width and current app environment;
/// - one-, two- and three-column grid layouts;
/// - narrow component constraints and exact width-density breakpoints;
/// - 100% through 250% accessibility text scaling;
/// - exact 1.30x and 1.80x text-scale thresholds;
/// - LTR and RTL direction;
/// - English, Italian, German, Arabic, Hebrew, Japanese, Korean,
///   Simplified Chinese and Hindi fixture strings;
/// - long labels, long descriptions and long badges;
/// - missing descriptions and badges;
/// - interactive and informational cards;
/// - reduced motion, bold-text and high-contrast MediaQuery settings;
/// - deliberately short fixed-height grid cells.
///
/// Language examples are visual fixture strings. They intentionally do not
/// depend on Cineara's ARB files so writing systems can be stress-tested even
/// when a locale is not yet enabled in the production app.
class HomeShortcutCardPreviewScreen extends StatefulWidget {
  const HomeShortcutCardPreviewScreen({super.key});

  @override
  State<HomeShortcutCardPreviewScreen> createState() =>
      _HomeShortcutCardPreviewScreenState();
}

class _HomeShortcutCardPreviewScreenState
    extends State<HomeShortcutCardPreviewScreen> {
  _ShortcutPreviewCategory _selectedCategory = _ShortcutPreviewCategory.all;

  @override
  Widget build(BuildContext context) {
    final List<_ShortcutScenario> visibleScenarios = _shortcutScenarios
        .where(
          (_ShortcutScenario scenario) =>
              (_selectedCategory == _ShortcutPreviewCategory.all &&
                  scenario.category != _ShortcutPreviewCategory.realDevice) ||
              scenario.category == _selectedCategory,
        )
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: const Text('HomeShortcutCard Preview')),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _PreviewFilterBar(
              selectedCategory: _selectedCategory,
              onCategoryChanged: (_ShortcutPreviewCategory category) {
                setState(() {
                  _selectedCategory = category;
                });
              },
            ),
            const _InheritedEnvironmentBanner(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                children: <Widget>[
                  if (_selectedCategory == _ShortcutPreviewCategory.all ||
                      _selectedCategory ==
                          _ShortcutPreviewCategory.realDevice) ...<Widget>[
                    const _SectionHeading(
                      category: _ShortcutPreviewCategory.realDevice,
                    ),
                    const SizedBox(height: 12),
                    const _RealDeviceShortcutSection(),
                    if (visibleScenarios.isNotEmpty) const SizedBox(height: 28),
                  ],

                  for (
                    int index = 0;
                    index < visibleScenarios.length;
                    index++
                  ) ...<Widget>[
                    if (index == 0 ||
                        visibleScenarios[index - 1].category !=
                            visibleScenarios[index].category) ...<Widget>[
                      _SectionHeading(
                        category: visibleScenarios[index].category,
                      ),
                      const SizedBox(height: 12),
                    ],
                    _ScenarioPreview(
                      key: ValueKey<String>(visibleScenarios[index].id),
                      scenario: visibleScenarios[index],
                    ),
                    if (index != visibleScenarios.length - 1)
                      const SizedBox(height: 20),
                    if (index != visibleScenarios.length - 1 &&
                        visibleScenarios[index + 1].category !=
                            visibleScenarios[index].category)
                      const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InheritedEnvironmentBanner extends StatelessWidget {
  const _InheritedEnvironmentBanner();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final Locale locale = Localizations.localeOf(context);
    final TextDirection direction = Directionality.of(context);

    final double textScale = mediaQuery.textScaler.scale(16) / 16;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Inherited from Cineara: '
              '${theme.brightness.name} theme · '
              '${locale.toLanguageTag()} · '
              '${direction == TextDirection.rtl ? 'RTL' : 'LTR'} · '
              '${textScale.toStringAsFixed(2)}× system text. '
              'Synthetic scenarios override only the values needed for '
              'that specific test.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewFilterBar extends StatelessWidget {
  const _PreviewFilterBar({
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  final _ShortcutPreviewCategory selectedCategory;
  final ValueChanged<_ShortcutPreviewCategory> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: <Widget>[
            for (final _ShortcutPreviewCategory category
                in _ShortcutPreviewCategory.values) ...<Widget>[
              ChoiceChip(
                selected: selectedCategory == category,
                label: Text(category.label),
                onSelected: (_) => onCategoryChanged(category),
              ),
              if (category != _ShortcutPreviewCategory.values.last)
                const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.category});

  final _ShortcutPreviewCategory category;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Row(
      children: <Widget>[
        Icon(category.icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            category.sectionTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _RealDeviceShortcutSection extends StatelessWidget {
  const _RealDeviceShortcutSection();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final Locale locale = Localizations.localeOf(context);
    final TextDirection direction = Directionality.of(context);

    final _ShortcutCopy copy = _copyForLocale(locale);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double availableWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : mediaQuery.size.width;

        final double textScale = mediaQuery.textScaler.scale(16) / 16;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _DeviceMeasurements(
              screenSize: mediaQuery.size,
              devicePixelRatio: mediaQuery.devicePixelRatio,
              availableWidth: availableWidth,
              textScale: textScale,
              locale: locale,
              direction: direction,
              padding: mediaQuery.padding,
            ),
            const SizedBox(height: 16),

            _RealDeviceGridPreview(
              title: 'Actual environment · 2 columns',
              description:
                  'Uses this device\'s real available width, current app '
                  'locale/direction and current system text scale.',
              copy: copy,
              crossAxisCount: 2,
            ),
            const SizedBox(height: 16),

            _RealDeviceGridPreview(
              title: 'Same device · 3 columns',
              description:
                  'Useful for checking whether three shortcuts become too '
                  'narrow on the current phone.',
              copy: copy,
              crossAxisCount: 3,
            ),
            const SizedBox(height: 16),

            _RealDeviceGridPreview(
              title: 'Same device · 130% text · 2 columns',
              description:
                  'Tests the first accessibility threshold on the real '
                  'available device width.',
              copy: copy,
              crossAxisCount: 2,
              textScaleOverride: 1.30,
            ),
            const SizedBox(height: 16),

            _RealDeviceGridPreview(
              title: 'Same device · 180% text · 2 columns',
              description:
                  'Tests very large text while keeping the usual two-column '
                  'Home shortcut arrangement.',
              copy: copy,
              crossAxisCount: 2,
              textScaleOverride: 1.80,
            ),
            const SizedBox(height: 16),

            _RealDeviceGridPreview(
              title: 'Same device · 200% text · 1 column',
              description:
                  'Recommended large-text fallback: full-width shortcuts '
                  'with enough vertical space.',
              copy: copy,
              crossAxisCount: 1,
              textScaleOverride: 2.00,
            ),
            const SizedBox(height: 16),

            _RealDeviceGridPreview(
              title: 'Same device · 200% text · 2 columns stress test',
              description:
                  'Intentional stress test. If this becomes cramped, the '
                  'Home grid should fall back to one column at this scale.',
              copy: copy,
              crossAxisCount: 2,
              textScaleOverride: 2.00,
            ),

            const SizedBox(height: 12),
            Text(
              'The component can hide secondary descriptions when necessary, '
              'but the parent Home grid still owns column count and cell '
              'height. If a 200% two-column case looks cramped, that is a '
              'signal to change the grid layout rather than shrink text.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DeviceMeasurements extends StatelessWidget {
  const _DeviceMeasurements({
    required this.screenSize,
    required this.devicePixelRatio,
    required this.availableWidth,
    required this.textScale,
    required this.locale,
    required this.direction,
    required this.padding,
  });

  final Size screenSize;
  final double devicePixelRatio;
  final double availableWidth;
  final double textScale;
  final Locale locale;
  final TextDirection direction;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final int physicalWidth = (screenSize.width * devicePixelRatio).round();
    final int physicalHeight = (screenSize.height * devicePixelRatio).round();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Measured on this device',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: <Widget>[
              _MetadataChip(
                label:
                    'Screen ${screenSize.width.toStringAsFixed(1)} × '
                    '${screenSize.height.toStringAsFixed(1)} logical px',
              ),
              _MetadataChip(
                label: 'Preview width ${availableWidth.toStringAsFixed(1)} px',
              ),
              _MetadataChip(
                label: 'Physical $physicalWidth × $physicalHeight px',
              ),
              _MetadataChip(
                label: 'DPR ${devicePixelRatio.toStringAsFixed(2)}',
              ),
              _MetadataChip(label: '${textScale.toStringAsFixed(2)}× text'),
              _MetadataChip(label: locale.toLanguageTag()),
              _MetadataChip(
                label: direction == TextDirection.rtl ? 'RTL' : 'LTR',
              ),
              _MetadataChip(
                label:
                    'Safe top ${padding.top.toStringAsFixed(0)} · '
                    'bottom ${padding.bottom.toStringAsFixed(0)}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RealDeviceGridPreview extends StatelessWidget {
  const _RealDeviceGridPreview({
    required this.title,
    required this.description,
    required this.copy,
    required this.crossAxisCount,
    this.textScaleOverride,
  });

  final String title;
  final String description;
  final _ShortcutCopy copy;
  final int crossAxisCount;
  final double? textScaleOverride;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MediaQueryData inheritedMediaQuery = MediaQuery.of(context);

    final MediaQueryData scenarioMediaQuery = textScaleOverride == null
        ? inheritedMediaQuery
        : inheritedMediaQuery.copyWith(
            textScaler: TextScaler.linear(textScaleOverride!),
          );

    final double effectiveScale = scenarioMediaQuery.textScaler.scale(16) / 16;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: <Widget>[
            _MetadataChip(
              label:
                  '$crossAxisCount column'
                  '${crossAxisCount == 1 ? '' : 's'}',
            ),
            _MetadataChip(label: '${effectiveScale.toStringAsFixed(2)}× text'),
            const _MetadataChip(label: 'Real available width'),
          ],
        ),
        const SizedBox(height: 10),
        MediaQuery(
          data: scenarioMediaQuery,
          child: _ShortcutGrid(
            copy: copy,
            crossAxisCount: crossAxisCount,
            mainAxisExtent: _recommendedExtent(
              crossAxisCount: crossAxisCount,
              textScale: effectiveScale,
            ),
          ),
        ),
      ],
    );
  }
}

class _ScenarioPreview extends StatelessWidget {
  const _ScenarioPreview({required this.scenario, super.key});

  final _ShortcutScenario scenario;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MediaQueryData baseMediaQuery = MediaQuery.of(context);

    final _ShortcutCopy copy =
        scenario.copyOverride ?? _copyForLanguage(scenario.language);

    final MediaQueryData scenarioMediaQuery = baseMediaQuery.copyWith(
      textScaler: TextScaler.linear(scenario.textScale),
      boldText: scenario.boldText,
      highContrast: scenario.highContrast,
      disableAnimations: scenario.disableAnimations,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _ScenarioHeader(scenario: scenario),
            const SizedBox(height: 12),

            Directionality(
              textDirection: scenario.textDirection,
              child: MediaQuery(
                data: scenarioMediaQuery,
                child: switch (scenario.presentation) {
                  _ShortcutPresentation.single => Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: SizedBox(
                      width: scenario.cardWidth,
                      height: scenario.fixedHeight,
                      child: _buildSingleCard(copy: copy, scenario: scenario),
                    ),
                  ),

                  _ShortcutPresentation.grid => SizedBox(
                    width: scenario.cardWidth,
                    child: _ShortcutGrid(
                      copy: copy,
                      crossAxisCount: scenario.crossAxisCount,
                      mainAxisExtent:
                          scenario.fixedHeight ??
                          _recommendedExtent(
                            crossAxisCount: scenario.crossAxisCount,
                            textScale: scenario.textScale,
                          ),
                      useStressContent: scenario.useStressContent,
                      interactive: scenario.interactive,
                    ),
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleCard({
    required _ShortcutCopy copy,
    required _ShortcutScenario scenario,
  }) {
    final _ShortcutItem item = scenario.useStressContent
        ? _stressShortcutItems.first
        : copy.items.first;

    return HomeShortcutCard(
      icon: item.icon,
      label: item.label,
      description: scenario.hideDescription ? null : item.description,
      badgeLabel: scenario.hideBadge ? null : item.badgeLabel,
      semanticLabel: item.semanticLabel,
      enableHaptics: false,
      onTap: scenario.interactive ? () {} : null,
    );
  }
}

class _ScenarioHeader extends StatelessWidget {
  const _ScenarioHeader({required this.scenario});

  final _ShortcutScenario scenario;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final List<String> metadata = <String>[
      '${scenario.cardWidth.toStringAsFixed(0)} px',
      '${scenario.textScale.toStringAsFixed(2)}× text',
      scenario.textDirection == TextDirection.rtl ? 'RTL' : 'LTR',
      scenario.language.label,
      if (scenario.presentation == _ShortcutPresentation.grid)
        '${scenario.crossAxisCount} columns',
      if (scenario.fixedHeight case final double height)
        '${height.toStringAsFixed(0)} px height',
      if (scenario.boldText) 'Bold text',
      if (scenario.highContrast) 'High contrast',
      if (scenario.disableAnimations) 'Reduced motion',
      if (!scenario.interactive) 'Non-interactive',
      if (scenario.hideDescription) 'No description',
      if (scenario.hideBadge) 'No badge',
      if (scenario.useStressContent) 'Stress copy',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          scenario.name,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          scenario.description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: <Widget>[
            for (final String value in metadata) _MetadataChip(label: value),
          ],
        ),
      ],
    );
  }
}

class _MetadataChip extends StatelessWidget {
  const _MetadataChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(label, style: theme.textTheme.labelSmall),
      ),
    );
  }
}

class _ShortcutGrid extends StatelessWidget {
  const _ShortcutGrid({
    required this.copy,
    required this.crossAxisCount,
    required this.mainAxisExtent,
    this.useStressContent = false,
    this.interactive = true,
  });

  final _ShortcutCopy copy;
  final int crossAxisCount;
  final double mainAxisExtent;
  final bool useStressContent;
  final bool interactive;

  @override
  Widget build(BuildContext context) {
    final List<_ShortcutItem> items = useStressContent
        ? _stressShortcutItems
        : copy.items;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: mainAxisExtent,
      ),
      itemBuilder: (BuildContext context, int index) {
        final _ShortcutItem item = items[index];

        return HomeShortcutCard(
          icon: item.icon,
          label: item.label,
          description: item.description,
          badgeLabel: item.badgeLabel,
          semanticLabel: item.semanticLabel,
          enableHaptics: false,
          onTap: interactive ? () {} : null,
        );
      },
    );
  }
}

double _recommendedExtent({
  required int crossAxisCount,
  required double textScale,
}) {
  // These are preview/test cell heights, not component constants.
  // Production Home should use the same idea: larger text receives more
  // vertical space and can reduce the column count when necessary.
  if (textScale >= 2.0) {
    return crossAxisCount == 1 ? 260 : 235;
  }

  if (textScale >= 1.8) {
    return crossAxisCount == 1 ? 240 : 225;
  }

  if (textScale >= 1.3) {
    if (crossAxisCount >= 3) {
      return 195;
    }

    return crossAxisCount == 1 ? 215 : 220;
  }

  return crossAxisCount >= 3 ? 170 : 185;
}

enum _ShortcutPreviewCategory {
  all,
  realDevice,
  layout,
  grid,
  textScale,
  languages,
  direction,
  content,
  accessibility;

  String get label => switch (this) {
    _ShortcutPreviewCategory.all => 'All',
    _ShortcutPreviewCategory.realDevice => 'Device',
    _ShortcutPreviewCategory.layout => 'Width',
    _ShortcutPreviewCategory.grid => 'Grid',
    _ShortcutPreviewCategory.textScale => 'Text scale',
    _ShortcutPreviewCategory.languages => 'Languages',
    _ShortcutPreviewCategory.direction => 'Direction',
    _ShortcutPreviewCategory.content => 'Content',
    _ShortcutPreviewCategory.accessibility => 'Accessibility',
  };

  String get sectionTitle => switch (this) {
    _ShortcutPreviewCategory.all => 'All scenarios',
    _ShortcutPreviewCategory.realDevice => 'Real device',
    _ShortcutPreviewCategory.layout => 'Synthetic card-width breakpoints',
    _ShortcutPreviewCategory.grid => 'One-, two- and three-column Home layouts',
    _ShortcutPreviewCategory.textScale => 'Accessibility text scaling',
    _ShortcutPreviewCategory.languages => 'Languages and writing systems',
    _ShortcutPreviewCategory.direction => 'Text-direction stress tests',
    _ShortcutPreviewCategory.content => 'Content and interaction edge cases',
    _ShortcutPreviewCategory.accessibility => 'Other accessibility settings',
  };

  IconData get icon => switch (this) {
    _ShortcutPreviewCategory.all => Icons.dashboard_customize_rounded,
    _ShortcutPreviewCategory.realDevice => Icons.smartphone_rounded,
    _ShortcutPreviewCategory.layout => Icons.aspect_ratio_rounded,
    _ShortcutPreviewCategory.grid => Icons.grid_view_rounded,
    _ShortcutPreviewCategory.textScale => Icons.text_fields_rounded,
    _ShortcutPreviewCategory.languages => Icons.translate_rounded,
    _ShortcutPreviewCategory.direction => Icons.swap_horiz_rounded,
    _ShortcutPreviewCategory.content => Icons.tune_rounded,
    _ShortcutPreviewCategory.accessibility => Icons.accessibility_new_rounded,
  };
}

enum _ShortcutPresentation { single, grid }

enum _ShortcutLanguage {
  english,
  italian,
  german,
  arabic,
  hebrew,
  japanese,
  korean,
  chinese,
  hindi;

  String get label => switch (this) {
    _ShortcutLanguage.english => 'English',
    _ShortcutLanguage.italian => 'Italiano',
    _ShortcutLanguage.german => 'Deutsch',
    _ShortcutLanguage.arabic => 'العربية',
    _ShortcutLanguage.hebrew => 'עברית',
    _ShortcutLanguage.japanese => '日本語',
    _ShortcutLanguage.korean => '한국어',
    _ShortcutLanguage.chinese => '中文',
    _ShortcutLanguage.hindi => 'हिन्दी',
  };
}

@immutable
class _ShortcutScenario {
  const _ShortcutScenario({
    required this.id,
    required this.category,
    required this.name,
    required this.description,
    required this.cardWidth,
    required this.textScale,
    required this.language,
    required this.textDirection,
    this.presentation = _ShortcutPresentation.single,
    this.crossAxisCount = 2,
    this.fixedHeight,
    this.boldText = false,
    this.highContrast = false,
    this.disableAnimations = false,
    this.interactive = true,
    this.hideDescription = false,
    this.hideBadge = false,
    this.useStressContent = false,
    this.copyOverride,
  });

  final String id;
  final _ShortcutPreviewCategory category;
  final String name;
  final String description;
  final double cardWidth;
  final double textScale;
  final _ShortcutLanguage language;
  final TextDirection textDirection;
  final _ShortcutPresentation presentation;
  final int crossAxisCount;
  final double? fixedHeight;
  final bool boldText;
  final bool highContrast;
  final bool disableAnimations;
  final bool interactive;
  final bool hideDescription;
  final bool hideBadge;
  final bool useStressContent;
  final _ShortcutCopy? copyOverride;
}

@immutable
class _ShortcutCopy {
  const _ShortcutCopy({required this.items});

  final List<_ShortcutItem> items;
}

@immutable
class _ShortcutItem {
  const _ShortcutItem({
    required this.icon,
    required this.label,
    this.description,
    this.badgeLabel,
    this.semanticLabel,
  });

  final IconData icon;
  final String label;
  final String? description;
  final String? badgeLabel;
  final String? semanticLabel;
}

_ShortcutCopy _copyForLanguage(_ShortcutLanguage language) {
  return switch (language) {
    _ShortcutLanguage.english => _englishCopy,
    _ShortcutLanguage.italian => _italianCopy,
    _ShortcutLanguage.german => _germanCopy,
    _ShortcutLanguage.arabic => _arabicCopy,
    _ShortcutLanguage.hebrew => _hebrewCopy,
    _ShortcutLanguage.japanese => _japaneseCopy,
    _ShortcutLanguage.korean => _koreanCopy,
    _ShortcutLanguage.chinese => _chineseCopy,
    _ShortcutLanguage.hindi => _hindiCopy,
  };
}

_ShortcutCopy _copyForLocale(Locale locale) {
  return switch (locale.languageCode) {
    'it' => _italianCopy,
    'de' => _germanCopy,
    'ar' => _arabicCopy,
    'he' => _hebrewCopy,
    'ja' => _japaneseCopy,
    'ko' => _koreanCopy,
    'zh' => _chineseCopy,
    'hi' => _hindiCopy,
    _ => _englishCopy,
  };
}

const _ShortcutCopy _englishCopy = _ShortcutCopy(
  items: <_ShortcutItem>[
    _ShortcutItem(
      icon: Icons.shuffle_rounded,
      label: 'Random Picker',
      description: 'Let Cineara choose something for tonight',
      badgeLabel: 'NEW',
    ),
    _ShortcutItem(
      icon: Icons.calendar_month_rounded,
      label: 'Calendar',
      description: 'Upcoming releases and your watch schedule',
      badgeLabel: '3',
    ),
    _ShortcutItem(
      icon: Icons.public_rounded,
      label: 'Cinema Passport',
      description: 'Explore your journey through world cinema',
    ),
    _ShortcutItem(
      icon: Icons.emoji_events_rounded,
      label: 'Achievements',
      description: 'See badges, ranks and milestones',
      badgeLabel: '12',
    ),
    _ShortcutItem(
      icon: Icons.video_library_rounded,
      label: 'Collections',
      description: 'Open your saved custom collections',
    ),
    _ShortcutItem(
      icon: Icons.travel_explore_rounded,
      label: 'Spin the Globe',
      description: 'Discover something from another country',
      badgeLabel: 'NEW',
    ),
  ],
);

const _ShortcutCopy _italianCopy = _ShortcutCopy(
  items: <_ShortcutItem>[
    _ShortcutItem(
      icon: Icons.shuffle_rounded,
      label: 'Scelta casuale',
      description: 'Lascia che Cineara scelga qualcosa per stasera',
      badgeLabel: 'NUOVO',
    ),
    _ShortcutItem(
      icon: Icons.calendar_month_rounded,
      label: 'Calendario',
      description: 'Prossime uscite e programmi di visione',
      badgeLabel: '3',
    ),
    _ShortcutItem(
      icon: Icons.public_rounded,
      label: 'Passaporto cinematografico',
      description: 'Esplora il tuo viaggio nel cinema mondiale',
    ),
    _ShortcutItem(
      icon: Icons.emoji_events_rounded,
      label: 'Traguardi',
      description: 'Scopri distintivi, livelli e progressi',
      badgeLabel: '12',
    ),
    _ShortcutItem(
      icon: Icons.video_library_rounded,
      label: 'Collezioni',
      description: 'Apri le tue collezioni personalizzate',
    ),
    _ShortcutItem(
      icon: Icons.travel_explore_rounded,
      label: 'Gira il mondo',
      description: 'Scopri qualcosa proveniente da un altro paese',
      badgeLabel: 'NUOVO',
    ),
  ],
);

const _ShortcutCopy _germanCopy = _ShortcutCopy(
  items: <_ShortcutItem>[
    _ShortcutItem(
      icon: Icons.shuffle_rounded,
      label: 'Zufällige Auswahl',
      description: 'Lass Cineara etwas für heute Abend auswählen',
      badgeLabel: 'NEU',
    ),
    _ShortcutItem(
      icon: Icons.calendar_month_rounded,
      label: 'Veröffentlichungskalender',
      description: 'Kommende Veröffentlichungen und dein Sehplan',
      badgeLabel: '3',
    ),
    _ShortcutItem(
      icon: Icons.public_rounded,
      label: 'Internationaler Kinopass',
      description: 'Entdecke deine Reise durch das weltweite Kino',
    ),
    _ShortcutItem(
      icon: Icons.emoji_events_rounded,
      label: 'Errungenschaften',
      description: 'Sieh Abzeichen, Ränge und erreichte Meilensteine',
      badgeLabel: '12',
    ),
    _ShortcutItem(
      icon: Icons.video_library_rounded,
      label: 'Eigene Sammlungen',
      description: 'Öffne deine gespeicherten Filmsammlungen',
    ),
    _ShortcutItem(
      icon: Icons.travel_explore_rounded,
      label: 'Dreh den Globus',
      description: 'Entdecke etwas aus einem anderen Produktionsland',
      badgeLabel: 'NEU',
    ),
  ],
);

const _ShortcutCopy _arabicCopy = _ShortcutCopy(
  items: <_ShortcutItem>[
    _ShortcutItem(
      icon: Icons.shuffle_rounded,
      label: 'اختيار عشوائي',
      description: 'دع سينيارا تختار لك شيئًا لمشاهدته الليلة',
      badgeLabel: 'جديد',
    ),
    _ShortcutItem(
      icon: Icons.calendar_month_rounded,
      label: 'التقويم',
      description: 'الإصدارات القادمة وجدول المشاهدة الخاص بك',
      badgeLabel: '٣',
    ),
    _ShortcutItem(
      icon: Icons.public_rounded,
      label: 'جواز السينما',
      description: 'استكشف رحلتك عبر السينما العالمية',
    ),
    _ShortcutItem(
      icon: Icons.emoji_events_rounded,
      label: 'الإنجازات',
      description: 'شاهد الشارات والرتب والمحطات التي حققتها',
      badgeLabel: '١٢',
    ),
    _ShortcutItem(
      icon: Icons.video_library_rounded,
      label: 'المجموعات',
      description: 'افتح مجموعاتك المخصصة المحفوظة',
    ),
    _ShortcutItem(
      icon: Icons.travel_explore_rounded,
      label: 'أدر الكرة الأرضية',
      description: 'اكتشف عملًا من بلد آخر',
      badgeLabel: 'جديد',
    ),
  ],
);

const _ShortcutCopy _hebrewCopy = _ShortcutCopy(
  items: <_ShortcutItem>[
    _ShortcutItem(
      icon: Icons.shuffle_rounded,
      label: 'בחירה אקראית',
      description: 'תנו ל-Cineara לבחור משהו לצפייה הערב',
      badgeLabel: 'חדש',
    ),
    _ShortcutItem(
      icon: Icons.calendar_month_rounded,
      label: 'לוח שנה',
      description: 'יציאות קרובות ותוכנית הצפייה שלך',
      badgeLabel: '3',
    ),
    _ShortcutItem(
      icon: Icons.public_rounded,
      label: 'דרכון קולנוע',
      description: 'גלו את המסע שלכם בקולנוע העולמי',
    ),
    _ShortcutItem(
      icon: Icons.emoji_events_rounded,
      label: 'הישגים',
      description: 'צפו בתגים, דרגות ואבני דרך',
      badgeLabel: '12',
    ),
    _ShortcutItem(
      icon: Icons.video_library_rounded,
      label: 'אוספים',
      description: 'פתחו את האוספים המותאמים ששמרתם',
    ),
    _ShortcutItem(
      icon: Icons.travel_explore_rounded,
      label: 'סובבו את הגלובוס',
      description: 'גלו משהו ממדינה אחרת',
      badgeLabel: 'חדש',
    ),
  ],
);

const _ShortcutCopy _japaneseCopy = _ShortcutCopy(
  items: <_ShortcutItem>[
    _ShortcutItem(
      icon: Icons.shuffle_rounded,
      label: 'ランダムピッカー',
      description: '今夜観る作品をCinearaに選んでもらう',
      badgeLabel: '新着',
    ),
    _ShortcutItem(
      icon: Icons.calendar_month_rounded,
      label: 'カレンダー',
      description: '今後の公開作品と視聴予定を確認',
      badgeLabel: '3',
    ),
    _ShortcutItem(
      icon: Icons.public_rounded,
      label: 'シネマパスポート',
      description: '世界の映画を巡るあなたの旅を振り返る',
    ),
    _ShortcutItem(
      icon: Icons.emoji_events_rounded,
      label: '実績',
      description: 'バッジ、ランク、マイルストーンを確認',
      badgeLabel: '12',
    ),
    _ShortcutItem(
      icon: Icons.video_library_rounded,
      label: 'コレクション',
      description: '保存したカスタムコレクションを開く',
    ),
    _ShortcutItem(
      icon: Icons.travel_explore_rounded,
      label: '地球を回す',
      description: '別の国から新しい作品を発見',
      badgeLabel: '新着',
    ),
  ],
);

const _ShortcutCopy _koreanCopy = _ShortcutCopy(
  items: <_ShortcutItem>[
    _ShortcutItem(
      icon: Icons.shuffle_rounded,
      label: '랜덤 선택',
      description: '오늘 밤 볼 작품을 Cineara가 골라줍니다',
      badgeLabel: '신규',
    ),
    _ShortcutItem(
      icon: Icons.calendar_month_rounded,
      label: '캘린더',
      description: '개봉 예정작과 나의 시청 일정을 확인합니다',
      badgeLabel: '3',
    ),
    _ShortcutItem(
      icon: Icons.public_rounded,
      label: '시네마 패스포트',
      description: '세계 영화를 따라온 나의 여정을 살펴봅니다',
    ),
    _ShortcutItem(
      icon: Icons.emoji_events_rounded,
      label: '업적',
      description: '배지, 랭크와 달성 기록을 확인합니다',
      badgeLabel: '12',
    ),
    _ShortcutItem(
      icon: Icons.video_library_rounded,
      label: '컬렉션',
      description: '저장한 사용자 컬렉션을 엽니다',
    ),
    _ShortcutItem(
      icon: Icons.travel_explore_rounded,
      label: '지구본 돌리기',
      description: '다른 나라에서 새로운 작품을 발견합니다',
      badgeLabel: '신규',
    ),
  ],
);

const _ShortcutCopy _chineseCopy = _ShortcutCopy(
  items: <_ShortcutItem>[
    _ShortcutItem(
      icon: Icons.shuffle_rounded,
      label: '随机选择',
      description: '让 Cineara 为今晚挑选一部作品',
      badgeLabel: '新',
    ),
    _ShortcutItem(
      icon: Icons.calendar_month_rounded,
      label: '日历',
      description: '查看即将上线的作品和你的观看计划',
      badgeLabel: '3',
    ),
    _ShortcutItem(
      icon: Icons.public_rounded,
      label: '电影护照',
      description: '回顾你探索世界电影的旅程',
    ),
    _ShortcutItem(
      icon: Icons.emoji_events_rounded,
      label: '成就',
      description: '查看徽章、等级和里程碑',
      badgeLabel: '12',
    ),
    _ShortcutItem(
      icon: Icons.video_library_rounded,
      label: '收藏集',
      description: '打开你保存的自定义收藏集',
    ),
    _ShortcutItem(
      icon: Icons.travel_explore_rounded,
      label: '转动地球',
      description: '发现来自另一个国家的作品',
      badgeLabel: '新',
    ),
  ],
);

const _ShortcutCopy _hindiCopy = _ShortcutCopy(
  items: <_ShortcutItem>[
    _ShortcutItem(
      icon: Icons.shuffle_rounded,
      label: 'यादृच्छिक चयन',
      description: 'आज रात क्या देखें, Cineara को चुनने दें',
      badgeLabel: 'नया',
    ),
    _ShortcutItem(
      icon: Icons.calendar_month_rounded,
      label: 'कैलेंडर',
      description: 'आने वाली रिलीज़ और अपना देखने का कार्यक्रम देखें',
      badgeLabel: '३',
    ),
    _ShortcutItem(
      icon: Icons.public_rounded,
      label: 'सिनेमा पासपोर्ट',
      description: 'विश्व सिनेमा की अपनी यात्रा को देखें',
    ),
    _ShortcutItem(
      icon: Icons.emoji_events_rounded,
      label: 'उपलब्धियाँ',
      description: 'बैज, रैंक और हासिल किए गए पड़ाव देखें',
      badgeLabel: '१२',
    ),
    _ShortcutItem(
      icon: Icons.video_library_rounded,
      label: 'संग्रह',
      description: 'अपने सहेजे हुए कस्टम संग्रह खोलें',
    ),
    _ShortcutItem(
      icon: Icons.travel_explore_rounded,
      label: 'ग्लोब घुमाएँ',
      description: 'किसी दूसरे देश की नई रचना खोजें',
      badgeLabel: 'नया',
    ),
  ],
);

const List<_ShortcutItem> _stressShortcutItems = <_ShortcutItem>[
  _ShortcutItem(
    icon: Icons.shuffle_rounded,
    label: 'An intentionally very long shortcut title that should wrap safely',
    description:
        'This description is deliberately verbose so the preview can verify '
        'wrapping, height allocation and the rule that secondary text '
        'disappears before the primary shortcut name.',
    badgeLabel: 'VERY LONG BADGE',
  ),
  _ShortcutItem(
    icon: Icons.calendar_month_rounded,
    label: 'A long label with no description below it',
    badgeLabel: '123456',
  ),
  _ShortcutItem(
    icon: Icons.public_rounded,
    label: 'No badge on this shortcut',
    description:
        'The icon row should remain correctly aligned even without a badge.',
  ),
  _ShortcutItem(
    icon: Icons.emoji_events_rounded,
    label: 'Short',
    description: 'Short description',
    badgeLabel: '1',
  ),
  _ShortcutItem(
    icon: Icons.video_library_rounded,
    label: 'Another translated-style title with several words',
    description: 'Secondary information used to exercise a later grid row.',
    badgeLabel: 'NEW',
  ),
  _ShortcutItem(
    icon: Icons.travel_explore_rounded,
    label: 'Final stress shortcut',
    description: 'Checks final-row sizing, alignment and interaction behavior.',
  ),
];

const List<_ShortcutScenario> _shortcutScenarios = <_ShortcutScenario>[
  //
  // SYNTHETIC WIDTHS
  //
  _ShortcutScenario(
    id: 'width-104',
    category: _ShortcutPreviewCategory.layout,
    name: '104 px card constraint',
    description:
        'Very narrow card. The description should disappear and the primary '
        'label remains the priority.',
    cardWidth: 104,
    fixedHeight: 160,
    textScale: 1.0,
    language: _ShortcutLanguage.english,
    textDirection: TextDirection.ltr,
  ),
  _ShortcutScenario(
    id: 'width-119',
    category: _ShortcutPreviewCategory.layout,
    name: '119 px — just below compact breakpoint',
    description:
        'Regression test immediately below the 120 px shortcut-density '
        'breakpoint.',
    cardWidth: 119,
    fixedHeight: 160,
    textScale: 1.0,
    language: _ShortcutLanguage.english,
    textDirection: TextDirection.ltr,
  ),
  _ShortcutScenario(
    id: 'width-120',
    category: _ShortcutPreviewCategory.layout,
    name: '120 px — exact compact/regular breakpoint',
    description:
        'Checks the exact width where the component leaves compact density.',
    cardWidth: 120,
    fixedHeight: 165,
    textScale: 1.0,
    language: _ShortcutLanguage.english,
    textDirection: TextDirection.ltr,
  ),
  _ShortcutScenario(
    id: 'width-160',
    category: _ShortcutPreviewCategory.layout,
    name: '160 px typical two-column card',
    description: 'Representative shortcut width on a compact phone Home grid.',
    cardWidth: 160,
    fixedHeight: 170,
    textScale: 1.0,
    language: _ShortcutLanguage.english,
    textDirection: TextDirection.ltr,
  ),
  _ShortcutScenario(
    id: 'width-179',
    category: _ShortcutPreviewCategory.layout,
    name: '179 px — just below spacious breakpoint',
    description:
        'Regression test immediately below the 180 px density breakpoint.',
    cardWidth: 179,
    fixedHeight: 170,
    textScale: 1.0,
    language: _ShortcutLanguage.english,
    textDirection: TextDirection.ltr,
  ),
  _ShortcutScenario(
    id: 'width-180',
    category: _ShortcutPreviewCategory.layout,
    name: '180 px — exact spacious breakpoint',
    description:
        'Checks icon and padding changes at the regular/spacious boundary.',
    cardWidth: 180,
    fixedHeight: 175,
    textScale: 1.0,
    language: _ShortcutLanguage.english,
    textDirection: TextDirection.ltr,
  ),
  _ShortcutScenario(
    id: 'width-240',
    category: _ShortcutPreviewCategory.layout,
    name: '240 px wide shortcut',
    description:
        'Wide component constraint where description and badge have generous '
        'space.',
    cardWidth: 240,
    fixedHeight: 180,
    textScale: 1.0,
    language: _ShortcutLanguage.english,
    textDirection: TextDirection.ltr,
  ),

  //
  // GRID LAYOUTS
  //
  _ShortcutScenario(
    id: 'grid-1',
    category: _ShortcutPreviewCategory.grid,
    name: '1-column grid',
    description:
        'Full-width shortcuts. This is the safest large-text fallback.',
    cardWidth: 380,
    textScale: 1.0,
    language: _ShortcutLanguage.english,
    textDirection: TextDirection.ltr,
    presentation: _ShortcutPresentation.grid,
    crossAxisCount: 1,
  ),
  _ShortcutScenario(
    id: 'grid-2',
    category: _ShortcutPreviewCategory.grid,
    name: '2-column grid',
    description: 'Expected default Home arrangement on many phones.',
    cardWidth: 380,
    textScale: 1.0,
    language: _ShortcutLanguage.english,
    textDirection: TextDirection.ltr,
    presentation: _ShortcutPresentation.grid,
    crossAxisCount: 2,
  ),
  _ShortcutScenario(
    id: 'grid-3',
    category: _ShortcutPreviewCategory.grid,
    name: '3-column grid',
    description:
        'Checks the compact-density version and whether descriptions hide '
        'appropriately.',
    cardWidth: 380,
    textScale: 1.0,
    language: _ShortcutLanguage.english,
    textDirection: TextDirection.ltr,
    presentation: _ShortcutPresentation.grid,
    crossAxisCount: 3,
  ),
  _ShortcutScenario(
    id: 'grid-2-180',
    category: _ShortcutPreviewCategory.grid,
    name: '2 columns at 180%',
    description: 'Intentional accessibility stress case for the parent grid.',
    cardWidth: 380,
    textScale: 1.8,
    language: _ShortcutLanguage.italian,
    textDirection: TextDirection.ltr,
    presentation: _ShortcutPresentation.grid,
    crossAxisCount: 2,
  ),
  _ShortcutScenario(
    id: 'grid-1-200',
    category: _ShortcutPreviewCategory.grid,
    name: '1 column at 200%',
    description: 'Recommended very-large-text layout with full-width cards.',
    cardWidth: 380,
    textScale: 2.0,
    language: _ShortcutLanguage.english,
    textDirection: TextDirection.ltr,
    presentation: _ShortcutPresentation.grid,
    crossAxisCount: 1,
  ),
  _ShortcutScenario(
    id: 'grid-short-cell',
    category: _ShortcutPreviewCategory.grid,
    name: 'Deliberately short cells · defensive stress test',
    description:
        'Tests the component when the parent gives it only 135 px of height. '
        'It must not RenderFlex-overflow; descriptions should be sacrificed '
        'before primary labels.',
    cardWidth: 380,
    fixedHeight: 135,
    textScale: 1.3,
    language: _ShortcutLanguage.english,
    textDirection: TextDirection.ltr,
    presentation: _ShortcutPresentation.grid,
    crossAxisCount: 2,
  ),

  //
  // TEXT SCALE
  //
  _ShortcutScenario(
    id: 'scale-100',
    category: _ShortcutPreviewCategory.textScale,
    name: '100% text',
    description: 'Baseline shortcut at standard accessibility scale.',
    cardWidth: 170,
    fixedHeight: 170,
    textScale: 1.0,
    language: _ShortcutLanguage.english,
    textDirection: TextDirection.ltr,
  ),
  _ShortcutScenario(
    id: 'scale-129',
    category: _ShortcutPreviewCategory.textScale,
    name: '129% — just below first threshold',
    description: 'Should still use the normal text behavior.',
    cardWidth: 170,
    fixedHeight: 180,
    textScale: 1.29,
    language: _ShortcutLanguage.english,
    textDirection: TextDirection.ltr,
  ),
  _ShortcutScenario(
    id: 'scale-130',
    category: _ShortcutPreviewCategory.textScale,
    name: '130% — exact first threshold',
    description:
        'Primary label can use more lines and the card reserves more vertical '
        'room for localized text.',
    cardWidth: 170,
    fixedHeight: 190,
    textScale: 1.30,
    language: _ShortcutLanguage.english,
    textDirection: TextDirection.ltr,
  ),
  _ShortcutScenario(
    id: 'scale-160',
    category: _ShortcutPreviewCategory.textScale,
    name: '160% text',
    description: 'Intermediate large-text stress test.',
    cardWidth: 170,
    fixedHeight: 195,
    textScale: 1.60,
    language: _ShortcutLanguage.english,
    textDirection: TextDirection.ltr,
  ),
  _ShortcutScenario(
    id: 'scale-179',
    category: _ShortcutPreviewCategory.textScale,
    name: '179% — just below second threshold',
    description: 'Checks behavior immediately before the very-large-text rule.',
    cardWidth: 170,
    fixedHeight: 200,
    textScale: 1.79,
    language: _ShortcutLanguage.english,
    textDirection: TextDirection.ltr,
  ),
  _ShortcutScenario(
    id: 'scale-180',
    category: _ShortcutPreviewCategory.textScale,
    name: '180% — exact second threshold',
    description:
        'Description may disappear on an ordinary narrow shortcut so the '
        'primary label remains usable.',
    cardWidth: 170,
    fixedHeight: 205,
    textScale: 1.80,
    language: _ShortcutLanguage.english,
    textDirection: TextDirection.ltr,
  ),
  _ShortcutScenario(
    id: 'scale-200',
    category: _ShortcutPreviewCategory.textScale,
    name: '200% text',
    description: 'Primary very-large-text accessibility test.',
    cardWidth: 170,
    fixedHeight: 215,
    textScale: 2.0,
    language: _ShortcutLanguage.english,
    textDirection: TextDirection.ltr,
  ),
  _ShortcutScenario(
    id: 'scale-250',
    category: _ShortcutPreviewCategory.textScale,
    name: '250% extreme text',
    description:
        'Beyond the normal target; useful for exposing hard-coded height '
        'assumptions.',
    cardWidth: 170,
    fixedHeight: 245,
    textScale: 2.5,
    language: _ShortcutLanguage.english,
    textDirection: TextDirection.ltr,
  ),

  //
  // LANGUAGES
  //
  _ShortcutScenario(
    id: 'lang-en',
    category: _ShortcutPreviewCategory.languages,
    name: 'English',
    description: 'Baseline Latin-script shortcut grid.',
    cardWidth: 380,
    textScale: 1.3,
    language: _ShortcutLanguage.english,
    textDirection: TextDirection.ltr,
    presentation: _ShortcutPresentation.grid,
    crossAxisCount: 2,
  ),
  _ShortcutScenario(
    id: 'lang-it',
    category: _ShortcutPreviewCategory.languages,
    name: 'Italian',
    description: 'Longer Romance-language shortcut names and descriptions.',
    cardWidth: 380,
    textScale: 1.3,
    language: _ShortcutLanguage.italian,
    textDirection: TextDirection.ltr,
    presentation: _ShortcutPresentation.grid,
    crossAxisCount: 2,
  ),
  _ShortcutScenario(
    id: 'lang-de',
    category: _ShortcutPreviewCategory.languages,
    name: 'German',
    description:
        'Long compounds such as Veröffentlichungskalender and longer copy.',
    cardWidth: 380,
    textScale: 1.3,
    language: _ShortcutLanguage.german,
    textDirection: TextDirection.ltr,
    presentation: _ShortcutPresentation.grid,
    crossAxisCount: 2,
  ),
  _ShortcutScenario(
    id: 'lang-ar',
    category: _ShortcutPreviewCategory.languages,
    name: 'Arabic RTL',
    description: 'Arabic script, RTL layout and localized-style badges.',
    cardWidth: 380,
    textScale: 1,
    language: _ShortcutLanguage.arabic,
    textDirection: TextDirection.rtl,
    presentation: _ShortcutPresentation.grid,
    crossAxisCount: 2,
  ),
  _ShortcutScenario(
    id: 'lang-he',
    category: _ShortcutPreviewCategory.languages,
    name: 'Hebrew RTL',
    description: 'Second RTL script to catch Arabic-specific assumptions.',
    cardWidth: 380,
    textScale: 1,
    language: _ShortcutLanguage.hebrew,
    textDirection: TextDirection.rtl,
    presentation: _ShortcutPresentation.grid,
    crossAxisCount: 2,
  ),
  _ShortcutScenario(
    id: 'lang-ja',
    category: _ShortcutPreviewCategory.languages,
    name: 'Japanese',
    description: 'CJK glyphs and compact ideographic labels.',
    cardWidth: 380,
    textScale: 1,
    language: _ShortcutLanguage.japanese,
    textDirection: TextDirection.ltr,
    presentation: _ShortcutPresentation.grid,
    crossAxisCount: 2,
  ),
  _ShortcutScenario(
    id: 'lang-ko',
    category: _ShortcutPreviewCategory.languages,
    name: 'Korean',
    description: 'Hangul text and mixed Latin/CJK product name.',
    cardWidth: 380,
    textScale: 1,
    language: _ShortcutLanguage.korean,
    textDirection: TextDirection.ltr,
    presentation: _ShortcutPresentation.grid,
    crossAxisCount: 2,
  ),
  _ShortcutScenario(
    id: 'lang-zh',
    category: _ShortcutPreviewCategory.languages,
    name: 'Simplified Chinese',
    description: 'Dense Han-script strings and short localized badges.',
    cardWidth: 380,
    textScale: 1.3,
    language: _ShortcutLanguage.chinese,
    textDirection: TextDirection.ltr,
    presentation: _ShortcutPresentation.grid,
    crossAxisCount: 2,
  ),
  _ShortcutScenario(
    id: 'lang-hi',
    category: _ShortcutPreviewCategory.languages,
    name: 'Hindi',
    description: 'Devanagari shaping, combining marks and longer descriptions.',
    cardWidth: 380,
    textScale: 1.3,
    language: _ShortcutLanguage.hindi,
    textDirection: TextDirection.ltr,
    presentation: _ShortcutPresentation.grid,
    crossAxisCount: 2,
  ),
  _ShortcutScenario(
    id: 'lang-ja-200',
    category: _ShortcutPreviewCategory.languages,
    name: 'Japanese at 200%',
    description: 'Combined ideographic and very-large-text regression test.',
    cardWidth: 380,
    textScale: 2.0,
    language: _ShortcutLanguage.japanese,
    textDirection: TextDirection.ltr,
    presentation: _ShortcutPresentation.grid,
    crossAxisCount: 1,
  ),
  _ShortcutScenario(
    id: 'lang-ar-200',
    category: _ShortcutPreviewCategory.languages,
    name: 'Arabic RTL at 200%',
    description:
        'Combined RTL, Arabic shaping and very-large-text regression test.',
    cardWidth: 380,
    textScale: 2.0,
    language: _ShortcutLanguage.arabic,
    textDirection: TextDirection.rtl,
    presentation: _ShortcutPresentation.grid,
    crossAxisCount: 1,
  ),

  //
  // DIRECTION
  //
  _ShortcutScenario(
    id: 'direction-en-rtl',
    category: _ShortcutPreviewCategory.direction,
    name: 'English forced RTL',
    description:
        'Artificial direction stress test for badge placement, text alignment '
        'and the navigation arrow.',
    cardWidth: 380,
    textScale: 1.3,
    language: _ShortcutLanguage.english,
    textDirection: TextDirection.rtl,
    presentation: _ShortcutPresentation.grid,
    crossAxisCount: 2,
  ),
  _ShortcutScenario(
    id: 'direction-ar-ltr',
    category: _ShortcutPreviewCategory.direction,
    name: 'Arabic forced LTR',
    description:
        'Artificial opposite-direction test used to expose hard-coded left/'
        'right assumptions.',
    cardWidth: 380,
    textScale: 1.3,
    language: _ShortcutLanguage.arabic,
    textDirection: TextDirection.ltr,
    presentation: _ShortcutPresentation.grid,
    crossAxisCount: 2,
  ),
  _ShortcutScenario(
    id: 'direction-he-rtl',
    category: _ShortcutPreviewCategory.direction,
    name: 'Hebrew RTL at 180%',
    description: 'RTL direction combined with the very-large-text threshold.',
    cardWidth: 380,
    textScale: 1.8,
    language: _ShortcutLanguage.hebrew,
    textDirection: TextDirection.rtl,
    presentation: _ShortcutPresentation.grid,
    crossAxisCount: 1,
  ),

  //
  // CONTENT + INTERACTION
  //
  _ShortcutScenario(
    id: 'content-no-description',
    category: _ShortcutPreviewCategory.content,
    name: 'No description',
    description: 'Checks a shortcut that only needs a primary label.',
    cardWidth: 170,
    fixedHeight: 150,
    textScale: 1.0,
    language: _ShortcutLanguage.english,
    textDirection: TextDirection.ltr,
    hideDescription: true,
  ),
  _ShortcutScenario(
    id: 'content-no-badge',
    category: _ShortcutPreviewCategory.content,
    name: 'No badge',
    description:
        'Top row should remain balanced when no status/count is present.',
    cardWidth: 170,
    fixedHeight: 170,
    textScale: 1.0,
    language: _ShortcutLanguage.english,
    textDirection: TextDirection.ltr,
    hideBadge: true,
  ),
  _ShortcutScenario(
    id: 'content-noninteractive',
    category: _ShortcutPreviewCategory.content,
    name: 'Informational / non-interactive',
    description:
        'No navigation callback and therefore no interactive semantics.',
    cardWidth: 170,
    fixedHeight: 170,
    textScale: 1.0,
    language: _ShortcutLanguage.english,
    textDirection: TextDirection.ltr,
    interactive: false,
  ),
  _ShortcutScenario(
    id: 'content-stress-single',
    category: _ShortcutPreviewCategory.content,
    name: 'Long-content single card',
    description:
        'Long title, description and badge in a normal two-column-sized card.',
    cardWidth: 170,
    fixedHeight: 195,
    textScale: 1.0,
    language: _ShortcutLanguage.english,
    textDirection: TextDirection.ltr,
    useStressContent: true,
  ),
  _ShortcutScenario(
    id: 'content-stress-grid',
    category: _ShortcutPreviewCategory.content,
    name: 'Long-content grid',
    description:
        'Multiple content combinations: long badge, no description, no badge '
        'and short strings.',
    cardWidth: 380,
    textScale: 1.3,
    language: _ShortcutLanguage.english,
    textDirection: TextDirection.ltr,
    presentation: _ShortcutPresentation.grid,
    crossAxisCount: 2,
    useStressContent: true,
  ),
  _ShortcutScenario(
    id: 'content-stress-200',
    category: _ShortcutPreviewCategory.content,
    name: 'Long-content grid at 200%',
    description:
        'Extreme content and accessibility combination in a full-width layout.',
    cardWidth: 380,
    textScale: 2.0,
    language: _ShortcutLanguage.english,
    textDirection: TextDirection.ltr,
    presentation: _ShortcutPresentation.grid,
    crossAxisCount: 1,
    useStressContent: true,
  ),

  //
  // ACCESSIBILITY FLAGS
  //
  _ShortcutScenario(
    id: 'a11y-bold',
    category: _ShortcutPreviewCategory.accessibility,
    name: 'System bold-text flag',
    description:
        'Checks heavier primary/secondary copy without changing the component '
        'width.',
    cardWidth: 380,
    textScale: 1.3,
    language: _ShortcutLanguage.english,
    textDirection: TextDirection.ltr,
    presentation: _ShortcutPresentation.grid,
    crossAxisCount: 2,
    boldText: true,
  ),
  _ShortcutScenario(
    id: 'a11y-high-contrast',
    category: _ShortcutPreviewCategory.accessibility,
    name: 'High contrast',
    description: 'Checks stronger borders and secondary-text visibility.',
    cardWidth: 380,
    textScale: 1.3,
    language: _ShortcutLanguage.english,
    textDirection: TextDirection.ltr,
    presentation: _ShortcutPresentation.grid,
    crossAxisCount: 2,
    highContrast: true,
  ),
  _ShortcutScenario(
    id: 'a11y-reduced-motion',
    category: _ShortcutPreviewCategory.accessibility,
    name: 'Reduced motion',
    description:
        'Press/tap behavior should remain usable while animations resolve '
        'immediately.',
    cardWidth: 380,
    textScale: 1.3,
    language: _ShortcutLanguage.english,
    textDirection: TextDirection.ltr,
    presentation: _ShortcutPresentation.grid,
    crossAxisCount: 2,
    disableAnimations: true,
  ),
  _ShortcutScenario(
    id: 'a11y-combined',
    category: _ShortcutPreviewCategory.accessibility,
    name: 'Combined accessibility stress',
    description:
        '200% text, Arabic RTL, bold text, high contrast and reduced motion '
        'together.',
    cardWidth: 380,
    textScale: 2.0,
    language: _ShortcutLanguage.arabic,
    textDirection: TextDirection.rtl,
    presentation: _ShortcutPresentation.grid,
    crossAxisCount: 1,
    boldText: true,
    highContrast: true,
    disableAnimations: true,
  ),
];
