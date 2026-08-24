import 'package:cineara_design_system/cineara_design_system.dart';
import 'package:flutter/material.dart';

typedef CinearaGlobalSearchContentBuilder =
    Widget Function(BuildContext context, String query);

/// Accessibility-aware geometry for Cineara's global search header.
///
/// Search text follows the user's full text scaling preference. The surrounding
/// controls grow more slowly so the header remains usable without allowing a
/// large accessibility scale to make the toolbar disproportionately tall.
@immutable
class _SearchHeaderGeometry {
  const _SearchHeaderGeometry({
    required this.controlScale,
    required this.fieldHeight,
    required this.toolbarHeight,
    required this.leadingWidth,
  });

  final double controlScale;
  final double fieldHeight;
  final double toolbarHeight;
  final double leadingWidth;

  factory _SearchHeaderGeometry.of(BuildContext context) {
    final TextScaler scaler = MediaQuery.textScalerOf(context);
    final double scaledBodySize = scaler.scale(16);
    final double textScale = scaledBodySize / 16;

    final double controlScale = (1 + ((textScale - 1) * 0.22))
        .clamp(1.0, 1.18)
        .toDouble();

    // Enough height for fully-scaled single-line search text plus vertical
    // breathing room. The cap protects the app-bar composition at extreme
    // accessibility scales while the editable text itself remains fully scaled.
    final double fieldHeight = (scaledBodySize * 1.20 + 24)
        .clamp(48.0, 80.0)
        .toDouble();

    final double toolbarHeight = (fieldHeight + 16)
        .clamp(64.0, 96.0)
        .toDouble();

    return _SearchHeaderGeometry(
      controlScale: controlScale,
      fieldHeight: fieldHeight,
      toolbarHeight: toolbarHeight,
      leadingWidth: 48 * controlScale + 8,
    );
  }
}

/// Opens Cineara's global search experience as a focused full-screen route.
///
/// The caller's accessibility and text-direction overrides are preserved on the
/// pushed route. This matters for manual previews and any subtree that applies
/// its own [MediaQuery] or [Directionality].
Future<T?> showCinearaGlobalSearch<T>({
  required BuildContext context,
  required Widget page,
}) {
  final MediaQueryData callerMediaQuery = MediaQuery.of(context);
  final TextDirection callerDirection = Directionality.of(context);

  return Navigator.of(context).push<T>(
    MaterialPageRoute<T>(
      fullscreenDialog: true,
      builder: (BuildContext routeContext) {
        final MediaQueryData routeMediaQuery = MediaQuery.of(routeContext);

        return Directionality(
          textDirection: callerDirection,
          child: MediaQuery(
            data: routeMediaQuery.copyWith(
              textScaler: callerMediaQuery.textScaler,
              boldText: callerMediaQuery.boldText,
              highContrast: callerMediaQuery.highContrast,
              disableAnimations: callerMediaQuery.disableAnimations,
              accessibleNavigation: callerMediaQuery.accessibleNavigation,
            ),
            child: page,
          ),
        );
      },
    ),
  );
}

/// Global search surface used when the root-app-bar search action is pressed.
///
/// The normal app bar is replaced by a focused search header. Search owns only
/// presentation; debouncing, TMDB/backend requests, grouping and result state
/// remain in the application layer through [contentBuilder].
///
/// The component is designed for:
///
/// - LTR and RTL layouts;
/// - localized placeholder/action strings of very different lengths;
/// - large accessibility text settings;
/// - bold text, high contrast and reduced-motion preferences.
class CinearaGlobalSearchPage extends StatefulWidget {
  const CinearaGlobalSearchPage({
    required this.placeholder,
    required this.backSemanticLabel,
    required this.clearSemanticLabel,
    required this.contentBuilder,
    super.key,
    this.initialQuery = '',
    this.autoFocus = true,
    this.onQueryChanged,
    this.onSubmitted,
    this.trailingAction,
  });

  /// Localized search placeholder.
  final String placeholder;

  /// Localized label for the back action.
  final String backSemanticLabel;

  /// Localized label for clearing the query.
  final String clearSemanticLabel;

  final String initialQuery;
  final bool autoFocus;
  final ValueChanged<String>? onQueryChanged;
  final ValueChanged<String>? onSubmitted;
  final CinearaGlobalSearchContentBuilder contentBuilder;

  /// Optional secondary search action such as filters.
  ///
  /// Keep this visually compact because the search field receives all remaining
  /// horizontal space, especially under large text and long translations.
  final Widget? trailingAction;

  @override
  State<CinearaGlobalSearchPage> createState() =>
      _CinearaGlobalSearchPageState();
}

class _CinearaGlobalSearchPageState extends State<CinearaGlobalSearchPage> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  String _query = '';

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery;
    _controller = TextEditingController(text: widget.initialQuery);
    _focusNode = FocusNode();
    _controller.addListener(_handleQueryChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_handleQueryChanged)
      ..dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleQueryChanged() {
    final String next = _controller.text;
    if (_query == next) {
      return;
    }

    setState(() => _query = next);
    widget.onQueryChanged?.call(next);
  }

  void _clear() {
    if (_controller.text.isEmpty) {
      return;
    }

    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final _SearchHeaderGeometry geometry = _SearchHeaderGeometry.of(context);

    final bool reduceMotion =
        mediaQuery.disableAnimations || mediaQuery.accessibleNavigation;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: geometry.toolbarHeight,
        backgroundColor: theme.appBarTheme.backgroundColor ?? colors.surface,
        foregroundColor: theme.appBarTheme.foregroundColor ?? colors.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        leadingWidth: geometry.leadingWidth,
        leading: Center(
          child: _SearchIconAction(
            icon: Icons.arrow_back_rounded,
            semanticLabel: widget.backSemanticLabel,
            onPressed: () => Navigator.of(context).maybePop(),
            controlScale: geometry.controlScale,
          ),
        ),
        title: Padding(
          padding: const EdgeInsetsDirectional.only(end: CinearaSpacing.xs),
          child: _CinearaSearchField(
            controller: _controller,
            focusNode: _focusNode,
            placeholder: widget.placeholder,
            clearSemanticLabel: widget.clearSemanticLabel,
            autoFocus: widget.autoFocus,
            onClearPressed: _clear,
            onSubmitted: widget.onSubmitted,
            fieldHeight: geometry.fieldHeight,
            controlScale: geometry.controlScale,
          ),
        ),
        actions: widget.trailingAction == null
            ? null
            : <Widget>[
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    end: CinearaSpacing.sm,
                  ),
                  child: Center(child: widget.trailingAction),
                ),
              ],
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: colors.outlineVariant.withValues(alpha: 0.60),
              width: 0.75,
            ),
          ),
        ),
        child: AnimatedSwitcher(
          duration: reduceMotion
              ? Duration.zero
              : const Duration(milliseconds: 180),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: KeyedSubtree(
            key: ValueKey<String>(_query.trim()),
            child: widget.contentBuilder(context, _query.trim()),
          ),
        ),
      ),
    );
  }
}

class _CinearaSearchField extends StatelessWidget {
  const _CinearaSearchField({
    required this.controller,
    required this.focusNode,
    required this.placeholder,
    required this.clearSemanticLabel,
    required this.autoFocus,
    required this.onClearPressed,
    required this.onSubmitted,
    required this.fieldHeight,
    required this.controlScale,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String placeholder;
  final String clearSemanticLabel;
  final bool autoFocus;
  final VoidCallback onClearPressed;
  final ValueChanged<String>? onSubmitted;
  final double fieldHeight;
  final double controlScale;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final bool highContrast = MediaQuery.highContrastOf(context);

    final BorderRadius radius = BorderRadius.circular(CinearaRadii.lg);

    final OutlineInputBorder enabledBorder = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(
        color: colors.outlineVariant.withValues(alpha: highContrast ? 1 : 0.76),
        width: highContrast ? 1.5 : 0.8,
      ),
    );

    final OutlineInputBorder focusedBorder = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(
        color: colors.primary.withValues(alpha: highContrast ? 1 : 0.78),
        width: highContrast ? 2 : 1.35,
      ),
    );

    final double iconExtent = 44 * controlScale;
    final double searchIconSize = 21 * controlScale;

    return SizedBox(
      height: fieldHeight,
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (BuildContext context, TextEditingValue value, Widget? child) {
          return TextField(
            controller: controller,
            focusNode: focusNode,
            autofocus: autoFocus,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.search,
            textAlign: TextAlign.start,
            textAlignVertical: TextAlignVertical.center,
            maxLines: 1,
            cursorColor: colors.primary,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
            onSubmitted: onSubmitted,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: colors.surfaceContainerLow,
              hintText: placeholder,
              hintMaxLines: 1,
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                color: colors.onSurfaceVariant.withValues(alpha: 0.78),
                fontWeight: FontWeight.w400,
                height: 1.2,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                size: searchIconSize,
                color: colors.onSurfaceVariant,
              ),
              prefixIconConstraints: BoxConstraints(
                minWidth: iconExtent,
                minHeight: fieldHeight,
              ),
              suffixIcon: value.text.isEmpty
                  ? null
                  : _SearchClearButton(
                      semanticLabel: clearSemanticLabel,
                      onPressed: onClearPressed,
                      controlScale: controlScale,
                    ),
              suffixIconConstraints: BoxConstraints(
                minWidth: iconExtent,
                minHeight: fieldHeight,
              ),
              contentPadding: const EdgeInsetsDirectional.fromSTEB(
                0,
                CinearaSpacing.xs,
                CinearaSpacing.xs,
                CinearaSpacing.xs,
              ),
              border: enabledBorder,
              enabledBorder: enabledBorder,
              focusedBorder: focusedBorder,
              errorBorder: enabledBorder,
              focusedErrorBorder: focusedBorder,
            ),
          );
        },
      ),
    );
  }
}

/// Transparent app-bar action: no permanent circle, only transient interaction.
class _SearchIconAction extends StatelessWidget {
  const _SearchIconAction({
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    required this.controlScale,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback onPressed;
  final double controlScale;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool highContrast = MediaQuery.highContrastOf(context);

    final double extent = 48 * controlScale;

    return IconButton(
      tooltip: semanticLabel,
      onPressed: onPressed,
      iconSize: 22 * controlScale,
      style:
          IconButton.styleFrom(
            minimumSize: Size.square(extent),
            maximumSize: Size.square(extent),
            padding: EdgeInsets.zero,
            foregroundColor: colors.onSurface,
            backgroundColor: Colors.transparent,
            shape: const CircleBorder(),
            side: BorderSide.none,
          ).copyWith(
            overlayColor: WidgetStateProperty.resolveWith<Color?>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.pressed)) {
                return colors.primary.withValues(
                  alpha: highContrast ? 0.18 : 0.09,
                );
              }

              if (states.contains(WidgetState.hovered)) {
                return colors.primary.withValues(alpha: 0.045);
              }

              if (states.contains(WidgetState.focused)) {
                return colors.primary.withValues(
                  alpha: highContrast ? 0.14 : 0.065,
                );
              }

              return null;
            }),
          ),

      // Material's back icon has matchTextDirection enabled, so it mirrors
      // automatically in RTL. Do not manually replace it with arrow_forward.
      icon: Icon(icon),
    );
  }
}

class _SearchClearButton extends StatelessWidget {
  const _SearchClearButton({
    required this.semanticLabel,
    required this.onPressed,
    required this.controlScale,
  });

  final String semanticLabel;
  final VoidCallback onPressed;
  final double controlScale;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final double extent = 40 * controlScale;

    return IconButton(
      tooltip: semanticLabel,
      onPressed: onPressed,
      iconSize: 19 * controlScale,
      style:
          IconButton.styleFrom(
            minimumSize: Size.square(extent),
            maximumSize: Size.square(extent),
            padding: EdgeInsets.zero,
            foregroundColor: colors.onSurfaceVariant,
            backgroundColor: Colors.transparent,
            shape: const CircleBorder(),
            side: BorderSide.none,
          ).copyWith(
            overlayColor: WidgetStateProperty.resolveWith<Color?>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.pressed)) {
                return colors.primary.withValues(alpha: 0.08);
              }

              if (states.contains(WidgetState.hovered)) {
                return colors.primary.withValues(alpha: 0.04);
              }

              if (states.contains(WidgetState.focused)) {
                return colors.primary.withValues(alpha: 0.06);
              }

              return null;
            }),
          ),
      icon: const Icon(Icons.close_rounded),
    );
  }
}
