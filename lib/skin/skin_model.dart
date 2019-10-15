import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appirc/platform_widgets/platform_aware.dart';

typedef AndroidThemeDataCreator = ThemeData Function();
typedef IOSThemeDataCreator = CupertinoThemeData Function();

class AppSkinTheme {
  final String id;

  get textColor => platformSkinTheme.onBackgroundColor;

  get backgroundColor => platformSkinTheme.backgroundColor;

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

  AppSkinTheme(
      this.id, this.androidThemeDataCreator, this.iosThemeDataCreator) {
    if (isMaterial) {
      platformSkinTheme = AndroidAppSkinTheme(androidThemeDataCreator());
    } else if (isCupertino) {
      platformSkinTheme = MaterialBasedIOSAppSkinTheme(
          AndroidAppSkinTheme(androidThemeDataCreator()));
    } else {
      throw Exception("Not supported platform ${Platform.operatingSystem}");
    }
  }
}

abstract class PlatformSkinTheme {
  Color get disabledColor;

  Color get primaryColor;

  Color get primaryVariantColor;

  Color get secondaryColor;

  Color get secondaryVariantColor;

  Color get onPrimaryColor;

  Color get onSecondaryColor;

  TextStyle get textRegularMediumStyle;

  TextStyle get textBoldMediumStyle;

  TextStyle get textRegularSmallStyle;

  TextStyle get textBoldSmallStyle;

  TextStyle get textInputDecorationLabelStyle;

  TextStyle get textInputDecorationHintStyle;

  TextStyle get textTitleStyle;

  TextStyle get textEditTextStyle;

  Color get buttonColor;

  Color get onBackgroundColor;

  Color get backgroundColor;

}

class AndroidAppSkinTheme extends PlatformSkinTheme {
  final ThemeData theme;

  TextTheme get textTheme => theme.textTheme;

  AndroidAppSkinTheme(this.theme);

  Color get buttonColor => theme.buttonColor;

  @override
  TextStyle get textBoldMediumStyle => textTheme.caption;

  @override
  TextStyle get textBoldSmallStyle => textTheme.body2;

  @override
  TextStyle get textEditTextStyle => textTheme.body1;

  @override
  TextStyle get textInputDecorationHintStyle =>
      textEditTextStyle.copyWith(color: theme.hintColor);

  @override
  TextStyle get textInputDecorationLabelStyle => textTheme.body1;

  @override
  TextStyle get textRegularMediumStyle => textTheme.body1;

  @override
  TextStyle get textRegularSmallStyle => textTheme.body2.copyWith(fontSize: 14);

  @override
  TextStyle get textTitleStyle =>
      textTheme.headline.copyWith(color: onPrimaryColor);

  @override
  Color get primaryColor => theme.colorScheme.primary;

  @override
  Color get primaryVariantColor => theme.colorScheme.primaryVariant;

  @override
  Color get secondaryColor => theme.colorScheme.secondary;

  @override
  Color get secondaryVariantColor => theme.colorScheme.secondaryVariant;

  @override
  Color get onPrimaryColor => theme.colorScheme.onPrimary;

  @override
  Color get onSecondaryColor => theme.colorScheme.onSecondary;

  @override
  Color get disabledColor => theme.disabledColor;

  @override
  Color get onBackgroundColor => theme.colorScheme.onBackground;

  @override
  Color get backgroundColor => theme.backgroundColor;

}

class MaterialBasedIOSAppSkinTheme extends PlatformSkinTheme {
  AndroidAppSkinTheme androidAppSkinTheme;
  CupertinoThemeData theme;

  CupertinoTextThemeData get textTheme => theme.textTheme;

  Color get buttonColor => androidAppSkinTheme.theme.buttonColor;

  @override
  Color get disabledColor => androidAppSkinTheme.theme.disabledColor;

  @override
  Color get primaryColor => androidAppSkinTheme.theme.colorScheme.primary;

  @override
  Color get primaryVariantColor =>
      androidAppSkinTheme.theme.colorScheme.primaryVariant;

  @override
  Color get secondaryColor => androidAppSkinTheme.theme.colorScheme.secondary;

  @override
  Color get secondaryVariantColor =>
      androidAppSkinTheme.theme.colorScheme.secondaryVariant;

  @override
  Color get onPrimaryColor => androidAppSkinTheme.theme.colorScheme.onPrimary;

  @override
  Color get onSecondaryColor =>
      androidAppSkinTheme.theme.colorScheme.onSecondary;

  MaterialBasedIOSAppSkinTheme(this.androidAppSkinTheme) {
    theme = MaterialBasedCupertinoThemeData(
        materialTheme: androidAppSkinTheme.theme);
  }

  @override
  TextStyle get textBoldMediumStyle => textTheme.navTitleTextStyle;

  @override
  TextStyle get textBoldSmallStyle =>
      textTheme.navTitleTextStyle.copyWith(fontSize: 12);

  @override
  TextStyle get textEditTextStyle => textTheme.textStyle;

  @override
  TextStyle get textInputDecorationHintStyle => textTheme.textStyle;

  @override
  TextStyle get textInputDecorationLabelStyle => textTheme.textStyle;

  @override
  TextStyle get textRegularMediumStyle => textTheme.textStyle;

  @override
  TextStyle get textRegularSmallStyle =>
      textTheme.textStyle.copyWith(fontSize: 12);

  @override
  TextStyle get textTitleStyle => textTheme.navTitleTextStyle;

  Color get onBackgroundColor =>
      androidAppSkinTheme.theme.colorScheme.onPrimary;

  @override
  Color get backgroundColor => androidAppSkinTheme.theme.backgroundColor;
}
