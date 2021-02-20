import 'package:flutter/painting.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_model.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/themes/app_irc_skin_theme.dart';

class AppIRCRegularMessageSkinBloc extends RegularMessageSkinBloc {
  final AppIRCSkinTheme theme;



  TextStyle createDateTextStyle(Color color) =>
      _getSubTitleTextStyleForColor(color);

  TextStyle createMessageSubTitleTextStyle(Color color) =>
      _getSubTitleTextStyleForColor(color);

  TextStyle createNickTextStyle(Color color) =>
      _getNicknameTextStyleForColor(color);

  final Map<Color, TextStyle> _subTitleColorToTextStyle = {};
  final Map<Color, TextStyle> _nicknameColorToTextStyle = {};

  TextStyle _getSubTitleTextStyleForColor(Color color) {
    if (!_subTitleColorToTextStyle.containsKey(color)) {
      _subTitleColorToTextStyle[color] =
          theme.platformSkinTheme.textRegularSmallStyle.copyWith(color: color);
    }
    return _subTitleColorToTextStyle[color];
  }


  @override
  TextStyle getTextStyleDataForMessage(RegularMessageType regularMessageType) {
    return theme.platformSkinTheme.textRegularSmallStyle;
  }

  TextStyle _getNicknameTextStyleForColor(Color color) {
    if (!_nicknameColorToTextStyle.containsKey(color)) {
      _nicknameColorToTextStyle[color] =
          theme.platformSkinTheme.textRegularSmallStyle.copyWith(color: color);
    }
    return _nicknameColorToTextStyle[color];
  }


  AppIRCRegularMessageSkinBloc(this.theme);


  @override
  Color getColorForMessageType(RegularMessageType messageType) =>
      theme.findMessageColorByType(messageType);


}
