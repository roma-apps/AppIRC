import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/async/disposable.dart';
import 'package:rxdart/rxdart.dart';

abstract class Providable extends Disposable {
  final CompositeDisposable _compositeDisposable = CompositeDisposable([]);


  void addDisposable(
      {Disposable disposable,
      StreamSubscription streamSubscription,
      TextEditingController textEditingController, Subject subject, Timer timer}) {
    if (disposable != null) {
      _compositeDisposable.children.add(disposable);
    }

    if(subject != null) {
      _compositeDisposable.children
          .add(SubjectDisposable(subject));
    }


    if(timer != null) {
      _compositeDisposable.children
          .add(TimerDisposable(timer));
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

  @mustCallSuper
  void dispose() {
    _compositeDisposable.dispose();
  }
}

class Provider<T extends Providable> extends StatefulWidget {
  Provider({
    Key key,
    @required this.child,
    @required this.providable,
  }) : super(key: key);

  final T providable;
  final Widget child;

  @override
  _ProviderState<T> createState() => _ProviderState<T>();

  static T of<T extends Providable>(BuildContext context) {
    final type = _typeOf<Provider<T>>();
    Provider<T> provider = context.ancestorWidgetOfExactType(type);
    return provider.providable;
  }

  static Type _typeOf<T>() => T;
}

class _ProviderState<T> extends State<Provider<Providable>> {
  @override
  void dispose() {
    widget.providable.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
