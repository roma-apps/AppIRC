import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/context/app_context_bloc.dart';

class AppContextWidget extends StatelessWidget {
  final Widget child;

  const AppContextWidget({@required this.child});

  @override
  Widget build(BuildContext context) {
    var appContextBloc = IAppContextBloc.of(context);
    return appContextBloc.provideContextToChild(child: child);
  }
}
