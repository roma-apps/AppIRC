import 'package:flutter/painting.dart';
import 'package:flutter_appirc/app/message/message_skin_bloc.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_model.dart';
import 'package:flutter_appirc/app/skin/themes/app_irc_skin_theme.dart';

class AppIRCMessageSkinBloc extends MessageSkinBloc {
  final AppIRCSkinTheme theme;

  @override
  TextStyle messageBodyTextStyle;

  @override
  TextStyle messageHighlightTextStyle;

  @override
  TextStyle linkTextStyle;

  TextStyle createDateTextStyle(Color color) =>
      _getSubTitleTextStyleForColor(color);

  TextStyle createMessageSubTitleTextStyle(Color color) =>
      _getSubTitleTextStyleForColor(color);

  TextStyle createNickTextStyle(Color color) =>
      _getNicknameTextStyleForColor(color);

  Map<Color, TextStyle> _subTitleColorToTextStyle = Map();
  Map<Color, TextStyle> _nicknameColorToTextStyle = Map();

  TextStyle _getSubTitleTextStyleForColor(Color color) {
    if (!_subTitleColorToTextStyle.containsKey(color)) {
      _subTitleColorToTextStyle[color] =
          messageBodyTextStyle.copyWith(color: color);
    }
    return _subTitleColorToTextStyle[color];
  }

  TextStyle _getNicknameTextStyleForColor(Color color) {
    if (!_nicknameColorToTextStyle.containsKey(color)) {
      _nicknameColorToTextStyle[color] = messageBodyTextStyle.copyWith(
           color: color, fontWeight: FontWeight.bold);
    }
    return _nicknameColorToTextStyle[color];
  }

  AppIRCMessageSkinBloc(this.theme) {
    messageBodyTextStyle = theme.platformSkinTheme.textRegularSmallStyle
        .copyWith(fontFamily: "CourierNew");

    messageHighlightTextStyle = messageBodyTextStyle.copyWith(
        backgroundColor: textHighlightBackgroundColor);
    linkTextStyle = messageBodyTextStyle.copyWith(color: theme.linkColor);
  }

  Color findTitleColorDataForMessage(RegularMessageType messageType) =>
      theme.findMessageColorByType(messageType);

  Color get textHighlightBackgroundColor => theme.textHighlightBackgroundColor;

  @override
  Color get highlightSearchBackgroundColor =>
      theme.highlightSearchBackgroundColor;

  @override
  Color get highlightServerBackgroundColor =>
      theme.highlightServerBackgroundColor;
}
