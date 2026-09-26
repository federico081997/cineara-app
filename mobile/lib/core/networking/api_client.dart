import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cineara_mobile/core/logging/app_logger.dart';
import 'package:cineara_mobile/core/networking/api_exceptions.dart';

final class ApiClient {
  /// Creates the Cineara API client.
  ///
  /// Parameters:
  /// - [apiBaseUrl] — Base URL used for API requests.
  /// - [logger] — Logger used for API debug messages.
  /// - [requestTimeout] — Maximum connection timeout. Defaults to 15 seconds.
  /// - [defaultHeaders] — Headers included with every request.
  /// - [httpClient] — Optional HTTP client. A new [HttpClient] is created
  /// if none is provided.

  // === Constructors ===

  ApiClient({
    required this.apiBaseUrl,
    required AppLogger logger,
    this.requestTimeout = const Duration(seconds: 15),
    Map<String, String> defaultHeaders = const <String, String>{},
    HttpClient? httpClient,
  }) : _logger = logger,
       _defaultHeaders = Map<String, String>.unmodifiable(defaultHeaders),
       _httpClient = httpClient ?? HttpClient() {
    _httpClient.connectionTimeout = requestTimeout;
  }

  // === Instance fields ===

  final Uri apiBaseUrl;
  final AppLogger _logger;
  final Duration requestTimeout;
  final Map<String, String> _defaultHeaders;
  final HttpClient _httpClient;

  // === Public methods ===

  /// Sends a GET request and returns the decoded JSON response.
  ///
  /// **Parameters:**
  /// - [url] — URL of the requested resource.
  /// - [headers] — Additional headers for this request.
  ///
  /// **Returns:**
  /// The decoded JSON response.
  Future<Object?> getJson(
    Uri url, {
    Map<String, String> headers = const <String, String>{},
  }) {
    return _requestJson(method: 'GET', url: url, headers: headers);
  }

  /// Sends a POST request and returns the decoded JSON response.
  ///
  /// **Parameters:**
  /// - [url] — URL of the requested resource.
  /// - [headers] — Additional headers for this request.
  /// - [body] — Optional request body to encode as JSON.
  ///
  /// **Returns:**
  /// The decoded JSON response.
  Future<Object?> postJson(
    Uri url, {
    Map<String, String> headers = const <String, String>{},
    Object? body,
  }) {
    return _requestJson(method: 'POST', url: url, headers: headers, body: body);
  }

  /// Sends a PUT request and returns the decoded JSON response.
  ///
  /// **Parameters:**
  /// - [url] — URL of the requested resource.
  /// - [headers] — Additional headers for this request.
  /// - [body] — Optional request body to encode as JSON.
  ///
  /// **Returns:**
  /// The decoded JSON response.
  Future<Object?> putJson(
    Uri url, {
    Map<String, String> headers = const <String, String>{},
    Object? body,
  }) {
    return _requestJson(method: 'PUT', url: url, headers: headers, body: body);
  }

  /// Sends a PATCH request and returns the decoded JSON response.
  ///
  /// **Parameters:**
  /// - [url] — URL of the requested resource.
  /// - [headers] — Additional headers for this request.
  /// - [body] — Optional request body to encode as JSON.
  ///
  /// **Returns:**
  /// The decoded JSON response.
  Future<Object?> patchJson(
    Uri url, {
    Map<String, String> headers = const <String, String>{},
    Object? body,
  }) {
    return _requestJson(
      method: 'PATCH',
      url: url,
      headers: headers,
      body: body,
    );
  }

  /// Sends a DELETE request and returns the decoded JSON response.
  ///
  /// **Parameters:**
  /// - [url] — URL of the requested resource.
  /// - [headers] — Additional headers for this request.
  /// - [body] — Optional request body to encode as JSON.
  ///
  /// **Returns:**
  /// The decoded JSON response.
  Future<Object?> deleteJson(
    Uri url, {
    Map<String, String> headers = const <String, String>{},
    Object? body,
  }) {
    return _requestJson(
      method: 'DELETE',
      url: url,
      headers: headers,
      body: body,
    );
  }

  /// Closes the underlying HTTP client.
  ///
  /// **Parameters:**
  /// - [force] — Whether active connections should be closed immediately.
  /// Defaults to false.
  void close({bool force = false}) {
    _httpClient.close(force: force);
  }

  // === Private helpers ===

  Future<Object?> _requestJson({
    required String method,
    required Uri url,
    required Map<String, String> headers,
    Object? body,
  }) async {
    final Uri resolvedUrl = apiBaseUrl.resolveUri(url);
    final Stopwatch stopwatch = Stopwatch()..start();

    final mergedHeaders = <String, String>{
      HttpHeaders.acceptHeader: 'application/json',
      ..._defaultHeaders,
      ...headers,
    };

    _logger.debug('$method $resolvedUrl', source: 'ApiClient');

    try {
      final HttpClientRequest request = await _httpClient
          .openUrl(method, resolvedUrl)
          .timeout(requestTimeout);

      for (final entry in mergedHeaders.entries) {
        request.headers.set(entry.key, entry.value);
      }

      if (body != null) {
        request.headers.contentType = ContentType.json;
        request.add(utf8.encode(jsonEncode(body)));
      }

      final HttpClientResponse httpResponse = await request.close().timeout(
        requestTimeout,
      );

      final String responseBody;

      try {
        responseBody = await httpResponse
            .transform(utf8.decoder)
            .join()
            .timeout(requestTimeout);
      } on FormatException catch (error) {
        throw ApiInvalidResponseException(
          url: resolvedUrl,
          message: 'The server returned invalid UTF-8.',
          cause: error,
        );
      }

      final int statusCode = httpResponse.statusCode;

      if (statusCode < 200 || statusCode >= 300) {
        final String? responseExcerpt = _getResponseExcerpt(responseBody);

        _logger.debug(
          '$method $resolvedUrl -> $statusCode '
          '(${stopwatch.elapsedMilliseconds} ms) '
          '${responseExcerpt ?? ''}',
          source: 'ApiClient',
        );

        throw ApiHttpException(
          url: resolvedUrl,
          statusCode: statusCode,
          responseBody: responseExcerpt,
        );
      }

      if (statusCode == HttpStatus.noContent || responseBody.trim().isEmpty) {
        _logger.debug(
          '$method $resolvedUrl -> $statusCode '
          '(${stopwatch.elapsedMilliseconds} ms)',
          source: 'ApiClient',
        );

        return null;
      }

      try {
        final Object? decodedJson = jsonDecode(responseBody);

        _logger.debug(
          '$method $resolvedUrl -> $statusCode '
          '(${stopwatch.elapsedMilliseconds} ms)',
          source: 'ApiClient',
        );

        return decodedJson;
      } on FormatException catch (error) {
        throw ApiInvalidResponseException(
          url: resolvedUrl,
          message: 'The server returned invalid JSON.',
          cause: error,
        );
      }
    } on TimeoutException catch (error) {
      throw ApiTimeoutException(
        url: resolvedUrl,
        timeout: requestTimeout,
        cause: error,
      );
    } on SocketException catch (error) {
      throw ApiNetworkException(
        url: resolvedUrl,
        message: error.message,
        cause: error,
      );
    } on HandshakeException catch (error) {
      throw ApiNetworkException(
        url: resolvedUrl,
        message: 'Secure connection failed.',
        cause: error,
      );
    } on HttpException catch (error) {
      throw ApiNetworkException(
        url: resolvedUrl,
        message: error.message,
        cause: error,
      );
    } finally {
      stopwatch.stop();
    }
  }

  String? _getResponseExcerpt(String responseBody, {int maxLength = 512}) {
    final String trimmed = responseBody.trim();

    if (trimmed.isEmpty) {
      return null;
    }

    if (trimmed.length <= maxLength) {
      trimmed;
    }

    return trimmed.substring(0, maxLength);
  }
}
