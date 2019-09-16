import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_preferences_bloc.dart';
import 'package:flutter_appirc/lounge/lounge_service.dart';

import 'lounge_connection_bloc.dart';

class LoungeEditConnectionBloc extends LoungeConnectionBloc {
  final SocketIOManager socketIOManager;

  final LoungePreferencesBloc preferencesBloc;

  LoungeEditConnectionBloc(
      {@required this.socketIOManager,
      @required this.preferencesBloc,
      @required newLoungePreferences})
      : super(newLoungePreferences: newLoungePreferences);

  Future<bool> checkPreferences() async => doAsyncOperation(() async {
        var loungeService = LoungeService(socketIOManager);

        var result = await loungeService.connect(newLoungePreferences);

        if (result) {
          loungeService.disconnect();
        }
        loungeService.dispose();

        return result;
      });

  @override
  void dispose() {
    super.dispose();
  }
}
