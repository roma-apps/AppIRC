
import 'package:flutter/cupertino.dart';

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
