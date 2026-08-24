import 'package:flutter/material.dart';

/// Primary personalized Home experience.
final class HomePage extends StatelessWidget {
  const HomePage({super.key});

  /// TODO: Create actual Home page when other widgets have been finalised.
  @override
  Widget build(BuildContext context) {
    return const CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.all(24),
          sliver: SliverToBoxAdapter(child: Text('Home content starts here')),
        ),
      ],
    );
  }
}
