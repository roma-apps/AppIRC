import 'package:flutter/painting.dart';
import 'package:flutter_appirc/app/network/list/networks_list_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/themes/app_irc_skin_theme.dart';

import 'app_irc_channels_list_skin_bloc.dart';

class AppIRCNetworkListSkinBloc extends AppIRCChannelsListSkinBloc implements NetworkListSkinBloc {
  AppIRCNetworkListSkinBloc(AppIRCSkinTheme theme) : super(theme);



  Color get separatorColor => theme.platformSkinTheme.secondaryColor;

  TextStyle getNetworkItemTextStyle(bool isChannelActive) {
    if(isChannelActive) {
      return theme.platformSkinTheme.textBoldMediumStyle.copyWith(color: theme.onActiveListItemColor);
    } else {
      return theme.platformSkinTheme.textBoldMediumStyle.copyWith(color: theme.onNotActiveListItemColor);
    }
  }

  Color getNetworkItemIconColor(bool isChannelActive) => getChannelItemIconColor(isChannelActive);

  Color getNetworkItemBackgroundColor(bool isChannelActive)  => getChannelItemBackgroundColor(isChannelActive);
}
