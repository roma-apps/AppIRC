import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/form/field/form_field_bloc.dart';
import 'package:flutter_appirc/form/form_validation.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:rxdart/rxdart.dart';

MyLogger _logger =
    MyLogger(logTag: "form_value_field_bloc.dart", enabled: true);

class FormValueFieldBloc<T> extends FormFieldBloc<T> {
  final bool enabled;
  final bool visible;

  final focusNode = FocusNode();

  BehaviorSubject<T> _valueController;

  Stream<T> get valueStream => _valueController.stream;

  T get value => _valueController.value;

  FormValueFieldBloc(T startValue,
      {List<Validator<T>> validators = const [],
      this.enabled = true,
      this.visible = true})
      : super(validators) {
    _valueController = BehaviorSubject<T>(seedValue: startValue);
    Timer.run(() async {
      onNewError(await validate(startValue));
    });

    addDisposable(streamSubscription: valueStream.listen((newValue) async {
      onNewError(await validate(newValue));
    }));
    addDisposable(subject: _valueController);
  }

  void onNewValue(T newValue) {
    var isNew = value != newValue;

    _logger.d(() => "onNewValue = $isNew.");
    if (isNew) {
      _valueController.add(newValue);
    }
  }
}
