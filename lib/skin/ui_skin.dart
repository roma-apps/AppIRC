import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart'
    show CupertinoThemeData, CupertinoTextThemeData;
import 'package:flutter/material.dart' show ThemeData, TextTheme;
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/helpers/provider.dart';

class AppSkin {
  final Color accentColor;
  final TextStyle formRowLabelTextStyle;
  final TextStyle networksListNetworkTextStyle;
  final TextStyle channelMessagesNickTextStyle;
  final TextStyle channelMessagesDateTextStyle;
  final TextStyle networksListChannelTextStyle;
  final TextStyle topicTextStyle;

  AppSkin(
      {@required this.accentColor,
        @required this.formRowLabelTextStyle, @required this.networksListNetworkTextStyle,
        @required this.channelMessagesNickTextStyle, @required this.channelMessagesDateTextStyle,
        @required this.networksListChannelTextStyle, @required this.topicTextStyle});


}

class UISkin extends Providable {

  final ThemeData androidTheme;
  final CupertinoThemeData iosTheme;
  AppSkin appSkin;

  TextTheme get androidTextTheme => androidTheme.textTheme;

  CupertinoTextThemeData get iosTextTheme => iosTheme.textTheme;


  UISkin(this.androidTheme, this.iosTheme) {
    if (Platform.isIOS) {
      appSkin = AppSkin(
          accentColor: iosTheme.primaryColor,
          formRowLabelTextStyle: iosTextTheme.navTitleTextStyle,
          networksListNetworkTextStyle: iosTextTheme.navTitleTextStyle,
          channelMessagesNickTextStyle: iosTextTheme.navTitleTextStyle,
          channelMessagesDateTextStyle: iosTextTheme.textStyle,
          networksListChannelTextStyle: iosTextTheme.textStyle,
          topicTextStyle: iosTextTheme.textStyle);
    } else if (Platform.isAndroid) {
      appSkin = AppSkin(
          accentColor: androidTheme.accentColor,
          formRowLabelTextStyle: androidTextTheme.title,
          networksListNetworkTextStyle: androidTheme.textTheme.title,
          channelMessagesNickTextStyle: androidTheme.textTheme.subtitle,
          channelMessagesDateTextStyle: androidTheme.textTheme.subtitle,
          networksListChannelTextStyle: androidTheme.textTheme.body2,
          topicTextStyle: androidTheme.textTheme.body1);
    } else {
      Future.error("UISkin Platform ${Platform.operatingSystem} not supported");
    }
  }


  static UISkin of(BuildContext context) => Provider.of<UISkin>(context);

  @override
  void dispose() {}
}
