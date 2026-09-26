// Application environment
enum AppEnvironment { development, staging, production }

// Build variants of the application.
enum AppFlavor { play, personal }

/// Stores build-time and environment configuration for Cineara.
final class AppConfig {
  /// Creates the Cineara application configuration.
  ///
  /// **Parameters:**
  /// - [environment] — Development, staging, or production environment.
  /// - [flavor] — Distribution variant of the application.
  /// - [apiBaseUrl] — Base URI used for backend API requests.
  /// - [enableDebugLogging] — Whether additional debug logging is enabled.
  const AppConfig({
    required this.environment,
    required this.flavor,
    required this.apiBaseUrl,
    required this.enableDebugLogging,
  });

  // === Factory constructors ===

  // Creates the configuration from Flutter `--dart-define` values.
  factory AppConfig.fromEnvironment() {
    const environmentValue = String.fromEnvironment(
      'CINEARA_ENV',
      defaultValue: 'development',
    );

    const flavorValue = String.fromEnvironment(
      'CINEARA_FLAVOR',
      defaultValue: 'play',
    );

    const apiBaseUrlValue = String.fromEnvironment('CINEARA_API_BASE_URL');

    const debugLoggingValue = bool.fromEnvironment(
      'CINEARA_DEBUG_LOGGING',
      defaultValue: true,
    );

    final AppEnvironment environment = _parseEnvironment(environmentValue);

    final AppFlavor flavor = _parseFlavor(flavorValue);

    final Uri apiBaseUrl = apiBaseUrlValue.trim().isNotEmpty
        ? _normalizeBaseUrl(apiBaseUrlValue)
        : _defaultApiBaseUrl(environment);

    final bool enableDebugLogging =
        debugLoggingValue || environment == AppEnvironment.development;

    return AppConfig(
      environment: environment,
      flavor: flavor,
      apiBaseUrl: apiBaseUrl,
      enableDebugLogging: enableDebugLogging,
    );
  }

  // === Instance fields ===

  final AppEnvironment environment;
  final AppFlavor flavor;
  final Uri apiBaseUrl;
  final bool enableDebugLogging;

  // === Getters ===

  bool get supportsAdultContent => flavor == AppFlavor.personal;

  // === Overrides ===

  @override
  String toString() {
    return 'AppConfig('
        'environment: ${environment.name}, '
        'flavor: ${flavor.name}, '
        'apiBaseUrl: $apiBaseUrl, '
        'enableDebugLogging: $enableDebugLogging'
        ')';
  }

  // === Private helpers ===

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

  /// TODO: Change staging and production URLs when available.
  static Uri _defaultApiBaseUrl(AppEnvironment environment) {
    return switch (environment) {
      AppEnvironment.development => Uri.parse('http://10.0.2.2:8000'),
      AppEnvironment.staging => Uri.parse(''),
      AppEnvironment.production => Uri.parse(''),
    };
  }

  static Uri _normalizeBaseUrl(String value) {
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
        'CINEARA_API_BASE_URL',
        'Only HTTP and HTTPS URLs are supported.',
      );
    }

    return uri;
  }
}
