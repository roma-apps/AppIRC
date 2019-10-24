import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/disposable/disposable.dart';

class TextEditingControllerDisposable extends CustomDisposable {
  final TextEditingController textEditingController;

  TextEditingControllerDisposable(this.textEditingController)
      : super(() => textEditingController.dispose());
}
