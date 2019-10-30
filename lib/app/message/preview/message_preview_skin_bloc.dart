import 'package:flutter/painting.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_model.dart';
import 'package:flutter_appirc/skin/skin_bloc.dart';

abstract class MessagePreviewSkinBloc extends SkinBloc {
  Color get previewBorderColor;
}
