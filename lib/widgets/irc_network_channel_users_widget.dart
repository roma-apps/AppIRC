import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/blocs/irc_network_channel_users_bloc.dart';
import 'package:flutter_appirc/helpers/provider.dart';
import 'package:flutter_appirc/models/irc_network_channel_model.dart';
import 'package:flutter_appirc/models/irc_network_channel_user_model.dart';
import 'package:flutter_appirc/service/lounge_service.dart';

class IRCNetworkChannelUsersWidget extends StatefulWidget {
  final IRCNetworkChannel channel;

  IRCNetworkChannelUsersWidget(this.channel);

  @override
  State<StatefulWidget> createState() => IRCNetworkChannelUsersState(channel);
}

class IRCNetworkChannelUsersState extends State<IRCNetworkChannelUsersWidget> {
  final IRCNetworkChannel channel;

  IRCNetworkChannelUsersState(this.channel);

  @override
  Widget build(BuildContext context) {
    final LoungeService loungeService = Provider.of<LoungeService>(context);

    var channelUsersBloc = IRCNetworkChannelUsersBloc(loungeService, channel);

    var appLocalizations = AppLocalizations.of(context);
    return StreamBuilder<List<IRCNetworkChannelUser>>(
        stream: channelUsersBloc.usersStream,
        builder: (BuildContext context,
            AsyncSnapshot<List<IRCNetworkChannelUser>> snapshot) {
          var users = snapshot.data;

          if (users != null && users.isNotEmpty) {
            return ListView.builder(
                itemCount: users.length,
                itemBuilder: (BuildContext context, int index) {
                  return _buildUserListItem(context, users[index]);
                });
          } else {
            return Center(
                child: Text(appLocalizations.tr("chat.users.loading")));
          }
        });
  }
}

Widget _buildUserListItem(BuildContext context, IRCNetworkChannelUser user) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(user.mode),
        Text(user.nick),
      ],
    ),
  );
}
