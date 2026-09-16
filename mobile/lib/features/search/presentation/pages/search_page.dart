import 'package:cineara_design_system/cineara_design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Placeholder Search page.
///
/// Search lives inside the currently active root branch, so the persistent
/// bottom navigation remains visible while this page is open.
///
/// Replace this implementation with Cineara's real Search feature once the
/// routing and shell foundations are complete.
final class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Search'),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          CinearaSpacing.md,
          CinearaSpacing.md,
          CinearaSpacing.md,
          CinearaNavigationPillMetrics.contentClearanceFor(context),
        ),
        children: [
          Text('Search', style: theme.textTheme.headlineSmall),
          const SizedBox(height: CinearaSpacing.sm),
          Text(
            'Search UI will be implemented here.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
