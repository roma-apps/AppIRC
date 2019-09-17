import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:rxdart/rxdart.dart';

typedef ValidatorFunction<T> = Future<ValidationError> Function(T newValue);

abstract class Validator<T> {
  Future<ValidationError> validate(T value);
}

class FormFieldValidator extends Validator<List<FormFieldBloc>> {
  Future<ValidationError> validate(List<FormFieldBloc> value) {
    var error;
    for (var bloc in value) {
      error = bloc.validate();
      if (error != null) {
        break;
      }
    }

    return error;
  }
}

class CustomValidator<T> extends Validator<T> {
  final ValidatorFunction validator;


  CustomValidator(this.validator);

  @override
  Future<ValidationError> validate(T value) async => await validator(value);

}

abstract class ValidationError {
  String getDescription(BuildContext context);
}

class IsEmptyValidationError extends ValidationError {
  String getDescription(BuildContext context) =>
      AppLocalizations.of(context).tr("form.empty_field_not_valid");
}

class NoWhitespacesValidationError extends ValidationError {
  String getDescription(BuildContext context) =>
      AppLocalizations.of(context).tr("form.no_whitespace");
}

class NotUniqueValidationError extends ValidationError {
  String getDescription(BuildContext context) =>
      AppLocalizations.of(context).tr("form.not_unique");
}

abstract class FormFieldBloc<T> extends Providable {
  T get value;

  var _validationErrorController =
  BehaviorSubject<ValidationError>(seedValue: null);

  Stream<ValidationError> get errorStream => _validationErrorController.stream;
  ValidationError get error => _validationErrorController.value;

  Stream<bool> get dataValidStream =>
      _validationErrorController.stream.map((error) => error == null);

  bool get isDataValid => _validationErrorController.value == null;

  final List<Validator<T>> validators;

  FormFieldBloc(this.validators);

  void onNewError(ValidationError newError) {
    if(error != newError) {
      _validationErrorController.add(newError);
    }

  }

  Future<ValidationError> validate() async {
    var error;
    var newValue = value;
    for (var validator in validators) {
      error = await validator.validate(newValue);
      if (error != null) {
        break;
      }
    }
    return error;
  }

  @override
  void dispose() {
    _validationErrorController.close();
  }
}

abstract class FormBloc extends FormFieldBloc<List<FormFieldBloc>> {
  var listeners = <StreamSubscription>[];
  
  FormBloc() : super([FormFieldValidator()]) {

    Future.delayed(Duration(milliseconds: 1),() {
      children.forEach((child) {
        listeners.add(child.errorStream.listen((_) => onDataChanged()) );
      });
    });

  }

  List<FormFieldBloc> get children;

  @override
  List<FormFieldBloc> get value => children;

  @override
  void dispose() {
    children.forEach((bloc) => bloc.dispose());
    listeners.forEach((listener) => listener.cancel());
  }

  onDataChanged() {

    var error;
    for(var child in children) {
      error = child.error;
      if(error != null) {
        break;
      }
    }

    onNewError(error);

  }
}



class FormValueFieldBloc<T> extends FormFieldBloc<T> {
  T _currentValue;

  StreamSubscription<T> _listener;

  BehaviorSubject<T> _valueController = BehaviorSubject<T>();

  Stream<T> get valueStream => _valueController.stream;

  T get value => _currentValue;

  FormValueFieldBloc(T startValue, {List<Validator<T>> validators = const []})
      : super(validators) {
    _listener = valueStream.listen((newValue) async => onNewError(await validate()));
    onNewValue(startValue);
  }

  void onNewValue(T newValue) {
    if(_currentValue != newValue) {
      _currentValue = newValue;
      _valueController.add(newValue);
    }
  }


  @override
  void dispose() {
    _listener.cancel();
    _valueController.close();
  }
}

class NotEmptyTextValidator extends Validator<String> {
  @override
  Future<ValidationError> validate(String value) async =>
      value.isEmpty ? IsEmptyValidationError() : null;
}

class NoWhitespaceTextValidator extends Validator<String> {
  @override
  Future<ValidationError> validate(String value) async =>
      value.contains(" ") ? NoWhitespacesValidationError() : null;
}
