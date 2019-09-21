import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart'
    show CupertinoThemeData, CupertinoTextThemeData;
import 'package:flutter/material.dart' show Colors, TextTheme, ThemeData;
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/skin/themes/day.dart';
import 'package:flutter_appirc/app/skin/themes/night.dart';
import 'package:flutter_appirc/provider/provider.dart';

class UISkin extends Providable {

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

  UISkin({@required this.accentColor,
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


  static UISkin of(BuildContext context) => Provider.of<UISkin>(context);

}

class AppSkin {
  final String id;

  TextTheme get androidTextTheme => androidTheme.textTheme;

  CupertinoTextThemeData get iosTextTheme => iosTheme.textTheme;

  final ThemeData androidTheme;
  final CupertinoThemeData iosTheme;

  UISkin uiSkin;

  AppSkin(this.id, this.androidTheme, this.iosTheme) {
    if (Platform.isIOS) {
      uiSkin = UISkin(
          accentColor: iosTheme.primaryColor,
          formRowLabelTextStyle: iosTextTheme.navTitleTextStyle.copyWith(
              fontWeight: FontWeight.bold),
          networksListNetworkTextStyle: iosTextTheme.navTitleTextStyle,
          channelMessagesNickTextStyle: iosTextTheme.navTitleTextStyle,
          channelMessagesDateTextStyle: iosTextTheme.navTitleTextStyle,
          networksListChannelTextStyle: iosTextTheme.textStyle,
          topicTextStyle: iosTextTheme.textStyle.copyWith(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.normal),
          networksListActiveChannelTextStyle: iosTextTheme.navTitleTextStyle,
          networksListActiveNetworkTextStyle: iosTextTheme.navTitleTextStyle,
          enterMessageTextStyle: iosTextTheme.textStyle.copyWith(
              color: Colors.white),
          channelMessagesBodyTextStyle: iosTextTheme.textStyle);
    } else if (Platform.isAndroid) {
      uiSkin = UISkin(
          accentColor: androidTheme.accentColor,
          formRowLabelTextStyle: androidTextTheme.headline.copyWith(
              fontWeight: FontWeight.bold, fontSize: 20),
          networksListNetworkTextStyle: androidTheme.textTheme.title.copyWith(
              fontWeight: FontWeight.bold),
          channelMessagesNickTextStyle: androidTheme.textTheme.body1.copyWith(
              fontWeight: FontWeight.bold),
          channelMessagesDateTextStyle: androidTheme.textTheme.caption,
          networksListChannelTextStyle: androidTheme.textTheme.body2,
          topicTextStyle: androidTheme.textTheme.headline.copyWith(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.normal),
          networksListActiveChannelTextStyle: androidTheme.textTheme.title,
          networksListActiveNetworkTextStyle: androidTextTheme.title,
          channelMessagesBodyTextStyle: androidTheme.textTheme.body1.copyWith(
              height: 1.5),
          enterMessageTextStyle: androidTheme.textTheme.body1.copyWith(
              color: Colors.white));
    } else {
      Future.error("UISkin Platform ${Platform.operatingSystem} not supported");
    }
  }

}


final AppSkin dayAppSkin = DayAppSkin();
final AppSkin nightAppSkin = NightAppSkin();

List<AppSkin> getAvailableSkins() {
  return [dayAppSkin, nightAppSkin];
}

AppSkin getDefaultUISkin() => dayAppSkin;
