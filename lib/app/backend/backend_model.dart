import 'package:flutter/cupertino.dart';
import 'package:flutter_appirc/app/chat/chat_model.dart';
import 'package:flutter_appirc/app/chat/init/chat_init_model.dart';

class RequestResult<T> {
  final bool isSentSuccessfully;
  final bool isTimeout;

  final bool isResponseReceived;

  final T result;
  final dynamic error;

  RequestResult._name({
    @required this.isSentSuccessfully,
    @required this.isTimeout,
    @required this.result,
    @required this.error,
    @required this.isResponseReceived,
  });

  RequestResult.notWaitForResponse()
      : this._name(
            isSentSuccessfully: true,
            isTimeout: false,
            result: null,
            error: null,
            isResponseReceived: true);

  RequestResult.withResponse(T result)
      : this._name(
            isSentSuccessfully: true,
            isTimeout: false,
            result: result,
            error: null,
            isResponseReceived: true);

  RequestResult.notSend()
      : this._name(
            isSentSuccessfully: false,
            isTimeout: false,
            result: null,
            error: null,
            isResponseReceived: false);

  RequestResult.timeout()
      : this._name(
            isSentSuccessfully: true,
            isTimeout: true,
            result: null,
            error: null,
            isResponseReceived: false);

  RequestResult.error(error)
      : this._name(
            isSentSuccessfully: true,
            isTimeout: true,
            result: null,
            error: error,
            isResponseReceived: false);

  @override
  String toString() {
    return 'RequestResult{isSentSuccessfully: $isSentSuccessfully,'
        ' result: $result}';
  }
}

class ChatLoginResult<T> {
  bool success;

  bool isAuthUsed;
  ChatConfig config;
  ChatInitInformation chatInit;

  ChatLoginResult();
}

class ChatRegistrationResult<T> {
  final bool success;

  final RegistrationErrorType errorType;

  ChatRegistrationResult._name(
      {@required this.success, @required this.errorType});

  ChatRegistrationResult.success()
      : this._name(success: true, errorType: null);

  ChatRegistrationResult.fail(RegistrationErrorType errorType)
      : this._name(success: false, errorType: errorType);
}

enum RegistrationErrorType { alreadyExist, invalid, unknown }
