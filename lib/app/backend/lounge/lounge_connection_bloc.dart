import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/async/async_operation_bloc.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';

class LoungeConnectionBloc extends AsyncOperationBloc {
  LoungePreferences newLoungePreferences;

  LoungeConnectionBloc({@required this.newLoungePreferences});

  @override
  void dispose() {
    super.dispose();
  }

  void changeHost(String text) {
    newLoungePreferences.host = text;
  }
}
