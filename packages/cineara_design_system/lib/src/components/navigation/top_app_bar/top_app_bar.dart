import 'package:flutter/material.dart';

import '../../../branding/cineara_brand_mark.dart';
import '../../../foundations/tokens/spacing.dart';
import '../../../motion/shared_switcher.dart';
import 'top_app_bar_metrics.dart';

/// Cineara's shared top application bar.
///
/// The bar provides a stable shell-level surface for page identity, leading
/// navigation, and global actions. Changes between compatible bar states use
/// coordinated motion so controls appear to flow between layouts rather than
/// being replaced abruptly.
///
/// Feature-specific content remains outside the bar unless it directly
/// represents the current top-bar identity, such as an active search field.
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

  /// Localized page title displayed when [showBrand] is false.
  final String? title;

  /// Whether the Cineara brand is displayed instead of [title].
  final bool showBrand;

  /// Optional custom identity widget.
  ///
  /// When null, [CinearaBrandMark] is used.
  ///
  /// Custom identity widgets can use the available horizontal space. This is
  /// used by shell states such as Search, where the identity region becomes an
  /// interactive field.
  final Widget? brand;

  /// Accessibility label used by the standard Cineara brand.
  final String brandSemanticLabel;

  /// Global actions displayed at the directional end of the bar.
  ///
  /// Cineara top-app-bar action components should be used so interaction,
  /// press feedback, accessibility, and motion remain consistent.
  final List<Widget> actions;

  /// Optional leading control.
  final Widget? leading;

  /// Whether Flutter may automatically provide a leading navigation control.
  final bool automaticallyImplyLeading;

  /// Height of the toolbar excluding the system status-bar inset.
  final double toolbarHeight;

  /// Optional width reserved for [leading].
  final double? leadingWidth;

  /// Optional Material app-bar bottom region.
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize {
    return Size.fromHeight(toolbarHeight + (bottom?.preferredSize.height ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    final double actionExtent = CinearaTopAppBarMetrics.actionExtentFor(
      context,
    );

    return AppBar(
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: _buildLeading(actionExtent),
      leadingWidth: leading == null
          ? leadingWidth
          : leadingWidth ?? actionExtent,
      toolbarHeight: toolbarHeight,
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
              children: <Widget>[
                Expanded(
                  child: SizedBox(
                    height: actionExtent,
                    child: _AnimatedIdentity(
                      identity: _buildIdentity(),
                      identityKey: _identityKey(),
                    ),
                  ),
                ),
                _AnimatedActionGroup(actions: actions),
              ],
            ),
          ),
        ),
      ),
      actions: null,
      bottom: bottom,
    );
  }

  Widget? _buildLeading(double actionExtent) {
    final Widget? leadingControl = leading;

    if (leadingControl == null) {
      return null;
    }

    return SizedBox.square(
      dimension: actionExtent,
      child: Center(child: leadingControl),
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

  Object _identityKey() {
    final Widget? customBrand = brand;

    if (showBrand) {
      if (customBrand != null) {
        return Object.hash(
          'custom-brand',
          customBrand.key,
          customBrand.runtimeType,
        );
      }

      return const _TopAppBarIdentityKey.brand();
    }

    return _TopAppBarIdentityKey.title(title!);
  }
}

/// Animates changes to the identity region while allowing the region to respond
/// continuously to width changes caused by trailing actions.
final class _AnimatedIdentity extends StatelessWidget {
  const _AnimatedIdentity({required this.identity, required this.identityKey});

  final Widget identity;
  final Object identityKey;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: CinearaSharedSwitcher(
        axis: CinearaSharedSwitcherAxis.horizontal,
        distance: 0.018,
        scaleFrom: 0.98,
        alignment: AlignmentDirectional.centerStart,
        child: KeyedSubtree(
          key: ValueKey<Object>(identityKey),
          child: identity,
        ),
      ),
    );
  }
}

/// Animates the trailing action region as actions enter, leave, or change.
///
/// The region animates its width as well as its content. This allows the
/// identity region to expand into released space smoothly.
final class _AnimatedActionGroup extends StatelessWidget {
  const _AnimatedActionGroup({required this.actions});

  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final bool empty = actions.isEmpty;

    return CinearaSharedSwitcher(
      axis: CinearaSharedSwitcherAxis.horizontal,
      reverse: true,
      distance: 0.025,
      scaleFrom: 0.96,
      alignment: AlignmentDirectional.centerEnd,
      child: empty
          ? const SizedBox.shrink(
              key: ValueKey<String>('top-app-bar-actions-empty'),
            )
          : KeyedSubtree(
              key: ValueKey<int>(_actionsSignature(actions)),
              child: _ActionGroup(children: actions),
            ),
    );
  }

  static int _actionsSignature(List<Widget> actions) {
    return Object.hashAll(
      actions.map<Object>(
        (Widget action) => Object.hash(action.runtimeType, action.key),
      ),
    );
  }
}

final class _ActionGroup extends StatelessWidget {
  const _ActionGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int index = 0; index < children.length; index++) ...<Widget>[
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
    final ThemeData theme = Theme.of(context);

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

/// Stable identity used to distinguish standard top-bar presentation states.
final class _TopAppBarIdentityKey {
  const _TopAppBarIdentityKey._(this.type, this.value);

  const _TopAppBarIdentityKey.brand() : this._('brand', null);

  const _TopAppBarIdentityKey.title(String title) : this._('title', title);

  final String type;
  final String? value;

  @override
  bool operator ==(Object other) {
    return other is _TopAppBarIdentityKey &&
        other.type == type &&
        other.value == value;
  }

  @override
  int get hashCode => Object.hash(type, value);
}
