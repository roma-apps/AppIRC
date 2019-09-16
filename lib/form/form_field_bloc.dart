import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:rxdart/rxdart.dart';

abstract class FormFieldBloc extends Providable {
  var _dataValidController = BehaviorSubject<bool>(seedValue: false);

  Stream<bool> get dataValidStream => _dataValidController.stream;

  Future<bool> get isDataValid async => await dataValidStream.last;


  FormFieldBloc() {
    _dataValidController.add(checkIsDataValid());
  }
  bool checkIsDataValid();

  @override
  void dispose() {
    _dataValidController.close();
  }
}

abstract class FormTextFieldBloc extends FormFieldBloc {
  final TextEditingController textEditingController;

  FormTextFieldBloc(this.textEditingController) {

    textEditingController.addListener(_onChangeCallback);
  }
  @override
  void dispose() {
    super.dispose();
    textEditingController.removeListener(_onChangeCallback);
    textEditingController.dispose();
  }



  void _onChangeCallback() =>
      _dataValidController.add(checkIsDataValid());
}

class FormNotEmptyTextFieldBloc extends FormTextFieldBloc {
  FormNotEmptyTextFieldBloc(TextEditingController textEditingController)
      : super(textEditingController);

  bool checkIsDataValid() => textEditingController.text.isNotEmpty;
}
