import 'package:flutter/painting.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_model.dart';
import 'package:flutter_appirc/skin/skin_bloc.dart';

abstract class MessageRegularSkinBloc extends SkinBloc {

  TextStyle getTextStyleDataForMessage(RegularMessageType regularMessageType);

  Color findTitleColorDataForMessage(RegularMessageType regularMessageType) =>
      getTextStyleDataForMessage(regularMessageType).color;
}
