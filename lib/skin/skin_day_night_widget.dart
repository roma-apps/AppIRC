import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appirc/app/skin/themes/day_app_irc_skin_theme.dart';
import 'package:flutter_appirc/app/skin/themes/night_app_irc_skin_theme.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/skin/app_skin_day_night_bloc.dart';
import 'package:flutter_appirc/skin/skin_preference_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class AppSkinDayNightIconButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var preferenceBloc = Provider.of<AppSkinPreferenceBloc>(context);
    var dayNightBloc = AppSkinDayNightBloc(
        preferenceBloc, DayAppSkinTheme(), NightAppSkinTheme());

    IconData iconData;

    return StreamBuilder<bool>(
        stream: preferenceBloc.appSkinStream.map((_) => dayNightBloc.isDay),
        builder: (context, snapshot) {
          var isDay = snapshot.data;
          if (isDay == true) {
            iconData = Icons.brightness_5;
          } else {
            iconData = Icons.brightness_3;
          }
          return PlatformIconButton(
              icon: Icon(iconData),
              onPressed: () => dayNightBloc.toggleTheme());
        });
  }
}
