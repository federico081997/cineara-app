import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

/// Shared JSON HTTP client used by Cineara's mobile features.
///
/// The client owns transport-level concerns only:
///
/// - absolute/relative URI resolution;
/// - default JSON headers;
/// - request timeout handling;
/// - HTTP status validation;
/// - UTF-8 decoding;
/// - JSON decoding;
/// - lightweight debug logging.
///
/// Feature repositories remain responsible for validating and mapping their own
/// response schemas.
final class ApiClient {
  ApiClient({
    required Uri baseUri,
    this.requestTimeout = const Duration(seconds: 15),
    this.enableDebugLogging = false,
    Map<String, String> defaultHeaders = const <String, String>{},
    HttpClient? httpClient,
  }) : _baseUri = _validateBaseUri(baseUri),
       _defaultHeaders = Map<String, String>.unmodifiable(defaultHeaders),
       _httpClient = httpClient ?? HttpClient() {
    _httpClient.connectionTimeout = requestTimeout;
  }

  final Uri _baseUri;
  final HttpClient _httpClient;
  final Map<String, String> _defaultHeaders;

  final Duration requestTimeout;
  final bool enableDebugLogging;

  Uri get baseUri => _baseUri;

  Future<Object?> getJson(
    Uri uri, {
    Map<String, String> headers = const <String, String>{},
  }) {
    return _requestJson(method: 'GET', uri: uri, headers: headers);
  }

  Future<Object?> postJson(
    Uri uri, {
    Object? body,
    Map<String, String> headers = const <String, String>{},
  }) {
    return _requestJson(method: 'POST', uri: uri, headers: headers, body: body);
  }

  Future<Object?> putJson(
    Uri uri, {
    Object? body,
    Map<String, String> headers = const <String, String>{},
  }) {
    return _requestJson(method: 'PUT', uri: uri, headers: headers, body: body);
  }

  Future<Object?> deleteJson(
    Uri uri, {
    Object? body,
    Map<String, String> headers = const <String, String>{},
  }) {
    return _requestJson(
      method: 'DELETE',
      uri: uri,
      headers: headers,
      body: body,
    );
  }

  Future<Object?> _requestJson({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    Object? body,
  }) async {
    final Uri resolvedUri = _resolve(uri);
    final Stopwatch stopwatch = Stopwatch()..start();

    _log('$method $resolvedUri');

    try {
      final HttpClientRequest request = await _httpClient
          .openUrl(method, resolvedUri)
          .timeout(requestTimeout);

      request.headers.set(HttpHeaders.acceptHeader, 'application/json');

      for (final MapEntry<String, String> header in _defaultHeaders.entries) {
        request.headers.set(header.key, header.value);
      }

      for (final MapEntry<String, String> header in headers.entries) {
        request.headers.set(header.key, header.value);
      }

      if (body != null) {
        request.headers.contentType = ContentType.json;
        request.add(utf8.encode(jsonEncode(body)));
      }

      final HttpClientResponse response = await request.close().timeout(
        requestTimeout,
      );

      final List<int> bytes = await response
          .fold<List<int>>(
            <int>[],
            (List<int> current, List<int> chunk) => current..addAll(chunk),
          )
          .timeout(requestTimeout);

      late final String responseText;

      try {
        responseText = utf8.decode(bytes, allowMalformed: false);
      } on FormatException catch (error) {
        throw ApiInvalidResponseException(
          uri: resolvedUri,
          message: 'The server returned invalid UTF-8.',
          cause: error,
        );
      }

      final int statusCode = response.statusCode;

      if (statusCode < 200 || statusCode >= 300) {
        _log(
          '$method $resolvedUri -> $statusCode '
          '(${stopwatch.elapsedMilliseconds} ms) '
          '${_safeResponseExcerpt(responseText) ?? ''}',
        );

        throw ApiHttpException(
          uri: resolvedUri,
          statusCode: statusCode,
          responseBody: _safeResponseExcerpt(responseText),
        );
      }

      if (statusCode == HttpStatus.noContent || responseText.trim().isEmpty) {
        _log(
          '$method $resolvedUri -> $statusCode '
          '(${stopwatch.elapsedMilliseconds} ms)',
        );
        return null;
      }

      try {
        final Object? decoded = jsonDecode(responseText);

        _log(
          '$method $resolvedUri -> $statusCode '
          '(${stopwatch.elapsedMilliseconds} ms)',
        );
        return decoded;
      } on FormatException catch (error) {
        throw ApiInvalidResponseException(
          uri: resolvedUri,
          message: 'The server returned invalid JSON.',
          cause: error,
        );
      }
    } on TimeoutException catch (error) {
      throw ApiTimeoutException(
        uri: resolvedUri,
        timeout: requestTimeout,
        cause: error,
      );
    } on SocketException catch (error) {
      throw ApiNetworkException(
        uri: resolvedUri,
        message: error.message,
        cause: error,
      );
    } on HandshakeException catch (error) {
      throw ApiNetworkException(
        uri: resolvedUri,
        message: 'Secure connection failed.',
        cause: error,
      );
    } on HttpException catch (error) {
      throw ApiNetworkException(
        uri: resolvedUri,
        message: error.message,
        cause: error,
      );
    } finally {
      stopwatch.stop();
    }
  }

  Uri _resolve(Uri uri) {
    if (uri.hasScheme) {
      return uri;
    }

    return _baseUri.resolveUri(uri);
  }

  void close({bool force = false}) {
    _httpClient.close(force: force);
  }

  void _log(String message) {
    if (!enableDebugLogging || !kDebugMode) {
      return;
    }

    debugPrint('[ApiClient] $message');
  }

  static String? _safeResponseExcerpt(String value) {
    final String normalized = value.trim();

    if (normalized.isEmpty) {
      return null;
    }

    const int maxLength = 512;

    if (normalized.length <= maxLength) {
      return normalized;
    }

    return '${normalized.substring(0, maxLength)}…';
  }

  static Uri _validateBaseUri(Uri value) {
    if (!value.hasScheme ||
        value.host.isEmpty ||
        (value.scheme != 'http' && value.scheme != 'https')) {
      throw ArgumentError.value(
        value,
        'baseUri',
        'Expected an absolute HTTP or HTTPS URI.',
      );
    }

    return value;
  }
}

sealed class ApiException implements Exception {
  ApiException({required this.uri, required this.message, this.cause});

  final Uri uri;
  final String message;
  final Object? cause;

  @override
  String toString() => '$runtimeType: $message ($uri)';
}

final class ApiNetworkException extends ApiException {
  ApiNetworkException({
    required super.uri,
    required super.message,
    super.cause,
  });
}

final class ApiTimeoutException extends ApiException {
  ApiTimeoutException({required super.uri, required this.timeout, super.cause})
    : super(message: 'Request timed out after $timeout.');

  final Duration timeout;
}

final class ApiHttpException extends ApiException {
  ApiHttpException({
    required super.uri,
    required this.statusCode,
    this.responseBody,
  }) : super(message: 'Server returned HTTP $statusCode.');

  final int statusCode;
  final String? responseBody;
}

final class ApiInvalidResponseException extends ApiException {
  ApiInvalidResponseException({
    required super.uri,
    required super.message,
    super.cause,
  });
}
