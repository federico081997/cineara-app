import 'package:cineara_design_system/cineara_design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Placeholder episode-details page.
///
/// The final implementation will provide episode artwork, metadata, progress,
/// actions, contextual links, and previous/next episode navigation while
/// keeping Cineara's persistent bottom navigation visible.
final class EpisodeDetailsPage extends StatelessWidget {
  const EpisodeDetailsPage({
    required this.mediaType,
    required this.mediaId,
    required this.seasonNumber,
    required this.episodeNumber,
    super.key,
  });

  final String mediaType;
  final int mediaId;
  final int seasonNumber;
  final int episodeNumber;

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
              _EpisodePlaceholderHero(
                seasonNumber: seasonNumber,
                episodeNumber: episodeNumber,
              ),
              Padding(
                padding: const EdgeInsets.all(CinearaSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Season $seasonNumber · Episode $episodeNumber',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: CinearaSpacing.xs),
                    Text(
                      '$mediaType · $mediaId',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: CinearaSpacing.xl),
                    Text(
                      'Episode details will be implemented here.',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(CinearaSpacing.md),
              child: Align(
                alignment: AlignmentDirectional.topStart,
                child: Material(
                  color: theme.colorScheme.surfaceContainerHigh,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: IconButton(
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).backButtonTooltip,
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      }
                    },
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final class _EpisodePlaceholderHero extends StatelessWidget {
  const _EpisodePlaceholderHero({
    required this.seasonNumber,
    required this.episodeNumber,
  });

  final int seasonNumber;
  final int episodeNumber;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AspectRatio(
      aspectRatio: CinearaGeometry.landscapeAspectRatio,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colors.surfaceContainerHighest, colors.surfaceContainer],
          ),
        ),
        child: Center(
          child: Icon(
            Icons.movie_outlined,
            size: 48,
            color: colors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
