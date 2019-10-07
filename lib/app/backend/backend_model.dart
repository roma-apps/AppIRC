
import 'package:flutter/cupertino.dart';
import 'package:flutter_appirc/app/chat/chat_model.dart';

class RequestResult<T> {
  final bool isSentSuccessfully;
  final T result;

  RequestResult(this.isSentSuccessfully, this.result);
  RequestResult.name({@required this.isSentSuccessfully, @required this.result});

  @override
  String toString() {
    return 'RequestResult{isSentSuccessfully: $isSentSuccessfully, result: $result}';
  }


}


class ConnectResult<T> {
  
  ChatConfig config;
  bool isSocketConnected = false;
  bool isTimeout = false;
  bool isPrivateModeResponseReceived = false;
  bool isAuthRequestSent = false;
  bool isFailAuthResponseReceived = false;
  dynamic error;

  @override
  String toString() {
    return 'ConnectResult{config: $config,'
        ' isSocketConnected: $isSocketConnected, isTimeout: $isTimeout, '
        'isPrivateModeResponseReceived: $isPrivateModeResponseReceived, '
        'isAuthRequestSent: $isAuthRequestSent, '
        'isFailAuthResponseReceived: $isFailAuthResponseReceived,'
        ' error: $error}';
  }


}
