import 'package:flutter/material.dart';

import '../../../branding/cineara_brand_mark.dart';
import '../../../tokens/spacing.dart';
import 'top_app_bar_metrics.dart';

/// Cineara's shared top application bar.
///
/// The bar owns shell-level presentation:
///
/// - Cineara branding or a localized page title;
/// - an optional leading control;
/// - an extensible list of global actions;
/// - an optional Material app-bar bottom region.
///
/// Feature-specific content should remain outside the bar. For example, Home
/// greetings and personalized context belong in the Home page body.
///
/// Actions are supplied as widgets so new global controls can be introduced
/// without changing this component.
final class CinearaTopAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const CinearaTopAppBar({
    this.title,
    this.showBrand = false,
    this.brand,
    this.brandSemanticLabel = 'Cineara',
    this.actions = const <Widget>[],
    this.leading,
    this.automaticallyImplyLeading = false,
    this.toolbarHeight = CinearaTopAppBarMetrics.toolbarHeight,
    this.leadingWidth,
    this.bottom,
    super.key,
  }) : assert(
         showBrand || title != null,
         'Provide a title or set showBrand to true.',
       ),
       assert(
         !(showBrand && title != null),
         'CinearaTopAppBar cannot show both the brand and a page title.',
       ),
       assert(
         brand == null || showBrand,
         'A custom brand can only be provided when showBrand is true.',
       ),
       assert(
         toolbarHeight >= CinearaTopAppBarMetrics.minimumToolbarHeight,
         'toolbarHeight is smaller than the supported minimum.',
       ),
       assert(
         leadingWidth == null || leadingWidth > 0,
         'leadingWidth must be greater than zero.',
       );

  /// Localized root-page title displayed when [showBrand] is false.
  final String? title;

  /// Whether the Cineara brand is displayed instead of [title].
  final bool showBrand;

  /// Optional custom Cineara brand widget.
  ///
  /// When null, the standard [CinearaBrandMark] is used.
  final Widget? brand;

  /// Accessibility label used by the standard Cineara brand.
  final String brandSemanticLabel;

  /// Global actions displayed at the directional end of the bar.
  ///
  /// Prefer Cineara's dedicated top-app-bar action components so sizing and
  /// interaction behavior remain consistent.
  final List<Widget> actions;

  /// Optional leading control.
  final Widget? leading;

  /// Whether Flutter may automatically provide a leading navigation control.
  ///
  /// Root destinations normally leave this false.
  final bool automaticallyImplyLeading;

  /// Height of the Material toolbar excluding the system status-bar inset.
  final double toolbarHeight;

  /// Optional width reserved for [leading].
  final double? leadingWidth;

  /// Optional Material app-bar bottom region.
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize =>
      Size.fromHeight(toolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final actionExtent = CinearaTopAppBarMetrics.actionExtentFor(context);

    return AppBar(
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading == null
          ? null
          : SizedBox.square(
              dimension: actionExtent,
              child: Center(child: leading),
            ),
      leadingWidth: leading == null
          ? leadingWidth
          : leadingWidth ?? actionExtent,
      toolbarHeight: toolbarHeight,

      // Colors, surfaces, elevation and system-overlay styling
      // come from ThemeData.appBarTheme.
      centerTitle: false,
      titleSpacing: 0,

      title: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: CinearaTopAppBarMetrics.contentMaxWidthFor(context),
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: CinearaTopAppBarMetrics.horizontalPaddingFor(context),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: actionExtent,
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: _buildIdentity(),
                    ),
                  ),
                ),
                if (actions.isNotEmpty) _ActionGroup(children: actions),
              ],
            ),
          ),
        ),
      ),

      // Actions are part of the constrained title row so they remain aligned
      // with the identity on wider layouts.
      actions: null,
      bottom: bottom,
    );
  }

  Widget _buildIdentity() {
    if (showBrand) {
      return brand ??
          CinearaBrandMark(
            size: CinearaBrandMarkSize.compact,
            semanticLabel: brandSemanticLabel,
          );
    }

    return _RootTitle(title: title!);
  }
}

final class _ActionGroup extends StatelessWidget {
  const _ActionGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < children.length; index++) ...[
          if (index > 0) const SizedBox(width: CinearaSpacing.xxs),
          children[index],
        ],
      ],
    );
  }
}

final class _RootTitle extends StatelessWidget {
  const _RootTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.titleMedium?.copyWith(
        color: theme.colorScheme.onSurface,
        fontSize: CinearaTopAppBarMetrics.titleFontSizeFor(context),
        fontWeight: FontWeight.w600,
        letterSpacing: 0.35,
        height: 1.05,
      ),
    );
  }
}
