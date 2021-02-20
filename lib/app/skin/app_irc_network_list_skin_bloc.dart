import 'package:flutter/painting.dart';
import 'package:flutter_appirc/app/network/list/network_list_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/themes/app_irc_skin_theme.dart';

import 'app_irc_channel_list_skin_bloc.dart';

class AppIRCNetworkListSkinBloc extends AppIRCChannelListSkinBloc
    implements NetworkListSkinBloc {
  TextStyle _activeChannelItemTextStyle;
  TextStyle _nonActiveChannelItemTextStyle;

  AppIRCNetworkListSkinBloc(AppIRCSkinTheme theme) : super(theme) {
    _activeChannelItemTextStyle = theme.platformSkinTheme.textBoldMediumStyle
        .copyWith(color: theme.onActiveListItemColor);

    _nonActiveChannelItemTextStyle = theme.platformSkinTheme.textBoldMediumStyle
        .copyWith(color: theme.onNotActiveListItemColor);
  }

  @override
  Color get separatorColor => theme.platformSkinTheme.secondaryColor;

  @override
  TextStyle getNetworkItemTextStyle(bool isChannelActive) {
    if (isChannelActive) {
      return _activeChannelItemTextStyle;
    } else {
      return _nonActiveChannelItemTextStyle;
    }
  }

  @override
  Color getNetworkItemIconColor(bool isChannelActive) =>
      getChannelItemIconColor(isChannelActive);

  @override
  Color getNetworkItemBackgroundColor(bool isChannelActive) =>
      getChannelItemBackgroundColor(isChannelActive);
}
