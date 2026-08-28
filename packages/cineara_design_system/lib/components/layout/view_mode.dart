/// Layout mode used by Cineara collections of media or other repeated content.
///
/// The enum intentionally describes only the presentation mode. Persistence,
/// feature defaults, and user preferences belong to the application layer.
///
/// Typical usage:
///
/// ```dart
/// switch (viewMode) {
///   CinearaViewMode.grid => buildGrid(),
///   CinearaViewMode.list => buildList(),
/// }
/// ```
///
/// Different features may choose different defaults. For example, Search may
/// prefer [CinearaViewMode.list] while discovery or library experiences may
/// prefer [CinearaViewMode.grid].
enum CinearaViewMode {
  /// Display content in a multi-column grid.
  grid,

  /// Display content as vertically stacked rows.
  list,
}
