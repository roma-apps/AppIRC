import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_model.dart';
import 'package:flutter_appirc/app/user/colored_nicknames_bloc.dart';
import 'package:flutter_appirc/app/user/user_widget.dart';
import 'package:flutter_appirc/provider/provider.dart';

class ChannelUsersInfoWidget extends StatefulWidget {
  ChannelUsersInfoWidget();

  @override
  State<StatefulWidget> createState() => ChannelUsersInfoState();
}

class ChannelUsersInfoState extends State<ChannelUsersInfoWidget> {

  NetworkChannelBloc channelBloc;


  @override
  void dispose() {
    super.dispose();
    channelBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appLocalizations = AppLocalizations.of(context);

    ColoredNicknamesBloc coloredNicknamesBloc = Provider.of(context);
    channelBloc = NetworkChannelBloc.of(context);


    return StreamBuilder<List<ChannelUserInfo>>(
        stream: channelBloc.usersStream,
        initialData: channelBloc.currentNotUpdateUsers,
        builder: (BuildContext context,
            AsyncSnapshot<List<ChannelUserInfo>> snapshot) {
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
                child: Text(appLocalizations.tr("chat.users.loading")));
          }
        });
  }
}

Widget _buildUserListItem(BuildContext context, ChannelUserInfo user,
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
