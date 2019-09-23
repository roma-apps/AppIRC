import 'package:flutter/painting.dart';
import 'package:flutter_appirc/app/channel/channels_list_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/themes/app_irc_skin_theme.dart';

class AppIRCChannelsListSkinBloc extends ChannelsListSkinBloc {
  final AppIRCSkinTheme theme;

  AppIRCChannelsListSkinBloc(this.theme);

  TextStyle getChannelItemTextStyle(bool isChannelActive) {
    if (isChannelActive) {
      return theme.platformSkinTheme.textRegularMediumStyle.copyWith(color: theme.platformSkinTheme.foregroundColor);
    } else {
      return theme.platformSkinTheme.textRegularMediumStyle.copyWith(color: theme.platformSkinTheme.backgroundColor);
    }
  }


  Color getChannelItemBackgroundColor(bool isChannelActive) {
    if (isChannelActive) {
      return theme.platformSkinTheme.backgroundColor;
    } else {
      return theme.platformSkinTheme.foregroundColor;
    }
  }

  Color getChannelItemIconColor(bool isChannelActive) {
    if (isChannelActive) {
      return theme.platformSkinTheme.foregroundColor;
    } else {
      return theme.platformSkinTheme.backgroundColor;
    }
  }


  TextStyle getChannelUnreadTextStyle(bool isChannelActive) {
    if (!isChannelActive) {
      return theme.platformSkinTheme.textRegularMediumStyle.copyWith(color: theme.platformSkinTheme.foregroundColor);
    } else {
      return theme.platformSkinTheme.textRegularMediumStyle.copyWith(color: theme.platformSkinTheme.backgroundColor);
    }
  }


  Color getChannelUnreadItemBackgroundColor(bool isChannelActive) {
    if (!isChannelActive) {
      return theme.platformSkinTheme.backgroundColor;
    } else {
      return theme.platformSkinTheme.foregroundColor;
    }
  }

}
