import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/blocs/async_operation_bloc.dart';
import 'package:flutter_appirc/helpers/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class ButtonLoadingWidget extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;

  const ButtonLoadingWidget({this.child, this.onPressed});

  @override
  Widget build(BuildContext context) {
    var asyncBloc = Provider.of<AsyncOperationBloc>(context);

    return StreamBuilder<bool>(
        stream: asyncBloc.outInProgress,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          var data = snapshot.data;
          var inProgress =
              data == null ? AsyncOperationBloc.defaultValue : data;

          if (inProgress) {
            return PlatformButton(child: Row(
              children: <Widget>[
                PlatformCircularProgressIndicator(),
                child,
              ],
            ), onPressed: onPressed);
          } else {
            return PlatformButton(child: child, onPressed: onPressed);
          }
        });
  }
}
