import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

const bool logEnabled = true;

/// Wrapper for logger
/// It uses functions instead of dynamic types for args
/// It helps avoid memory allocation when log disabled
class MyLogger {
  final bool enabled;
  final String logTag;

  bool get globalAndLoggerEnabled =>
      enabled && logEnabled && !(kReleaseMode || kProfileMode);

  Logger _logger;

  MyLogger({
    @required this.logTag,
    @required this.enabled,
  }) {
    if (globalAndLoggerEnabled) {
      _logger = Logger(
        logTag,
      );
    }
  }

  void i(
    dynamic message(), [
    Object error,
    StackTrace stackTrace,
  ]) {
    if (globalAndLoggerEnabled) {
      _logger.finest(
        message,
        error,
        stackTrace,
      );
    }
  }

  void d(
    dynamic message(), [
    Object error,
    StackTrace stackTrace,
  ]) {
    if (globalAndLoggerEnabled) {
      _logger.fine(
        message,
        error,
        stackTrace,
      );
    }
  }

  void w(
    dynamic message(), [
    Object error,
    StackTrace stackTrace,
  ]) {
    if (globalAndLoggerEnabled) {
      _logger.warning(
        message,
        error,
        stackTrace,
      );
    }
  }

  void e(
    dynamic message(), [
    Object error,
    StackTrace stackTrace,
  ]) {
    if (globalAndLoggerEnabled) {
      _logger.shout(
        message,
        error,
        stackTrace,
      );
    }
  }
}
