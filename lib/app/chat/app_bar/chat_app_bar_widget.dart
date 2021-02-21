import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appirc/app/ui/theme/appirc_ui_theme_model.dart';
import 'package:flutter_appirc/platform_aware/platform_aware.dart';

class ChatAppBarWidget extends StatelessWidget {
  final String title;
  final String subTitle;

  ChatAppBarWidget(this.title, this.subTitle);

  @override
  Widget build(BuildContext context) {
    assert(title != null && title.isNotEmpty);

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
          child: _buildTitle(context, title));
    }
  }
}

Widget _buildSubTitle(BuildContext context, String subTitle) => Text(
      subTitle,
      overflow: TextOverflow.fade,
      softWrap: false,
      style: IAppIrcUiTextTheme.of(context).subHeaderDarkGrey,
    );

Widget _buildTitle(BuildContext context, String title) => Text(
      title,
  style: IAppIrcUiTextTheme.of(context).dialogTitleBoldDarkGrey,
    );
