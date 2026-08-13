import 'package:cineara_design_system/cineara_design_system.dart';
import 'package:flutter/material.dart';

/// Comprehensive manual preview for [PosterMediaCard].
///
/// Use this screen directly as the `home` of Cineara's existing [MaterialApp].
/// It deliberately does not create another [MaterialApp] or override Cineara's
/// light/dark themes.
///
/// The preview covers:
///
/// - real-device constraints and inherited accessibility settings;
/// - an interactive playground with live status mutations;
/// - all three quick-action types, with directly tappable actions;
/// - card tap and long-press interactions;
/// - `artworkOnly` and `artworkWithInformation`;
/// - portrait, square and shallow landscape artwork ratios;
/// - very narrow through spacious component widths;
/// - 100%, 130%, 180%, 200% and 250% text scaling;
/// - bold text, high contrast and reduced motion;
/// - LTR and RTL direction;
/// - English, Italian, German, Arabic, Hebrew, Japanese, Korean,
///   Simplified Chinese and Hindi fixture strings;
/// - status-dock suppression through [PosterStatusContext];
/// - NEW-release and NEW-episode visibility rules;
/// - dense combinations of status, rating, progress and quick-action overlays.
///
/// Language fixtures are intentionally local to this preview so different
/// scripts can be stress-tested even when a locale is not yet enabled in the
/// production ARB files.
class PosterMediaCardPreviewScreen extends StatefulWidget {
  const PosterMediaCardPreviewScreen({super.key});

  @override
  State<PosterMediaCardPreviewScreen> createState() =>
      _PosterMediaCardPreviewScreenState();
}

class _PosterMediaCardPreviewScreenState
    extends State<PosterMediaCardPreviewScreen> {
  _PreviewLanguage _language = _PreviewLanguage.english;
  _DirectionMode _directionMode = _DirectionMode.automatic;

  double _cardWidth = 170;
  double _textScale = 1.0;
  double _aspectRatio = 2 / 3;

  PosterMediaCardLayout _layout = PosterMediaCardLayout.artworkWithInformation;
  PosterQuickActionType _quickActionType = PosterQuickActionType.watchlist;
  PosterViewingStatus _viewingStatus = PosterViewingStatus.watching;

  bool _isFavourite = true;
  bool _isInWatchlist = false;
  bool _showProgress = true;
  bool _showNewContent = true;
  bool _newContentIsEpisodes = true;
  bool _boldText = false;
  bool _highContrast = false;
  bool _reduceMotion = false;

  int _collectionCount = 2;
  int _newEpisodeCount = 3;
  double _progress = 0.42;

  _PreviewCopy get _copy => _previewCopy(_language);

  TextDirection get _resolvedDirection {
    return switch (_directionMode) {
      _DirectionMode.automatic => _copy.direction,
      _DirectionMode.ltr => TextDirection.ltr,
      _DirectionMode.rtl => TextDirection.rtl,
    };
  }

  bool get _quickActionIsActive {
    return switch (_quickActionType) {
      PosterQuickActionType.watchlist => _isInWatchlist,
      PosterQuickActionType.favourite => _isFavourite,
      PosterQuickActionType.watched =>
        _viewingStatus == PosterViewingStatus.completed,
    };
  }

  void _showMessage(String message) {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(milliseconds: 900),
        ),
      );
  }

  void _handleQuickAction() {
    setState(() {
      switch (_quickActionType) {
        case PosterQuickActionType.watchlist:
          _isInWatchlist = !_isInWatchlist;
          break;

        case PosterQuickActionType.favourite:
          _isFavourite = !_isFavourite;
          break;

        case PosterQuickActionType.watched:
          if (_viewingStatus == PosterViewingStatus.completed) {
            _viewingStatus = PosterViewingStatus.notStarted;
            _progress = 0;
          } else {
            _viewingStatus = PosterViewingStatus.completed;
            _progress = 1;
          }
          break;
      }
    });

    _showMessage('Quick action: ${_quickActionType.name}');
  }

  void _resetPlayground() {
    setState(() {
      _language = _PreviewLanguage.english;
      _directionMode = _DirectionMode.automatic;
      _cardWidth = 170;
      _textScale = 1;
      _aspectRatio = 2 / 3;
      _layout = PosterMediaCardLayout.artworkWithInformation;
      _quickActionType = PosterQuickActionType.watchlist;
      _viewingStatus = PosterViewingStatus.watching;
      _isFavourite = true;
      _isInWatchlist = false;
      _showProgress = true;
      _showNewContent = true;
      _newContentIsEpisodes = true;
      _boldText = false;
      _highContrast = false;
      _reduceMotion = false;
      _collectionCount = 2;
      _newEpisodeCount = 3;
      _progress = 0.42;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PosterMediaCard Preview'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Reset playground',
            onPressed: _resetPlayground,
            icon: const Icon(Icons.restart_alt_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 48),
          children: <Widget>[
            const _InheritedEnvironmentBanner(),
            const SizedBox(height: 24),

            _PreviewSection(
              title: 'Interactive playground',
              subtitle:
                  'Tap the poster, long-press it, tap the quick action, '
                  'and mutate the passive status dock with the controls below.',
              icon: Icons.touch_app_rounded,
              child: _buildInteractivePlayground(context),
            ),

            const SizedBox(height: 32),

            _PreviewSection(
              title: 'Width and density breakpoints',
              subtitle:
                  'Dense overlay state at narrow, boundary and spacious widths.',
              icon: Icons.width_normal_rounded,
              child: _ScenarioStrip(
                scenarios: _widthScenarios,
                onEvent: _showMessage,
              ),
            ),

            const SizedBox(height: 32),

            _PreviewSection(
              title: 'Layouts and artwork ratios',
              subtitle:
                  'Information/no-information layouts plus portrait, square '
                  'and shallow artwork.',
              icon: Icons.aspect_ratio_rounded,
              child: _ScenarioStrip(
                scenarios: _layoutScenarios,
                onEvent: _showMessage,
              ),
            ),

            const SizedBox(height: 32),

            _PreviewSection(
              title: 'Languages and direction',
              subtitle:
                  'Long Latin text, RTL scripts and dense CJK/Indic scripts.',
              icon: Icons.translate_rounded,
              child: _ScenarioStrip(
                scenarios: _languageScenarios,
                onEvent: _showMessage,
              ),
            ),

            const SizedBox(height: 32),

            _PreviewSection(
              title: 'Accessibility text scaling',
              subtitle:
                  'The artwork remains finite while information below the '
                  'poster is allowed to grow.',
              icon: Icons.text_increase_rounded,
              child: _ScenarioStrip(
                scenarios: _textScaleScenarios,
                onEvent: _showMessage,
              ),
            ),

            const SizedBox(height: 32),

            _PreviewSection(
              title: 'Accessibility combinations',
              subtitle:
                  'Bold text, high contrast, reduced motion, RTL and large text '
                  'in difficult combinations.',
              icon: Icons.accessibility_new_rounded,
              child: _ScenarioStrip(
                scenarios: _accessibilityScenarios,
                onEvent: _showMessage,
              ),
            ),

            const SizedBox(height: 32),

            _PreviewSection(
              title: 'Status-dock context suppression',
              subtitle:
                  'The same personal state with each surrounding-context hint.',
              icon: Icons.view_compact_alt_rounded,
              child: _ScenarioStrip(
                scenarios: _statusContextScenarios,
                onEvent: _showMessage,
              ),
            ),

            const SizedBox(height: 32),

            _PreviewSection(
              title: 'Quick-action interaction',
              subtitle:
                  'Each quick action has independent mutable state. '
                  'Tap the circular action itself.',
              icon: Icons.ads_click_rounded,
              child: const _QuickActionInteractionStrip(),
            ),

            const SizedBox(height: 32),

            _PreviewSection(
              title: 'NEW-content visibility rules',
              subtitle:
                  'Release markers and episodic markers across viewing states.',
              icon: Icons.fiber_new_rounded,
              child: _ScenarioStrip(
                scenarios: _newContentScenarios,
                onEvent: _showMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractivePlayground(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MediaQueryData inheritedMediaQuery = MediaQuery.of(context);

    final PosterNewContent? newContent = !_showNewContent
        ? null
        : _newContentIsEpisodes
        ? PosterNewContent(
            type: PosterNewContentType.episodes,
            count: _newEpisodeCount,
          )
        : const PosterNewContent(type: PosterNewContentType.release);

    final _PreviewEnvironment environment = _PreviewEnvironment(
      textScale: _textScale,
      boldText: _boldText,
      highContrast: _highContrast,
      reduceMotion: _reduceMotion,
      direction: _resolvedDirection,
    );

    final PosterMediaCard card = PosterMediaCard(
      title: _copy.title,
      mediaTypeLabel: _copy.mediaType,
      labels: _copy.labels,
      subtitle: _copy.subtitle,
      secondarySubtitle: _copy.secondarySubtitle,
      worldIdentity: _copy.worldIdentity,
      externalRating: _copy.externalRating,
      userRating: '9.5',
      viewingStatus: _viewingStatus,
      isFavourite: _isFavourite,
      isInWatchlist: _isInWatchlist,
      collectionCount: _collectionCount,
      progress: _showProgress ? _progress : null,
      newContent: newContent,
      quickAction: PosterQuickAction(
        type: _quickActionType,
        isActive: _quickActionIsActive,
        onPressed: _handleQuickAction,
      ),
      aspectRatio: _aspectRatio,
      layout: _layout,
      onTap: () => _showMessage('Poster tapped'),
      onLongPress: () => _showMessage('Long press / action sheet'),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            children: <Widget>[
              Text(
                '${_copy.languageName} · '
                '${_resolvedDirection == TextDirection.rtl ? 'RTL' : 'LTR'} · '
                '${_textScale.toStringAsFixed(2)}× · '
                '${_cardWidth.round()} logical px',
                textAlign: TextAlign.center,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: _PreviewMediaQuery(
                  base: inheritedMediaQuery,
                  environment: environment,
                  child: SizedBox(width: _cardWidth, child: card),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'The status dock on the artwork is intentionally passive. '
                'Change Favourite, Watchlist, Collections and Viewing status '
                'below to verify its animated state changes.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        _ControlGroup(
          title: 'Language and direction',
          children: <Widget>[
            _LabeledDropdown<_PreviewLanguage>(
              label: 'Language fixture',
              value: _language,
              items: _PreviewLanguage.values,
              itemLabel: (_PreviewLanguage value) =>
                  _previewCopy(value).languageName,
              onChanged: (_PreviewLanguage value) {
                setState(() {
                  _language = value;
                });
              },
            ),
            _LabeledDropdown<_DirectionMode>(
              label: 'Text direction',
              value: _directionMode,
              items: _DirectionMode.values,
              itemLabel: (_DirectionMode value) => value.label,
              onChanged: (_DirectionMode value) {
                setState(() {
                  _directionMode = value;
                });
              },
            ),
          ],
        ),

        _ControlGroup(
          title: 'Component geometry',
          children: <Widget>[
            _ValueSlider(
              label: 'Card width',
              valueLabel: '${_cardWidth.round()} px',
              value: _cardWidth,
              min: 84,
              max: 320,
              divisions: 59,
              onChanged: (double value) {
                setState(() {
                  _cardWidth = value;
                });
              },
            ),
            _ValueSlider(
              label: 'Text scale',
              valueLabel: '${_textScale.toStringAsFixed(2)}×',
              value: _textScale,
              min: 1,
              max: 2.5,
              divisions: 30,
              onChanged: (double value) {
                setState(() {
                  _textScale = value;
                });
              },
            ),
            _LabeledDropdown<double>(
              label: 'Artwork ratio',
              value: _aspectRatio,
              items: const <double>[2 / 3, 1, 4 / 3, 16 / 9],
              itemLabel: _aspectRatioLabel,
              onChanged: (double value) {
                setState(() {
                  _aspectRatio = value;
                });
              },
            ),
            _LabeledDropdown<PosterMediaCardLayout>(
              label: 'Card layout',
              value: _layout,
              items: PosterMediaCardLayout.values,
              itemLabel: (PosterMediaCardLayout value) => value.name,
              onChanged: (PosterMediaCardLayout value) {
                setState(() {
                  _layout = value;
                });
              },
            ),
          ],
        ),

        _ControlGroup(
          title: 'Accessibility',
          children: <Widget>[
            _PreviewSwitch(
              label: 'Bold text',
              value: _boldText,
              onChanged: (bool value) {
                setState(() {
                  _boldText = value;
                });
              },
            ),
            _PreviewSwitch(
              label: 'High contrast',
              value: _highContrast,
              onChanged: (bool value) {
                setState(() {
                  _highContrast = value;
                });
              },
            ),
            _PreviewSwitch(
              label: 'Reduced motion',
              value: _reduceMotion,
              onChanged: (bool value) {
                setState(() {
                  _reduceMotion = value;
                });
              },
            ),
          ],
        ),

        _ControlGroup(
          title: 'Personal/status state',
          children: <Widget>[
            Text(
              'Viewing status',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (final PosterViewingStatus status
                    in PosterViewingStatus.values)
                  ChoiceChip(
                    selected: _viewingStatus == status,
                    label: Text(status.name),
                    onSelected: (_) {
                      setState(() {
                        _viewingStatus = status;

                        if (status == PosterViewingStatus.completed) {
                          _progress = 1;
                        } else if (status == PosterViewingStatus.notStarted) {
                          _progress = 0;
                        }
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                FilterChip(
                  selected: _isFavourite,
                  label: const Text('Favourite'),
                  onSelected: (bool value) {
                    setState(() {
                      _isFavourite = value;
                    });
                  },
                ),
                FilterChip(
                  selected: _isInWatchlist,
                  label: const Text('Watchlist'),
                  onSelected: (bool value) {
                    setState(() {
                      _isInWatchlist = value;
                    });
                  },
                ),
                ActionChip(
                  avatar: const Icon(Icons.remove_rounded, size: 18),
                  label: const Text('Collection'),
                  onPressed: _collectionCount <= 0
                      ? null
                      : () {
                          setState(() {
                            _collectionCount--;
                          });
                        },
                ),
                Chip(label: Text('$_collectionCount')),
                ActionChip(
                  avatar: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Collection'),
                  onPressed: () {
                    setState(() {
                      _collectionCount++;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            _PreviewSwitch(
              label: 'Show progress',
              value: _showProgress,
              onChanged: (bool value) {
                setState(() {
                  _showProgress = value;
                });
              },
            ),
            if (_showProgress)
              _ValueSlider(
                label: 'Progress',
                valueLabel: '${(_progress * 100).round()}%',
                value: _progress,
                min: 0,
                max: 1,
                divisions: 20,
                onChanged: (double value) {
                  setState(() {
                    _progress = value;
                  });
                },
              ),
          ],
        ),

        _ControlGroup(
          title: 'NEW content',
          children: <Widget>[
            _PreviewSwitch(
              label: 'Show NEW content',
              value: _showNewContent,
              onChanged: (bool value) {
                setState(() {
                  _showNewContent = value;
                });
              },
            ),
            if (_showNewContent) ...<Widget>[
              Wrap(
                spacing: 8,
                children: <Widget>[
                  ChoiceChip(
                    selected: !_newContentIsEpisodes,
                    label: const Text('Release'),
                    onSelected: (_) {
                      setState(() {
                        _newContentIsEpisodes = false;
                      });
                    },
                  ),
                  ChoiceChip(
                    selected: _newContentIsEpisodes,
                    label: const Text('Episodes'),
                    onSelected: (_) {
                      setState(() {
                        _newContentIsEpisodes = true;
                      });
                    },
                  ),
                ],
              ),
              if (_newContentIsEpisodes) ...<Widget>[
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    IconButton(
                      tooltip: 'Decrease new episode count',
                      onPressed: _newEpisodeCount <= 1
                          ? null
                          : () {
                              setState(() {
                                _newEpisodeCount--;
                              });
                            },
                      icon: const Icon(Icons.remove_circle_outline_rounded),
                    ),
                    Text(
                      '$_newEpisodeCount new episodes',
                      style: theme.textTheme.bodyMedium,
                    ),
                    IconButton(
                      tooltip: 'Increase new episode count',
                      onPressed: () {
                        setState(() {
                          _newEpisodeCount++;
                        });
                      },
                      icon: const Icon(Icons.add_circle_outline_rounded),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),

        _ControlGroup(
          title: 'Quick action',
          children: <Widget>[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (final PosterQuickActionType type
                    in PosterQuickActionType.values)
                  ChoiceChip(
                    selected: _quickActionType == type,
                    label: Text(type.name),
                    onSelected: (_) {
                      setState(() {
                        _quickActionType = type;
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Active: $_quickActionIsActive. '
              'Tap the circular button on the poster to toggle it.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
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
      padding: const EdgeInsets.all(12),
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
            size: 19,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Inherited from Cineara: ${theme.brightness.name} theme · '
              '${locale.toLanguageTag()} · '
              '${direction == TextDirection.rtl ? 'RTL' : 'LTR'} · '
              '${textScale.toStringAsFixed(2)}× text · '
              '${mediaQuery.boldText ? 'bold text' : 'normal weight'} · '
              '${mediaQuery.highContrast ? 'high contrast' : 'normal contrast'} · '
              '${mediaQuery.disableAnimations ? 'reduced motion' : 'motion enabled'}.',
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

class _PreviewSection extends StatelessWidget {
  const _PreviewSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, size: 21, color: theme.colorScheme.primary),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        child,
      ],
    );
  }
}

class _ControlGroup extends StatelessWidget {
  const _ControlGroup({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          ...children.expand(
            (Widget child) => <Widget>[child, const SizedBox(height: 10)],
          ),
        ],
      ),
    );
  }
}

class _PreviewSwitch extends StatelessWidget {
  const _PreviewSwitch({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(label),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _ValueSlider extends StatelessWidget {
  const _ValueSlider({
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  final String label;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
            Text(
              valueLabel,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        Slider(
          value: value.clamp(min, max).toDouble(),
          min: min,
          max: max,
          divisions: divisions,
          label: valueLabel,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _LabeledDropdown<T> extends StatelessWidget {
  const _LabeledDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> items;
  final String Function(T value) itemLabel;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Row(
      children: <Widget>[
        Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
        const SizedBox(width: 12),
        DropdownButton<T>(
          value: value,
          items: <DropdownMenuItem<T>>[
            for (final T item in items)
              DropdownMenuItem<T>(value: item, child: Text(itemLabel(item))),
          ],
          onChanged: (T? next) {
            if (next != null) {
              onChanged(next);
            }
          },
        ),
      ],
    );
  }
}

class _PreviewEnvironment {
  const _PreviewEnvironment({
    this.textScale = 1,
    this.boldText = false,
    this.highContrast = false,
    this.reduceMotion = false,
    this.direction = TextDirection.ltr,
  });

  final double textScale;
  final bool boldText;
  final bool highContrast;
  final bool reduceMotion;
  final TextDirection direction;
}

class _PreviewMediaQuery extends StatelessWidget {
  const _PreviewMediaQuery({
    required this.base,
    required this.environment,
    required this.child,
  });

  final MediaQueryData base;
  final _PreviewEnvironment environment;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: base.copyWith(
        textScaler: TextScaler.linear(environment.textScale),
        boldText: environment.boldText,
        highContrast: environment.highContrast,
        disableAnimations: environment.reduceMotion,
      ),
      child: Directionality(textDirection: environment.direction, child: child),
    );
  }
}

class _PosterScenario {
  const _PosterScenario({
    required this.id,
    required this.label,
    required this.language,
    this.width = 170,
    this.textScale = 1,
    this.boldText = false,
    this.highContrast = false,
    this.reduceMotion = false,
    this.directionOverride,
    this.aspectRatio = 2 / 3,
    this.layout = PosterMediaCardLayout.artworkWithInformation,
    this.viewingStatus = PosterViewingStatus.watching,
    this.isFavourite = true,
    this.isInWatchlist = true,
    this.collectionCount = 2,
    this.progress = 0.46,
    this.statusContext = PosterStatusContext.none,
    this.newContent,
    this.quickActionType,
    this.quickActionActive = false,
    this.showExternalRating = true,
    this.showUserRating = true,
    this.showStatusDock = true,
    this.showWorldIdentity = true,
    this.showNewContent = true,
  });

  final String id;
  final String label;
  final _PreviewLanguage language;

  final double width;
  final double textScale;
  final bool boldText;
  final bool highContrast;
  final bool reduceMotion;
  final TextDirection? directionOverride;
  final double aspectRatio;
  final PosterMediaCardLayout layout;

  final PosterViewingStatus viewingStatus;
  final bool isFavourite;
  final bool isInWatchlist;
  final int collectionCount;
  final double? progress;
  final PosterStatusContext statusContext;

  final PosterNewContent? newContent;
  final PosterQuickActionType? quickActionType;
  final bool quickActionActive;

  final bool showExternalRating;
  final bool showUserRating;
  final bool showStatusDock;
  final bool showWorldIdentity;
  final bool showNewContent;
}

class _ScenarioStrip extends StatelessWidget {
  const _ScenarioStrip({required this.scenarios, required this.onEvent});

  final List<_PosterScenario> scenarios;
  final ValueChanged<String> onEvent;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (int index = 0; index < scenarios.length; index++) ...<Widget>[
            _StaticScenarioCard(
              scenario: scenarios[index],
              mediaQuery: mediaQuery,
              onEvent: onEvent,
            ),
            if (index != scenarios.length - 1) const SizedBox(width: 18),
          ],
        ],
      ),
    );
  }
}

class _StaticScenarioCard extends StatelessWidget {
  const _StaticScenarioCard({
    required this.scenario,
    required this.mediaQuery,
    required this.onEvent,
  });

  final _PosterScenario scenario;
  final MediaQueryData mediaQuery;
  final ValueChanged<String> onEvent;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final _PreviewCopy copy = _previewCopy(scenario.language);

    final TextDirection direction =
        scenario.directionOverride ?? copy.direction;

    final double frameWidth = scenario.width < 116 ? 132 : scenario.width + 20;

    return SizedBox(
      width: frameWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            scenario.label,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '${scenario.width.round()}px · '
            '${scenario.textScale.toStringAsFixed(2)}× · '
            '${direction == TextDirection.rtl ? 'RTL' : 'LTR'}',
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          _PreviewMediaQuery(
            base: mediaQuery,
            environment: _PreviewEnvironment(
              textScale: scenario.textScale,
              boldText: scenario.boldText,
              highContrast: scenario.highContrast,
              reduceMotion: scenario.reduceMotion,
              direction: direction,
            ),
            child: SizedBox(
              width: scenario.width,
              child: PosterMediaCard(
                title: copy.title,
                mediaTypeLabel: copy.mediaType,
                labels: copy.labels,
                subtitle: copy.subtitle,
                secondarySubtitle: copy.secondarySubtitle,
                worldIdentity: copy.worldIdentity,
                externalRating: copy.externalRating,
                userRating: '9.5',
                viewingStatus: scenario.viewingStatus,
                isFavourite: scenario.isFavourite,
                isInWatchlist: scenario.isInWatchlist,
                collectionCount: scenario.collectionCount,
                statusContext: scenario.statusContext,
                progress: scenario.progress,
                newContent: scenario.newContent,
                quickAction: scenario.quickActionType == null
                    ? null
                    : PosterQuickAction(
                        type: scenario.quickActionType!,
                        isActive: scenario.quickActionActive,
                        onPressed: () =>
                            onEvent('${scenario.label}: quick action'),
                      ),
                aspectRatio: scenario.aspectRatio,
                layout: scenario.layout,
                showExternalRating: scenario.showExternalRating,
                showUserRating: scenario.showUserRating,
                showStatusDock: scenario.showStatusDock,
                showWorldIdentity: scenario.showWorldIdentity,
                showNewContent: scenario.showNewContent,
                onTap: () => onEvent('${scenario.label}: poster tap'),
                onLongPress: () => onEvent('${scenario.label}: long press'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionInteractionStrip extends StatelessWidget {
  const _QuickActionInteractionStrip();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (
            int index = 0;
            index < PosterQuickActionType.values.length;
            index++
          ) ...<Widget>[
            _QuickActionInteractionCard(
              type: PosterQuickActionType.values[index],
            ),
            if (index != PosterQuickActionType.values.length - 1)
              const SizedBox(width: 18),
          ],
        ],
      ),
    );
  }
}

class _QuickActionInteractionCard extends StatefulWidget {
  const _QuickActionInteractionCard({required this.type});

  final PosterQuickActionType type;

  @override
  State<_QuickActionInteractionCard> createState() =>
      _QuickActionInteractionCardState();
}

class _QuickActionInteractionCardState
    extends State<_QuickActionInteractionCard> {
  bool _active = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final _PreviewCopy copy = _previewCopy(_PreviewLanguage.english);

    final PosterViewingStatus viewingStatus =
        widget.type == PosterQuickActionType.watched && _active
        ? PosterViewingStatus.completed
        : PosterViewingStatus.watching;

    return SizedBox(
      width: 180,
      child: Column(
        children: <Widget>[
          Text(
            '${widget.type.name}: ${_active ? 'active' : 'inactive'}',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 160,
            child: PosterMediaCard(
              title: copy.title,
              mediaTypeLabel: copy.mediaType,
              labels: copy.labels,
              subtitle: copy.subtitle,
              secondarySubtitle: copy.secondarySubtitle,
              worldIdentity: copy.worldIdentity,
              externalRating: copy.externalRating,
              userRating: '9.5',
              viewingStatus: viewingStatus,
              isFavourite: widget.type == PosterQuickActionType.favourite
                  ? _active
                  : true,
              isInWatchlist: widget.type == PosterQuickActionType.watchlist
                  ? _active
                  : true,
              collectionCount: 2,
              progress: viewingStatus == PosterViewingStatus.completed
                  ? null
                  : 0.46,
              newContent: const PosterNewContent(
                type: PosterNewContentType.episodes,
                count: 2,
              ),
              quickAction: PosterQuickAction(
                type: widget.type,
                isActive: _active,
                onPressed: () {
                  setState(() {
                    _active = !_active;
                  });
                },
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Poster tap'),
                    duration: Duration(milliseconds: 800),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

String _aspectRatioLabel(double value) {
  if ((value - (2 / 3)).abs() < 0.001) {
    return '2:3 portrait';
  }
  if ((value - 1).abs() < 0.001) {
    return '1:1 square';
  }
  if ((value - (4 / 3)).abs() < 0.001) {
    return '4:3 landscape';
  }
  if ((value - (16 / 9)).abs() < 0.001) {
    return '16:9 landscape';
  }
  return value.toStringAsFixed(2);
}

enum _DirectionMode {
  automatic('Automatic'),
  ltr('Force LTR'),
  rtl('Force RTL');

  const _DirectionMode(this.label);

  final String label;
}

enum _PreviewLanguage {
  english,
  italian,
  german,
  arabic,
  hebrew,
  japanese,
  korean,
  chineseSimplified,
  hindi,
}

class _PreviewCopy {
  const _PreviewCopy({
    required this.languageName,
    required this.direction,
    required this.title,
    required this.mediaType,
    required this.subtitle,
    required this.secondarySubtitle,
    required this.worldIdentity,
    required this.externalRating,
    required this.labels,
  });

  final String languageName;
  final TextDirection direction;
  final String title;
  final String mediaType;
  final String subtitle;
  final String secondarySubtitle;
  final PosterWorldIdentity worldIdentity;
  final PosterExternalRating externalRating;
  final PosterMediaCardLabels labels;
}

_PreviewCopy _previewCopy(_PreviewLanguage language) {
  return switch (language) {
    _PreviewLanguage.english => _englishCopy,
    _PreviewLanguage.italian => _italianCopy,
    _PreviewLanguage.german => _germanCopy,
    _PreviewLanguage.arabic => _arabicCopy,
    _PreviewLanguage.hebrew => _hebrewCopy,
    _PreviewLanguage.japanese => _japaneseCopy,
    _PreviewLanguage.korean => _koreanCopy,
    _PreviewLanguage.chineseSimplified => _chineseCopy,
    _PreviewLanguage.hindi => _hindiCopy,
  };
}

final _PreviewCopy _englishCopy = _PreviewCopy(
  languageName: 'English',
  direction: TextDirection.ltr,
  title: 'The Extremely Long Journey Beyond the Horizon',
  mediaType: 'TV Series',
  subtitle: 'Season 2 · Episode 7 · Japan',
  secondarySubtitle: 'Fantasy · Adventure · 24 min',
  worldIdentity: const PosterWorldIdentity(
    label: 'JP · Anime',
    compactLabel: 'JP',
    semanticLabel: 'Japan, Anime',
  ),
  externalRating: const PosterExternalRating(
    sourceLabel: 'TMDb',
    value: '8.9',
    semanticLabel: 'TMDb rating 8.9',
  ),
  labels: PosterMediaCardLabels(
    notStarted: 'Not started',
    watching: 'Watching',
    caughtUp: 'Caught up',
    completed: 'Completed',
    rewatching: 'Rewatching',
    onHold: 'On hold',
    dropped: 'Dropped',
    favourite: 'Favourite',
    watchlist: 'In watchlist',
    userRating: (String rating) => 'Your rating $rating',
    collectionCount: (int count) =>
        count == 1 ? 'In 1 collection' : 'In $count collections',
    progress: (int percentage) => '$percentage percent watched',
    newContent: 'NEW',
    newContentBadge: (PosterNewContentType type, int? count) =>
        type == PosterNewContentType.release ? 'NEW' : '${count ?? 1} NEW',
    newContentDescription: (PosterNewContentType type, int? count) =>
        type == PosterNewContentType.release
        ? 'Newly released'
        : '${count ?? 1} new episodes available',
    quickAction: (PosterQuickActionType type, bool active, String title) =>
        '${active ? 'Remove' : 'Add'} ${type.name} for $title',
  ),
);

final _PreviewCopy _italianCopy = _PreviewCopy(
  languageName: 'Italiano',
  direction: TextDirection.ltr,
  title: 'Il lunghissimo viaggio oltre l’orizzonte',
  mediaType: 'Serie TV',
  subtitle: 'Stagione 2 · Episodio 7 · Giappone',
  secondarySubtitle: 'Fantasy · Avventura · 24 min',
  worldIdentity: const PosterWorldIdentity(
    label: 'JP · Anime',
    compactLabel: 'JP',
    semanticLabel: 'Giappone, anime',
  ),
  externalRating: const PosterExternalRating(
    sourceLabel: 'TMDb',
    value: '8,9',
    semanticLabel: 'Valutazione TMDb 8,9',
  ),
  labels: PosterMediaCardLabels(
    notStarted: 'Non iniziato',
    watching: 'In visione',
    caughtUp: 'In pari',
    completed: 'Completato',
    rewatching: 'In revisione',
    onHold: 'In pausa',
    dropped: 'Interrotto',
    favourite: 'Preferito',
    watchlist: 'Nella watchlist',
    userRating: (String rating) => 'La tua valutazione $rating',
    collectionCount: (int count) =>
        count == 1 ? 'In 1 raccolta' : 'In $count raccolte',
    progress: (int percentage) => '$percentage% visto',
    newContent: 'NOVITÀ',
    newContentBadge: (PosterNewContentType type, int? count) =>
        type == PosterNewContentType.release
        ? 'NOVITÀ'
        : '${count ?? 1} NOVITÀ',
    newContentDescription: (PosterNewContentType type, int? count) =>
        type == PosterNewContentType.release
        ? 'Nuova uscita'
        : '${count ?? 1} nuovi episodi disponibili',
    quickAction: (PosterQuickActionType type, bool active, String title) =>
        '${active ? 'Rimuovi' : 'Aggiungi'} ${type.name} per $title',
  ),
);

final _PreviewCopy _germanCopy = _PreviewCopy(
  languageName: 'Deutsch',
  direction: TextDirection.ltr,
  title: 'Die außergewöhnlich lange Reise hinter den Horizont',
  mediaType: 'Fernsehserie',
  subtitle: 'Staffel 2 · Folge 7 · Japan',
  secondarySubtitle: 'Fantasy · Abenteuer · 24 Minuten',
  worldIdentity: const PosterWorldIdentity(
    label: 'JP · Anime',
    compactLabel: 'JP',
    semanticLabel: 'Japan, Anime',
  ),
  externalRating: const PosterExternalRating(
    sourceLabel: 'TMDb',
    value: '8,9',
    semanticLabel: 'TMDb-Bewertung 8,9',
  ),
  labels: PosterMediaCardLabels(
    notStarted: 'Nicht begonnen',
    watching: 'Wird angesehen',
    caughtUp: 'Auf dem neuesten Stand',
    completed: 'Abgeschlossen',
    rewatching: 'Wird erneut angesehen',
    onHold: 'Pausiert',
    dropped: 'Abgebrochen',
    favourite: 'Favorit',
    watchlist: 'Auf der Merkliste',
    userRating: (String rating) => 'Deine Bewertung $rating',
    collectionCount: (int count) =>
        count == 1 ? 'In 1 Sammlung' : 'In $count Sammlungen',
    progress: (int percentage) => '$percentage% angesehen',
    newContent: 'NEU',
    newContentBadge: (PosterNewContentType type, int? count) =>
        type == PosterNewContentType.release ? 'NEU' : '${count ?? 1} NEU',
    newContentDescription: (PosterNewContentType type, int? count) =>
        type == PosterNewContentType.release
        ? 'Neu veröffentlicht'
        : '${count ?? 1} neue Folgen verfügbar',
    quickAction: (PosterQuickActionType type, bool active, String title) =>
        '${active ? 'Entfernen' : 'Hinzufügen'} ${type.name}: $title',
  ),
);

final _PreviewCopy _arabicCopy = _PreviewCopy(
  languageName: 'العربية',
  direction: TextDirection.rtl,
  title: 'الرحلة الطويلة للغاية إلى ما وراء الأفق',
  mediaType: 'مسلسل تلفزيوني',
  subtitle: 'الموسم ٢ · الحلقة ٧ · اليابان',
  secondarySubtitle: 'خيال · مغامرة · ٢٤ دقيقة',
  worldIdentity: const PosterWorldIdentity(
    label: 'JP · أنمي',
    compactLabel: 'JP',
    semanticLabel: 'اليابان، أنمي',
  ),
  externalRating: const PosterExternalRating(
    sourceLabel: 'TMDb',
    value: '٨٫٩',
    semanticLabel: 'تقييم TMDb هو ٨٫٩',
  ),
  labels: PosterMediaCardLabels(
    notStarted: 'لم يبدأ',
    watching: 'قيد المشاهدة',
    caughtUp: 'تمت متابعة المتاح',
    completed: 'مكتمل',
    rewatching: 'إعادة مشاهدة',
    onHold: 'متوقف مؤقتًا',
    dropped: 'تم تركه',
    favourite: 'مفضلة',
    watchlist: 'في قائمة المشاهدة',
    userRating: (String rating) => 'تقييمك $rating',
    collectionCount: (int count) => 'في $count مجموعات',
    progress: (int percentage) => 'تمت مشاهدة $percentage٪',
    newContent: 'جديد',
    newContentBadge: (PosterNewContentType type, int? count) =>
        type == PosterNewContentType.release ? 'جديد' : '${count ?? 1} جديد',
    newContentDescription: (PosterNewContentType type, int? count) =>
        type == PosterNewContentType.release
        ? 'إصدار جديد'
        : '${count ?? 1} حلقات جديدة متاحة',
    quickAction: (PosterQuickActionType type, bool active, String title) =>
        '${active ? 'إزالة' : 'إضافة'} ${type.name} لـ $title',
  ),
);

final _PreviewCopy _hebrewCopy = _PreviewCopy(
  languageName: 'עברית',
  direction: TextDirection.rtl,
  title: 'המסע הארוך במיוחד מעבר לאופק',
  mediaType: 'סדרת טלוויזיה',
  subtitle: 'עונה 2 · פרק 7 · יפן',
  secondarySubtitle: 'פנטזיה · הרפתקה · 24 דקות',
  worldIdentity: const PosterWorldIdentity(
    label: 'JP · אנימה',
    compactLabel: 'JP',
    semanticLabel: 'יפן, אנימה',
  ),
  externalRating: const PosterExternalRating(
    sourceLabel: 'TMDb',
    value: '8.9',
    semanticLabel: 'דירוג TMDb 8.9',
  ),
  labels: PosterMediaCardLabels(
    notStarted: 'לא התחיל',
    watching: 'בצפייה',
    caughtUp: 'מעודכן',
    completed: 'הושלם',
    rewatching: 'צפייה חוזרת',
    onHold: 'בהשהיה',
    dropped: 'ננטש',
    favourite: 'מועדף',
    watchlist: 'ברשימת הצפייה',
    userRating: (String rating) => 'הדירוג שלך $rating',
    collectionCount: (int count) => 'ב־$count אוספים',
    progress: (int percentage) => '$percentage% נצפו',
    newContent: 'חדש',
    newContentBadge: (PosterNewContentType type, int? count) =>
        type == PosterNewContentType.release ? 'חדש' : '${count ?? 1} חדש',
    newContentDescription: (PosterNewContentType type, int? count) =>
        type == PosterNewContentType.release
        ? 'מהדורה חדשה'
        : '${count ?? 1} פרקים חדשים זמינים',
    quickAction: (PosterQuickActionType type, bool active, String title) =>
        '${active ? 'הסר' : 'הוסף'} ${type.name} עבור $title',
  ),
);

final _PreviewCopy _japaneseCopy = _PreviewCopy(
  languageName: '日本語',
  direction: TextDirection.ltr,
  title: '地平線の彼方へ続く、とても長い旅の物語',
  mediaType: 'テレビシリーズ',
  subtitle: 'シーズン2 · 第7話 · 日本',
  secondarySubtitle: 'ファンタジー · アドベンチャー · 24分',
  worldIdentity: const PosterWorldIdentity(
    label: 'JP · アニメ',
    compactLabel: 'JP',
    semanticLabel: '日本、アニメ',
  ),
  externalRating: const PosterExternalRating(
    sourceLabel: 'TMDb',
    value: '8.9',
    semanticLabel: 'TMDb評価8.9',
  ),
  labels: PosterMediaCardLabels(
    notStarted: '未視聴',
    watching: '視聴中',
    caughtUp: '最新話まで視聴',
    completed: '視聴済み',
    rewatching: '再視聴中',
    onHold: '一時停止',
    dropped: '視聴中止',
    favourite: 'お気に入り',
    watchlist: 'ウォッチリスト',
    userRating: (String rating) => 'あなたの評価 $rating',
    collectionCount: (int count) => '$count個のコレクション',
    progress: (int percentage) => '視聴率$percentage%',
    newContent: '新着',
    newContentBadge: (PosterNewContentType type, int? count) =>
        type == PosterNewContentType.release ? '新着' : '新着${count ?? 1}話',
    newContentDescription: (PosterNewContentType type, int? count) =>
        type == PosterNewContentType.release
        ? '新着作品'
        : '新しいエピソードが${count ?? 1}話あります',
    quickAction: (PosterQuickActionType type, bool active, String title) =>
        '$title の ${type.name} を${active ? '解除' : '追加'}',
  ),
);

final _PreviewCopy _koreanCopy = _PreviewCopy(
  languageName: '한국어',
  direction: TextDirection.ltr,
  title: '지평선 너머로 이어지는 아주 긴 여행 이야기',
  mediaType: 'TV 시리즈',
  subtitle: '시즌 2 · 에피소드 7 · 일본',
  secondarySubtitle: '판타지 · 모험 · 24분',
  worldIdentity: const PosterWorldIdentity(
    label: 'JP · 애니메이션',
    compactLabel: 'JP',
    semanticLabel: '일본, 애니메이션',
  ),
  externalRating: const PosterExternalRating(
    sourceLabel: 'TMDb',
    value: '8.9',
    semanticLabel: 'TMDb 평점 8.9',
  ),
  labels: PosterMediaCardLabels(
    notStarted: '시작 안 함',
    watching: '시청 중',
    caughtUp: '최신화까지 시청',
    completed: '완료',
    rewatching: '다시 보는 중',
    onHold: '일시 중지',
    dropped: '중단',
    favourite: '즐겨찾기',
    watchlist: '관심 목록',
    userRating: (String rating) => '내 평점 $rating',
    collectionCount: (int count) => '$count개 컬렉션',
    progress: (int percentage) => '$percentage% 시청',
    newContent: '신규',
    newContentBadge: (PosterNewContentType type, int? count) =>
        type == PosterNewContentType.release ? '신규' : '신규 ${count ?? 1}화',
    newContentDescription: (PosterNewContentType type, int? count) =>
        type == PosterNewContentType.release ? '새 작품' : '새 에피소드 ${count ?? 1}개',
    quickAction: (PosterQuickActionType type, bool active, String title) =>
        '$title ${type.name} ${active ? '해제' : '추가'}',
  ),
);

final _PreviewCopy _chineseCopy = _PreviewCopy(
  languageName: '简体中文',
  direction: TextDirection.ltr,
  title: '通往地平线彼端的漫长旅程故事',
  mediaType: '电视剧',
  subtitle: '第2季 · 第7集 · 日本',
  secondarySubtitle: '奇幻 · 冒险 · 24分钟',
  worldIdentity: const PosterWorldIdentity(
    label: 'JP · 动画',
    compactLabel: 'JP',
    semanticLabel: '日本，动画',
  ),
  externalRating: const PosterExternalRating(
    sourceLabel: 'TMDb',
    value: '8.9',
    semanticLabel: 'TMDb评分8.9',
  ),
  labels: PosterMediaCardLabels(
    notStarted: '未开始',
    watching: '观看中',
    caughtUp: '已追到最新',
    completed: '已看完',
    rewatching: '重看中',
    onHold: '已暂停',
    dropped: '已弃剧',
    favourite: '收藏',
    watchlist: '想看列表',
    userRating: (String rating) => '你的评分 $rating',
    collectionCount: (int count) => '位于$count个片单',
    progress: (int percentage) => '已观看$percentage%',
    newContent: '新内容',
    newContentBadge: (PosterNewContentType type, int? count) =>
        type == PosterNewContentType.release ? '新内容' : '${count ?? 1}集新内容',
    newContentDescription: (PosterNewContentType type, int? count) =>
        type == PosterNewContentType.release ? '新上线' : '有${count ?? 1}集新内容',
    quickAction: (PosterQuickActionType type, bool active, String title) =>
        '${active ? '移除' : '添加'} $title 的 ${type.name}',
  ),
);

final _PreviewCopy _hindiCopy = _PreviewCopy(
  languageName: 'हिन्दी',
  direction: TextDirection.ltr,
  title: 'क्षितिज के उस पार की बहुत लंबी यात्रा की कहानी',
  mediaType: 'टीवी श्रृंखला',
  subtitle: 'सीज़न 2 · एपिसोड 7 · जापान',
  secondarySubtitle: 'फैंटेसी · रोमांच · 24 मिनट',
  worldIdentity: const PosterWorldIdentity(
    label: 'JP · ऐनिमे',
    compactLabel: 'JP',
    semanticLabel: 'जापान, ऐनिमे',
  ),
  externalRating: const PosterExternalRating(
    sourceLabel: 'TMDb',
    value: '8.9',
    semanticLabel: 'TMDb रेटिंग 8.9',
  ),
  labels: PosterMediaCardLabels(
    notStarted: 'शुरू नहीं किया',
    watching: 'देख रहे हैं',
    caughtUp: 'नवीनतम तक देखा',
    completed: 'पूरा किया',
    rewatching: 'फिर से देख रहे हैं',
    onHold: 'रुका हुआ',
    dropped: 'छोड़ दिया',
    favourite: 'पसंदीदा',
    watchlist: 'वॉचलिस्ट में',
    userRating: (String rating) => 'आपकी रेटिंग $rating',
    collectionCount: (int count) => '$count संग्रहों में',
    progress: (int percentage) => '$percentage% देखा',
    newContent: 'नया',
    newContentBadge: (PosterNewContentType type, int? count) =>
        type == PosterNewContentType.release ? 'नया' : '${count ?? 1} नए',
    newContentDescription: (PosterNewContentType type, int? count) =>
        type == PosterNewContentType.release
        ? 'नई रिलीज़'
        : '${count ?? 1} नए एपिसोड उपलब्ध',
    quickAction: (PosterQuickActionType type, bool active, String title) =>
        '$title के ${type.name} को ${active ? 'हटाएँ' : 'जोड़ें'}',
  ),
);

final List<_PosterScenario> _widthScenarios = <_PosterScenario>[
  const _PosterScenario(
    id: 'width-88',
    label: 'Very narrow',
    language: _PreviewLanguage.english,
    width: 88,
    newContent: PosterNewContent(type: PosterNewContentType.episodes, count: 3),
    quickActionType: PosterQuickActionType.watchlist,
  ),
  const _PosterScenario(
    id: 'width-100',
    label: '100 boundary',
    language: _PreviewLanguage.english,
    width: 100,
    newContent: PosterNewContent(type: PosterNewContentType.episodes, count: 3),
    quickActionType: PosterQuickActionType.watchlist,
  ),
  const _PosterScenario(
    id: 'width-144',
    label: '144 boundary',
    language: _PreviewLanguage.english,
    width: 144,
    newContent: PosterNewContent(type: PosterNewContentType.episodes, count: 3),
    quickActionType: PosterQuickActionType.watchlist,
  ),
  const _PosterScenario(
    id: 'width-145',
    label: '145 boundary',
    language: _PreviewLanguage.english,
    width: 145,
    newContent: PosterNewContent(type: PosterNewContentType.episodes, count: 3),
    quickActionType: PosterQuickActionType.watchlist,
  ),
  const _PosterScenario(
    id: 'width-219',
    label: '219 boundary',
    language: _PreviewLanguage.english,
    width: 219,
    newContent: PosterNewContent(type: PosterNewContentType.episodes, count: 3),
    quickActionType: PosterQuickActionType.watchlist,
  ),
  const _PosterScenario(
    id: 'width-220',
    label: '220 boundary',
    language: _PreviewLanguage.english,
    width: 220,
    newContent: PosterNewContent(type: PosterNewContentType.episodes, count: 3),
    quickActionType: PosterQuickActionType.watchlist,
  ),
  const _PosterScenario(
    id: 'width-300',
    label: 'Spacious',
    language: _PreviewLanguage.english,
    width: 300,
    newContent: PosterNewContent(type: PosterNewContentType.episodes, count: 3),
    quickActionType: PosterQuickActionType.watchlist,
  ),
];

final List<_PosterScenario> _layoutScenarios = <_PosterScenario>[
  const _PosterScenario(
    id: 'layout-info-portrait',
    label: 'Info · 2:3',
    language: _PreviewLanguage.italian,
    width: 180,
    aspectRatio: 2 / 3,
    newContent: PosterNewContent(type: PosterNewContentType.release),
  ),
  const _PosterScenario(
    id: 'layout-artwork-portrait',
    label: 'Artwork only · 2:3',
    language: _PreviewLanguage.english,
    width: 180,
    aspectRatio: 2 / 3,
    layout: PosterMediaCardLayout.artworkOnly,
    newContent: PosterNewContent(type: PosterNewContentType.episodes, count: 2),
  ),
  const _PosterScenario(
    id: 'layout-square',
    label: 'Info · 1:1',
    language: _PreviewLanguage.japanese,
    width: 210,
    aspectRatio: 1,
    newContent: PosterNewContent(type: PosterNewContentType.episodes, count: 2),
  ),
  const _PosterScenario(
    id: 'layout-4-3',
    label: 'Info · 4:3',
    language: _PreviewLanguage.german,
    width: 240,
    aspectRatio: 4 / 3,
    newContent: PosterNewContent(type: PosterNewContentType.release),
    quickActionType: PosterQuickActionType.favourite,
  ),
  const _PosterScenario(
    id: 'layout-16-9',
    label: 'Artwork only · 16:9',
    language: _PreviewLanguage.arabic,
    width: 280,
    aspectRatio: 16 / 9,
    layout: PosterMediaCardLayout.artworkOnly,
    newContent: PosterNewContent(type: PosterNewContentType.episodes, count: 4),
    quickActionType: PosterQuickActionType.watchlist,
  ),
];

final List<_PosterScenario> _languageScenarios = <_PosterScenario>[
  for (final _PreviewLanguage language in _PreviewLanguage.values)
    _PosterScenario(
      id: 'language-${language.name}',
      label: _previewCopy(language).languageName,
      language: language,
      width: 180,
      newContent: const PosterNewContent(
        type: PosterNewContentType.episodes,
        count: 3,
      ),
      quickActionType: PosterQuickActionType.watchlist,
    ),
];

final List<_PosterScenario> _textScaleScenarios = <_PosterScenario>[
  const _PosterScenario(
    id: 'scale-100',
    label: '100%',
    language: _PreviewLanguage.german,
    width: 165,
    textScale: 1,
    newContent: PosterNewContent(type: PosterNewContentType.episodes, count: 3),
  ),
  const _PosterScenario(
    id: 'scale-130',
    label: '130%',
    language: _PreviewLanguage.german,
    width: 165,
    textScale: 1.30,
    newContent: PosterNewContent(type: PosterNewContentType.episodes, count: 3),
  ),
  const _PosterScenario(
    id: 'scale-180',
    label: '180%',
    language: _PreviewLanguage.japanese,
    width: 165,
    textScale: 1.80,
    newContent: PosterNewContent(type: PosterNewContentType.episodes, count: 3),
  ),
  const _PosterScenario(
    id: 'scale-200',
    label: '200%',
    language: _PreviewLanguage.arabic,
    width: 165,
    textScale: 2,
    newContent: PosterNewContent(type: PosterNewContentType.episodes, count: 3),
  ),
  const _PosterScenario(
    id: 'scale-250',
    label: '250%',
    language: _PreviewLanguage.hindi,
    width: 165,
    textScale: 2.5,
    newContent: PosterNewContent(type: PosterNewContentType.episodes, count: 3),
  ),
];

final List<_PosterScenario> _accessibilityScenarios = <_PosterScenario>[
  const _PosterScenario(
    id: 'a11y-bold',
    label: 'Bold text',
    language: _PreviewLanguage.italian,
    width: 170,
    boldText: true,
    newContent: PosterNewContent(type: PosterNewContentType.episodes, count: 2),
  ),
  const _PosterScenario(
    id: 'a11y-contrast',
    label: 'High contrast',
    language: _PreviewLanguage.english,
    width: 170,
    highContrast: true,
    newContent: PosterNewContent(type: PosterNewContentType.release),
  ),
  const _PosterScenario(
    id: 'a11y-motion',
    label: 'Reduced motion',
    language: _PreviewLanguage.english,
    width: 170,
    reduceMotion: true,
    quickActionType: PosterQuickActionType.favourite,
  ),
  const _PosterScenario(
    id: 'a11y-combined',
    label: '200% · bold · contrast',
    language: _PreviewLanguage.german,
    width: 170,
    textScale: 2,
    boldText: true,
    highContrast: true,
    newContent: PosterNewContent(type: PosterNewContentType.episodes, count: 4),
    quickActionType: PosterQuickActionType.watchlist,
  ),
  const _PosterScenario(
    id: 'a11y-rtl-combined',
    label: 'RTL · 200% · all',
    language: _PreviewLanguage.arabic,
    width: 170,
    textScale: 2,
    boldText: true,
    highContrast: true,
    reduceMotion: true,
    newContent: PosterNewContent(type: PosterNewContentType.episodes, count: 4),
    quickActionType: PosterQuickActionType.watchlist,
  ),
  const _PosterScenario(
    id: 'a11y-narrow-cjk',
    label: 'CJK · 250% · narrow',
    language: _PreviewLanguage.japanese,
    width: 118,
    textScale: 2.5,
    boldText: true,
    newContent: PosterNewContent(type: PosterNewContentType.episodes, count: 5),
    quickActionType: PosterQuickActionType.favourite,
  ),
];

final List<_PosterScenario> _statusContextScenarios = <_PosterScenario>[
  for (final PosterStatusContext context in PosterStatusContext.values)
    _PosterScenario(
      id: 'context-${context.name}',
      label: context.name,
      language: _PreviewLanguage.english,
      width: 165,
      viewingStatus: PosterViewingStatus.rewatching,
      isFavourite: true,
      isInWatchlist: true,
      collectionCount: 3,
      progress: 0.64,
      statusContext: context,
      newContent: const PosterNewContent(
        type: PosterNewContentType.episodes,
        count: 2,
      ),
    ),
];

final List<_PosterScenario> _newContentScenarios = <_PosterScenario>[
  const _PosterScenario(
    id: 'new-release-not-started',
    label: 'Release · not started',
    language: _PreviewLanguage.english,
    width: 165,
    viewingStatus: PosterViewingStatus.notStarted,
    progress: null,
    newContent: PosterNewContent(type: PosterNewContentType.release),
  ),
  const _PosterScenario(
    id: 'new-episodes-not-started',
    label: 'Episodes · not started',
    language: _PreviewLanguage.english,
    width: 165,
    viewingStatus: PosterViewingStatus.notStarted,
    progress: null,
    newContent: PosterNewContent(type: PosterNewContentType.episodes, count: 3),
  ),
  const _PosterScenario(
    id: 'new-episodes-watching',
    label: 'Episodes · watching',
    language: _PreviewLanguage.japanese,
    width: 165,
    viewingStatus: PosterViewingStatus.watching,
    newContent: PosterNewContent(type: PosterNewContentType.episodes, count: 3),
  ),
  const _PosterScenario(
    id: 'new-episodes-completed',
    label: 'Episodes · completed',
    language: _PreviewLanguage.german,
    width: 165,
    viewingStatus: PosterViewingStatus.completed,
    progress: null,
    newContent: PosterNewContent(type: PosterNewContentType.episodes, count: 4),
  ),
  const _PosterScenario(
    id: 'new-episodes-dropped',
    label: 'Episodes · dropped',
    language: _PreviewLanguage.arabic,
    width: 165,
    viewingStatus: PosterViewingStatus.dropped,
    progress: null,
    newContent: PosterNewContent(type: PosterNewContentType.episodes, count: 2),
  ),
];
