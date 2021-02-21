import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/ui/theme/appirc_ui_theme_model.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';


Widget buildPlatformScaffold(
  BuildContext context, {
  Key key,
  Key widgetKey,
  Widget body,
  Color backgroundColor,
  PlatformAppBar appBar,
  PlatformNavBar bottomNavBar,
  PlatformBuilder<MaterialScaffoldData> material,
  PlatformBuilder<CupertinoPageScaffoldData> cupertino,
  bool iosContentPadding = false,
  bool iosContentBottomPadding = false,
}) {
  var platformProviderState = PlatformProvider.of(context);

  if (platformProviderState.platform == TargetPlatform.android) {
    return PlatformScaffold(
      key: key,
      widgetKey: widgetKey,
      body: body,
      backgroundColor: backgroundColor,
      appBar: appBar,
      bottomNavBar: bottomNavBar,
      material: material,
      cupertino: cupertino,
      iosContentPadding: iosContentPadding,
      iosContentBottomPadding: iosContentBottomPadding,
    );
  } else {
    var currentThee = Provider.of<IAppIrcUiTheme>(context);
    return PlatformScaffold(
      key: key,
      widgetKey: widgetKey,
      body: Theme(
        child: body,
        data: currentThee.themeData,
      ),
      backgroundColor: backgroundColor,
      appBar: appBar,
      bottomNavBar: bottomNavBar,
      material: material,
      cupertino: cupertino,
      iosContentPadding: iosContentPadding,
      iosContentBottomPadding: iosContentBottomPadding,
    );
  }
}

PlatformIconButton buildPlatformScaffoldAppBarBackButton(BuildContext context) {
  return PlatformIconButton(
    material: (context, platform) => MaterialIconButtonData(
      icon: Icon(Icons.arrow_back),
    ),
    cupertino: (context, platform) => CupertinoIconButtonData(
      icon: Icon(Icons.arrow_back_ios),
    ),
    onPressed: () {
      Navigator.pop(context);
    },
  );
}
