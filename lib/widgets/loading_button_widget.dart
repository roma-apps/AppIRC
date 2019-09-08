import 'package:flutter/material.dart';
import 'package:flutter_appirc/blocs/async_operation_bloc.dart';
import 'package:flutter_appirc/provider.dart';

class LoadingButtonWidget extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;

  const LoadingButtonWidget({this.child, this.onPressed});

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
            return RaisedButton(child: child, onPressed: onPressed);
          } else {
            return RaisedButton(child: child, onPressed: onPressed);
          }
        });
  }
}
