import 'package:flutter/cupertino.dart';
import 'package:flutter_appirc/blocs/async_operation_bloc.dart';
import 'package:flutter_appirc/blocs/lounge_preferences_bloc.dart';
import 'package:flutter_appirc/models/lounge_model.dart';
import 'package:flutter_appirc/service/lounge_service.dart';

class LoungeNewConnectionBloc extends AsyncOperationBloc {
  final LoungeService loungeService;

  final LoungePreferencesBloc preferencesBloc;

  LoungePreferences newLoungePreferences;

  LoungeNewConnectionBloc(
      {@required this.loungeService,
      @required this.preferencesBloc,
      @required this.newLoungePreferences});

  connect() async {
    onOperationStarted();
    var result = await loungeService.connect(newLoungePreferences);
    if (result) {
      preferencesBloc.setNewPreferenceValue(newLoungePreferences);
    }
    onOperationFinished();
    return result;
  }



  @override
  void dispose() {
    super.dispose();
  }
}
