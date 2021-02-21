import 'dart:async';

import 'package:flutter_appirc/disposable/disposable_owner.dart';
import 'package:flutter_appirc/form/form_validation.dart';
import 'package:rxdart/subjects.dart';

abstract class FormFieldBloc<T> extends DisposableOwner {
  T get value;

  final _validationErrorController = BehaviorSubject<ValidationError>();

  Stream<ValidationError> get errorStream =>
      _validationErrorController.stream.distinct();

  ValidationError get error => _validationErrorController.value;

  Stream<bool> get dataValidStream =>
      _validationErrorController.stream.map((error) => error == null);

  bool get isDataValid => _validationErrorController.value == null;

  final List<Validator<T>> validators;

  FormFieldBloc(this.validators) {
    addDisposable(subject: _validationErrorController);
  }

  void onNewError(ValidationError newError) {
    _validationErrorController.add(newError);
  }

  Future<ValidationError> validate(newValue) async {
    var error;
    for (var validator in validators) {
      error = await validator.validate(newValue);
      if (error != null) {
        break;
      }
    }
    return error;
  }
}
