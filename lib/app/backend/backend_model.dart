import 'package:flutter/cupertino.dart';
import 'package:flutter_appirc/app/chat/chat_model.dart';
import 'package:flutter_appirc/app/chat/init/chat_init_model.dart';

class RequestResult<T> {
  final bool isSentSuccessfully;
  final bool isTimeout;

  final bool isResponseReceived;

  final T result;
  final dynamic error;

  const RequestResult._private({
    @required this.isSentSuccessfully,
    @required this.isTimeout,
    @required this.result,
    @required this.error,
    @required this.isResponseReceived,
  });

  const RequestResult.notWaitForResponse()
      : this._private(
          isSentSuccessfully: true,
          isTimeout: false,
          result: null,
          error: null,
          isResponseReceived: true,
        );

  const RequestResult.withResponse(T result)
      : this._private(
          isSentSuccessfully: true,
          isTimeout: false,
          result: result,
          error: null,
          isResponseReceived: true,
        );

  const RequestResult.notSend()
      : this._private(
            isSentSuccessfully: false,
            isTimeout: false,
            result: null,
            error: null,
            isResponseReceived: false);

  const RequestResult.timeout()
      : this._private(
          isSentSuccessfully: true,
          isTimeout: true,
          result: null,
          error: null,
          isResponseReceived: false,
        );

  const RequestResult.error(error)
      : this._private(
          isSentSuccessfully: true,
          isTimeout: true,
          result: null,
          error: error,
          isResponseReceived: false,
        );

  @override
  String toString() {
    return 'RequestResult{'
        'isSentSuccessfully: $isSentSuccessfully, '
        'result: $result'
        '}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RequestResult &&
          runtimeType == other.runtimeType &&
          isSentSuccessfully == other.isSentSuccessfully &&
          isTimeout == other.isTimeout &&
          isResponseReceived == other.isResponseReceived &&
          result == other.result &&
          error == other.error;

  @override
  int get hashCode =>
      isSentSuccessfully.hashCode ^
      isTimeout.hashCode ^
      isResponseReceived.hashCode ^
      result.hashCode ^
      error.hashCode;
}

class ChatLoginResult {
  bool success;

  bool isAuthUsed;
  ChatConfig config;
  ChatInitInformation chatInit;

  ChatLoginResult({
    @required this.success,
    @required this.isAuthUsed,
    @required this.config,
    @required this.chatInit,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatLoginResult &&
          runtimeType == other.runtimeType &&
          success == other.success &&
          isAuthUsed == other.isAuthUsed &&
          config == other.config &&
          chatInit == other.chatInit;

  @override
  int get hashCode =>
      success.hashCode ^
      isAuthUsed.hashCode ^
      config.hashCode ^
      chatInit.hashCode;

  @override
  String toString() {
    return 'ChatLoginResult{'
        'success: $success, '
        'isAuthUsed: $isAuthUsed, '
        'config: $config, '
        'chatInit: $chatInit'
        '}';
  }
}

class ChatRegistrationResult<T> {
  final bool success;

  final RegistrationErrorType errorType;

  ChatRegistrationResult._private(
      {@required this.success, @required this.errorType});

  ChatRegistrationResult.success()
      : this._private(success: true, errorType: null);

  ChatRegistrationResult.fail(RegistrationErrorType errorType)
      : this._private(success: false, errorType: errorType);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatRegistrationResult &&
          runtimeType == other.runtimeType &&
          success == other.success &&
          errorType == other.errorType;

  @override
  int get hashCode => success.hashCode ^ errorType.hashCode;

  @override
  String toString() {
    return 'ChatRegistrationResult{'
        'success: $success, '
        'errorType: $errorType'
        '}';
  }
}

enum RegistrationErrorType {
  alreadyExist,
  invalid,
  unknown,
}
