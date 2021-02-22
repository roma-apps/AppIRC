import 'package:flutter/widgets.dart';

typedef ErrorDataTitleCreator = String Function(BuildContext context);
typedef ErrorDataContentCreator = String Function(BuildContext context);

class ErrorData {
  final dynamic error;
  final StackTrace stackTrace;
  final ErrorDataTitleCreator titleCreator;
  final ErrorDataContentCreator contentCreator;

  ErrorData({
    @required this.error,
    @required this.stackTrace,
    @required this.titleCreator,
    @required this.contentCreator,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ErrorData &&
          runtimeType == other.runtimeType &&
          error == other.error &&
          stackTrace == other.stackTrace &&
          titleCreator == other.titleCreator &&
          contentCreator == other.contentCreator;

  @override
  int get hashCode =>
      error.hashCode ^
      stackTrace.hashCode ^
      titleCreator.hashCode ^
      contentCreator.hashCode;

  @override
  String toString() {
    return 'ErrorData{'
        'error: $error, '
        'stackTrace: $stackTrace, '
        'titleCreator: $titleCreator, '
        'contentCreator: $contentCreator'
        '}';
  }
}
