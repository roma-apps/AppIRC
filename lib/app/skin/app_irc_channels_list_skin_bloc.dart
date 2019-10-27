import 'package:flutter/painting.dart';
import 'package:flutter_appirc/app/channel/list/channels_list_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/themes/app_irc_skin_theme.dart';

class AppIRCChannelsListSkinBloc extends ChannelsListSkinBloc {
  final AppIRCSkinTheme theme;

  TextStyle _activeChannelItemTextStyle;
  TextStyle _nonActiveChannelItemTextStyle;

  TextStyle _activeChannelUnreadTextStyle;
  TextStyle _nonActiveChannelUnreadTextStyle;

  AppIRCChannelsListSkinBloc(this.theme) {
    _activeChannelItemTextStyle = theme.platformSkinTheme.textRegularMediumStyle
        .copyWith(color: theme.onActiveListItemColor);

    _nonActiveChannelItemTextStyle = theme.platformSkinTheme.textRegularMediumStyle
        .copyWith(color: theme.onNotActiveListItemColor);

    _activeChannelUnreadTextStyle = theme.platformSkinTheme
        .textRegularMediumStyle.copyWith(
          color: theme.platformSkinTheme.onPrimaryColor);
    _nonActiveChannelUnreadTextStyle = theme.platformSkinTheme
        .textRegularMediumStyle
          .copyWith(color: theme.platformSkinTheme.onPrimaryColor);

  }


  TextStyle getChannelItemTextStyle(bool isChannelActive) {
    if (isChannelActive) {
      return _activeChannelItemTextStyle;
    } else {
      return _nonActiveChannelItemTextStyle;
    }
  }

  Color getChannelItemBackgroundColor(bool isChannelActive) {
    if (isChannelActive) {
      return theme.activeListItemColor;
    } else {
      return theme.notActiveListItemColor;
    }
  }

  Color getChannelItemIconColor(bool isChannelActive) {
    if (isChannelActive) {
      return theme.onActiveListItemColor;
    } else {
      return theme.onNotActiveListItemColor;
    }
  }

  TextStyle getChannelUnreadTextStyle(bool isChannelActive) {
    if (!isChannelActive) {
      return _activeChannelUnreadTextStyle;
    } else {
      return _nonActiveChannelUnreadTextStyle;
    }
  }

  Color getChannelUnreadItemBackgroundColor(bool isChannelActive) {
    if (isChannelActive) {
      return theme.platformSkinTheme.primaryVariantColor;
    } else {
      return theme.platformSkinTheme.primaryVariantColor;
    }
  }
}
