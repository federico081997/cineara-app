import 'package:cineara_design_system/cineara_design_system.dart';
import 'package:cineara_design_system/components/navigation/bottom_navigation/navigation_pill_metrics.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Placeholder media-details page.
///
/// This page intentionally has no conventional app bar. Cineara's eventual
/// movie and series detail experience will use cinematic artwork with floating
/// navigation controls.
///
/// [mediaType] identifies the routed media category.
///
/// [mediaId] is the corresponding external media identifier.
final class MediaDetailsPage extends StatelessWidget {
  const MediaDetailsPage({
    required this.mediaType,
    required this.mediaId,
    super.key,
  });

  final String mediaType;
  final int mediaId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.only(
              bottom: CinearaNavigationPillMetrics.contentClearanceFor(context),
            ),
            children: [
              _PlaceholderHero(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Media details',
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: CinearaSpacing.xs),
                    Text(
                      '$mediaType · $mediaId',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(CinearaSpacing.md),
                child: Text(
                  'The cinematic media-details layout will be implemented here.',
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ],
          ),

          // Cinematic pages use a floating back control rather than the root
          // application app bar.
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(CinearaSpacing.md),
              child: _FloatingBackButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final class _PlaceholderHero extends StatelessWidget {
  const _PlaceholderHero({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      height: 360,
      padding: const EdgeInsets.all(CinearaSpacing.lg),
      alignment: Alignment.bottomLeft,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colors.surfaceContainerHighest, colors.surface],
        ),
      ),
      child: SafeArea(bottom: false, child: child),
    );
  }
}

final class _FloatingBackButton extends StatelessWidget {
  const _FloatingBackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: IconButton(
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        onPressed: onPressed,
        icon: const Icon(Icons.arrow_back_rounded),
      ),
    );
  }
}
