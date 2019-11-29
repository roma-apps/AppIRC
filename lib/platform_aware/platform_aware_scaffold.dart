import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/skin/app_skin_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'platform_aware.dart' as platform_aware;

Widget buildPlatformScaffold(BuildContext context,
    {Key key,
    Key widgetKey,
    Widget body,
    Color backgroundColor,
    PlatformAppBar appBar,
    PlatformNavBar bottomNavBar,
    PlatformBuilder<MaterialScaffoldData> android,
    PlatformBuilder<CupertinoPageScaffoldData> ios,
    bool iosContentPadding = false,
    bool iosContentBottomPadding = false}) {
  if (platform_aware.isMaterial) {
    return PlatformScaffold(
        key: key,
        widgetKey: widgetKey,
        body: body,
        backgroundColor: backgroundColor,
        appBar: appBar,
        bottomNavBar: bottomNavBar,
        android: android,
        ios: ios,
        iosContentPadding: iosContentPadding,
        iosContentBottomPadding: iosContentBottomPadding);
  } else {
    AppSkinBloc appSkinBloc = Provider.of(context);
    return PlatformScaffold(
        key: key,
        widgetKey: widgetKey,
        body: Theme(
          child: body,
          data: appSkinBloc.appSkinTheme.androidThemeDataCreator(),
        ),
        backgroundColor: backgroundColor,
        appBar: appBar,
        bottomNavBar: bottomNavBar,
        android: android,
        ios: ios,
        iosContentPadding: iosContentPadding,
        iosContentBottomPadding: iosContentBottomPadding);
  }
}

PlatformIconButton buildPlatformScaffoldAppBarBackButton(BuildContext context) {
  return PlatformIconButton(
    androidIcon: Icon(Icons.arrow_back),
    iosIcon: Icon(Icons.arrow_back_ios),
    onPressed: () {
      Navigator.pop(context);
    },
  );
}
