import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appirc/app/ui/theme/appirc_ui_theme_model.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class ChatAppBarWidget extends StatelessWidget {
  final String title;
  final String subTitle;

  ChatAppBarWidget(
    this.title,
    this.subTitle,
  );

  @override
  Widget build(BuildContext context) {
    assert(title != null && title.isNotEmpty);
    var platformProvider = PlatformProvider.of(context);
    var isMaterial = platformProvider.platform == TargetPlatform.android;
    if (subTitle != null && subTitle.isNotEmpty) {
      return Column(
        //        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisAlignment:
            isMaterial ? MainAxisAlignment.center : MainAxisAlignment.start,
        crossAxisAlignment:
            isMaterial ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: <Widget>[
          _buildTitle(context, title),
          _buildSubTitle(context, subTitle)
        ],
      );
    } else {
      return Align(
        alignment: isMaterial ? Alignment.centerLeft : Alignment.center,
        child: _buildTitle(
          context,
          title,
        ),
      );
    }
  }
}

Widget _buildSubTitle(BuildContext context, String subTitle) {
  var platformProviderState = PlatformProvider.of(context);
  return Text(
    subTitle,
    overflow: TextOverflow.fade,
    softWrap: false,
    style: IAppIrcUiTextTheme.of(context).bigBoldPrimary.copyWith(
          color: platformProviderState.platform == TargetPlatform.android
              ? Colors.white
              : IAppIrcUiColorTheme.of(context).primary,
        ),
  );
}

Widget _buildTitle(BuildContext context, String title) {
  var platformProviderState = PlatformProvider.of(context);
  return Text(
    title,
    style: IAppIrcUiTextTheme.of(context).bigPrimary.copyWith(
          color: platformProviderState.platform == TargetPlatform.android
              ? Colors.white
              : IAppIrcUiColorTheme.of(context).primary,
        ),
  );
}
