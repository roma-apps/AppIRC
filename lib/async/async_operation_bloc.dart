import 'dart:async';

import 'package:flutter_appirc/provider/provider.dart';
import 'package:rxdart/rxdart.dart';

abstract class AsyncOperationBloc extends Providable {
  static const bool defaultValue = false;

  bool _inProgress = defaultValue;

  BehaviorSubject<bool> _inProgressController =
      new BehaviorSubject<bool>(seedValue: defaultValue);

  Stream<bool> get outInProgress => _inProgressController.stream;

  void _onOperationStarted() => _newInProgressValue(true);

  void _onOperationFinished() => _newInProgressValue(false);

  FutureOr<T> doAsyncOperation<T>(FutureOr<T> asyncCode()) async {
    _onOperationStarted();
    FutureOr<T> result;
    try {
      result = await asyncCode();
    } finally {
      _onOperationFinished();
    }


    return result;
  }

  @override
  void dispose() {
    _inProgressController.close();
  }

  _newInProgressValue(bool newValue) {
    _inProgress = newValue;
    _inProgressController.sink.add(newValue);
  }
}
