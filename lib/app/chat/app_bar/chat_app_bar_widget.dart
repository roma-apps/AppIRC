import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

Widget _buildSubTitle(BuildContext context, String subTitle) => Text(
      subTitle,
      overflow: TextOverflow.fade,
      softWrap: false,
      // style: IAppIrcUiTextTheme.of(context).bigTallBoldLightGrey,
    );

Widget _buildTitle(BuildContext context, String title) => Text(
      title,
      // style: IAppIrcUiTextTheme.of(context).bigTallLightGrey,
    );
