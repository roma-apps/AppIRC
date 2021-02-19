import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';


bool _forceMaterial = false;
void changeToMaterialPlatformAware(BuildContext context) {
  PlatformProvider.of(context).changeToCupertinoPlatform();
  _forceMaterial = true;
  _forceCupertino = false;
}

bool _forceCupertino = false;
void changeToCupertinoPlatformAware(BuildContext context) {
  PlatformProvider.of(context).changeToCupertinoPlatform();
  _forceCupertino = true;
  _forceMaterial = false;
}

void changeToAutoDetectPlatformAware(BuildContext context) {
  PlatformProvider.of(context).changeToAutoDetectPlatform();
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