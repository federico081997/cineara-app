import 'package:flutter/material.dart';

import '../../tokens/icon_sizes.dart';
import '../../tokens/spacing.dart';

/// Presents a standard application state using Cineara's visual hierarchy.
///
/// Suitable for error states, empty states, offline states, unavailable
/// content, successful completion states, and similar focused messages.
///
/// The view provides consistent icon sizing, typography, spacing, semantics,
/// and optional slots for additional details and actions.
final class CinearaStateView extends StatelessWidget {
  const CinearaStateView({
    required this.title,
    this.message,
    this.icon,
    this.leading,
    this.iconColor,
    this.details,
    this.action,
    this.headingLevel = 1,
    super.key,
  }) : assert(
         icon == null || leading == null,
         'Provide either icon or leading, but not both.',
       ),
       assert(
         headingLevel >= 1 && headingLevel <= 6,
         'headingLevel must be between 1 and 6.',
       );

  /// Primary title describing the current state.
  final String title;

  /// Optional supporting message describing the state or suggesting what the
  /// user can do next.
  final String? message;

  /// Optional state icon.
  ///
  /// State icons are treated as decorative because the state itself is
  /// communicated by [title].
  ///
  /// Use either [icon] or [leading], but not both.
  final IconData? icon;

  /// Optional custom content displayed above the title.
  ///
  /// This can be used instead of [icon] for a custom illustration or another
  /// visual representation of the state.
  final Widget? leading;

  /// Optional color override for [icon].
  ///
  /// Defaults to the current theme's primary color.
  final Color? iconColor;

  /// Optional additional content displayed below the message.
  ///
  /// Suitable for technical details, supplementary information, or other
  /// state-specific content.
  final Widget? details;

  /// Optional action displayed at the bottom of the state.
  ///
  /// This can be a Cineara button or another appropriate action widget.
  final Widget? action;

  /// Semantic heading level assigned to [title].
  final int headingLevel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final stateLeading = leading ?? _buildIcon(context, theme);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (stateLeading != null) ...[
          Center(child: stateLeading),
          const SizedBox(height: CinearaSpacing.lg),
        ],
        Semantics(
          headingLevel: headingLevel,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: CinearaSpacing.sm),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        if (details != null) ...[
          const SizedBox(height: CinearaSpacing.md),
          details!,
        ],
        if (action != null) ...[
          const SizedBox(height: CinearaSpacing.xl),
          Center(child: action),
        ],
      ],
    );
  }

  Widget? _buildIcon(BuildContext context, ThemeData theme) {
    if (icon == null) {
      return null;
    }

    return ExcludeSemantics(
      child: Icon(
        icon,
        size: CinearaIconSizing.feedback(context),
        color: iconColor ?? theme.colorScheme.primary,
      ),
    );
  }
}
