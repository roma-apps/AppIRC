import 'package:flutter_appirc/skin/skin_model.dart';
import 'package:flutter_appirc/skin/skin_preference_bloc.dart';
import 'package:flutter_appirc/provider/provider.dart';

class AppSkinDayNightBloc extends Providable {
  final AppSkinPreferenceBloc preferenceBloc;
  final AppSkinTheme dayTheme;
  final AppSkinTheme nightSkin;

  AppSkinDayNightBloc(this.preferenceBloc, this.dayTheme, this.nightSkin);

  toggleTheme() {
    var newSkin;
    if(isDay) {
      newSkin = nightSkin;
    } else {
      newSkin = dayTheme;
    }

    preferenceBloc.currentAppSkinTheme = newSkin;
  }

  bool get isDay => preferenceBloc.currentAppSkinTheme == dayTheme;
}
