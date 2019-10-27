import 'dart:io';

import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';


bool _forceMaterial = false;
void changeToMaterialPlatformAware() {
  changeToMaterialPlatform();
  _forceMaterial = true;
  _forceCupertino = false;
}

bool _forceCupertino = false;
void changeToCupertinoPlatformAware() {
  changeToCupertinoPlatform();
  _forceCupertino = true;
  _forceMaterial = false;
}

void changeToAutoDetectPlatformAware() {
  changeToAutoDetectPlatform();
  _forceMaterial = false;
  _forceCupertino = false;
}

bool get isMaterial =>
    _forceMaterial || (!_forceCupertino && _isMaterialCompatible);

bool get isCupertino =>
    _forceCupertino || (!_forceMaterial && _isCupertinoCompatible);

bool get _isMaterialCompatible =>
    Platform.isWindows ||
        Platform.isAndroid ||
        Platform.isFuchsia ||
        Platform.isLinux;

bool get _isCupertinoCompatible => Platform.isIOS || Platform.isMacOS;

enum UIPlatform {
  material, cupertino
}


UIPlatform detectCurrentUIPlatform() {
  if(isMaterial) {
    return UIPlatform.material;
  }

  if(isCupertino) {
    return UIPlatform.cupertino;
  }

  throw("Platform not supported");
}