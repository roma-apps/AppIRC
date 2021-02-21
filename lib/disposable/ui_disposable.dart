
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/disposable/disposable.dart';

class TextEditingControllerDisposable extends CustomDisposable {
  final TextEditingController textEditingController;

  TextEditingControllerDisposable(this.textEditingController)
      : super(() async => textEditingController.dispose());
}

class FocusNodeDisposable extends CustomDisposable {
  final FocusNode focusNode;

  FocusNodeDisposable(this.focusNode) : super(() async => focusNode.dispose());
}

class ScrollControllerDisposable extends CustomDisposable {
  final ScrollController scrollController;

  ScrollControllerDisposable(this.scrollController)
      : super(() async {
          scrollController.dispose();
        });
}
