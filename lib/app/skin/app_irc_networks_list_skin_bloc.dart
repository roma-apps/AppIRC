

import 'package:flutter/painting.dart';
import 'package:flutter_appirc/app/network/networks_list_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/themes/app_irc_skin_theme.dart';
import 'package:flutter_appirc/skin/skin_bloc.dart';

import 'app_irc_channels_list_skin_bloc.dart';

class AppIRCNetworkListSkinBloc extends AppIRCChannelsListSkinBloc implements NetworkListSkinBloc {
  AppIRCNetworkListSkinBloc(AppIRCSkinTheme theme) : super(theme);



  Color get separatorColor => theme.platformSkinTheme.separatorColor;

  TextStyle getNetworkItemTextStyle(bool isChannelActive) {
    if(isChannelActive) {
      return theme.platformSkinTheme.textBoldMediumStyle.copyWith(color: theme.platformSkinTheme.foregroundColor);
    } else {
      return theme.platformSkinTheme.textBoldMediumStyle.copyWith(color: theme.platformSkinTheme.backgroundColor);
    }
  }

  Color getNetworkItemIconColor(bool isChannelActive) => getChannelItemIconColor(isChannelActive);

  Color getNetworkItemBackgroundColor(bool isChannelActive)  => getChannelItemBackgroundColor(isChannelActive);
}
