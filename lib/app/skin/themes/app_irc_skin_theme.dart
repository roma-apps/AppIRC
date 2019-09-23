
import 'package:flutter/painting.dart';
import 'package:flutter_appirc/app/message/messages_colored_nicknames_model.dart';
import 'package:flutter_appirc/app/message/messages_regular_model.dart';
import 'package:flutter_appirc/skin/skin_model.dart';

abstract class AppIRCSkinTheme extends AppSkinTheme {
  MessagesColoredNicknamesData coloredNicknamesData;

  Color get linkColor;



  Color findMessageColorByType(RegularMessageType regularMessageType);

  AppIRCSkinTheme(String id, this.coloredNicknamesData, androidThemeDataCreator,
      iosThemeDataCreator)
      : super(id, androidThemeDataCreator, iosThemeDataCreator);
}
