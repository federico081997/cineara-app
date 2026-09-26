/// Base exception for errors produced by the Cineara API client.
abstract class ApiException implements Exception {
  /// Creates an API exception.
  ///
  /// **Parameters:**
  /// - [url] — URL associated with the failed API request.
  /// - [message] — Human-readable description of the error.
  /// - [cause] — Optional original exception or error that caused this failure.
  const ApiException({required this.url, required this.message, this.cause});

  final Uri url;
  final String message;
  final Object? cause;

  @override
  String toString() {
    return '$runtimeType: $message ($url)';
  }
}

/// Thrown when an API request exceeds its allowed timeout.
final class ApiTimeoutException extends ApiException {
  /// Creates an API timeout exception.
  ///
  /// **Parameters:**
  /// - [url] — URL associated with the timed-out request.
  /// - [timeout] — Maximum duration allowed for the request.
  /// - [cause] — Optional original timeout error.
  ApiTimeoutException({required super.url, required this.timeout, super.cause})
    : super(
        message: 'The request timed out after ${timeout.inSeconds} seconds',
      );

  final Duration timeout;
}

/// Thrown when a network-level error prevents the API request.
final class ApiNetworkException extends ApiException {
  /// Creates an API network exception.
  ///
  /// **Parameters:**
  /// - [url] — URL associated with the failed request.
  /// - [message] — Description of the network error.
  /// - [cause] — Optional original network error.
  ApiNetworkException({
    required super.url,
    required super.message,
    super.cause,
  });
}

/// Thrown when the API returns an unsuccessful HTTP status code.
final class ApiHttpException extends ApiException {
  /// Creates an API HTTP exception.
  ///
  /// **Parameters:**
  /// - [url] — URL associated with the failed request.
  /// - [statusCode] — HTTP status code returned by the server.
  /// - [responseBody] — Optional excerpt from the server response body.
  ApiHttpException({
    required super.url,
    required this.statusCode,
    this.responseBody,
  }) : super(message: 'The server returned HTTP status $statusCode.');

  final int statusCode;
  final String? responseBody;

  @override
  String toString() {
    final String bodyDetails = responseBody == null
        ? ''
        : 'Response: $responseBody';

    return '$runtimeType: $message ($url). $bodyDetails';
  }
}

/// Thrown when the server cannot be processed correctly.
final class ApiInvalidResponseException extends ApiException {
  /// Creates an invalid API response exception.
  ///
  /// **Parameters:**
  /// - [url] — URL associated with the invalid response.
  /// - [message] — Description of why the response is invalid.
  /// - [cause] — Optional original decoding or parsing error.
  const ApiInvalidResponseException({
    required super.url,
    required super.message,
    super.cause,
  });
}
