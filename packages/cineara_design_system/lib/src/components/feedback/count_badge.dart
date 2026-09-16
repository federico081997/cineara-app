import 'package:flutter/material.dart';

import '../../foundations/tokens/icon_sizes.dart';
import '../../foundations/tokens/radius.dart';
import '../../foundations/tokens/spacing.dart';
import '../../foundations/tokens/typography.dart';

/// Displays a compact Cineara count or status badge.
///
/// Suitable for notification counts and other short badge labels such as
/// `3`, `9+`, or a localized short status label.
///
/// Badges are normally supplementary. When embedded inside another accessible
/// control, leave [semanticLabel] null and provide the full meaning through the
/// parent control's semantic label.
final class CinearaCountBadge extends StatelessWidget {
  const CinearaCountBadge({
    required this.label,
    this.scale = 1,
    this.backgroundColor,
    this.foregroundColor,
    this.outlineColor,
    this.semanticLabel,
    super.key,
  }) : assert(scale > 0);

  static const double _outlineWidth = 1.5;
  static const double _highContrastOutlineWidth = 2;

  /// Visible badge label.
  final String label;

  /// Restrained visual scale applied to the badge.
  final double scale;

  /// Optional badge background override.
  ///
  /// Defaults to the active theme's primary color.
  final Color? backgroundColor;

  /// Optional badge foreground override.
  ///
  /// Defaults to the active theme's on-primary color.
  final Color? foregroundColor;

  /// Optional outline override.
  ///
  /// Defaults to the active theme's surface color.
  final Color? outlineColor;

  /// Optional standalone semantic description.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final highContrast = MediaQuery.highContrastOf(context);

    final visual = Container(
      constraints: BoxConstraints(
        minWidth: CinearaIconSizes.small * scale,
        minHeight: CinearaIconSizes.small * scale,
      ),
      padding: EdgeInsets.symmetric(horizontal: CinearaSpacing.xxs * scale),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.primary,
        borderRadius: BorderRadius.circular(CinearaRadii.pill),
        border: Border.all(
          color: outlineColor ?? colors.surface,
          width: highContrast ? _highContrastOutlineWidth : _outlineWidth,
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label.trim(),
          maxLines: 1,
          softWrap: false,
          textScaler: TextScaler.noScaling,
          style: theme.textTheme.labelSmall?.copyWith(
            color: foregroundColor ?? colors.onPrimary,
            fontSize: CinearaFontSizes.labelSmall * scale,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
      ),
    );

    final accessibleLabel = semanticLabel?.trim();

    if (accessibleLabel == null || accessibleLabel.isEmpty) {
      return ExcludeSemantics(child: visual);
    }

    return Semantics(
      label: accessibleLabel,
      child: ExcludeSemantics(child: visual),
    );
  }
}
