import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/async/loading/init/async_init_loading_bloc.dart';
import 'package:flutter_appirc/disposable/disposable.dart';
import 'package:flutter_appirc/push/push_model.dart';
import 'package:provider/provider.dart';

abstract class IFcmPushService extends IDisposable
    implements IAsyncInitLoadingBloc {
  Stream<String> get deviceTokenStream;

  String get deviceToken;

  Stream<PushMessage> get messageStream;

  Future<bool> askPermissions();

  static IFcmPushService of(BuildContext context, {bool listen = true}) =>
      Provider.of<IFcmPushService>(context, listen: listen);
}
