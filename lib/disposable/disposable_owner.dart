import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/disposable/async_disposable.dart';
import 'package:flutter_appirc/disposable/disposable.dart';
import 'package:flutter_appirc/disposable/rx_disposable.dart';
import 'package:flutter_appirc/disposable/ui_disposable.dart';
import 'package:rxdart/subjects.dart';

class DisposableOwner extends Disposable {
  bool disposed = false;
  final CompositeDisposable _compositeDisposable = CompositeDisposable([]);

  void addDisposable({
    Disposable disposable,
    StreamSubscription streamSubscription,
    TextEditingController textEditingController,
    Subject subject,
    Timer timer,
  }) {
    if (disposable != null) {
      _compositeDisposable.children.add(disposable);
    }

    if (subject != null) {
      _compositeDisposable.children.add(SubjectDisposable(subject));
    }

    if (timer != null) {
      _compositeDisposable.children.add(TimerDisposable(timer));
    }

    if (streamSubscription != null) {
      _compositeDisposable.children
          .add(StreamSubscriptionDisposable(streamSubscription));
    }

    if (textEditingController != null) {
      _compositeDisposable.children
          .add(TextEditingControllerDisposable(textEditingController));
    }
  }

  @override
  @mustCallSuper
  void dispose() {
    disposed = true;
    _compositeDisposable.dispose();
  }
}
