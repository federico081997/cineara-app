import 'package:cineara_design_system/cineara_design_system.dart';
import 'package:cineara_design_system/components/buttons/filled_button.dart';
import 'package:cineara_design_system/components/layout/centered_content.dart';
import 'package:cineara_design_system/components/states/state_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

final class RouteErrorPage extends StatelessWidget {
  const RouteErrorPage({required this.onGoHome, this.error, super.key});

  /// Navigates back to the home screen.
  final VoidCallback onGoHome;

  /// Technical routing error.
  ///
  /// Only displayed in debug builds.
  final Object? error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: CinearaCenteredContent(
        maxWidth: CinearaContentWidths.narrow,
        child: CinearaStateView(
          icon: Icons.error_outline_rounded,
          title: l10n.routeErrorTitle,
          message: l10n.routeErrorMessage,
          details: kDebugMode && error != null
              ? SelectableText(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                )
              : null,
          action: CinearaFilledButton(
            onPressed: onGoHome,
            icon: Icons.home_outlined,
            label: l10n.routeErrorGoHome,
          ),
        ),
      ),
    );
  }
}
