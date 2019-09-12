import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/blocs/async_operation_bloc.dart';
import 'package:flutter_appirc/models/lounge_model.dart';

class LoungeConnectionBloc extends AsyncOperationBloc {
  LoungePreferences newLoungePreferences;

  LoungeConnectionBloc({@required this.newLoungePreferences});

  @override
  void dispose() {
    super.dispose();
  }
}
