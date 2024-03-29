import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/disposable/async_disposable.dart';
import 'package:flutter_appirc/disposable/rx_disposable.dart';
import 'package:flutter_appirc/disposable/ui_disposable.dart';
import 'package:rxdart/subjects.dart';

import 'disposable.dart';

class DisposableOwner implements IDisposable {
  @override
  bool isDisposed = false;
  final CompositeDisposable _compositeDisposable = CompositeDisposable([]);

  void addDisposable({
    IDisposable disposable,
    StreamSubscription streamSubscription,
    TextEditingController textEditingController,
    ScrollController scrollController,
    FocusNode focusNode,
    Subject subject,
    StreamController streamController,
    Timer timer,
    FutureOr Function() custom,
  }) {
    if (disposable != null) {
      _compositeDisposable.children.add(disposable);
    }

    if (subject != null) {
      _compositeDisposable.children.add(SubjectDisposable(subject));
    }

    if (streamController != null) {
      _compositeDisposable.children
          .add(StreamControllerDisposable(streamController));
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
    if (focusNode != null) {
      _compositeDisposable.children.add(FocusNodeDisposable(focusNode));
    }
    if (scrollController != null) {
      _compositeDisposable.children
          .add(ScrollControllerDisposable(scrollController));
    }
    if (custom != null) {
      _compositeDisposable.children.add(CustomDisposable(custom));
    }
  }

  @override
  @mustCallSuper
  Future dispose() async {
    isDisposed = true;
    await _compositeDisposable.dispose();
  }
}
