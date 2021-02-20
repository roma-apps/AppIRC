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
    Provider<T> provider = context.findAncestorWidgetOfExactType<Provider<T>>();
    return provider.providable;
  }
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
