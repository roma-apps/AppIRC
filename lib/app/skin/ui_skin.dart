import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart'
    show CupertinoThemeData, CupertinoTextThemeData;
import 'package:flutter/material.dart' show Colors, TextTheme, ThemeData;
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/provider/provider.dart';

class AppSkin {
  final Color accentColor;
  final TextStyle formRowLabelTextStyle;
  final TextStyle networksListNetworkTextStyle;
  final TextStyle networksListActiveNetworkTextStyle;
  final TextStyle channelMessagesNickTextStyle;
  final TextStyle channelMessagesDateTextStyle;
  final TextStyle enterMessageTextStyle;
  final TextStyle networksListChannelTextStyle;
  final TextStyle networksListActiveChannelTextStyle;
  final TextStyle topicTextStyle;
  final TextStyle channelMessagesBodyTextStyle;

  AppSkin(
      {@required this.accentColor,
      @required this.formRowLabelTextStyle,
      @required this.networksListNetworkTextStyle,
      @required this.networksListActiveNetworkTextStyle,
      @required this.channelMessagesNickTextStyle,
      @required this.channelMessagesDateTextStyle,
      @required this.networksListChannelTextStyle,
      @required this.enterMessageTextStyle,
      @required this.networksListActiveChannelTextStyle,
      @required this.channelMessagesBodyTextStyle,
      @required this.topicTextStyle});
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
          formRowLabelTextStyle: iosTextTheme.navTitleTextStyle.copyWith(fontWeight: FontWeight.bold),
          networksListNetworkTextStyle: iosTextTheme.navTitleTextStyle,
          channelMessagesNickTextStyle: iosTextTheme.navTitleTextStyle,
          channelMessagesDateTextStyle: iosTextTheme.navTitleTextStyle,
          networksListChannelTextStyle: iosTextTheme.textStyle,
          topicTextStyle: iosTextTheme.textStyle.copyWith(color: Colors.white),
          networksListActiveChannelTextStyle: iosTextTheme.navTitleTextStyle,
          networksListActiveNetworkTextStyle: iosTextTheme.navTitleTextStyle,
          enterMessageTextStyle: iosTextTheme.textStyle.copyWith(color: Colors.white),
          channelMessagesBodyTextStyle:  iosTextTheme.textStyle);
    } else if (Platform.isAndroid) {
      appSkin = AppSkin(
          accentColor: androidTheme.accentColor,
          formRowLabelTextStyle: androidTextTheme.headline.copyWith(fontWeight: FontWeight.bold, fontSize: 20),
          networksListNetworkTextStyle: androidTheme.textTheme.title.copyWith(fontWeight: FontWeight.bold),
          channelMessagesNickTextStyle: androidTheme.textTheme.body1.copyWith(fontWeight: FontWeight.bold),
          channelMessagesDateTextStyle: androidTheme.textTheme.caption,
          networksListChannelTextStyle: androidTheme.textTheme.body2,
          topicTextStyle: androidTheme.textTheme.headline.copyWith(color: Colors.white),
          networksListActiveChannelTextStyle: androidTheme.textTheme.title,
          networksListActiveNetworkTextStyle: androidTextTheme.title,
          channelMessagesBodyTextStyle:  androidTheme.textTheme.body1.copyWith(height: 1.5),
          enterMessageTextStyle: androidTheme.textTheme.body1.copyWith(color: Colors.white));
    } else {
      Future.error("UISkin Platform ${Platform.operatingSystem} not supported");
    }
  }

  static UISkin of(BuildContext context) => Provider.of<UISkin>(context);

  @override
  void dispose() {}
}


UISkin createDefaultUISkin() {
  var accentColor = Colors.red;
  final themeData = new ThemeData(
    primarySwatch: accentColor,
  );

  final cupertinoTheme = new CupertinoThemeData(
    primaryColor: accentColor,
  );

  return UISkin(themeData, cupertinoTheme);
}