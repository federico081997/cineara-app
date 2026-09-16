import 'package:cineara_design_system/cineara_design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Placeholder season-details page.
///
/// The final implementation will present season metadata, progress, episode
/// lists, and previous/next season navigation without introducing a separate
/// root application app bar.
final class SeasonDetailsPage extends StatelessWidget {
  const SeasonDetailsPage({
    required this.mediaType,
    required this.mediaId,
    required this.seasonNumber,
    super.key,
  });

  final String mediaType;
  final int mediaId;
  final int seasonNumber;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.fromLTRB(
              CinearaSpacing.md,
              96,
              CinearaSpacing.md,
              CinearaNavigationPillMetrics.contentClearanceFor(context),
            ),
            children: [
              Text(
                'Season $seasonNumber',
                style: theme.textTheme.headlineMedium,
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
                'Season details and episodes will be implemented here.',
                style: theme.textTheme.bodyLarge,
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
