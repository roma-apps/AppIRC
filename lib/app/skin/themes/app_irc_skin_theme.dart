import 'package:flutter/painting.dart';
import 'package:flutter_appirc/app/message/regular/messages_regular_model.dart';
import 'package:flutter_appirc/colored_nicknames/colored_nicknames_model.dart';
import 'package:flutter_appirc/skin/skin_model.dart';

abstract class AppIRCSkinTheme extends AppSkinTheme {
  ColoredNicknamesData coloredNicknamesData;

  Color get linkColor;

  Color get appBackgroundColor;

  Color get onAppBackgroundColor;

  Color get appBarColor;

  Color get onAppBarColor;

  Color get chatInputColor;

  Color get onChatInputColor;

  Color get onChatInputHintColor;

  Color get activeListItemColor;

  Color get onActiveListItemColor;

  Color get notActiveListItemColor;

  Color get onNotActiveListItemColor;

  Color get highlightSearchBackgroundColor;
  Color get highlightServerBackgroundColor;

  Color get searchBackgroundColor;

  TextStyle get defaultTextStyle;

  Color get disabledTextColor;

  Color findMessageColorByType(RegularMessageType regularMessageType);

  AppIRCSkinTheme(String id, this.coloredNicknamesData, androidThemeDataCreator,
      iosThemeDataCreator)
      : super(id, androidThemeDataCreator, iosThemeDataCreator);
}
