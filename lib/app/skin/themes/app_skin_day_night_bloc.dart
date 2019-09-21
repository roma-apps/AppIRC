import 'package:flutter_appirc/app/skin/app_skin_preference_bloc.dart';
import 'package:flutter_appirc/app/skin/ui_skin.dart';
import 'package:flutter_appirc/provider/provider.dart';

class AppSkinDayNightBloc extends Providable {
  final AppSkinPreferenceBloc preferenceBloc;
  final AppSkin daySkin;
  final AppSkin nightSkin;

  AppSkinDayNightBloc(this.preferenceBloc, this.daySkin, this.nightSkin);

  toggleTheme() {
    var newSkin;
    if(isDay) {
      newSkin = nightSkin;
    } else {
      newSkin = daySkin;
    }

    preferenceBloc.currentAppSkin = newSkin;
  }

  bool get isDay => preferenceBloc.currentAppSkin == daySkin;
}
