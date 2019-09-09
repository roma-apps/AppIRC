import 'dart:io';


import 'package:flutter/cupertino.dart' show CupertinoSwitch;
import 'package:flutter/material.dart' show Checkbox;
import 'package:flutter/widgets.dart';

Widget buildPlatformAwareCheckBox(
    {@required bool value, @required void onChanged(bool)}) {
  if(Platform.isAndroid) {
    return Checkbox(value: value, onChanged: onChanged);
  } else if(Platform.isIOS) {
    return CupertinoSwitch(value: value, onChanged: onChanged);
  } else {
    Future.error("buildPlatformAwareCheckBox Platform ${Platform.operatingSystem} not supported");
    return null;
  }
}
