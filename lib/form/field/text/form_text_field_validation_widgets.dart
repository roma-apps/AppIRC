import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/form/field/text/form_text_field_validation.dart';
import 'package:flutter_appirc/generated/l10n.dart';

String createDefaultTextValidationErrorDescription(
  BuildContext context,
  TextValidationError textValidationError,
) {
  if (textValidationError is IsEmptyTextValidationError) {
    return S.of(context).form_field_text_error_empty_field;
  } else if (textValidationError is NoWhitespacesTextValidationError) {
    return S.of(context).form_field_text_error_no_whitespace;
  } else if (textValidationError is NotUniqueTextValidationError) {
    return S.of(context).form_field_text_error_not_unique;
  } else {
    throw Exception("Not supported error $textValidationError");
  }
}
