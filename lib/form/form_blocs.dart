import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:rxdart/rxdart.dart';

MyLogger _logger = MyLogger(logTag: "form_blocs.dart", enabled: true);

typedef ValidatorFunction<T> = Future<ValidationError> Function(T newValue);

abstract class Validator<T> {
  Future<ValidationError> validate(T value);
}

class FormFieldValidator extends Validator<List<FormFieldBloc>> {
  Future<ValidationError> validate(List<FormFieldBloc> value) {
    var error;
    for (var bloc in value) {
      error = bloc.validate(bloc.value);
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
      AppLocalizations.of(context).tr("form.field.text.error.empty_field");
}

class NoWhitespacesValidationError extends ValidationError {
  String getDescription(BuildContext context) =>
      AppLocalizations.of(context).tr("form.field.text.error.no_whitespace");
}

class NotUniqueValidationError extends ValidationError {
  String getDescription(BuildContext context) =>
      AppLocalizations.of(context).tr("form.field.text.error.not_unique");
}

abstract class FormFieldBloc<T> extends Providable {
  T get value;

  var _validationErrorController =
      BehaviorSubject<ValidationError>(seedValue: null);

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

abstract class FormBloc extends FormFieldBloc<List<FormFieldBloc>> {
  var listeners = <StreamSubscription>[];

  FormBloc() : super([FormFieldValidator()]) {
    Timer.run(() {
      resubscribeInternalFormsErrors();
    });
  }

  void resubscribeInternalFormsErrors() {
    listeners.forEach((listener) {
      listener.cancel();
    });
    children.forEach((child) {
      listeners.add(child.errorStream.listen((_) => onDataChanged()));
    });

    onDataChanged();
  }

  List<FormFieldBloc> get children;

  @override
  List<FormFieldBloc> get value => children;

  @override
  void dispose() {
    super.dispose();
    children.forEach((bloc) => bloc.dispose());
    listeners.forEach((listener) => listener.cancel());
  }

  onDataChanged() {
    var error;
    for (var child in children) {
      error = child.error;
      if (error != null) {
        break;
      }
    }

    onNewError(error);
  }
}

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

class NotEmptyTextValidator extends Validator<String> {
  static final NotEmptyTextValidator instance =
      NotEmptyTextValidator._internal();
  @override
  Future<ValidationError> validate(String value) async =>
      value == null || value.isEmpty ? IsEmptyValidationError() : null;

  NotEmptyTextValidator._internal();
}

class NoWhitespaceTextValidator extends Validator<String> {
  static final NoWhitespaceTextValidator instance =
      NoWhitespaceTextValidator._internal();
  @override
  Future<ValidationError> validate(String value) async =>
      value?.contains(" ") == true ? NoWhitespacesValidationError() : null;

  NoWhitespaceTextValidator._internal();
}
