import 'dart:math' as math;

import 'package:flutter/material.dart';

// =============================================================================
// Public API
// =============================================================================

/// Visual treatment used by [CinearaMediaMetadata].
enum CinearaMediaMetadataVariant {
  /// Compact metadata used below Grid posters.
  grid,

  /// Richer metadata used beside posters in editorial List rows.
  list,
}

/// Shared media metadata presentation.
///
/// This component centralizes the exact title / descriptor / year / primary
/// genre grammar used by Cineara's media surfaces while remaining independent
/// from feature/domain models.
///
/// Grid:
///
/// ```text
/// Dune: Part Two
/// Movie · 2024
/// ```
///
/// List:
///
/// ```text
/// Dune: Part Two
/// Movie · 2024
/// Science fiction
/// ```
///
/// The caller owns localization for [descriptor] and [primaryGenre].
final class CinearaMediaMetadata extends StatelessWidget {
  const CinearaMediaMetadata.grid({
    required this.title,
    required this.descriptor,
    super.key,
    this.year,
  }) : variant = CinearaMediaMetadataVariant.grid,
       primaryGenre = null;

  const CinearaMediaMetadata.list({
    required this.title,
    required this.descriptor,
    super.key,
    this.year,
    this.primaryGenre,
  }) : variant = CinearaMediaMetadataVariant.list;

  final String title;
  final String descriptor;
  final int? year;
  final String? primaryGenre;
  final CinearaMediaMetadataVariant variant;

  /// Descriptor/year grammar used throughout the media presentation layer.
  String get descriptorLine {
    final int? resolvedYear = year;

    if (resolvedYear == null) {
      return descriptor;
    }

    return '$descriptor · $resolvedYear';
  }

  @override
  Widget build(BuildContext context) {
    return switch (variant) {
      CinearaMediaMetadataVariant.grid => _buildGrid(context),
      CinearaMediaMetadataVariant.list => _buildList(context),
    };
  }

  Widget _buildGrid(BuildContext context) {
    final _MetadataStyles styles = _MetadataStyles.resolve(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: styles.gridTitle,
        ),
        const SizedBox(height: 3),
        Text(
          descriptorLine,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: styles.metadata,
        ),
      ],
    );
  }

  Widget _buildList(BuildContext context) {
    final _MetadataStyles styles = _MetadataStyles.resolve(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: styles.listTitle,
        ),
        const SizedBox(height: 5),
        Text(
          descriptorLine,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: styles.metadata,
        ),
        if (_normalizedPrimaryGenre case final String genre) ...<Widget>[
          const SizedBox(height: 4),
          Text(
            genre,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: styles.genre,
          ),
        ],
      ],
    );
  }

  String? get _normalizedPrimaryGenre {
    final String? value = primaryGenre?.trim();

    if (value == null || value.isEmpty) {
      return null;
    }

    return value;
  }

  /// Measures the exact List metadata block used by
  /// [CinearaMediaMetadata.list].
  ///
  /// `media_list_item.dart` uses this to preserve the preview's adaptive
  /// vertical choreography without estimating accessibility text height.
  static double measureListHeight(
    BuildContext context, {
    required String title,
    required String descriptor,
    required double maxWidth,
    int? year,
    String? primaryGenre,
  }) {
    final _MetadataStyles styles = _MetadataStyles.resolve(context);
    final TextDirection textDirection = Directionality.of(context);
    final TextScaler textScaler = MediaQuery.textScalerOf(context);

    final String descriptorLine = year == null
        ? descriptor
        : '$descriptor · $year';

    double height = _measureTextHeight(
      text: title,
      style: styles.listTitle,
      textDirection: textDirection,
      textScaler: textScaler,
      maxWidth: maxWidth,
      maxLines: 2,
    );

    height += 5;

    height += _measureTextHeight(
      text: descriptorLine,
      style: styles.metadata,
      textDirection: textDirection,
      textScaler: textScaler,
      maxWidth: maxWidth,
      maxLines: 1,
    );

    final String? genre = primaryGenre?.trim();

    if (genre != null && genre.isNotEmpty) {
      height += 4;

      height += _measureTextHeight(
        text: genre,
        style: styles.genre,
        textDirection: textDirection,
        textScaler: textScaler,
        maxWidth: maxWidth,
        maxLines: 1,
      );
    }

    return height;
  }

  static double _measureTextHeight({
    required String text,
    required TextStyle style,
    required TextDirection textDirection,
    required TextScaler textScaler,
    required double maxWidth,
    required int maxLines,
  }) {
    final TextPainter painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: textDirection,
      textScaler: textScaler,
      maxLines: maxLines,
      ellipsis: '…',
    )..layout(maxWidth: math.max(1, maxWidth));

    return painter.height;
  }
}

// =============================================================================
// Internal styles
// =============================================================================

@immutable
final class _MetadataStyles {
  const _MetadataStyles({
    required this.gridTitle,
    required this.listTitle,
    required this.metadata,
    required this.genre,
  });

  final TextStyle gridTitle;
  final TextStyle listTitle;
  final TextStyle metadata;
  final TextStyle genre;

  factory _MetadataStyles.resolve(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return _MetadataStyles(
      gridTitle:
          theme.textTheme.titleSmall?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
          ) ??
          TextStyle(color: colors.onSurface, fontWeight: FontWeight.w700),
      listTitle:
          theme.textTheme.titleMedium?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
            height: 1.18,
          ) ??
          TextStyle(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
            height: 1.18,
          ),
      metadata:
          theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ) ??
          TextStyle(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
      genre:
          theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant.withValues(alpha: 0.82),
            fontWeight: FontWeight.w500,
          ) ??
          TextStyle(
            color: colors.onSurfaceVariant.withValues(alpha: 0.82),
            fontWeight: FontWeight.w500,
          ),
    );
  }
}
