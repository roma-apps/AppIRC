import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';

const bool logEnabled = true;

/// Wrapper for logger
/// It uses functions instead of dynamic types for args
/// It helps avoid memory allocation when log disabled
class MyLogger {
  final bool enabled;
  final String logTag;
  final int methodCount;
  final int errorMethodCount;
  final bool printTime;
  final bool printEmojis;
  final bool colors;
  final int lineLength;

  bool get globalAndLoggerEnabled => enabled && logEnabled;

  Logger _logger;

  MyLogger(
      {@required this.logTag,
      @required this.enabled,
      this.methodCount = 0,
      this.errorMethodCount = 8,
      this.printTime = true,
      this.printEmojis = true,
      this.colors = true,
      this.lineLength = 120}) {
    if (globalAndLoggerEnabled) {
      _logger = Logger(
          printer: PrettyPrinter(
              methodCount: methodCount,
              errorMethodCount: errorMethodCount,
              lineLength: lineLength,
              colors: colors,
              printEmojis: printEmojis,
              printTime: printTime));
    }
  }

  void i(dynamic message(), [dynamic error(), StackTrace stackTrace()]) {
    if (globalAndLoggerEnabled) {
      _logger.i(message(), error != null ? error() : null,
          stackTrace != null ? stackTrace() : null);
    }
  }

  void d(dynamic message(), [dynamic error(), StackTrace stackTrace()]) {
    if (globalAndLoggerEnabled) {
      _logger.d(message(), error != null ? error() : null,
          stackTrace != null ? stackTrace() : null);
    }
  }

  void w(dynamic message(), [dynamic error(), StackTrace stackTrace()]) {
    if (globalAndLoggerEnabled) {
      _logger.w(message(), error != null ? error() : null,
          stackTrace != null ? stackTrace() : null);
    }
  }

  void e(dynamic message(), [dynamic error(), StackTrace stackTrace()]) {
    if (globalAndLoggerEnabled) {
      _logger.e(message(), error != null ? error() : null,
          stackTrace != null ? stackTrace() : null);
    }
  }
}
