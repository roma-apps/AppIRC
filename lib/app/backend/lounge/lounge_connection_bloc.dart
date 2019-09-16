import 'package:flutter_appirc/app/backend/lounge/lounge_backend_service.dart';
import 'package:flutter_appirc/async/async_operation_bloc.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';

class LoungeConnectionBloc extends AsyncOperationBloc {
  final LoungeBackendService loungeBackendService;

  LoungeConnectionBloc(this.loungeBackendService);

  Future<bool> tryConnect(LoungePreferences preferences) async =>
      await doAsyncOperation(
          () async => await loungeBackendService.tryConnect(preferences));
}
