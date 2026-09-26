import 'package:flutter/foundation.dart';

/// Application-wide debug logger for Cineara.
final class AppLogger {
  /// Creates the Cineara application logger.
  ///
  /// **Parameters:**
  /// - [enableDebugLogging] — Whether debug logging is enabled.
  const AppLogger({required this.enableDebugLogging});

  // === Instance fields ===

  final bool enableDebugLogging;

  // Public methods

  /// Prints a debug message with its source.
  ///
  /// **Parameters:**
  /// - [message] — Message to print.
  /// - [source] — Component or class that produced the message.
  void debug(String message, {required String source}) {
    if (!enableDebugLogging || !kDebugMode) {
      return;
    }

    debugPrint('[$source] $message');
  }
}
