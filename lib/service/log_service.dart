import 'package:logger/logger.dart';

var _logger = Logger(
  printer: PrettyPrinter(),
);


var _loggerNoStackTrace = Logger(
  printer: PrettyPrinter(methodCount: 0),
);


void logd(String tag, dynamic message, {bool stackTrace = true}) {
  if(stackTrace) {
    _logger.d(createMessage(tag, message));
  } else {
    _loggerNoStackTrace.d(createMessage(tag, message));
  }

}

String createMessage(String tag, message) => "$tag: $message";
void logi(String tag, dynamic message, {bool stackTrace = false}) {
  if(stackTrace) {
    _logger.i(createMessage(tag, message));
  } else {
    _loggerNoStackTrace.i(createMessage(tag, message));
  }
}
void logw(String tag, dynamic message, {bool stackTrace = true}) {
  if(stackTrace) {
    _logger.w(createMessage(tag, message));
  } else {
    _loggerNoStackTrace.w(createMessage(tag, message));
  }
}
void loge(String tag, dynamic message, {bool stackTrace = false}) {
  if(stackTrace) {
    _logger.e(createMessage(tag, message));
  } else {
    _loggerNoStackTrace.e(createMessage(tag, message));
  }
}
