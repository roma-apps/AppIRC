import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/lounge/connection/page/lounge_connection_page.dart';
import 'package:flutter_appirc/app/instance/current/current_auth_instance_bloc.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';

class NewLoungeConnectionPage extends LoungeConnectionPage {
  const NewLoungeConnectionPage();

  @override
  void onSuccessTestConnectionWithGivenPreferences(
      BuildContext context, LoungePreferences preferences) async {
    _savePreferences(context, preferences);
  }

  void _savePreferences(BuildContext context, LoungePreferences preferences) {
    var currentAuthInstanceBloc = ICurrentAuthInstanceBloc.of(
      context,
      listen: false,
    );

    currentAuthInstanceBloc.changeCurrentInstance(preferences);
  }
}
