import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_model.dart';
import 'package:flutter_appirc/app/user/colored_nicknames_bloc.dart';
import 'package:flutter_appirc/app/user/user_widget.dart';
import 'package:flutter_appirc/app/user/users_list_bloc.dart';
import 'package:flutter_appirc/platform_widgets/platform_aware_text_field.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/skin/app_skin_bloc.dart';

class ChannelUsersListWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ChannelUsersListWidgetState();
}

class ChannelUsersListWidgetState extends State<ChannelUsersListWidget> {
  TextEditingController filterController;

  @override
  void initState() {
    super.initState();
    filterController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    filterController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appLocalizations = AppLocalizations.of(context);

    ColoredNicknamesBloc coloredNicknamesBloc = Provider.of(context);
    ChannelUsersListBloc channelUsersListBloc =
        Provider.of<ChannelUsersListBloc>(context);


    return StreamBuilder<List<NetworkChannelUser>>(
        stream: channelUsersListBloc.usersStream,
        initialData: channelUsersListBloc.users,
        builder: (BuildContext context,
            AsyncSnapshot<List<NetworkChannelUser>> snapshot) {
          var users = snapshot.data;

          if (users != null) {
            Widget body;
            if (users.isEmpty) {
              body = Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                    child: Text(appLocalizations.tr("chat.users_list.search"
                        ".users_not_found"),
                        style: TextStyle(
                            color:
                                AppSkinBloc.of(context).appSkinTheme.textColor))),
              );
            } else {
              body = Flexible(
                child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _buildUserListItem(
                          context, users[index], coloredNicknamesBloc);
                    }),
              );
            }
            return Column(
              children: <Widget>[
                buildPlatformTextField(
                  context,
                  channelUsersListBloc.filterFieldBloc,
                  filterController,
                  AppLocalizations.of(context).tr("chat.users_list.search"
                      ".field.filter"
                      ".label"),
                  AppLocalizations.of(context).tr("chat.users_list.search"
                      ".field.filter"
                      ".hint"),
                ),
                body,
              ],
            );
          } else {
            return Center(
                child: Text(appLocalizations.tr("chat.users_list.loading"),
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

  NetworkChannelBloc channelBloc = NetworkChannelBloc.of(context);
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: buildUserNickWithPopupMenu(context, child, nick, channelBloc,
        actionCallback: (_) {
      Navigator.pop(context);
    }),
  );
}
