import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_model.dart';
import 'package:flutter_appirc/app/user/colored_nicknames_bloc.dart';
import 'package:flutter_appirc/app/user/user_model.dart';
import 'package:flutter_appirc/app/user/user_widget.dart';
import 'package:flutter_appirc/provider/provider.dart';

class ChannelUsersInfoWidget extends StatefulWidget {
  final Stream<List<ChannelUserInfo>> usersStream;
  final List<ChannelUserInfo> usersStreamInitialValue;

  ChannelUsersInfoWidget(this.usersStream, this.usersStreamInitialValue);

  @override
  State<StatefulWidget> createState() =>
      ChannelUsersInfoState(usersStream, usersStreamInitialValue);
}

class ChannelUsersInfoState extends State<ChannelUsersInfoWidget> {
  final Stream<List<ChannelUserInfo>> usersStream;
  final List<ChannelUserInfo> usersStreamInitialValue;

  ChannelUsersInfoState(this.usersStream, this.usersStreamInitialValue);

  @override
  Widget build(BuildContext context) {
    var appLocalizations = AppLocalizations.of(context);

    ColoredNicknamesBloc coloredNicknamesBloc = Provider.of(context);
    return StreamBuilder<List<ChannelUserInfo>>(
        stream: usersStream,
        initialData: usersStreamInitialValue,
        builder: (BuildContext context,
            AsyncSnapshot<List<ChannelUserInfo>> snapshot) {
          var users = snapshot.data;

          if (users != null && users.isNotEmpty) {
            return ListView.builder(
                itemCount: users.length,
                itemBuilder: (BuildContext context, int index) {
                  return _buildUserListItem(context, users[index], coloredNicknamesBloc);
                });
          } else {
            return Center(
                child: Text(appLocalizations.tr("chat.users.loading")));
          }
        });
  }
}

Widget _buildUserListItem(BuildContext context, ChannelUserInfo user, ColoredNicknamesBloc coloredNicknamesBloc) {

  var nick = user.nick;
  var color = coloredNicknamesBloc.getColorForNick(nick);

  var child = Text("${user.mode}$nick", style: TextStyle(color: color));



  NetworkChannelBloc channelBloc = Provider.of(context);
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: buildUserNickWithPopupMenu(context, child, nick, channelBloc, actionCallback: (_) {
      Navigator.pop(context);
    }),
  );
}
