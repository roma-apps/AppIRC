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
  final TextStyle networksListActiveNetworkTextStyle;
  final TextStyle channelMessagesNickTextStyle;
  final TextStyle channelMessagesDateTextStyle;
  final TextStyle networksListChannelTextStyle;
  final TextStyle networksListActiveChannelTextStyle;
  final TextStyle topicTextStyle;

  AppSkin(
      {@required this.accentColor,
      @required this.formRowLabelTextStyle,
      @required this.networksListNetworkTextStyle,
      @required this.networksListActiveNetworkTextStyle,
      @required this.channelMessagesNickTextStyle,
      @required this.channelMessagesDateTextStyle,
      @required this.networksListChannelTextStyle,
      @required this.networksListActiveChannelTextStyle,
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
          formRowLabelTextStyle: iosTextTheme.navTitleTextStyle,
          networksListNetworkTextStyle: iosTextTheme.navTitleTextStyle,
          channelMessagesNickTextStyle: iosTextTheme.navTitleTextStyle,
          channelMessagesDateTextStyle: iosTextTheme.textStyle,
          networksListChannelTextStyle: iosTextTheme.textStyle,
          topicTextStyle: iosTextTheme.textStyle,
          networksListActiveChannelTextStyle: iosTextTheme.navTitleTextStyle,
          networksListActiveNetworkTextStyle: iosTextTheme.navTitleTextStyle);
    } else if (Platform.isAndroid) {
      appSkin = AppSkin(
          accentColor: androidTheme.accentColor,
          formRowLabelTextStyle: androidTextTheme.title,
          networksListNetworkTextStyle: androidTheme.textTheme.title,
          channelMessagesNickTextStyle: androidTheme.textTheme.subtitle,
          channelMessagesDateTextStyle: androidTheme.textTheme.subtitle,
          networksListChannelTextStyle: androidTheme.textTheme.body2,
          topicTextStyle: androidTheme.textTheme.body1,
          networksListActiveChannelTextStyle: androidTheme.textTheme.title,
          networksListActiveNetworkTextStyle: androidTextTheme.title);
    } else {
      Future.error("UISkin Platform ${Platform.operatingSystem} not supported");
    }
  }

  static UISkin of(BuildContext context) => Provider.of<UISkin>(context);

  @override
  void dispose() {}
}
