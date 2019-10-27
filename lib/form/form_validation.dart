
import 'package:flutter_appirc/form/field/form_field_bloc.dart';

typedef ValidatorFunction<T> = Future<ValidationError> Function(T newValue);

abstract class Validator<T> {
  Future<ValidationError> validate(T value);
}

class CustomValidator<T> extends Validator<T> {
  final ValidatorFunction validator;

  CustomValidator(this.validator);

  @override
  Future<ValidationError> validate(T value) async => await validator(value);
}

abstract class ValidationError {
}

class FormFieldsValidator extends Validator<List<FormFieldBloc>> {
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
