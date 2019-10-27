import 'package:flutter_appirc/form/form_validation.dart';

class TextValidationError extends ValidationError {}

class IsEmptyTextValidationError extends TextValidationError {}

class NoWhitespacesTextValidationError extends TextValidationError {}

class NotUniqueTextValidationError extends TextValidationError {}

class NotEmptyTextValidator extends Validator<String> {
  static final NotEmptyTextValidator instance =
      NotEmptyTextValidator._internal();
  @override
  Future<ValidationError> validate(String value) async =>
      value == null || value.isEmpty ? IsEmptyTextValidationError() : null;

  NotEmptyTextValidator._internal();
}

class NoWhitespaceTextValidator extends Validator<String> {
  static final NoWhitespaceTextValidator instance =
      NoWhitespaceTextValidator._internal();
  static final String whitespace = " ";
  @override
  Future<ValidationError> validate(String value) async {
    return value?.contains(whitespace) == true
        ? NoWhitespacesTextValidationError()
        : null;
  }

  NoWhitespaceTextValidator._internal();
}
