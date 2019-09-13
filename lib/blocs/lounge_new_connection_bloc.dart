import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/blocs/lounge_preferences_bloc.dart';
import 'package:flutter_appirc/service/lounge_service.dart';

import 'lounge_connection_bloc.dart';

class LoungeNewConnectionBloc extends LoungeConnectionBloc {
  final LoungeService loungeService;

  final LoungePreferencesBloc preferencesBloc;

  LoungeNewConnectionBloc(
      {@required this.loungeService,
      @required this.preferencesBloc,
      @required newLoungePreferences})
      : super(newLoungePreferences: newLoungePreferences);

  Future<bool> connect() async => doAsyncOperation(() async {
        var result = await loungeService.connect(newLoungePreferences);
        if (result) {
          preferencesBloc.setNewPreferenceValue(newLoungePreferences);
        }
        return result;
      });

  @override
  void dispose() {
    super.dispose();
  }
}
