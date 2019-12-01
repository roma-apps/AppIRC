import 'package:flutter/painting.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_model.dart';
import 'package:flutter_appirc/skin/skin_bloc.dart';

abstract class MessageSkinBloc extends SkinBloc {

  TextStyle get messageBodyTextStyle;

  Color get highlightServerBackgroundColor;



  TextStyle createNickTextStyle(Color color);

  TextStyle createDateTextStyle(Color color);

  TextStyle createMessageSubTitleTextStyle(Color color);

  TextStyle linkTextStyle;
  TextStyle messageHighlightTextStyle;

  Color findTitleColorDataForMessage(RegularMessageType messageType);
}
