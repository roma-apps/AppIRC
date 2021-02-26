import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/disposable/disposable_owner.dart';
import 'package:provider/provider.dart';

class SocketIOService extends DisposableOwner {
  static SocketIOService of(BuildContext context, {bool listen = true}) =>
      Provider.of<SocketIOService>(context, listen: listen);
  SocketIOManager manager;

  SocketIOService() : manager = SocketIOManager() {
    addDisposable(custom: () {
      manager = null;
    });
  }

  Future<SocketIO> createInstance(SocketOptions socketOptions) =>
      manager.createInstance(socketOptions);

  Future clearInstance(SocketIO socketIO) => manager.clearInstance(socketIO);
}
