import 'package:flutter/material.dart';

import '../badges/external_rating_badge.dart';
import '../badges/status_badge.dart';
import 'media_metadata.dart';
import 'media_poster.dart';
import 'media_poster_overlay.dart';
import 'media_progress_indicator.dart';
import 'media_status_dock.dart';

// =============================================================================
// Media Grid item
// =============================================================================

/// Reusable Cineara Grid/rail media item.
///
/// It owns only presentation:
///
/// ```text
/// poster
/// ├─ lifecycle status      top-start
/// ├─ external rating       top-end
/// ├─ personal-state dock   bottom corner
/// └─ viewing progress      bottom edge
///
/// title
/// descriptor · year
/// ```
///
/// Only the poster is interactive.
///
/// The title and metadata are deliberately passive so tapping, hovering, or
/// focusing them does not produce a visual interaction highlight or a second
/// navigation target.
///
/// Poster interaction remains owned by [CinearaMediaPoster]. The application
/// owns navigation, quick actions, media state, localization, and the concrete
/// overlay widgets passed to this component.
final class CinearaMediaGridItem extends StatelessWidget {
  const CinearaMediaGridItem({
    required this.artwork,
    required this.title,
    required this.descriptor,
    required this.onPosterTap,
    super.key,
    this.year,
    this.statusBadge,
    this.externalRatingBadge,
    this.statusDock,
    this.progressIndicator,
    this.onPosterLongPress,
    this.semanticHint,
    this.heroTag,
    this.heroTransitionOnUserGestures = false,
    this.metadataTopGap = 10,
  }) : assert(metadataTopGap >= 0, 'metadataTopGap must not be negative.');

  final Widget artwork;

  final String title;
  final String descriptor;
  final int? year;

  final CinearaStatusBadge? statusBadge;
  final CinearaExternalRatingBadge? externalRatingBadge;
  final CinearaStatusDock? statusDock;
  final CinearaMediaProgressIndicator? progressIndicator;

  /// Opens the media destination from the poster.
  final VoidCallback onPosterTap;

  /// Opens media quick actions from a poster long press.
  final VoidCallback? onPosterLongPress;

  /// Localized poster interaction hint.
  final String? semanticHint;

  final Object? heroTag;
  final bool heroTransitionOnUserGestures;

  /// Gap between poster and metadata.
  ///
  /// The preview uses 10 dp.
  final double metadataTopGap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CinearaMediaPoster(
          artwork: artwork,
          semanticLabel: title,
          semanticHint: semanticHint,
          onTap: onPosterTap,
          onLongPress: onPosterLongPress,
          heroTag: heroTag,
          heroTransitionOnUserGestures: heroTransitionOnUserGestures,
          overlay: CinearaMediaPosterOverlay(
            statusBadge: statusBadge,
            externalRatingBadge: externalRatingBadge,
            statusDock: statusDock,
            progressIndicator: progressIndicator,
          ),
        ),
        SizedBox(height: metadataTopGap),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: CinearaMediaMetadata.grid(
            title: title,
            descriptor: descriptor,
            year: year,
          ),
        ),
      ],
    );
  }
}
