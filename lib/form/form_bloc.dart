import 'package:flutter_appirc/form/form_field_bloc.dart';

abstract class FormBloc extends FormFieldBloc {
   List<FormTextFieldBloc> get fieldBlocs;

  @override
  bool checkIsDataValid() {
    var valid = true;
    fieldBlocs.forEach((field) => valid = valid && field.checkIsDataValid());
    return valid;
  }

   @override
   void dispose() {
     super.dispose();
     fieldBlocs.forEach((fieldBloc) => fieldBloc.dispose());
   }

}
