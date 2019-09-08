import 'package:flutter/cupertino.dart';
import 'package:flutter_appirc/provider.dart';
import 'package:rxdart/rxdart.dart';



abstract class AsyncOperationBloc extends Providable {

  static const bool defaultValue = false;
  
  bool _inProgress = defaultValue;

  BehaviorSubject<bool> _inProgressController =
  new BehaviorSubject<bool>(seedValue: defaultValue);

  Stream<bool> get outInProgress => _inProgressController.stream;


  @protected
  void onOperationStarted() => _newInProgressValue(true);

  @protected
  void onOperationFinished() => _newInProgressValue(false);

  @override
  void dispose() {
    _inProgressController.close();
  }

  _newInProgressValue(bool newValue) {
    _inProgress = newValue;
    _inProgressController.sink.add(newValue);
  }


}
