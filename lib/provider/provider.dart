import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/disposable/disposable_owner.dart';

abstract class Providable extends DisposableOwner {}

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
