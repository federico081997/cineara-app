import 'package:flutter/material.dart';

import '../../tokens/icon_sizes.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

/// Displays a Cineara user avatar with resilient fallback content.
///
/// Avatar content resolves in this order:
///
/// 1. [imageProvider];
/// 2. [fallbackInitials];
/// 3. [fallbackIcon].
///
/// The component owns visual avatar presentation only. Interaction behavior,
/// such as taps, tooltips and pressed states, belongs to the parent control.
final class CinearaAvatar extends StatelessWidget {
  const CinearaAvatar({
    required this.size,
    this.imageProvider,
    this.fallbackInitials,
    this.fallbackIcon = Icons.person_rounded,
    this.fallbackIconSize = CinearaIconSizes.standard,
    this.initialsFontSize = CinearaFontSizes.labelMedium,
    this.backgroundColor,
    this.foregroundColor,
    this.semanticLabel,
    super.key,
  }) : assert(size > 0),
       assert(fallbackIconSize > 0),
       assert(initialsFontSize > 0);

  /// Diameter of the avatar.
  final double size;

  /// Optional profile image.
  final ImageProvider<Object>? imageProvider;

  /// Optional fallback initials.
  ///
  /// The value is rendered exactly as supplied. The application should derive
  /// initials according to its own localization and user-name rules.
  final String? fallbackInitials;

  /// Icon displayed when neither an image nor initials are available.
  final IconData fallbackIcon;

  /// Size of [fallbackIcon].
  final double fallbackIconSize;

  /// Font size used for fallback initials.
  final double initialsFontSize;

  /// Optional avatar background override.
  ///
  /// Defaults to the active theme's primary container.
  final Color? backgroundColor;

  /// Optional fallback-content foreground override.
  ///
  /// Defaults to the active theme's on-primary-container color.
  final Color? foregroundColor;

  /// Optional semantic description for standalone avatar usage.
  ///
  /// Leave null when a parent control already provides the relevant semantics.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final background = backgroundColor ?? colors.primaryContainer;

    final foreground = foregroundColor ?? colors.onPrimaryContainer;

    final initials = fallbackInitials?.trim();

    final fallback = initials != null && initials.isNotEmpty
        ? _Initials(
            value: initials,
            fontSize: initialsFontSize,
            color: foreground,
          )
        : Icon(fallbackIcon, size: fallbackIconSize, color: foreground);

    final visual = SizedBox.square(
      dimension: size,
      child: ClipOval(
        child: DecoratedBox(
          decoration: BoxDecoration(color: background),
          child: imageProvider == null
              ? Center(child: fallback)
              : Image(
                  image: imageProvider!,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.medium,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(child: fallback);
                  },
                ),
        ),
      ),
    );

    final label = semanticLabel?.trim();

    if (label == null || label.isEmpty) {
      return ExcludeSemantics(child: visual);
    }

    return Semantics(
      label: label,
      child: ExcludeSemantics(child: visual),
    );
  }
}

final class _Initials extends StatelessWidget {
  const _Initials({
    required this.value,
    required this.fontSize,
    required this.color,
  });

  final String value;
  final double fontSize;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final boldText = MediaQuery.boldTextOf(context);

    return Padding(
      padding: const EdgeInsets.all(CinearaSpacing.xxs),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          value,
          maxLines: 1,
          softWrap: false,
          textScaler: TextScaler.noScaling,
          style: theme.textTheme.labelMedium?.copyWith(
            color: color,
            fontSize: fontSize,
            fontWeight: boldText ? FontWeight.w900 : FontWeight.w800,
            height: 1,
          ),
        ),
      ),
    );
  }
}
