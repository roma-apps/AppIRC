import 'package:flutter/cupertino.dart';
import 'package:flutter_appirc/blocs/async_operation_bloc.dart';
import 'package:flutter_appirc/blocs/lounge_preferences_bloc.dart';
import 'package:flutter_appirc/models/lounge_model.dart';
import 'package:flutter_appirc/service/lounge_service.dart';

class NewLoungeConnectionBloc extends AsyncOperationBloc {
  final LoungeService loungeService;

  final LoungePreferencesBloc preferencesBloc;

  final LoungePreferences newConnectionPreferences;

  NewLoungeConnectionBloc(
      {@required this.loungeService,
      @required this.preferencesBloc,
      @required this.newConnectionPreferences});

  connect() async {
    onOperationStarted();
    var result = await loungeService.connect(newConnectionPreferences);
    if (result) {
      preferencesBloc.setNewPreferenceValue(newConnectionPreferences);
    }
    onOperationFinished();
    return result;
  }

  @override
  void dispose() {}
}
