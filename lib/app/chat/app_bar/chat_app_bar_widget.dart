import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appirc/app/chat/app_bar/chat_app_bar_skin_bloc.dart';
import 'package:flutter_appirc/platform_aware/platform_aware.dart';
import 'package:flutter_appirc/provider/provider.dart';

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

Widget _buildSubTitle(BuildContext context, String subTitle) => Text(subTitle,
    overflow: TextOverflow.fade,
    softWrap: false,
    style: Provider.of<ChatAppBarSkinBloc>(context).subTitleTextStyle
    );

Widget _buildTitle(BuildContext context, String title) => Text(title,
    style: Provider.of<ChatAppBarSkinBloc>(context).titleTextStyle);
