import 'package:flutter_appirc/app/skin/ui_skin.dart';
import 'package:flutter_appirc/local_preferences/preferences_bloc.dart';
import 'package:flutter_appirc/local_preferences/preferences_service.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:rxdart/rxdart.dart';

const String _preferenceKey = "app_skin";

class AppSkinPreferenceBloc extends Providable {

  final PreferencesService preferencesService;
  final AppSkin defaultSkin;
  final List<AppSkin> allAvailableSkins;

  StringPreferencesBloc _skinPreferenceBloc;

  Stream<AppSkin> get appSkinStream => _skinPreferenceBloc.valueStream(defaultValue: defaultSkin.id).map(_map).distinct();
  AppSkin get currentAppSkin => _map(_skinPreferenceBloc.getValue(defaultValue: defaultSkin.id));
  set currentAppSkin(AppSkin newValue) =>  _skinPreferenceBloc.setValue(newValue.id);

  AppSkin _map(skinId) {
        if(skinId == null){
          return defaultSkin;
        } else {
          var skin = allAvailableSkins.firstWhere((skin) => skin.id == skinId, orElse: () => null);
          if(skin == null) {
            skin = defaultSkin;
          }

          return skin;
        }
  }

  AppSkinPreferenceBloc(this.preferencesService, this.allAvailableSkins, this.defaultSkin) {
    _skinPreferenceBloc = StringPreferencesBloc(preferencesService, _preferenceKey);
    addDisposable(disposable: _skinPreferenceBloc);
  }


}
