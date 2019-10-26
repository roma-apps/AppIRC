import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/lounge/preferences/lounge_preferences_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/preferences/page/lounge_preferences_page.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/provider/provider.dart';

class NewLoungePreferencesPage extends LoungePreferencesPage {
  NewLoungePreferencesPage(LoungePreferences startPreferences)
      : super(startPreferences);

  @override
  onSuccessTestConnectionWithGivenPreferences(
      BuildContext context, LoungePreferences preferences) async {
    _savePreferences(context, preferences);
  }

  void _savePreferences(BuildContext context, LoungePreferences preferences) {
    Provider.of<LoungePreferencesBloc>(context).setValue(preferences);
  }
}
