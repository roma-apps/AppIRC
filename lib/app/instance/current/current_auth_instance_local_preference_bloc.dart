
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/local_preferences/local_preference_bloc_impl.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:provider/provider.dart';

abstract class ICurrentAuthInstanceLocalPreferenceBloc
    implements LocalPreferenceBloc<LoungePreferences> {
  static ICurrentAuthInstanceLocalPreferenceBloc of(BuildContext context,
          {bool listen = true}) =>
      Provider.of<ICurrentAuthInstanceLocalPreferenceBloc>(context,
          listen: listen);
}
