import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';

abstract class Disposable {
  @mustCallSuper
  void dispose();
}

class CustomDisposable extends Disposable {
  final VoidCallback _disposeCallback;

  CustomDisposable(this._disposeCallback);

  @override
  void dispose() => _disposeCallback();
}

class CompositeDisposable extends CustomDisposable {
  final List<Disposable> children;

  CompositeDisposable(this.children)
      : super(() {
          children.forEach((child) => child.dispose());
        });

  void add(Disposable disposable) => children.add(disposable);
}

class StreamSubscriptionDisposable extends CustomDisposable {
  final StreamSubscription streamSubscription;

  StreamSubscriptionDisposable(this.streamSubscription)
      : super(() => streamSubscription.cancel());
}

class SubjectDisposable extends CustomDisposable {
  final Subject subject;

  SubjectDisposable(this.subject)
      : super(() => subject.close());
}
class TimerDisposable extends CustomDisposable {
  final Timer timer;

  TimerDisposable(this.timer)
      : super(() => timer.cancel());
}

class TextEditingControllerDisposable extends CustomDisposable {
  final TextEditingController textEditingController;

  TextEditingControllerDisposable(this.textEditingController)
      : super(() => textEditingController.dispose());
}