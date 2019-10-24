import 'package:flutter/painting.dart';
import 'package:flutter_appirc/app/channel/list/channels_list_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/themes/app_irc_skin_theme.dart';

class AppIRCChannelsListSkinBloc extends ChannelsListSkinBloc {
  final AppIRCSkinTheme theme;

  AppIRCChannelsListSkinBloc(this.theme);

  TextStyle getChannelItemTextStyle(bool isChannelActive) {
    if (isChannelActive) {
      return theme.platformSkinTheme.textRegularMediumStyle
          .copyWith(color: theme.onActiveListItemColor);
    } else {
      return theme.platformSkinTheme.textRegularMediumStyle
          .copyWith(color: theme.onNotActiveListItemColor);
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
      return theme.platformSkinTheme.textRegularMediumStyle.copyWith(
          color: theme.platformSkinTheme.onPrimaryColor);
    } else {
      return theme.platformSkinTheme.textRegularMediumStyle
          .copyWith(color: theme.platformSkinTheme.onPrimaryColor);
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
