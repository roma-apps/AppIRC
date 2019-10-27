
import 'package:flutter/painting.dart';
import 'package:flutter_appirc/app/message/regular/messages_regular_model.dart';
import 'package:flutter_appirc/skin/skin_bloc.dart';

abstract class MessagesRegularSkinBloc extends SkinBloc {
  TextStyle get regularMessageBodyTextStyle;
  Color get highlightSearchBackgroundColor;
  Color get highlightServerBackgroundColor;


  Color get searchBackgroundColor;


  TextStyle createNickTextStyle(Color color);
  TextStyle createDateTextStyle(Color color);
  TextStyle createMessageSubTitleTextStyle(Color color);
  TextStyle linkTextStyle;
  TextStyle messageHighlightTextStyle;

  Color findTitleColorDataForMessage(RegularMessageType messageType);

}
