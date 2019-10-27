import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/form/field/text/form_text_field_validation.dart';

String createDefaultTextValidationErrorDescription(
    BuildContext context, TextValidationError textValidationError) {
  if (textValidationError is IsEmptyTextValidationError) {
    return AppLocalizations.of(context).tr("form.field.text.error.empty_field");
  } else if (textValidationError is NoWhitespacesTextValidationError) {
    return AppLocalizations.of(context)
        .tr("form.field.text.error.no_whitespace");
  } else if (textValidationError is NotUniqueTextValidationError) {
    return AppLocalizations.of(context).tr("form.field.text.error.not_unique");
  } else {
    throw Exception("Not supported error $textValidationError");
  }
}
