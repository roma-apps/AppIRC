import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef AndroidThemeDataCreator = ThemeData Function();
typedef IOSThemeDataCreator = CupertinoThemeData Function();

class AppSkinTheme {
  final String id;


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AppSkinTheme &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
  PlatformSkinTheme platformSkinTheme;
  AndroidThemeDataCreator androidThemeDataCreator;
  IOSThemeDataCreator iosThemeDataCreator;

  AppSkinTheme(this.id, this.androidThemeDataCreator,
      this.iosThemeDataCreator) {
    if (Platform.isAndroid) {
      platformSkinTheme = AndroidAppSkinTheme(androidThemeDataCreator());
    } else if (Platform.isAndroid) {
      platformSkinTheme = IOSAppSkinTheme(iosThemeDataCreator());
    } else {
      throw Exception("Not supported platform ${Platform.operatingSystem}");
    }
  }

}

abstract class PlatformSkinTheme {
  Color get primaryColor;

  Color get accentColor;
  Color get disabledColor;


  TextStyle get textRegularMediumStyle;
  TextStyle get textBoldMediumStyle;
  TextStyle get textRegularSmallStyle;
  TextStyle get textBoldSmallStyle;

  TextStyle get textInputDecorationLabelStyle;

  TextStyle get textInputDecorationHintStyle;

  TextStyle get textTitleStyle;

  Color get separatorColor;

  Color get foregroundColor;

  Color get backgroundColor;

  TextStyle get textEditTextStyle;
}

class AndroidAppSkinTheme extends PlatformSkinTheme {
  final ThemeData theme;
  TextTheme get  textTheme => theme.textTheme;

  AndroidAppSkinTheme(this.theme);

  @override
  Color get primaryColor => theme.primaryColor;

  @override
  Color get accentColor => theme.accentColor;

  @override
  Color get backgroundColor => theme.backgroundColor;

  @override
  Color get foregroundColor => theme.accentColor;

  @override
  Color get separatorColor => theme.accentColor;

  @override
  TextStyle get textBoldMediumStyle => textTheme.caption;

  @override
  TextStyle get textBoldSmallStyle => textTheme.body2;

  @override
  TextStyle get textEditTextStyle => textTheme.body1;

  @override
  TextStyle get textInputDecorationHintStyle => textEditTextStyle.copyWith(color: theme.hintColor);

  @override
  TextStyle get textInputDecorationLabelStyle => textTheme.body1;


  @override
  TextStyle get textRegularMediumStyle => textTheme.body1;

  @override
  TextStyle get textRegularSmallStyle => textTheme.body2;

  @override
  TextStyle get textTitleStyle => textTheme.headline;

  @override
  Color get disabledColor => theme.disabledColor;
}

class IOSAppSkinTheme extends PlatformSkinTheme {
  final CupertinoThemeData theme;
  CupertinoTextThemeData get  textTheme => theme.textTheme;

  IOSAppSkinTheme(this.theme);

  @override
  Color get primaryColor => theme.primaryColor;

  @override
  Color get accentColor => theme.barBackgroundColor;


  @override
  Color get backgroundColor => theme.barBackgroundColor;

  @override
  Color get foregroundColor => theme.primaryColor;

  @override
  Color get separatorColor => theme.primaryColor;

  @override
  TextStyle get textBoldMediumStyle => textTheme.textStyle;

  @override
  TextStyle get textBoldSmallStyle => textTheme.textStyle;

  @override
  TextStyle get textEditTextStyle => textTheme.textStyle;

  @override
  TextStyle get textInputDecorationHintStyle => textTheme.textStyle;

  @override
  TextStyle get textInputDecorationLabelStyle => textTheme.textStyle;


  @override
  TextStyle get textRegularMediumStyle => textTheme.textStyle;

  @override
  TextStyle get textRegularSmallStyle => textTheme.textStyle;

  @override
  TextStyle get textTitleStyle => textTheme.navLargeTitleTextStyle;


  @override
  Color get disabledColor => theme.primaryContrastingColor;
}
