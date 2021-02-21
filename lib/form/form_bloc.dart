import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/form/field/form_field_bloc.dart';
import 'package:flutter_appirc/form/form_validation.dart';

abstract class FormBloc extends FormFieldBloc<List<FormFieldBloc>> {
  var listeners = <StreamSubscription>[];

  FormBloc() : super(<Validator<List<FormFieldBloc>>>[FormFieldsValidator()]) {
    Timer.run(() {
      resubscribeInternalFormsErrors();
    });
  }

  @protected
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
  Future dispose() async {
    await super.dispose();
    for(var bloc in children) {
      await bloc.dispose();
    }
    for(var listener in listeners) {
      await listener.cancel();
    }
  }

  void onDataChanged() {
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
