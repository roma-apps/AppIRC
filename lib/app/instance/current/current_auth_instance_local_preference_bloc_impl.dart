import 'package:flutter_appirc/app/instance/current/current_auth_instance_local_preference_bloc.dart';
import 'package:flutter_appirc/local_preferences/local_preference_bloc_impl.dart';
import 'package:flutter_appirc/local_preferences/local_preferences_service.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';

class CurrentAuthInstanceLocalPreferenceBloc
    extends ObjectLocalPreferenceBloc<LoungePreferences>
    implements ICurrentAuthInstanceLocalPreferenceBloc {
  CurrentAuthInstanceLocalPreferenceBloc(
      ILocalPreferencesService preferencesService)
      : super(
          preferencesService,
          "instance.current",
          1,
          (json) => LoungePreferences.fromJson(json),
        );
}
