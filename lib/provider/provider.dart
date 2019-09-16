

import 'package:flutter/widgets.dart';

abstract class Providable {
  void dispose();
}

class Provider<T extends Providable> extends StatefulWidget {
  Provider({
    Key key,
    @required this.child,
    @required this.bloc,
  }) : super(key: key);

  final T bloc;
  final Widget child;

  @override
  _ProviderState<T> createState() => _ProviderState<T>();

  static T of<T extends Providable>(BuildContext context) {
    final type = _typeOf<Provider<T>>();
    Provider<T> provider = context.ancestorWidgetOfExactType(type);
    return provider.bloc;
  }

  static Type _typeOf<T>() => T;
}

class _ProviderState<T> extends State<Provider<Providable>> {
  @override
  void dispose() {
    widget.bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
