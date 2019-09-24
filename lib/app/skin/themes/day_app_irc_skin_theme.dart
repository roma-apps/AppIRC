import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appirc/app/message/messages_colored_nicknames_model.dart';
import 'package:flutter_appirc/app/message/messages_regular_model.dart';
import 'package:flutter_appirc/app/skin/themes/app_irc_skin_theme.dart';



class DayAppSkinTheme extends AppIRCSkinTheme {
  static const String ID = "DayAppSkin";

  DayAppSkinTheme()
      : super(
            ID,
            MessagesColoredNicknamesData(Colors.primaries),
            () =>_androidDayThemeData,
            () => MaterialBasedCupertinoThemeData(
                materialTheme: _androidDayThemeData));

  Color findMessageColorByType(RegularMessageType regularMessageType) {
    Color color;
    switch (regularMessageType) {
      case RegularMessageType.TOPIC_SET_BY:
        color = Colors.lightBlue;
        break;
      case RegularMessageType.TOPIC:
        color = Colors.lightBlue;
        break;
      case RegularMessageType.WHO_IS:
        color = Colors.lightBlue;
        break;
      case RegularMessageType.UNHANDLED:
        color = Colors.grey;
        break;
      case RegularMessageType.UNKNOWN:
        color = Colors.redAccent;
        break;
      case RegularMessageType.MESSAGE:
        color = Colors.grey;
        break;
      case RegularMessageType.JOIN:
        color = Colors.lightGreen;
        break;

      case RegularMessageType.AWAY:
        color = Colors.lightBlue;
        break;
      case RegularMessageType.MODE:
        color = Colors.grey;
        break;
      case RegularMessageType.MOTD:
        color = Colors.grey;
        break;
      case RegularMessageType.NOTICE:
        color = Colors.grey;
        break;
      case RegularMessageType.ERROR:
        color = Colors.redAccent;
        break;
      case RegularMessageType.BACK:
        color = Colors.lightGreen;
        break;
      case RegularMessageType.MODE_CHANNEL:
        color = Colors.grey;
        break;
      case RegularMessageType.QUIT:
        color = Colors.redAccent;
        break;
      case RegularMessageType.RAW:
        color = Colors.grey;
        break;
      case RegularMessageType.PART:
        color = Colors.redAccent;
        break;
      case RegularMessageType.NICK:
        color = Colors.lightBlue;
        break;
    }
    return color;
  }

  @override
  Color get linkColor => Colors.lightBlue;

  @override
  Color get activeListItemColor => _androidDayThemeData.primaryColor;

  @override
  Color get appBackgroundColor => _androidDayThemeData.scaffoldBackgroundColor;

  @override
  Color get appBarColor => _androidDayThemeData.primaryColor;

  @override
  Color get chatInputColor => _androidDayThemeData.primaryColor;

  @override
  Color get notActiveListItemColor => appBackgroundColor;

  @override
  Color get onActiveListItemColor => onAppBackgroundColor;

  @override
  Color get onAppBackgroundColor => _androidDayThemeData.colorScheme.onBackground;

  @override
  Color get onAppBarColor => Color(0xfff5f5f5);

  @override
  Color get onChatInputColor => onAppBarColor;

  @override
  Color get onChatInputHintColor => _androidDayThemeData.hintColor;

  @override
  Color get onNotActiveListItemColor => onAppBackgroundColor;
}

ThemeData _androidDayThemeData = ThemeData(
      primarySwatch: Colors.orange,
      brightness: Brightness.light,
      primaryColor: Color(0xffff9800),
      primaryColorBrightness: Brightness.light,
      primaryColorLight: Color(0xffffe0b2),
      primaryColorDark: Color(0xfff57c00),
      accentColor: Color(0xffff9800),
      accentColorBrightness: Brightness.light,
      canvasColor: Color(0xfffafafa),
      scaffoldBackgroundColor: Color(0xfffafafa),
      bottomAppBarColor: Color(0xffffffff),
      cardColor: Color(0xffffffff),
      dividerColor: Color(0x1f000000),
      highlightColor: Color(0x66bcbcbc),
      splashColor: Color(0x66c8c8c8),
      selectedRowColor: Color(0xfff5f5f5),
      unselectedWidgetColor: Color(0x8a000000),
      disabledColor: Color(0x61000000),
      buttonColor: Colors.orange,
      toggleableActiveColor: Color(0xfffb8c00),
      secondaryHeaderColor: Color(0xfffff3e0),
      textSelectionColor: Color(0xffffcc80),
      cursorColor: Color(0xff4285f4),
      textSelectionHandleColor: Color(0xffffb74d),
      backgroundColor: Color(0xffffcc80),
      dialogBackgroundColor: Color(0xffffffff),
      indicatorColor: Color(0xffff9800),
      hintColor: Color(0x8a000000),
      errorColor: Color(0xffd32f2f),
      buttonTheme: ButtonThemeData(
        textTheme: ButtonTextTheme.normal,
        minWidth: 88,
        height: 36,
        padding: EdgeInsets.only(top: 0, bottom: 0, left: 16, right: 16),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Color(0xff000000),
            width: 0,
            style: BorderStyle.none,
          ),
          borderRadius: BorderRadius.all(Radius.circular(2.0)),
        ),
        alignedDropdown: false,
        buttonColor: Color(0xffe0e0e0),
        disabledColor: Color(0x61000000),
        highlightColor: Color(0x29000000),
        splashColor: Color(0x1f000000),
        focusColor: Color(0x1f000000),
        hoverColor: Color(0x0a000000),
        colorScheme: ColorScheme(
          primary: Color(0xffff9800),
          primaryVariant: Color(0xfff57c00),
          secondary: Color(0xffff9800),
          secondaryVariant: Color(0xfff57c00),
          surface: Color(0xffffffff),
          background: Color(0xffffcc80),
          error: Color(0xffd32f2f),
          onPrimary: Color(0xff000000),
          onSecondary: Color(0xff000000),
          onSurface: Color(0xff000000),
          onBackground: Color(0xff000000),
          onError: Color(0xffffffff),
          brightness: Brightness.light,
        ),
      ),
      textTheme: TextTheme(
        display4: TextStyle(
          color: Color(0x8a000000),
          fontSize: null,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
        display3: TextStyle(
          color: Color(0x8a000000),
          fontSize: null,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
        display2: TextStyle(
          color: Color(0x8a000000),
          fontSize: null,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
        display1: TextStyle(
          color: Color(0xdd000000),
          fontSize: null,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
        headline: TextStyle(
          color: Color(0xddffffff),
          fontSize: null,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
        title: TextStyle(
          color: Color(0xddffffff),
          fontSize: null,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
        subhead: TextStyle(
          color: Color(0xdd000000),
          fontSize: null,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
        body2: TextStyle(
          color: Color(0xdd000000),
          fontSize: null,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
        body1: TextStyle(
          color: Color(0xdd000000),
          fontSize: null,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
        caption: TextStyle(
          color: Color(0x8a000000),
          fontSize: null,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
        button: TextStyle(
          color: Color(0xdd000000),
          fontSize: null,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
        subtitle: TextStyle(
          color: Color(0xff000000),
          fontSize: null,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
        overline: TextStyle(
          color: Color(0xff000000),
          fontSize: null,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
      ),
      primaryTextTheme: TextTheme(
        display4: TextStyle(
          color: Color(0x8a000000),
          fontSize: null,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
        display3: TextStyle(
          color: Color(0x8a000000),
          fontSize: null,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
        display2: TextStyle(
          color: Color(0x8a000000),
          fontSize: null,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
        display1: TextStyle(
          color: Color(0x8a000000),
          fontSize: null,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
        headline: TextStyle(
          color: Color(0xdd000000),
          fontSize: null,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
        title: TextStyle(
          color: Color(0xddffffff),
          fontSize: null,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
        subhead: TextStyle(
          color: Color(0xdd000000),
          fontSize: null,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
        body2: TextStyle(
          color: Color(0xdd000000),
          fontSize: null,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
        body1: TextStyle(
          color: Color(0xdd000000),
          fontSize: null,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
        caption: TextStyle(
          color: Color(0x8a000000),
          fontSize: null,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
        button: TextStyle(
          color: Color(0xdd000000),
          fontSize: null,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
        subtitle: TextStyle(
          color: Color(0xff000000),
          fontSize: null,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
        overline: TextStyle(
          color: Color(0xff000000),
          fontSize: null,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
      ),
      accentTextTheme: TextTheme(
        display4: TextStyle(
          color: Color(0x8a000000),
          fontSize: null,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
        display3: TextStyle(
          color: Color(0x8a000000),
          fontSize: null,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
        display2: TextStyle(
          color: Color(0x8a000000),
          fontSize: null,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
        display1: TextStyle(
          color: Color(0x8a000000),
          fontSize: null,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
        headline: TextStyle(
          color: Color(0xdd000000),
          fontSize: null,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
        title: TextStyle(
          color: Color(0xdd000000),
          fontSize: null,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
        subhead: TextStyle(
          color: Color(0xdd000000),
          fontSize: null,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
        body2: TextStyle(
          color: Color(0xdd000000),
          fontSize: null,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
        body1: TextStyle(
          color: Color(0xdd000000),
          fontSize: null,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
        caption: TextStyle(
          color: Color(0x8a000000),
          fontSize: null,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
        button: TextStyle(
          color: Color(0xdd000000),
          fontSize: null,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
        subtitle: TextStyle(
          color: Color(0xff000000),
          fontSize: null,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
        overline: TextStyle(
          color: Color(0xff000000),
          fontSize: null,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(
          color: Color(0xdd000000),
          fontSize: null,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
        helperStyle: TextStyle(
          color: Color(0xdd000000),
          fontSize: null,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
        hintStyle: TextStyle(
          color: Color(0xdd000000),
          fontSize: null,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
        errorStyle: TextStyle(
          color: Color(0xdd000000),
          fontSize: null,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
        errorMaxLines: null,
        hasFloatingPlaceholder: true,
        isDense: false,
        contentPadding: EdgeInsets.only(top: 12, bottom: 12, left: 0, right: 0),
        isCollapsed: false,
        prefixStyle: TextStyle(
          color: Color(0xdd000000),
          fontSize: null,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
        suffixStyle: TextStyle(
          color: Color(0xdd000000),
          fontSize: null,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
        counterStyle: TextStyle(
          color: Color(0xdd000000),
          fontSize: null,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
        filled: false,
        fillColor: Color(0x00000000),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xff000000),
            width: 1,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xff000000),
            width: 1,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xff000000),
            width: 1,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
        ),
        disabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xff000000),
            width: 1,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xff000000),
            width: 1,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xff000000),
            width: 1,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
        ),
      ),
      iconTheme: IconThemeData(
        color: Color(0xdd000000),
        opacity: 1,
        size: 24,
      ),
      primaryIconTheme: IconThemeData(
        color: Color(0xffffffff),
        opacity: 1,
        size: 24,
      ),
      accentIconTheme: IconThemeData(
        color: Color(0xff000000),
        opacity: 1,
        size: 24,
      ),
      sliderTheme: SliderThemeData(
        valueIndicatorTextStyle: TextStyle(
          color: Color(0xdd000000),
          fontSize: null,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
      ),
      tabBarTheme: TabBarTheme(
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Color(0xdd000000),
        unselectedLabelColor: Color(0xb2000000),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Color(0x1f000000),
        brightness: Brightness.light,
        deleteIconColor: Color(0xde000000),
        disabledColor: Color(0x0c000000),
        labelPadding: EdgeInsets.only(top: 0, bottom: 0, left: 8, right: 8),
        labelStyle: TextStyle(
          color: Color(0xde000000),
          fontSize: null,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
        padding: EdgeInsets.only(top: 4, bottom: 4, left: 4, right: 4),
        secondaryLabelStyle: TextStyle(
          color: Color(0x3d000000),
          fontSize: null,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
        secondarySelectedColor: Color(0x3dff9800),
        selectedColor: Color(0x3d000000),
        shape: StadiumBorder(
            side: BorderSide(
          color: Color(0xff000000),
          width: 0,
          style: BorderStyle.none,
        )),
      ),
      dialogTheme: DialogTheme(
          shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Color(0xff000000),
          width: 0,
          style: BorderStyle.none,
        ),
        borderRadius: BorderRadius.all(Radius.circular(0.0)),
      )),
    );
