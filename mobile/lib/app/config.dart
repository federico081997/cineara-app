/// Build-time and environment configuration for the Cineara mobile app.
///
/// This file contains configuration that is determined when the application
/// is built or started, such as:
///
/// - development / staging / production environment;
/// - Play Store / personal build flavour;
/// - backend API base URL;
/// - debug logging behaviour.
///
/// User preferences such as theme, poster size, spoiler protection, and
/// tracking behaviour do NOT belong here. Those belong to the Settings
/// feature.
///
/// Values can be overridden with Flutter `--dart-define`.
///
/// Example:
///
/// ```bash
/// flutter run \
///   --dart-define=CINEARA_ENV=development \
///   --dart-define=CINEARA_FLAVOR=personal \
///   --dart-define=CINEARA_API_BASE_URL=http://10.0.2.2:8000
/// ```
enum AppEnvironment { development, staging, production }

/// Distribution variant of the Cineara application.
///
/// `play`
///   Public Play Store build.
///
/// `personal`
///   Personal/private build that may enable functionality intentionally
///   excluded from the public Play Store release.
enum AppFlavor { play, personal }

final class AppConfig {
  const AppConfig({
    required this.environment,
    required this.flavor,
    required this.apiBaseUrl,
    required this.enableDebugLogging,
  });

  /// Current backend/application environment.
  final AppEnvironment environment;

  /// Current distribution flavour.
  final AppFlavor flavor;

  /// Base URL of the Cineara backend API.
  final String apiBaseUrl;

  /// Whether verbose application logging is enabled.
  ///
  /// This should be disabled in production.
  final bool enableDebugLogging;

  /// Creates the configuration from Flutter `--dart-define` values.
  ///
  /// Supported values:
  ///
  /// CINEARA_ENV:
  /// - development
  /// - staging
  /// - production
  ///
  /// CINEARA_FLAVOR:
  /// - play
  /// - personal
  ///
  /// CINEARA_API_BASE_URL:
  /// - optional explicit API URL
  ///
  /// CINEARA_DEBUG_LOGGING:
  /// - true
  /// - false
  factory AppConfig.fromEnvironment() {
    const environmentValue = String.fromEnvironment(
      'CINEARA_ENV',
      defaultValue: 'development',
    );

    const flavorValue = String.fromEnvironment(
      'CINEARA_FLAVOR',
      defaultValue: 'play',
    );

    const explicitApiBaseUrl = String.fromEnvironment('CINEARA_API_BASE_URL');

    final AppEnvironment environment = _parseEnvironment(environmentValue);

    final AppFlavor flavor = _parseFlavor(flavorValue);

    final String apiBaseUrl = explicitApiBaseUrl.trim().isNotEmpty
        ? _normalizeBaseUrl(explicitApiBaseUrl)
        : _defaultApiBaseUrl(environment);

    const explicitDebugLogging = bool.fromEnvironment('CINEARA_DEBUG_LOGGING');

    final bool enableDebugLogging =
        explicitDebugLogging || environment == AppEnvironment.development;

    return AppConfig(
      environment: environment,
      flavor: flavor,
      apiBaseUrl: apiBaseUrl,
      enableDebugLogging: enableDebugLogging,
    );
  }

  /// Parsed URI version of [apiBaseUrl].
  Uri get apiBaseUri => Uri.parse(apiBaseUrl);

  bool get isDevelopment => environment == AppEnvironment.development;

  bool get isStaging => environment == AppEnvironment.staging;

  bool get isProduction => environment == AppEnvironment.production;

  bool get isPlayBuild => flavor == AppFlavor.play;

  bool get isPersonalBuild => flavor == AppFlavor.personal;

  /// Whether this build is allowed to expose adult-content functionality.
  ///
  /// This is a build capability, not the user's content preference.
  ///
  /// A separate user setting can later decide whether the user actually
  /// enables adult content inside a build that supports it.
  bool get supportsAdultContent => flavor == AppFlavor.personal;

  @override
  String toString() {
    return 'AppConfig('
        'environment: ${environment.name}, '
        'flavor: ${flavor.name}, '
        'apiBaseUrl: $apiBaseUrl, '
        'enableDebugLogging: $enableDebugLogging'
        ')';
  }

  static AppEnvironment _parseEnvironment(String value) {
    return switch (value.trim().toLowerCase()) {
      'development' => AppEnvironment.development,
      'staging' => AppEnvironment.staging,
      'production' => AppEnvironment.production,
      _ => throw ArgumentError.value(
        value,
        'CINEARA_ENV',
        'Expected development, staging, or production.',
      ),
    };
  }

  static AppFlavor _parseFlavor(String value) {
    return switch (value.trim().toLowerCase()) {
      'play' => AppFlavor.play,
      'personal' => AppFlavor.personal,
      _ => throw ArgumentError.value(
        value,
        'CINEARA_FLAVOR',
        'Expected play or personal.',
      ),
    };
  }

  static String _defaultApiBaseUrl(AppEnvironment environment) {
    return switch (environment) {
      // Android emulator -> host machine localhost.
      AppEnvironment.development => 'http://10.0.2.2:8000',

      // TODO: Replace these when the staging/production domains exist.
      AppEnvironment.staging => 'https://staging-api.cineara.app',

      AppEnvironment.production => 'https://api.cineara.app',
    };
  }

  static String _normalizeBaseUrl(String value) {
    var normalized = value.trim();

    while (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }

    final Uri uri = Uri.parse(normalized);

    if (!uri.hasScheme || uri.host.isEmpty) {
      throw ArgumentError.value(
        value,
        'CINEARA_API_BASE_URL',
        'Expected an absolute HTTP or HTTPS URL.',
      );
    }

    if (uri.scheme != 'http' && uri.scheme != 'https') {
      throw ArgumentError.value(
        value,
        'CINEARA_API_BASE_URL',
        'Only HTTP and HTTPS URLs are supported.',
      );
    }

    return normalized;
  }
}
