import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/chat_model.dart';
import 'package:flutter_appirc/app/user/colored_nicknames_bloc.dart';
import 'package:flutter_appirc/app/user/user_widget.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/skin/app_skin_bloc.dart';

class ChannelUsersInfoWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ChannelUsersInfoState();
}

class ChannelUsersInfoState extends State<ChannelUsersInfoWidget> {
  @override
  Widget build(BuildContext context) {
    var appLocalizations = AppLocalizations.of(context);

    ColoredNicknamesBloc coloredNicknamesBloc = Provider.of(context);
    NetworkChannelBloc channelBloc = Provider.of<NetworkChannelBloc>(context);

    return StreamBuilder<List<NetworkChannelUser>>(
        stream: channelBloc.usersStream,
        initialData: channelBloc.currentNotUpdateUsers,
        builder: (BuildContext context,
            AsyncSnapshot<List<NetworkChannelUser>> snapshot) {
          var users = snapshot.data;

          if (users != null && users.isNotEmpty) {
            return ListView.builder(
                itemCount: users.length,
                itemBuilder: (BuildContext context, int index) {
                  return _buildUserListItem(
                      context, users[index], coloredNicknamesBloc);
                });
          } else {
            return Center(
                child: Text(appLocalizations.tr("chat.users.loading"),
                    style: TextStyle(
                        color:
                            AppSkinBloc.of(context).appSkinTheme.textColor)));
          }
        });
  }
}

Widget _buildUserListItem(BuildContext context, NetworkChannelUser user,
    ColoredNicknamesBloc coloredNicknamesBloc) {
  var nick = user.nick;
  var color = coloredNicknamesBloc.getColorForNick(nick);

  var child = Text("${user.mode}$nick", style: TextStyle(color: color));

  NetworkChannelBloc channelBloc = Provider.of(context);
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: buildUserNickWithPopupMenu(context, child, nick, channelBloc,
        actionCallback: (_) {
      Navigator.pop(context);
    }),
  );
}
