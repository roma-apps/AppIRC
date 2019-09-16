import 'package:flutter_appirc/app/skin/ui_skin.dart';
import 'package:flutter_appirc/local_preferences/preferences_service.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class AppSkinBloc extends Providable {
  final PreferencesService preferencesService;


  AppSkinBloc(this.preferencesService);

  //
//
//  AppSkinBloc(UISkin startSkin) {
//    _skinController = BehaviorSubject<UISkin>(seedValue: startSkin);
//  }

  BehaviorSubject<UISkin> _skinController;

  Stream<UISkin> get skinStream => _skinController.stream;

  @override
  void dispose() {
    _skinController.close();
  }
}
