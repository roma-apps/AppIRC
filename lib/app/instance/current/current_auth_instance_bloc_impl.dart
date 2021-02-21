import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/instance/current/current_auth_instance_bloc.dart';
import 'package:flutter_appirc/app/instance/current/current_auth_instance_local_preference_bloc.dart';
import 'package:flutter_appirc/disposable/disposable_owner.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:logging/logging.dart';

var _logger = Logger("current_auth_instance_bloc_impl.dart");

class CurrentAuthInstanceBloc extends DisposableOwner
    implements ICurrentAuthInstanceBloc {
  final ICurrentAuthInstanceLocalPreferenceBloc currentLocalPreferenceBloc;

  CurrentAuthInstanceBloc({
    @required this.currentLocalPreferenceBloc,
  });

  @override
  LoungePreferences get currentInstance => currentLocalPreferenceBloc.value;

  @override
  Stream<LoungePreferences> get currentInstanceStream =>
      currentLocalPreferenceBloc.stream;

  @override
  Future changeCurrentInstance(LoungePreferences instance) async {
    _logger.finest(() => "changeCurrentInstance $instance");

    await currentLocalPreferenceBloc.setValue(instance);
  }

  @override
  bool isCurrentInstance(LoungePreferences instance) =>
      currentInstance == instance;

  @override
  Future logoutCurrentInstance() async {
    _logger.finest(() => "logoutCurrentInstance $currentInstance");
    await currentLocalPreferenceBloc.setValue(null);
  }
}
