import 'package:flutter/cupertino.dart';
import 'package:flutter_appirc/app/chat/chat_app_bar_skin_bloc.dart';
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
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildTitle(context, title),
          _buildSubTitle(context, subTitle)
        ],
      );
    } else {
      return Align(
          alignment: Alignment.centerLeft, child: _buildTitle(context, title));
    }
  }
}

Widget _buildSubTitle(BuildContext context, String subTitle) => Text(subTitle,
    style: Provider.of<ChatAppBarSkinBloc>(context).subTitleTextStyle);

Widget _buildTitle(BuildContext context, String title) =>
    Text(title, style: Provider.of<ChatAppBarSkinBloc>(context).titleTextStyle);
