import 'package:flutter_appirc/app/skin/ui_skin.dart';
import 'package:flutter_appirc/local_preferences/preferences_service.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class AppSkinBloc extends Providable {
  final PreferencesService preferencesService;


  AppSkinBloc(this.preferencesService, UISkin startSkin) {
    _skinController = BehaviorSubject<UISkin>(seedValue: startSkin);
    addDisposable(subject: _skinController);
  }


  // ignore: close_sinks
  BehaviorSubject<UISkin> _skinController ;

  Stream<UISkin> get skinStream => _skinController.stream;


}
