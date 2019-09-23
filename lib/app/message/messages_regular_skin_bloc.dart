
import 'package:flutter/painting.dart';
import 'package:flutter_appirc/app/message/messages_regular_model.dart';
import 'package:flutter_appirc/skin/skin_bloc.dart';

abstract class MessagesRegularSkinBloc extends SkinBloc {
  TextStyle get regularMessageBodyTextStyle;

  TextStyle modifyToLinkTextStyle(TextStyle textStyle);

  TextStyle createNickTextStyle(Color color);
  TextStyle createDateTextStyle(Color color);
  TextStyle createMessageSubTitleTextStyle(Color color);

  Color findTitleColorDataForMessage(RegularMessageType messageType);

}