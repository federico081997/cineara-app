import 'package:flutter/material.dart';

import '../home/presentation/cards/home_insight_card.dart';

/// Comprehensive manual preview for [HomeInsightCard].
///
/// This screen is intentionally designed to be used as the `home` of Cineara's
/// existing [MaterialApp]. It does not create a second [MaterialApp] and it
/// does not define or override Cineara's light or dark themes.
///
/// The active theme is inherited from the parent app, for example:
///
/// ```dart
/// MaterialApp(
///   theme: CinearaLightTheme.theme,
///   darkTheme: CinearaDarkTheme.theme,
///   themeMode: ThemeMode.light,
///   home: const HomeInsightCardPreviewScreen(),
/// )
/// ```
///
/// To verify both Cineara themes, run this same preview once with
/// `ThemeMode.light` and once with `ThemeMode.dark` in the parent app.
///
/// The scenarios below exercise:
///
/// - narrow, compact, regular and expanded widths;
/// - the exact 320 px and 600 px width breakpoints;
/// - the exact 1.30x and 1.80x text-scale breakpoints;
/// - 100% through 250% text scaling;
/// - LTR and RTL layouts;
/// - multiple languages and writing systems;
/// - one through nine input insights;
/// - incomplete final pages;
/// - long values, labels and supporting descriptions;
/// - missing icons and missing supporting text;
/// - interactive and informational cards;
/// - reduced motion, bold text and high-contrast accessibility flags.
///
/// Language samples are preview fixtures. They deliberately do not depend on
/// Cineara's generated ARB strings so this screen can stress-test scripts and
/// layout even before every preview language is part of the production locale
/// set.
class HomeInsightCardPreviewScreen extends StatefulWidget {
  const HomeInsightCardPreviewScreen({super.key});

  @override
  State<HomeInsightCardPreviewScreen> createState() =>
      _HomeInsightCardPreviewScreenState();
}

class _HomeInsightCardPreviewScreenState
    extends State<HomeInsightCardPreviewScreen> {
  _PreviewCategory _selectedCategory = _PreviewCategory.all;

  @override
  Widget build(BuildContext context) {
    final List<_PreviewScenario> visibleScenarios = _allScenarios
        .where(
          (_PreviewScenario scenario) =>
              _selectedCategory == _PreviewCategory.all ||
              scenario.category == _selectedCategory,
        )
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: const Text('HomeInsightCard Preview')),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _PreviewToolbar(
              selectedCategory: _selectedCategory,
              onCategoryChanged: (_PreviewCategory category) {
                setState(() {
                  _selectedCategory = category;
                });
              },
            ),
            const _InheritedEnvironmentBanner(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                itemCount: visibleScenarios.length,
                itemBuilder: (BuildContext context, int index) {
                  final _PreviewScenario scenario = visibleScenarios[index];

                  final bool showSectionHeading =
                      index == 0 ||
                      visibleScenarios[index - 1].category != scenario.category;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      if (showSectionHeading) ...<Widget>[
                        if (index != 0) const SizedBox(height: 28),
                        _SectionHeading(category: scenario.category),
                        const SizedBox(height: 12),
                      ],
                      _ScenarioPreview(
                        key: ValueKey<String>(scenario.id),
                        scenario: scenario,
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                },
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
    final Brightness brightness = theme.brightness;
    final Locale locale = Localizations.localeOf(context);

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
              'Using the parent MaterialApp theme '
              '(${brightness.name}) and app locale '
              '${locale.toLanguageTag()}. '
              'Each card scenario overrides only its test locale, text '
              'direction, width and accessibility MediaQuery values.',
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

class _PreviewToolbar extends StatelessWidget {
  const _PreviewToolbar({
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  final _PreviewCategory selectedCategory;
  final ValueChanged<_PreviewCategory> onCategoryChanged;

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
            for (final _PreviewCategory category
                in _PreviewCategory.values) ...<Widget>[
              ChoiceChip(
                selected: selectedCategory == category,
                label: Text(category.label),
                onSelected: (_) => onCategoryChanged(category),
              ),
              if (category != _PreviewCategory.values.last)
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

  final _PreviewCategory category;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Row(
      children: <Widget>[
        Icon(category.icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          category.sectionTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _ScenarioPreview extends StatelessWidget {
  const _ScenarioPreview({required this.scenario, super.key});

  final _PreviewScenario scenario;

  @override
  Widget build(BuildContext context) {
    final _PreviewCopy copy =
        scenario.copyOverride ?? _copyFor(scenario.language);
    final List<HomeInsightItem> sourceInsights =
        scenario.insightsOverride ?? copy.insights;

    final int itemCount = scenario.itemCount.clamp(1, 9);

    final List<HomeInsightItem> insights = sourceInsights
        .take(itemCount)
        .toList(growable: false);

    final MediaQueryData mediaQuery = MediaQuery.of(context).copyWith(
      size: scenario.mediaSize,
      textScaler: TextScaler.linear(scenario.textScale),
      boldText: scenario.boldText,
      highContrast: scenario.highContrast,
      disableAnimations: scenario.disableAnimations,
    );

    final Widget card = Localizations.override(
      context: context,
      locale: scenario.language.locale,
      child: MediaQuery(
        data: mediaQuery,
        child: Directionality(
          textDirection: scenario.textDirection,
          child: HomeInsightCard(
            title: scenario.showTitle ? copy.title : null,
            insights: insights,
            semanticLabel: scenario.useCustomSemanticLabel
                ? copy.cardSemanticLabel
                : null,
            pageSemanticLabelBuilder: copy.pageSemanticLabel,
            enableHaptics: false,
            onTap: scenario.interactive ? () {} : null,
          ),
        ),
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _ScenarioHeader(scenario: scenario),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final Widget exactWidthPreview = SizedBox(
                  width: scenario.cardWidth,
                  child: card,
                );

                if (scenario.cardWidth <= constraints.maxWidth) {
                  return Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: exactWidthPreview,
                  );
                }

                // Only genuinely wide test cases receive a parent horizontal
                // scroller. Phone-sized cases stay free of nested horizontal
                // scrolling so PageView gestures can be tested normally.
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: exactWidthPreview,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ScenarioHeader extends StatelessWidget {
  const _ScenarioHeader({required this.scenario});

  final _PreviewScenario scenario;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final List<String> metadata = <String>[
      '${scenario.cardWidth.toStringAsFixed(0)} px',
      '${scenario.textScale.toStringAsFixed(2)}× text',
      scenario.textDirection == TextDirection.rtl ? 'RTL' : 'LTR',
      scenario.language.label,
      '${scenario.itemCount} items',
      if (scenario.boldText) 'Bold text',
      if (scenario.highContrast) 'High contrast',
      if (scenario.disableAnimations) 'Reduced motion',
      if (!scenario.interactive) 'Non-interactive',
      if (!scenario.showTitle) 'No title',
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

enum _PreviewCategory {
  all,
  layout,
  textScale,
  languages,
  direction,
  content,
  accessibility;

  String get label => switch (this) {
    _PreviewCategory.all => 'All',
    _PreviewCategory.layout => 'Layout',
    _PreviewCategory.textScale => 'Text scale',
    _PreviewCategory.languages => 'Languages',
    _PreviewCategory.direction => 'Direction',
    _PreviewCategory.content => 'Content',
    _PreviewCategory.accessibility => 'Accessibility',
  };

  String get sectionTitle => switch (this) {
    _PreviewCategory.all => 'All scenarios',
    _PreviewCategory.layout => 'Width and responsive breakpoints',
    _PreviewCategory.textScale => 'Accessibility text scaling',
    _PreviewCategory.languages => 'Languages and writing systems',
    _PreviewCategory.direction => 'Text-direction stress tests',
    _PreviewCategory.content => 'Content and paging edge cases',
    _PreviewCategory.accessibility => 'Accessibility settings',
  };

  IconData get icon => switch (this) {
    _PreviewCategory.all => Icons.dashboard_customize_rounded,
    _PreviewCategory.layout => Icons.aspect_ratio_rounded,
    _PreviewCategory.textScale => Icons.text_fields_rounded,
    _PreviewCategory.languages => Icons.translate_rounded,
    _PreviewCategory.direction => Icons.swap_horiz_rounded,
    _PreviewCategory.content => Icons.view_carousel_rounded,
    _PreviewCategory.accessibility => Icons.accessibility_new_rounded,
  };
}

enum _PreviewLanguage {
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
    _PreviewLanguage.english => 'English',
    _PreviewLanguage.italian => 'Italiano',
    _PreviewLanguage.german => 'Deutsch',
    _PreviewLanguage.arabic => 'العربية',
    _PreviewLanguage.hebrew => 'עברית',
    _PreviewLanguage.japanese => '日本語',
    _PreviewLanguage.korean => '한국어',
    _PreviewLanguage.chinese => '中文',
    _PreviewLanguage.hindi => 'हिन्दी',
  };

  Locale get locale => switch (this) {
    _PreviewLanguage.english => const Locale('en'),
    _PreviewLanguage.italian => const Locale('it'),
    _PreviewLanguage.german => const Locale('de'),
    _PreviewLanguage.arabic => const Locale('ar'),
    _PreviewLanguage.hebrew => const Locale('he'),
    _PreviewLanguage.japanese => const Locale('ja'),
    _PreviewLanguage.korean => const Locale('ko'),
    _PreviewLanguage.chinese => const Locale('zh'),
    _PreviewLanguage.hindi => const Locale('hi'),
  };
}

@immutable
class _PreviewScenario {
  const _PreviewScenario({
    required this.id,
    required this.category,
    required this.name,
    required this.description,
    required this.cardWidth,
    required this.textScale,
    required this.language,
    required this.textDirection,
    this.itemCount = 9,
    this.mediaSize = const Size(360, 800),
    this.boldText = false,
    this.highContrast = false,
    this.disableAnimations = false,
    this.interactive = true,
    this.showTitle = true,
    this.useCustomSemanticLabel = false,
    this.copyOverride,
    this.insightsOverride,
  });

  final String id;
  final _PreviewCategory category;
  final String name;
  final String description;
  final double cardWidth;
  final double textScale;
  final _PreviewLanguage language;
  final TextDirection textDirection;
  final int itemCount;
  final Size mediaSize;
  final bool boldText;
  final bool highContrast;
  final bool disableAnimations;
  final bool interactive;
  final bool showTitle;
  final bool useCustomSemanticLabel;
  final _PreviewCopy? copyOverride;
  final List<HomeInsightItem>? insightsOverride;
}

@immutable
class _PreviewCopy {
  const _PreviewCopy({
    required this.title,
    required this.cardSemanticLabel,
    required this.insights,
    required this.pageSemanticLabel,
  });

  final String title;
  final String cardSemanticLabel;
  final List<HomeInsightItem> insights;
  final String Function(int page, int pageCount) pageSemanticLabel;
}

_PreviewCopy _copyFor(_PreviewLanguage language) {
  return switch (language) {
    _PreviewLanguage.english => _englishCopy,
    _PreviewLanguage.italian => _italianCopy,
    _PreviewLanguage.german => _germanCopy,
    _PreviewLanguage.arabic => _arabicCopy,
    _PreviewLanguage.hebrew => _hebrewCopy,
    _PreviewLanguage.japanese => _japaneseCopy,
    _PreviewLanguage.korean => _koreanCopy,
    _PreviewLanguage.chinese => _chineseCopy,
    _PreviewLanguage.hindi => _hindiCopy,
  };
}

const _PreviewCopy _englishCopy = _PreviewCopy(
  title: 'Your Cineara',
  cardSemanticLabel: 'Your Cineara activity summary',
  pageSemanticLabel: _englishPageLabel,
  insights: <HomeInsightItem>[
    HomeInsightItem(
      value: '1,248 h',
      label: 'Total time watched',
      supportingText: '126 h more than last year',
      icon: Icons.schedule_rounded,
    ),
    HomeInsightItem(
      value: '128',
      label: 'Feature films this year',
      supportingText: '17 more than last year',
      icon: Icons.movie_rounded,
    ),
    HomeInsightItem(
      value: '37',
      label: 'Countries explored',
      supportingText: '6 new countries this year',
      icon: Icons.public_rounded,
    ),
    HomeInsightItem(
      value: '842',
      label: 'Episodes watched',
      supportingText: 'Across 54 television series',
      icon: Icons.live_tv_rounded,
    ),
    HomeInsightItem(
      value: '8.4',
      label: 'Average personal rating',
      supportingText: 'From 193 rated titles',
      icon: Icons.star_rounded,
    ),
    HomeInsightItem(
      value: '23',
      label: 'Anime completed',
      supportingText: '7 completed this year',
      icon: Icons.auto_awesome_rounded,
    ),
    HomeInsightItem(
      value: '14',
      label: 'Korean dramas discovered',
      supportingText: 'Across 9 different genres',
      icon: Icons.explore_rounded,
    ),
    HomeInsightItem(
      value: '61%',
      label: 'International cinema share',
      supportingText: 'Up 8 percentage points',
      icon: Icons.language_rounded,
    ),
    HomeInsightItem(
      value: '19 d',
      label: 'Longest watching streak',
      supportingText: 'Your best streak so far',
      icon: Icons.local_fire_department_rounded,
    ),
  ],
);

String _englishPageLabel(int page, int pageCount) => 'Page $page of $pageCount';

const _PreviewCopy _italianCopy = _PreviewCopy(
  title: 'La tua Cineara',
  cardSemanticLabel: 'Riepilogo della tua attività su Cineara',
  pageSemanticLabel: _italianPageLabel,
  insights: <HomeInsightItem>[
    HomeInsightItem(
      value: '1.248 h',
      label: 'Tempo totale di visione',
      supportingText: '126 h in più rispetto allo scorso anno',
      icon: Icons.schedule_rounded,
    ),
    HomeInsightItem(
      value: '128',
      label: 'Lungometraggi quest’anno',
      supportingText: '17 in più rispetto allo scorso anno',
      icon: Icons.movie_rounded,
    ),
    HomeInsightItem(
      value: '37',
      label: 'Paesi esplorati',
      supportingText: '6 nuovi paesi quest’anno',
      icon: Icons.public_rounded,
    ),
    HomeInsightItem(
      value: '842',
      label: 'Episodi guardati',
      supportingText: 'In 54 serie televisive',
      icon: Icons.live_tv_rounded,
    ),
    HomeInsightItem(
      value: '8,4',
      label: 'Valutazione personale media',
      supportingText: 'Su 193 titoli valutati',
      icon: Icons.star_rounded,
    ),
    HomeInsightItem(
      value: '23',
      label: 'Anime completati',
      supportingText: '7 completati quest’anno',
      icon: Icons.auto_awesome_rounded,
    ),
    HomeInsightItem(
      value: '14',
      label: 'Drama coreani scoperti',
      supportingText: 'In 9 generi differenti',
      icon: Icons.explore_rounded,
    ),
    HomeInsightItem(
      value: '61%',
      label: 'Quota di cinema internazionale',
      supportingText: 'In aumento di 8 punti percentuali',
      icon: Icons.language_rounded,
    ),
    HomeInsightItem(
      value: '19 g',
      label: 'Serie di visione più lunga',
      supportingText: 'Il tuo record finora',
      icon: Icons.local_fire_department_rounded,
    ),
  ],
);

String _italianPageLabel(int page, int pageCount) =>
    'Pagina $page di $pageCount';

const _PreviewCopy _germanCopy = _PreviewCopy(
  title: 'Dein Cineara',
  cardSemanticLabel: 'Zusammenfassung deiner Cineara-Aktivität',
  pageSemanticLabel: _germanPageLabel,
  insights: <HomeInsightItem>[
    HomeInsightItem(
      value: '1.248 Std.',
      label: 'Gesamte Wiedergabezeit',
      supportingText: '126 Stunden mehr als im Vorjahr',
      icon: Icons.schedule_rounded,
    ),
    HomeInsightItem(
      value: '128',
      label: 'Spielfilme in diesem Jahr',
      supportingText: '17 mehr als im vergangenen Jahr',
      icon: Icons.movie_rounded,
    ),
    HomeInsightItem(
      value: '37',
      label: 'Erkundete Produktionsländer',
      supportingText: '6 neue Länder in diesem Jahr',
      icon: Icons.public_rounded,
    ),
    HomeInsightItem(
      value: '842',
      label: 'Angesehene Serienepisoden',
      supportingText: 'Aus insgesamt 54 Fernsehserien',
      icon: Icons.live_tv_rounded,
    ),
    HomeInsightItem(
      value: '8,4',
      label: 'Durchschnittliche persönliche Bewertung',
      supportingText: 'Basierend auf 193 bewerteten Titeln',
      icon: Icons.star_rounded,
    ),
    HomeInsightItem(
      value: '23',
      label: 'Abgeschlossene Anime-Serien',
      supportingText: '7 davon in diesem Jahr',
      icon: Icons.auto_awesome_rounded,
    ),
    HomeInsightItem(
      value: '14',
      label: 'Entdeckte koreanische Dramen',
      supportingText: 'Aus 9 unterschiedlichen Genres',
      icon: Icons.explore_rounded,
    ),
    HomeInsightItem(
      value: '61 %',
      label: 'Anteil internationalen Kinos',
      supportingText: 'Um 8 Prozentpunkte gestiegen',
      icon: Icons.language_rounded,
    ),
    HomeInsightItem(
      value: '19 T.',
      label: 'Längste ununterbrochene Sehserie',
      supportingText: 'Dein bisher längster Zeitraum',
      icon: Icons.local_fire_department_rounded,
    ),
  ],
);

String _germanPageLabel(int page, int pageCount) =>
    'Seite $page von $pageCount';

const _PreviewCopy _arabicCopy = _PreviewCopy(
  title: 'سينيارا الخاصة بك',
  cardSemanticLabel: 'ملخص نشاطك على سينيارا',
  pageSemanticLabel: _arabicPageLabel,
  insights: <HomeInsightItem>[
    HomeInsightItem(
      value: '١٬٢٤٨ س',
      label: 'إجمالي وقت المشاهدة',
      supportingText: 'أكثر بـ ١٢٦ ساعة من العام الماضي',
      icon: Icons.schedule_rounded,
    ),
    HomeInsightItem(
      value: '١٢٨',
      label: 'الأفلام الطويلة هذا العام',
      supportingText: 'أكثر بـ ١٧ فيلمًا من العام الماضي',
      icon: Icons.movie_rounded,
    ),
    HomeInsightItem(
      value: '٣٧',
      label: 'البلدان التي استكشفتها',
      supportingText: '٦ بلدان جديدة هذا العام',
      icon: Icons.public_rounded,
    ),
    HomeInsightItem(
      value: '٨٤٢',
      label: 'الحلقات التي شاهدتها',
      supportingText: 'عبر ٥٤ مسلسلًا تلفزيونيًا',
      icon: Icons.live_tv_rounded,
    ),
    HomeInsightItem(
      value: '٨٫٤',
      label: 'متوسط تقييمك الشخصي',
      supportingText: 'من بين ١٩٣ عنوانًا قيّمته',
      icon: Icons.star_rounded,
    ),
    HomeInsightItem(
      value: '٢٣',
      label: 'أعمال الأنمي المكتملة',
      supportingText: '٧ منها هذا العام',
      icon: Icons.auto_awesome_rounded,
    ),
    HomeInsightItem(
      value: '١٤',
      label: 'الدراما الكورية التي اكتشفتها',
      supportingText: 'ضمن ٩ أنواع مختلفة',
      icon: Icons.explore_rounded,
    ),
    HomeInsightItem(
      value: '٪٦١',
      label: 'نسبة السينما الدولية',
      supportingText: 'بارتفاع قدره ٨ نقاط مئوية',
      icon: Icons.language_rounded,
    ),
    HomeInsightItem(
      value: '١٩ ي',
      label: 'أطول سلسلة مشاهدة',
      supportingText: 'أفضل سلسلة لك حتى الآن',
      icon: Icons.local_fire_department_rounded,
    ),
  ],
);

String _arabicPageLabel(int page, int pageCount) =>
    'الصفحة $page من $pageCount';

const _PreviewCopy _hebrewCopy = _PreviewCopy(
  title: 'Cineara שלך',
  cardSemanticLabel: 'סיכום הפעילות שלך ב-Cineara',
  pageSemanticLabel: _hebrewPageLabel,
  insights: <HomeInsightItem>[
    HomeInsightItem(
      value: '1,248 ש׳',
      label: 'זמן צפייה כולל',
      supportingText: '126 שעות יותר מהשנה שעברה',
      icon: Icons.schedule_rounded,
    ),
    HomeInsightItem(
      value: '128',
      label: 'סרטים באורך מלא השנה',
      supportingText: '17 יותר מהשנה שעברה',
      icon: Icons.movie_rounded,
    ),
    HomeInsightItem(
      value: '37',
      label: 'מדינות שנחקרו',
      supportingText: '6 מדינות חדשות השנה',
      icon: Icons.public_rounded,
    ),
    HomeInsightItem(
      value: '842',
      label: 'פרקים שנצפו',
      supportingText: 'מתוך 54 סדרות טלוויזיה',
      icon: Icons.live_tv_rounded,
    ),
    HomeInsightItem(
      value: '8.4',
      label: 'דירוג אישי ממוצע',
      supportingText: 'מתוך 193 כותרים שדורגו',
      icon: Icons.star_rounded,
    ),
    HomeInsightItem(
      value: '23',
      label: 'סדרות אנימה שהושלמו',
      supportingText: '7 הושלמו השנה',
      icon: Icons.auto_awesome_rounded,
    ),
    HomeInsightItem(
      value: '14',
      label: 'דרמות קוריאניות שהתגלו',
      supportingText: 'מתוך 9 ז׳אנרים שונים',
      icon: Icons.explore_rounded,
    ),
    HomeInsightItem(
      value: '61%',
      label: 'חלקו של הקולנוע הבינלאומי',
      supportingText: 'עלייה של 8 נקודות אחוז',
      icon: Icons.language_rounded,
    ),
    HomeInsightItem(
      value: '19 י׳',
      label: 'רצף הצפייה הארוך ביותר',
      supportingText: 'השיא הטוב ביותר שלך עד כה',
      icon: Icons.local_fire_department_rounded,
    ),
  ],
);

String _hebrewPageLabel(int page, int pageCount) =>
    'עמוד $page מתוך $pageCount';

const _PreviewCopy _japaneseCopy = _PreviewCopy(
  title: 'あなたのCineara',
  cardSemanticLabel: 'Cinearaでのアクティビティ概要',
  pageSemanticLabel: _japanesePageLabel,
  insights: <HomeInsightItem>[
    HomeInsightItem(
      value: '1,248時間',
      label: '合計視聴時間',
      supportingText: '昨年より126時間増加',
      icon: Icons.schedule_rounded,
    ),
    HomeInsightItem(
      value: '128本',
      label: '今年観た長編映画',
      supportingText: '昨年より17本増加',
      icon: Icons.movie_rounded,
    ),
    HomeInsightItem(
      value: '37か国',
      label: '作品を通して巡った国',
      supportingText: '今年は新たに6か国',
      icon: Icons.public_rounded,
    ),
    HomeInsightItem(
      value: '842話',
      label: '視聴したエピソード',
      supportingText: '54シリーズにわたって視聴',
      icon: Icons.live_tv_rounded,
    ),
    HomeInsightItem(
      value: '8.4',
      label: 'あなたの平均評価',
      supportingText: '193作品を評価',
      icon: Icons.star_rounded,
    ),
    HomeInsightItem(
      value: '23作品',
      label: '完走したアニメ',
      supportingText: '今年は7作品を完走',
      icon: Icons.auto_awesome_rounded,
    ),
    HomeInsightItem(
      value: '14作品',
      label: '発見した韓国ドラマ',
      supportingText: '9ジャンルにわたって発見',
      icon: Icons.explore_rounded,
    ),
    HomeInsightItem(
      value: '61%',
      label: '海外作品の視聴割合',
      supportingText: '8ポイント上昇',
      icon: Icons.language_rounded,
    ),
    HomeInsightItem(
      value: '19日',
      label: '最長連続視聴記録',
      supportingText: 'これまでの自己ベスト',
      icon: Icons.local_fire_department_rounded,
    ),
  ],
);

String _japanesePageLabel(int page, int pageCount) => '$pageCountページ中$pageページ目';

const _PreviewCopy _koreanCopy = _PreviewCopy(
  title: '나의 Cineara',
  cardSemanticLabel: 'Cineara 활동 요약',
  pageSemanticLabel: _koreanPageLabel,
  insights: <HomeInsightItem>[
    HomeInsightItem(
      value: '1,248시간',
      label: '총 시청 시간',
      supportingText: '작년보다 126시간 증가',
      icon: Icons.schedule_rounded,
    ),
    HomeInsightItem(
      value: '128편',
      label: '올해 본 장편 영화',
      supportingText: '작년보다 17편 증가',
      icon: Icons.movie_rounded,
    ),
    HomeInsightItem(
      value: '37개국',
      label: '탐험한 국가',
      supportingText: '올해 새롭게 6개국 추가',
      icon: Icons.public_rounded,
    ),
    HomeInsightItem(
      value: '842화',
      label: '시청한 에피소드',
      supportingText: '54개 시리즈에서 시청',
      icon: Icons.live_tv_rounded,
    ),
    HomeInsightItem(
      value: '8.4',
      label: '평균 개인 평점',
      supportingText: '193개 작품을 평가',
      icon: Icons.star_rounded,
    ),
    HomeInsightItem(
      value: '23편',
      label: '완료한 애니메이션',
      supportingText: '올해 7편 완료',
      icon: Icons.auto_awesome_rounded,
    ),
    HomeInsightItem(
      value: '14편',
      label: '발견한 한국 드라마',
      supportingText: '9개의 서로 다른 장르',
      icon: Icons.explore_rounded,
    ),
    HomeInsightItem(
      value: '61%',
      label: '해외 영화 시청 비율',
      supportingText: '8%p 증가',
      icon: Icons.language_rounded,
    ),
    HomeInsightItem(
      value: '19일',
      label: '최장 연속 시청 기록',
      supportingText: '지금까지의 최고 기록',
      icon: Icons.local_fire_department_rounded,
    ),
  ],
);

String _koreanPageLabel(int page, int pageCount) => '$pageCount페이지 중 $page페이지';

const _PreviewCopy _chineseCopy = _PreviewCopy(
  title: '你的 Cineara',
  cardSemanticLabel: '你的 Cineara 活动摘要',
  pageSemanticLabel: _chinesePageLabel,
  insights: <HomeInsightItem>[
    HomeInsightItem(
      value: '1,248小时',
      label: '总观看时长',
      supportingText: '比去年多126小时',
      icon: Icons.schedule_rounded,
    ),
    HomeInsightItem(
      value: '128部',
      label: '今年观看的长片',
      supportingText: '比去年多17部',
      icon: Icons.movie_rounded,
    ),
    HomeInsightItem(
      value: '37个',
      label: '探索过的国家和地区',
      supportingText: '今年新增6个',
      icon: Icons.public_rounded,
    ),
    HomeInsightItem(
      value: '842集',
      label: '已观看剧集',
      supportingText: '来自54部电视剧',
      icon: Icons.live_tv_rounded,
    ),
    HomeInsightItem(
      value: '8.4',
      label: '个人平均评分',
      supportingText: '基于193个已评分条目',
      icon: Icons.star_rounded,
    ),
    HomeInsightItem(
      value: '23部',
      label: '已看完的动画',
      supportingText: '今年看完7部',
      icon: Icons.auto_awesome_rounded,
    ),
    HomeInsightItem(
      value: '14部',
      label: '发现的韩剧',
      supportingText: '涵盖9种不同类型',
      icon: Icons.explore_rounded,
    ),
    HomeInsightItem(
      value: '61%',
      label: '国际影视观看占比',
      supportingText: '上升8个百分点',
      icon: Icons.language_rounded,
    ),
    HomeInsightItem(
      value: '19天',
      label: '最长连续观看记录',
      supportingText: '目前为止的最佳记录',
      icon: Icons.local_fire_department_rounded,
    ),
  ],
);

String _chinesePageLabel(int page, int pageCount) => '第$page页，共$pageCount页';

const _PreviewCopy _hindiCopy = _PreviewCopy(
  title: 'आपका Cineara',
  cardSemanticLabel: 'Cineara पर आपकी गतिविधि का सारांश',
  pageSemanticLabel: _hindiPageLabel,
  insights: <HomeInsightItem>[
    HomeInsightItem(
      value: '१,२४८ घं',
      label: 'कुल देखने का समय',
      supportingText: 'पिछले वर्ष से १२६ घंटे अधिक',
      icon: Icons.schedule_rounded,
    ),
    HomeInsightItem(
      value: '१२८',
      label: 'इस वर्ष देखी गई फ़ीचर फ़िल्में',
      supportingText: 'पिछले वर्ष से १७ अधिक',
      icon: Icons.movie_rounded,
    ),
    HomeInsightItem(
      value: '३७',
      label: 'खोजे गए देश',
      supportingText: 'इस वर्ष ६ नए देश',
      icon: Icons.public_rounded,
    ),
    HomeInsightItem(
      value: '८४२',
      label: 'देखे गए एपिसोड',
      supportingText: '५४ टीवी सीरीज़ में',
      icon: Icons.live_tv_rounded,
    ),
    HomeInsightItem(
      value: '८.४',
      label: 'औसत व्यक्तिगत रेटिंग',
      supportingText: '१९३ रेट किए गए शीर्षकों से',
      icon: Icons.star_rounded,
    ),
    HomeInsightItem(
      value: '२३',
      label: 'पूरे किए गए ऐनिमे',
      supportingText: 'इस वर्ष ७ पूरे किए',
      icon: Icons.auto_awesome_rounded,
    ),
    HomeInsightItem(
      value: '१४',
      label: 'खोजे गए कोरियाई ड्रामा',
      supportingText: '९ अलग-अलग शैलियों में',
      icon: Icons.explore_rounded,
    ),
    HomeInsightItem(
      value: '६१%',
      label: 'अंतरराष्ट्रीय सिनेमा का हिस्सा',
      supportingText: '८ प्रतिशत अंक की वृद्धि',
      icon: Icons.language_rounded,
    ),
    HomeInsightItem(
      value: '१९ दिन',
      label: 'सबसे लंबी देखने की लय',
      supportingText: 'अब तक का आपका सर्वश्रेष्ठ रिकॉर्ड',
      icon: Icons.local_fire_department_rounded,
    ),
  ],
);

String _hindiPageLabel(int page, int pageCount) => 'पृष्ठ $page / $pageCount';

const List<HomeInsightItem> _stressInsights = <HomeInsightItem>[
  HomeInsightItem(
    value: '123,456,789.50 h',
    label: 'Extremely long formatted value',
    supportingText:
        'This deliberately long supporting description checks wrapping, '
        'alignment and vertical slot stability at difficult sizes.',
    icon: Icons.schedule_rounded,
  ),
  HomeInsightItem(
    value: '99.999%',
    label:
        'A deliberately verbose translated-style label that needs several words',
    supportingText:
        'Supporting information should wrap naturally instead of scrolling sideways.',
    icon: Icons.public_rounded,
  ),
  HomeInsightItem(
    value: '8.75',
    label: 'No supporting text below this statistic',
    icon: Icons.star_rounded,
  ),
  HomeInsightItem(
    value: '42',
    label: 'No icon on this statistic',
    supportingText: 'The empty icon slot should still preserve alignment.',
  ),
  HomeInsightItem(
    value: '1',
    label: 'Very short label',
    supportingText: 'Short',
    icon: Icons.movie_rounded,
  ),
  HomeInsightItem(
    value: '777',
    label: 'Another ordinary metric',
    supportingText: 'Used to exercise the second page',
    icon: Icons.live_tv_rounded,
  ),
  HomeInsightItem(
    value: '12',
    label: 'Final-page metric A',
    supportingText: 'Checks centering on an incomplete final page',
    icon: Icons.explore_rounded,
  ),
  HomeInsightItem(
    value: '34',
    label: 'Final-page metric B',
    supportingText: 'Checks the divider and slot geometry',
    icon: Icons.language_rounded,
  ),
  HomeInsightItem(
    value: '56',
    label: 'Final-page metric C',
    supportingText: 'Used only when the current capacity can show it',
    icon: Icons.local_fire_department_rounded,
  ),
];

const List<_PreviewScenario> _allScenarios = <_PreviewScenario>[
  //
  // WIDTH + RESPONSIVE BREAKPOINTS
  //
  _PreviewScenario(
    id: 'layout-280',
    category: _PreviewCategory.layout,
    name: 'Very narrow card',
    description:
        'Exercises the narrow-phone fallback where normal text uses two insights per page.',
    cardWidth: 280,
    textScale: 1.0,
    language: _PreviewLanguage.english,
    textDirection: TextDirection.ltr,
    mediaSize: Size(280, 720),
  ),
  _PreviewScenario(
    id: 'layout-319',
    category: _PreviewCategory.layout,
    name: '319 px — just below compact breakpoint',
    description:
        'Regression test immediately below the 320 px density breakpoint.',
    cardWidth: 319,
    textScale: 1.0,
    language: _PreviewLanguage.english,
    textDirection: TextDirection.ltr,
    mediaSize: Size(319, 760),
  ),
  _PreviewScenario(
    id: 'layout-320',
    category: _PreviewCategory.layout,
    name: '320 px — exact compact breakpoint',
    description:
        'Checks the exact width at which the card switches from compact to regular density.',
    cardWidth: 320,
    textScale: 1.0,
    language: _PreviewLanguage.english,
    textDirection: TextDirection.ltr,
    mediaSize: Size(320, 760),
  ),
  _PreviewScenario(
    id: 'layout-360',
    category: _PreviewCategory.layout,
    name: '360 px phone',
    description: 'Typical narrow Android phone width at normal text size.',
    cardWidth: 360,
    textScale: 1.0,
    language: _PreviewLanguage.english,
    textDirection: TextDirection.ltr,
    mediaSize: Size(360, 800),
  ),
  _PreviewScenario(
    id: 'layout-412',
    category: _PreviewCategory.layout,
    name: '412 px large phone',
    description: 'Typical modern large-phone content width.',
    cardWidth: 412,
    textScale: 1.0,
    language: _PreviewLanguage.english,
    textDirection: TextDirection.ltr,
    mediaSize: Size(412, 915),
  ),
  _PreviewScenario(
    id: 'layout-599',
    category: _PreviewCategory.layout,
    name: '599 px — just below expanded breakpoint',
    description:
        'Regression test immediately below the 600 px expanded-width breakpoint.',
    cardWidth: 599,
    textScale: 1.3,
    language: _PreviewLanguage.english,
    textDirection: TextDirection.ltr,
    mediaSize: Size(599, 900),
  ),
  _PreviewScenario(
    id: 'layout-600',
    category: _PreviewCategory.layout,
    name: '600 px — exact expanded breakpoint',
    description:
        'At enlarged text, a 600 px card should retain three insights per page.',
    cardWidth: 600,
    textScale: 1.3,
    language: _PreviewLanguage.english,
    textDirection: TextDirection.ltr,
    mediaSize: Size(600, 900),
  ),
  _PreviewScenario(
    id: 'layout-840',
    category: _PreviewCategory.layout,
    name: '840 px tablet / expanded layout',
    description:
        'Wide-layout check with three columns and generous physical width.',
    cardWidth: 840,
    textScale: 1.0,
    language: _PreviewLanguage.english,
    textDirection: TextDirection.ltr,
    mediaSize: Size(840, 1180),
  ),

  //
  // TEXT-SCALE BREAKPOINTS
  //
  _PreviewScenario(
    id: 'scale-100',
    category: _PreviewCategory.textScale,
    name: '100% text',
    description: 'Baseline: three insights per page on a standard phone.',
    cardWidth: 325,
    textScale: 1.0,
    language: _PreviewLanguage.english,
    textDirection: TextDirection.ltr,
  ),
  _PreviewScenario(
    id: 'scale-129',
    category: _PreviewCategory.textScale,
    name: '129% text — just below first threshold',
    description: 'Should remain on the normal three-insight phone layout.',
    cardWidth: 360,
    textScale: 1.29,
    language: _PreviewLanguage.english,
    textDirection: TextDirection.ltr,
  ),
  _PreviewScenario(
    id: 'scale-130',
    category: _PreviewCategory.textScale,
    name: '130% text — exact first threshold',
    description: 'Should switch a phone-width card to two insights per page.',
    cardWidth: 360,
    textScale: 1.30,
    language: _PreviewLanguage.english,
    textDirection: TextDirection.ltr,
  ),
  _PreviewScenario(
    id: 'scale-160',
    category: _PreviewCategory.textScale,
    name: '160% text',
    description:
        'Two-insight layout with visibly enlarged labels and descriptions.',
    cardWidth: 360,
    textScale: 1.60,
    language: _PreviewLanguage.english,
    textDirection: TextDirection.ltr,
  ),
  _PreviewScenario(
    id: 'scale-179',
    category: _PreviewCategory.textScale,
    name: '179% text — just below second threshold',
    description: 'Should still use two insights per page on a phone.',
    cardWidth: 360,
    textScale: 1.79,
    language: _PreviewLanguage.english,
    textDirection: TextDirection.ltr,
  ),
  _PreviewScenario(
    id: 'scale-180',
    category: _PreviewCategory.textScale,
    name: '180% text — exact second threshold',
    description:
        'Should switch to one insight per page and expose only the first three Home insights.',
    cardWidth: 360,
    textScale: 1.80,
    language: _PreviewLanguage.english,
    textDirection: TextDirection.ltr,
  ),
  _PreviewScenario(
    id: 'scale-200',
    category: _PreviewCategory.textScale,
    name: '200% text',
    description:
        'Primary accessibility stress test: one insight per page with three-line text slots.',
    cardWidth: 360,
    textScale: 2.0,
    language: _PreviewLanguage.english,
    textDirection: TextDirection.ltr,
  ),
  _PreviewScenario(
    id: 'scale-250',
    category: _PreviewCategory.textScale,
    name: '250% extreme text',
    description:
        'Extreme stress test beyond the normal target. Useful for finding hard assumptions.',
    cardWidth: 360,
    textScale: 2.5,
    language: _PreviewLanguage.english,
    textDirection: TextDirection.ltr,
  ),
  _PreviewScenario(
    id: 'scale-wide-200',
    category: _PreviewCategory.textScale,
    name: '200% text on 700 px card',
    description:
        'Wide layouts should preserve two insights per page even at very large text.',
    cardWidth: 700,
    textScale: 2.0,
    language: _PreviewLanguage.english,
    textDirection: TextDirection.ltr,
    mediaSize: Size(700, 900),
  ),

  //
  // LANGUAGE + SCRIPT COVERAGE
  //
  _PreviewScenario(
    id: 'lang-en',
    category: _PreviewCategory.languages,
    name: 'English',
    description: 'Baseline Latin-script localization.',
    cardWidth: 360,
    textScale: 1.3,
    language: _PreviewLanguage.english,
    textDirection: TextDirection.ltr,
  ),
  _PreviewScenario(
    id: 'lang-it',
    category: _PreviewCategory.languages,
    name: 'Italian',
    description:
        'Longer Romance-language labels with decimal commas and localized copy.',
    cardWidth: 360,
    textScale: 1.3,
    language: _PreviewLanguage.italian,
    textDirection: TextDirection.ltr,
  ),
  _PreviewScenario(
    id: 'lang-de',
    category: _PreviewCategory.languages,
    name: 'German',
    description: 'Long compound nouns and longer supporting descriptions.',
    cardWidth: 360,
    textScale: 1.3,
    language: _PreviewLanguage.german,
    textDirection: TextDirection.ltr,
  ),
  _PreviewScenario(
    id: 'lang-ar',
    category: _PreviewCategory.languages,
    name: 'Arabic',
    description:
        'RTL layout, Arabic script and Arabic-Indic numerals at enlarged text.',
    cardWidth: 360,
    textScale: 1.3,
    language: _PreviewLanguage.arabic,
    textDirection: TextDirection.rtl,
  ),
  _PreviewScenario(
    id: 'lang-he',
    category: _PreviewCategory.languages,
    name: 'Hebrew',
    description:
        'Second RTL writing system to catch assumptions that only work for Arabic.',
    cardWidth: 360,
    textScale: 1.3,
    language: _PreviewLanguage.hebrew,
    textDirection: TextDirection.rtl,
  ),
  _PreviewScenario(
    id: 'lang-ja',
    category: _PreviewCategory.languages,
    name: 'Japanese',
    description: 'CJK glyphs, short labels and mixed Latin/CJK title text.',
    cardWidth: 360,
    textScale: 1.3,
    language: _PreviewLanguage.japanese,
    textDirection: TextDirection.ltr,
  ),
  _PreviewScenario(
    id: 'lang-ko',
    category: _PreviewCategory.languages,
    name: 'Korean',
    description: 'Hangul layout and compact CJK-style phrasing.',
    cardWidth: 360,
    textScale: 1.3,
    language: _PreviewLanguage.korean,
    textDirection: TextDirection.ltr,
  ),
  _PreviewScenario(
    id: 'lang-zh',
    category: _PreviewCategory.languages,
    name: 'Simplified Chinese',
    description: 'Dense Han-script layout with localized value suffixes.',
    cardWidth: 360,
    textScale: 1.3,
    language: _PreviewLanguage.chinese,
    textDirection: TextDirection.ltr,
  ),
  _PreviewScenario(
    id: 'lang-hi',
    category: _PreviewCategory.languages,
    name: 'Hindi',
    description:
        'Devanagari shaping and relatively long translated descriptions.',
    cardWidth: 360,
    textScale: 1.3,
    language: _PreviewLanguage.hindi,
    textDirection: TextDirection.ltr,
  ),

  //
  // DIRECTION STRESS
  //
  _PreviewScenario(
    id: 'direction-en-rtl',
    category: _PreviewCategory.direction,
    name: 'English forced RTL',
    description:
        'Artificial direction stress test. Useful for finding hard-coded left/right alignment.',
    cardWidth: 360,
    textScale: 1.3,
    language: _PreviewLanguage.english,
    textDirection: TextDirection.rtl,
  ),
  _PreviewScenario(
    id: 'direction-ar-ltr',
    category: _PreviewCategory.direction,
    name: 'Arabic forced LTR',
    description:
        'Artificial opposite-direction test for alignment and arrow behavior.',
    cardWidth: 360,
    textScale: 1.3,
    language: _PreviewLanguage.arabic,
    textDirection: TextDirection.ltr,
  ),
  _PreviewScenario(
    id: 'direction-ar-200',
    category: _PreviewCategory.direction,
    name: 'Arabic RTL at 200%',
    description:
        'High-priority combined test: RTL plus one-insight accessibility pages.',
    cardWidth: 360,
    textScale: 2.0,
    language: _PreviewLanguage.arabic,
    textDirection: TextDirection.rtl,
  ),

  //
  // CONTENT + PAGING EDGE CASES
  //
  _PreviewScenario(
    id: 'content-1',
    category: _PreviewCategory.content,
    name: '1 insight',
    description: 'No PageView pagination indicator should be needed.',
    cardWidth: 360,
    textScale: 1.0,
    language: _PreviewLanguage.english,
    textDirection: TextDirection.ltr,
    itemCount: 1,
  ),
  _PreviewScenario(
    id: 'content-2',
    category: _PreviewCategory.content,
    name: '2 insights',
    description:
        'Incomplete single page should remain centered without stretching metrics.',
    cardWidth: 360,
    textScale: 1.0,
    language: _PreviewLanguage.english,
    textDirection: TextDirection.ltr,
    itemCount: 2,
  ),
  _PreviewScenario(
    id: 'content-3',
    category: _PreviewCategory.content,
    name: '3 insights',
    description: 'Exactly one complete normal-density page.',
    cardWidth: 360,
    textScale: 1.0,
    language: _PreviewLanguage.english,
    textDirection: TextDirection.ltr,
    itemCount: 3,
  ),
  _PreviewScenario(
    id: 'content-4',
    category: _PreviewCategory.content,
    name: '4 insights',
    description:
        'Second page contains one centered statistic at normal text size.',
    cardWidth: 360,
    textScale: 1.0,
    language: _PreviewLanguage.english,
    textDirection: TextDirection.ltr,
    itemCount: 4,
  ),
  _PreviewScenario(
    id: 'content-6',
    category: _PreviewCategory.content,
    name: '6 insights',
    description: 'Exactly two full pages in the normal three-column layout.',
    cardWidth: 360,
    textScale: 1.0,
    language: _PreviewLanguage.english,
    textDirection: TextDirection.ltr,
    itemCount: 6,
  ),
  _PreviewScenario(
    id: 'content-9',
    category: _PreviewCategory.content,
    name: '9 insights',
    description: 'Maximum input and exactly three full normal-density pages.',
    cardWidth: 360,
    textScale: 1.0,
    language: _PreviewLanguage.english,
    textDirection: TextDirection.ltr,
    itemCount: 9,
  ),
  _PreviewScenario(
    id: 'content-stress-100',
    category: _PreviewCategory.content,
    name: 'Long-content stress test',
    description:
        'Long numeric value, verbose labels, missing supporting text and missing icon.',
    cardWidth: 360,
    textScale: 1.0,
    language: _PreviewLanguage.english,
    textDirection: TextDirection.ltr,
    insightsOverride: _stressInsights,
  ),
  _PreviewScenario(
    id: 'content-stress-200',
    category: _PreviewCategory.content,
    name: 'Long-content stress test at 200%',
    description:
        'Ensures long content becomes readable when the card falls back to one insight per page.',
    cardWidth: 360,
    textScale: 2.0,
    language: _PreviewLanguage.english,
    textDirection: TextDirection.ltr,
    insightsOverride: _stressInsights,
  ),
  _PreviewScenario(
    id: 'content-no-title',
    category: _PreviewCategory.content,
    name: 'No title',
    description:
        'Checks the card without a heading while retaining the navigation affordance.',
    cardWidth: 360,
    textScale: 1.0,
    language: _PreviewLanguage.english,
    textDirection: TextDirection.ltr,
    showTitle: false,
  ),
  _PreviewScenario(
    id: 'content-informational',
    category: _PreviewCategory.content,
    name: 'Informational / non-interactive',
    description:
        'No tap callback, no navigation affordance and no pressed state.',
    cardWidth: 360,
    textScale: 1.0,
    language: _PreviewLanguage.english,
    textDirection: TextDirection.ltr,
    interactive: false,
  ),

  //
  // OTHER ACCESSIBILITY FLAGS
  //
  _PreviewScenario(
    id: 'a11y-bold',
    category: _PreviewCategory.accessibility,
    name: 'System bold-text flag',
    description:
        'Exposes the boldText MediaQuery flag for current or future component behavior.',
    cardWidth: 360,
    textScale: 1.3,
    language: _PreviewLanguage.english,
    textDirection: TextDirection.ltr,
    boldText: true,
  ),
  _PreviewScenario(
    id: 'a11y-high-contrast',
    category: _PreviewCategory.accessibility,
    name: 'High-contrast flag',
    description:
        'Exposes the highContrast MediaQuery flag and makes future regressions easy to spot.',
    cardWidth: 360,
    textScale: 1.3,
    language: _PreviewLanguage.english,
    textDirection: TextDirection.ltr,
    highContrast: true,
  ),
  _PreviewScenario(
    id: 'a11y-reduced-motion',
    category: _PreviewCategory.accessibility,
    name: 'Reduced motion',
    description:
        'Animations should resolve immediately while paging and tapping remain functional.',
    cardWidth: 360,
    textScale: 1.3,
    language: _PreviewLanguage.english,
    textDirection: TextDirection.ltr,
    disableAnimations: true,
  ),
  _PreviewScenario(
    id: 'a11y-combined',
    category: _PreviewCategory.accessibility,
    name: 'Combined accessibility stress',
    description:
        '200% text, RTL Arabic, bold text, high contrast and reduced motion together.',
    cardWidth: 360,
    textScale: 2.0,
    language: _PreviewLanguage.arabic,
    textDirection: TextDirection.rtl,
    boldText: true,
    highContrast: true,
    disableAnimations: true,
    useCustomSemanticLabel: true,
  ),
];
